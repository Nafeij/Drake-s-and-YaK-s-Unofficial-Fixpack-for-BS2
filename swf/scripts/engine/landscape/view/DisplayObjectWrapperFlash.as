package engine.landscape.view
{
   import engine.core.util.ColorUtil;
   import engine.gui.IReleasable;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.errors.IllegalOperationError;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Transform;
   
   public class DisplayObjectWrapperFlash extends DisplayObjectWrapper
   {
      
      private static const _pi_o_180:Number = Math.PI / 180;
      
      private static const _180_o_pi:Number = 180 / Math.PI;
       
      
      public var d:DisplayObject;
      
      public var doc:DisplayObjectContainer;
      
      public function DisplayObjectWrapperFlash(param1:DisplayObject)
      {
         super();
         this.d = param1;
         this.doc = param1 as DisplayObjectContainer;
         this.gi = param1 as IReleasable;
      }
      
      private static function findRootParent(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         while(param1)
         {
            _loc2_ = param1.parent;
            if(!_loc2_)
            {
               return param1;
            }
            param1 = _loc2_;
         }
         return null;
      }
      
      public function toString() : String
      {
         return "DOW-Flash: " + (!!this.d ? this.d.name : "null");
      }
      
      override public function set color(param1:*) : void
      {
         var _loc2_:ColorTransform = null;
         var _loc3_:ColorTransform = null;
         if(this.d)
         {
            _loc2_ = this.d.transform.colorTransform;
            if(param1 != undefined && param1 != null && (param1 & 16777215) != 16777215)
            {
               if(!_loc2_ || param1 != _loc2_.color)
               {
                  _loc3_ = ColorUtil.colorTransform(param1,_loc2_);
                  this.d.transform.colorTransform = _loc3_;
               }
            }
            else if(!_loc2_ || _loc2_.alphaMultiplier != 1 || _loc2_.redMultiplier != 1 || _loc2_.greenMultiplier != 1 || _loc2_.blueMultiplier != 1 || _loc2_.alphaOffset != 0 || _loc2_.redOffset != 0 || _loc2_.greenOffset != 0 || _loc2_.blueOffset != 0)
            {
               this.d.transform.colorTransform = ColorUtil.colorTransform(16777215,_loc2_);
            }
         }
      }
      
      override public function get numChildren() : int
      {
         return !!this.doc ? this.doc.numChildren : 0;
      }
      
      override public function getMyBounds() : Rectangle
      {
         return this.d.getBounds(this.d);
      }
      
      override public function getStageBounds() : Rectangle
      {
         var _loc1_:Rectangle = this.getMyBounds();
         var _loc2_:Point = new Point(_loc1_.left,_loc1_.top);
         var _loc3_:Point = new Point(_loc1_.right,_loc1_.bottom);
         _loc2_ = this.d.localToGlobal(_loc2_);
         _loc3_ = this.d.localToGlobal(_loc3_);
         return new Rectangle(_loc2_.x,_loc2_.y,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(this.d)
         {
            this.d.visible = param1;
         }
      }
      
      override public function get visible() : Boolean
      {
         return Boolean(this.d) && this.d.visible;
      }
      
      override public function set transform(param1:Transform) : void
      {
         if(this.d)
         {
            this.d.transform = this.transform;
         }
      }
      
      override public function get transform() : Transform
      {
         return this.d.transform;
      }
      
      override public function set transformMatrix(param1:Matrix) : void
      {
         if(this.d)
         {
            this.d.transform.matrix = param1;
         }
      }
      
      override public function get transformMatrix() : Matrix
      {
         return this.d.transform.matrix;
      }
      
      override public function contains(param1:DisplayObjectWrapper) : Boolean
      {
         var _loc2_:DisplayObjectWrapperFlash = null;
         if(this.doc)
         {
            _loc2_ = param1 as DisplayObjectWrapperFlash;
            if(!_loc2_)
            {
               throw new ArgumentError("invalid wrapper [" + param1 + "]");
            }
            if(_loc2_)
            {
               return this.doc.contains(_loc2_.d);
            }
         }
         return false;
      }
      
      override public function removeFromParent() : void
      {
         if(this.d.parent)
         {
            this.d.parent.removeChild(this.d);
         }
      }
      
      override public function get hasParent() : Boolean
      {
         return Boolean(this.d) && this.d.parent != null;
      }
      
      override public function addChild(param1:DisplayObjectWrapper) : void
      {
         var _loc2_:DisplayObjectWrapperFlash = null;
         var _loc3_:DisplayObject = null;
         if(this.doc)
         {
            _loc2_ = param1 as DisplayObjectWrapperFlash;
            if(!_loc2_)
            {
               throw new ArgumentError("invalid wrapper [" + param1 + "]");
            }
            _loc3_ = _loc2_.d;
            if(_loc3_.parent != this.doc)
            {
               if(_loc3_.parent)
               {
                  _loc3_.parent.removeChild(_loc3_);
               }
               this.doc.addChild(_loc3_);
            }
            return;
         }
         throw new IllegalOperationError("Cannot add to non container");
      }
      
      override public function addChildAt(param1:DisplayObjectWrapper, param2:int) : void
      {
         var _loc3_:DisplayObjectWrapperFlash = null;
         var _loc4_:DisplayObject = null;
         if(this.doc)
         {
            _loc3_ = param1 as DisplayObjectWrapperFlash;
            if(!_loc3_)
            {
               throw new ArgumentError("invalid wrapper [" + param1 + "]");
            }
            _loc4_ = _loc3_.d;
            if(_loc4_.parent != this.doc)
            {
               if(_loc4_.parent)
               {
                  _loc4_.parent.removeChild(_loc4_);
               }
               this.doc.addChildAt(_loc4_,param2);
            }
            return;
         }
         throw new IllegalOperationError("Cannot add to non container");
      }
      
      override public function setChildIndex(param1:DisplayObjectWrapper, param2:int) : void
      {
         var _loc3_:DisplayObjectWrapperFlash = null;
         var _loc4_:DisplayObject = null;
         if(this.doc)
         {
            _loc3_ = param1 as DisplayObjectWrapperFlash;
            if(!_loc3_)
            {
               throw new ArgumentError("invalid wrapper [" + param1 + "]");
            }
            _loc4_ = _loc3_.d;
            this.doc.setChildIndex(_loc4_,param2);
            return;
         }
         throw new IllegalOperationError("Cannot add to non container");
      }
      
      override public function bringToFront() : void
      {
         if(this.d.parent)
         {
            if(this.d.parent.numChildren > 1)
            {
               this.d.parent.setChildIndex(this.d,this.d.parent.numChildren - 1);
            }
         }
      }
      
      override public function get myChildIndex() : int
      {
         return !!this.d.parent ? this.d.parent.getChildIndex(this.d) : -1;
      }
      
      override public function removeChild(param1:DisplayObjectWrapper) : void
      {
         var _loc2_:DisplayObjectWrapperFlash = param1 as DisplayObjectWrapperFlash;
         if(!_loc2_)
         {
            throw new ArgumentError("invalid wrapper [" + param1 + "]");
         }
         if(Boolean(this.doc) && Boolean(_loc2_))
         {
            this.doc.removeChild(_loc2_.d);
         }
      }
      
      override public function hitTestPoint(param1:Number, param2:Number) : Boolean
      {
         return this.d.hitTestPoint(param1,param2,true);
      }
      
      override public function globalToLocal(param1:Point) : Point
      {
         return this.d.globalToLocal(param1);
      }
      
      override public function localToGlobal(param1:Point) : Point
      {
         return this.d.localToGlobal(param1);
      }
      
      override public function set x(param1:Number) : void
      {
         if(this.d.x != param1)
         {
            this.d.x = param1;
         }
      }
      
      override public function set y(param1:Number) : void
      {
         if(this.d.y != param1)
         {
            this.d.y = param1;
         }
      }
      
      override public function get x() : Number
      {
         return this.d.x;
      }
      
      override public function get y() : Number
      {
         return this.d.y;
      }
      
      override public function get name() : String
      {
         return this.d.name;
      }
      
      override public function set name(param1:String) : void
      {
         this.d.name = param1;
      }
      
      override public function set scale(param1:Number) : void
      {
         this.d.scaleX = this.d.scaleY = param1;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         this.d.scaleX = param1;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         this.d.scaleY = param1;
      }
      
      override public function get scaleX() : Number
      {
         return this.d.scaleX;
      }
      
      override public function get scaleY() : Number
      {
         return this.d.scaleY;
      }
      
      override public function get width() : Number
      {
         return this.d.width;
      }
      
      override public function get height() : Number
      {
         return this.d.height;
      }
      
      override public function get rotationDegrees() : Number
      {
         return this.d.rotation;
      }
      
      override public function get rotationRadians() : Number
      {
         return this.d.rotation * _pi_o_180;
      }
      
      override public function set rotationDegrees(param1:Number) : void
      {
         this.d.rotation = param1;
      }
      
      override public function set rotationRadians(param1:Number) : void
      {
         this.d.rotation = param1 * _180_o_pi;
      }
      
      override public function set blendMode(param1:String) : void
      {
         this.d.blendMode = param1;
      }
      
      override public function get blendMode() : String
      {
         return this.d.blendMode;
      }
      
      override public function set opaqueBackground(param1:*) : void
      {
         this.d.opaqueBackground = param1;
      }
      
      override public function set alpha(param1:Number) : void
      {
         this.d.alpha = param1;
      }
      
      override public function get alpha() : Number
      {
         return this.d.alpha;
      }
      
      override public function removeAllChildren() : void
      {
         if(this.doc)
         {
            while(this.doc.numChildren)
            {
               this.doc.removeChildAt(this.doc.numChildren - 1);
            }
         }
      }
   }
}
