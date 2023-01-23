package as3isolib.core
{
   import as3isolib.bounds.IBounds;
   import as3isolib.bounds.PrimitiveBounds;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class IsoDisplayObject extends IsoContainer implements IIsoDisplayObject
   {
       
      
      protected var isoBoundsObject:IBounds;
      
      public var usePreciseValues:Boolean = false;
      
      public var isoX:Number = 0;
      
      protected var oldX:Number;
      
      public var isoY:Number = 0;
      
      protected var oldY:Number;
      
      as3isolib_internal var isoZ:Number = 0;
      
      protected var oldZ:Number;
      
      private var dist:Number;
      
      as3isolib_internal var isoWidth:Number = 0;
      
      protected var oldWidth:Number;
      
      as3isolib_internal var isoLength:Number = 0;
      
      protected var oldLength:Number;
      
      as3isolib_internal var isoHeight:Number = 0;
      
      protected var oldHeight:Number;
      
      private var bRenderAsOrphan:Boolean = false;
      
      public var autoUpdate:Boolean = false;
      
      as3isolib_internal var bInvalidateEventDispatched:Boolean = false;
      
      as3isolib_internal var bPositionInvalidated:Boolean = false;
      
      as3isolib_internal var bSizeInvalidated:Boolean = false;
      
      public function IsoDisplayObject(param1:String, param2:Object = null)
      {
         super(param1);
         if(param2)
         {
            this.createObjectFromDescriptor(param2);
         }
      }
      
      public function get isoBounds() : IBounds
      {
         if(!this.isoBoundsObject || this.isInvalidated)
         {
            this.isoBoundsObject = new PrimitiveBounds(this);
         }
         return this.isoBoundsObject;
      }
      
      public function get screenBounds() : Rectangle
      {
         var _loc1_:Rectangle = mainContainer.getMyBounds();
         _loc1_.x += mainContainer.x;
         _loc1_.y += mainContainer.y;
         return _loc1_;
      }
      
      public function getBounds(param1:DisplayObjectWrapper) : Rectangle
      {
         var _loc2_:Rectangle = this.screenBounds;
         var _loc3_:Point = new Point(_loc2_.x,_loc2_.y);
         _loc3_ = IIsoContainer(parent).container.localToGlobal(_loc3_);
         _loc3_ = param1.globalToLocal(_loc3_);
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y;
         return _loc2_;
      }
      
      public function get inverseOriginX() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x + this.width,this.y + this.length,this.z)).x;
      }
      
      public function get inverseOriginY() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x + this.width,this.y + this.length,this.z)).y;
      }
      
      public function moveTo(param1:Number, param2:Number, param3:Number) : void
      {
         if(this.x != param1 || this.y != param2 || this.z != param3)
         {
            this.invalidatePosition();
         }
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public function moveBy(param1:Number, param2:Number, param3:Number) : void
      {
         if(0 != param1 || 0 != param2 || 0 != param3)
         {
            this.invalidatePosition();
         }
         this.x += param1;
         this.y += param2;
         this.z += param3;
      }
      
      public function get x() : Number
      {
         return this.isoX;
      }
      
      public function set x(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         if(this.isoX != param1)
         {
            this.oldX = this.isoX;
            this.isoX = param1;
            this.invalidatePosition();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get screenX() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x,this.y,this.z)).x;
      }
      
      public function get y() : Number
      {
         return this.isoY;
      }
      
      public function set y(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         if(this.isoY != param1)
         {
            this.oldY = this.isoY;
            this.isoY = param1;
            this.invalidatePosition();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get screenY() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x,this.y,this.z)).y;
      }
      
      public function get z() : Number
      {
         return this.as3isolib_internal::isoZ;
      }
      
      public function set z(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         if(this.as3isolib_internal::isoZ != param1)
         {
            this.oldZ = this.as3isolib_internal::isoZ;
            this.as3isolib_internal::isoZ = param1;
            this.invalidatePosition();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get distance() : Number
      {
         return this.dist;
      }
      
      public function set distance(param1:Number) : void
      {
         this.dist = param1;
      }
      
      public function setSize(param1:Number, param2:Number, param3:Number) : void
      {
         this.width = param1;
         this.length = param2;
         this.height = param3;
      }
      
      public function get width() : Number
      {
         return this.as3isolib_internal::isoWidth;
      }
      
      public function set width(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         param1 = Math.abs(param1);
         if(this.as3isolib_internal::isoWidth != param1)
         {
            this.oldWidth = this.as3isolib_internal::isoWidth;
            this.as3isolib_internal::isoWidth = param1;
            this.invalidateSize();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get length() : Number
      {
         return this.as3isolib_internal::isoLength;
      }
      
      public function set length(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         param1 = Math.abs(param1);
         if(this.as3isolib_internal::isoLength != param1)
         {
            this.oldLength = this.as3isolib_internal::isoLength;
            this.as3isolib_internal::isoLength = param1;
            this.invalidateSize();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get height() : Number
      {
         return this.as3isolib_internal::isoHeight;
      }
      
      public function set height(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         param1 = Math.abs(param1);
         if(this.as3isolib_internal::isoHeight != param1)
         {
            this.oldHeight = this.as3isolib_internal::isoHeight;
            this.as3isolib_internal::isoHeight = param1;
            this.invalidateSize();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get renderAsOrphan() : Boolean
      {
         return this.bRenderAsOrphan;
      }
      
      public function set renderAsOrphan(param1:Boolean) : void
      {
         this.bRenderAsOrphan = param1;
      }
      
      override protected function renderLogic(param1:Boolean = true) : void
      {
         if(!hasParent && !this.renderAsOrphan)
         {
            return;
         }
         if(this.as3isolib_internal::bPositionInvalidated)
         {
            this.validatePosition();
            this.as3isolib_internal::bPositionInvalidated = false;
         }
         if(this.as3isolib_internal::bSizeInvalidated)
         {
            this.as3isolib_internal::bSizeInvalidated = false;
         }
         this.as3isolib_internal::bInvalidateEventDispatched = false;
         super.renderLogic(param1);
      }
      
      protected function validatePosition() : void
      {
         var _loc1_:Pt = new Pt(this.x,this.y,this.z);
         IsoMath.isoToScreen(_loc1_);
         mainContainer.x = _loc1_.x;
         mainContainer.y = _loc1_.y;
      }
      
      public function invalidatePosition() : void
      {
         this.as3isolib_internal::bPositionInvalidated = true;
         if(!this.as3isolib_internal::bInvalidateEventDispatched)
         {
            notifySceneChildDirty();
            this.as3isolib_internal::bInvalidateEventDispatched = true;
         }
      }
      
      public function invalidateSize() : void
      {
         this.as3isolib_internal::bSizeInvalidated = true;
         if(!this.as3isolib_internal::bInvalidateEventDispatched)
         {
            notifySceneChildDirty();
            this.as3isolib_internal::bInvalidateEventDispatched = true;
         }
      }
      
      override public function get isInvalidated() : Boolean
      {
         return this.as3isolib_internal::bPositionInvalidated || this.as3isolib_internal::bSizeInvalidated;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
      }
      
      public function clone() : *
      {
         var _loc1_:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
         var _loc2_:IIsoDisplayObject = new _loc1_();
         _loc2_.setSize(this.as3isolib_internal::isoWidth,this.as3isolib_internal::isoLength,this.as3isolib_internal::isoHeight);
         return _loc2_;
      }
      
      private function createObjectFromDescriptor(param1:Object) : void
      {
         var _loc2_:* = null;
         for(_loc2_ in param1)
         {
            if(this.hasOwnProperty(_loc2_))
            {
               this[_loc2_] = param1[_loc2_];
            }
         }
      }
   }
}
