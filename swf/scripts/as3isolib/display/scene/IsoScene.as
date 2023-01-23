package as3isolib.display.scene
{
   import as3isolib.bounds.IBounds;
   import as3isolib.bounds.SceneBounds;
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.core.IsoContainer;
   import as3isolib.core.as3isolib_internal;
   import as3isolib.data.INode;
   import as3isolib.display.renderers.DefaultSceneLayoutRenderer;
   import as3isolib.display.renderers.ISceneLayoutRenderer;
   import engine.landscape.view.DisplayObjectWrapper;
   import mx.core.ClassFactory;
   import mx.core.IFactory;
   
   public class IsoScene extends IsoContainer implements IIsoScene
   {
       
      
      private var _isoBounds:IBounds;
      
      protected var host:DisplayObjectWrapper;
      
      protected var invalidatedChildrenArray:Array;
      
      public var layoutEnabled:Boolean = true;
      
      private var bLayoutIsFactory:Boolean = true;
      
      private var layoutObject:Object;
      
      public function IsoScene(param1:String)
      {
         this.invalidatedChildrenArray = [];
         super(param1);
         this.layoutObject = new ClassFactory(DefaultSceneLayoutRenderer);
      }
      
      public function get isoBounds() : IBounds
      {
         return new SceneBounds(this);
      }
      
      public function get hostContainer() : DisplayObjectWrapper
      {
         return this.host;
      }
      
      public function set hostContainer(param1:DisplayObjectWrapper) : void
      {
         if(Boolean(param1) && this.host != param1)
         {
            if(Boolean(this.host) && this.host.contains(container))
            {
               this.host.removeChild(container);
               as3isolib_internal::ownerObject = null;
            }
            else if(hasParent)
            {
               parent.removeChild(this);
            }
            this.host = param1;
            if(this.host)
            {
               this.host.addChild(container);
               as3isolib_internal::ownerObject = this.host;
               as3isolib_internal::parentNode = null;
               hasParent = false;
            }
         }
      }
      
      public function get invalidatedChildren() : Array
      {
         return this.invalidatedChildrenArray;
      }
      
      override public function addChildAt(param1:INode, param2:uint) : void
      {
         if(param1 is IIsoDisplayObject)
         {
            super.addChildAt(param1,param2);
            param1.scene = this;
            as3isolib_internal::bIsInvalidated = true;
            return;
         }
         throw new Error("parameter child is not of type IIsoDisplayObject");
      }
      
      override public function setChildIndex(param1:INode, param2:uint) : void
      {
         super.setChildIndex(param1,param2);
         as3isolib_internal::bIsInvalidated = true;
      }
      
      override public function removeChildByID(param1:String) : INode
      {
         var _loc2_:INode = super.removeChildByID(param1);
         if(_loc2_)
         {
            _loc2_.scene = null;
            as3isolib_internal::bIsInvalidated = true;
         }
         return _loc2_;
      }
      
      override public function removeAllChildren() : void
      {
         var _loc1_:INode = null;
         for each(_loc1_ in children)
         {
            _loc1_.scene = null;
         }
         super.removeAllChildren();
         as3isolib_internal::bIsInvalidated = true;
      }
      
      public function invalidateChild(param1:Object) : void
      {
         if(this.invalidatedChildrenArray.indexOf(param1) == -1)
         {
            this.invalidatedChildrenArray.push(param1);
         }
         as3isolib_internal::bIsInvalidated = true;
      }
      
      public function get layoutRenderer() : Object
      {
         return this.layoutObject;
      }
      
      public function set layoutRenderer(param1:Object) : void
      {
         if(!param1)
         {
            this.layoutObject = new ClassFactory(DefaultSceneLayoutRenderer);
            this.bLayoutIsFactory = true;
            as3isolib_internal::bIsInvalidated = true;
         }
         if(Boolean(param1) && this.layoutObject != param1)
         {
            if(param1 is IFactory)
            {
               this.bLayoutIsFactory = true;
            }
            else
            {
               if(!(param1 is ISceneLayoutRenderer))
               {
                  throw new Error("value for layoutRenderer is not of type IFactory or ISceneLayoutRenderer");
               }
               this.bLayoutIsFactory = false;
            }
            this.layoutObject = param1;
            as3isolib_internal::bIsInvalidated = true;
         }
      }
      
      public function invalidateScene() : void
      {
         as3isolib_internal::bIsInvalidated = true;
      }
      
      override protected function renderLogic(param1:Boolean = true) : void
      {
         var _loc2_:ISceneLayoutRenderer = null;
         super.renderLogic(param1);
         if(as3isolib_internal::bIsInvalidated)
         {
            if(this.layoutEnabled)
            {
               if(this.bLayoutIsFactory)
               {
                  _loc2_ = IFactory(this.layoutObject).newInstance();
               }
               else
               {
                  _loc2_ = ISceneLayoutRenderer(this.layoutObject);
               }
               if(_loc2_)
               {
                  _loc2_.renderScene(this);
               }
            }
            as3isolib_internal::bIsInvalidated = false;
         }
      }
   }
}
