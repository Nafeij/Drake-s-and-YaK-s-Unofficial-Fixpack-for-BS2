package as3isolib.display
{
   import as3isolib.bounds.IBounds;
   import as3isolib.bounds.PrimitiveBounds;
   import as3isolib.bounds.SceneBounds;
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.core.IsoDisplayObject;
   import as3isolib.core.as3isolib_internal;
   import as3isolib.display.renderers.ISceneLayoutRenderer;
   import as3isolib.display.renderers.SimpleSceneLayoutRenderer;
   import as3isolib.display.scene.IIsoScene;
   import engine.landscape.view.DisplayObjectWrapper;
   
   public class IsoGroup extends IsoDisplayObject implements IIsoScene
   {
       
      
      private var bSizeSetExplicitly:Boolean;
      
      public var renderer:ISceneLayoutRenderer;
      
      public function IsoGroup(param1:String, param2:Object = null)
      {
         this.renderer = new SimpleSceneLayoutRenderer();
         super(param1,param2);
      }
      
      public function get hostContainer() : DisplayObjectWrapper
      {
         return null;
      }
      
      public function set hostContainer(param1:DisplayObjectWrapper) : void
      {
      }
      
      public function get invalidatedChildren() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:IIsoDisplayObject = null;
         for each(_loc2_ in children)
         {
            if(_loc2_.isInvalidated)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      override public function get isoBounds() : IBounds
      {
         return this.bSizeSetExplicitly ? new PrimitiveBounds(this) : new SceneBounds(this);
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.bSizeSetExplicitly = !isNaN(param1);
      }
      
      override public function set length(param1:Number) : void
      {
         super.length = param1;
         this.bSizeSetExplicitly = !isNaN(param1);
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.bSizeSetExplicitly = !isNaN(param1);
      }
      
      override protected function renderLogic(param1:Boolean = true) : void
      {
         super.renderLogic(param1);
         if(as3isolib_internal::bIsInvalidated)
         {
            if(!this.bSizeSetExplicitly)
            {
               this.calculateSizeFromChildren();
            }
            if(!this.renderer)
            {
               this.renderer = new SimpleSceneLayoutRenderer();
            }
            this.renderer.renderScene(this);
            as3isolib_internal::bIsInvalidated = false;
         }
      }
      
      protected function calculateSizeFromChildren() : void
      {
         var _loc1_:IBounds = new SceneBounds(this);
         as3isolib_internal::isoWidth = _loc1_.width;
         as3isolib_internal::isoLength = _loc1_.length;
         as3isolib_internal::isoHeight = _loc1_.height;
      }
   }
}
