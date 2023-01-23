package as3isolib.core
{
   import as3isolib.data.INode;
   import as3isolib.data.Node;
   import as3isolib.utils.IsoUtil;
   import engine.landscape.view.DisplayObjectWrapper;
   
   public class IsoContainer extends Node implements IIsoContainer
   {
       
      
      protected var bIncludeInLayout:Boolean = true;
      
      protected var includeInLayoutChanged:Boolean = false;
      
      protected var displayListChildrenArray:Vector.<IIsoContainer>;
      
      as3isolib_internal var bIsInvalidated:Boolean;
      
      protected var mainContainer:DisplayObjectWrapper;
      
      public function IsoContainer(param1:String)
      {
         this.displayListChildrenArray = new Vector.<IIsoContainer>();
         this.name = param1;
         super();
         this.createChildren();
      }
      
      public function get includeInLayout() : Boolean
      {
         return this.bIncludeInLayout;
      }
      
      public function set includeInLayout(param1:Boolean) : void
      {
         if(this.bIncludeInLayout != param1)
         {
            this.bIncludeInLayout = param1;
            this.includeInLayoutChanged = true;
         }
      }
      
      public function get displayListChildren() : Array
      {
         var _loc2_:IIsoContainer = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.displayListChildrenArray)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      override public function addChildAt(param1:INode, param2:uint) : void
      {
         var _loc3_:DisplayObjectWrapper = null;
         if(param1 is IIsoContainer)
         {
            super.addChildAt(param1,param2);
            if(IIsoContainer(param1).includeInLayout)
            {
               this.displayListChildrenArray.push(param1);
               if(param2 > this.mainContainer.numChildren)
               {
                  param2 = this.mainContainer.numChildren;
               }
               _loc3_ = IIsoContainer(param1).container;
               this.mainContainer.addChildAt(_loc3_,param2);
            }
            return;
         }
         throw new Error("parameter child does not implement IContainer.");
      }
      
      override public function setChildIndex(param1:INode, param2:uint) : void
      {
         if(!param1 is IIsoContainer)
         {
            throw new Error("parameter child does not implement IContainer.");
         }
         if(!(param1 as Node).hasParent || param1.parent != this)
         {
            throw new Error("parameter child is not found within node structure.");
         }
         super.setChildIndex(param1,param2);
         this.mainContainer.setChildIndex(IIsoContainer(param1).container,param2);
      }
      
      override public function removeChildByID(param1:String) : INode
      {
         var _loc3_:int = 0;
         var _loc2_:IIsoContainer = IIsoContainer(super.removeChildByID(param1));
         if(Boolean(_loc2_) && _loc2_.includeInLayout)
         {
            _loc3_ = this.displayListChildrenArray.indexOf(_loc2_);
            if(_loc3_ > -1)
            {
               this.displayListChildrenArray.splice(_loc3_,1);
            }
            this.mainContainer.removeChild(IIsoContainer(_loc2_).container);
         }
         return _loc2_;
      }
      
      override public function removeAllChildren() : void
      {
         var _loc1_:IIsoContainer = null;
         for each(_loc1_ in children)
         {
            if(_loc1_.includeInLayout)
            {
               this.mainContainer.removeChild(_loc1_.container);
            }
         }
         this.displayListChildrenArray = new Vector.<IIsoContainer>();
         super.removeAllChildren();
      }
      
      protected function createChildren() : void
      {
         this.mainContainer = IsoUtil.createDisplayObjectWrapper();
         this.mainContainer.name = name;
         this.attachMainContainerEventListeners();
      }
      
      public function cleanupIsoContainer() : void
      {
         if(this.mainContainer)
         {
            this.mainContainer = null;
         }
      }
      
      protected function attachMainContainerEventListeners() : void
      {
      }
      
      public function get isInvalidated() : Boolean
      {
         return this.as3isolib_internal::bIsInvalidated;
      }
      
      public function render(param1:Boolean = true) : void
      {
         this.renderLogic(param1);
      }
      
      protected function renderLogic(param1:Boolean = true) : void
      {
         var _loc2_:IIsoContainer = null;
         var _loc3_:int = 0;
         var _loc4_:IIsoContainer = null;
         if(this.includeInLayoutChanged && Boolean(as3isolib_internal::parentNode))
         {
            _loc2_ = IIsoContainer(as3isolib_internal::parentNode);
            _loc3_ = _loc2_.displayListChildren.indexOf(this);
            if(this.bIncludeInLayout)
            {
               if(_loc3_ == -1)
               {
                  _loc2_.displayListChildren.push(this);
               }
            }
            else if(!this.bIncludeInLayout)
            {
               if(_loc3_ >= 0)
               {
                  _loc2_.displayListChildren.splice(_loc3_,1);
               }
            }
            this.mainContainer.visible = this.bIncludeInLayout;
            this.includeInLayoutChanged = false;
         }
         if(param1)
         {
            for each(_loc4_ in children)
            {
               this.renderChild(_loc4_);
            }
         }
      }
      
      protected function renderChild(param1:IIsoContainer) : void
      {
         param1.render(true);
      }
      
      public function get depth() : int
      {
         return this.mainContainer.myChildIndex;
      }
      
      public function get container() : DisplayObjectWrapper
      {
         return this.mainContainer;
      }
   }
}
