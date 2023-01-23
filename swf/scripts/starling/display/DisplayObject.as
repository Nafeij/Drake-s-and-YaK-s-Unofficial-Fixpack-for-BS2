package starling.display
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.system.Capabilities;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.errors.AbstractMethodError;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.TouchEvent;
   import starling.filters.FragmentFilter;
   import starling.utils.HAlign;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.VAlign;
   
   [Event(name="keyDown",type="starling.events.KeyboardEvent")]
   [Event(name="keyUp",type="starling.events.KeyboardEvent")]
   [Event(name="touch",type="starling.events.TouchEvent")]
   [Event(name="enterFrame",type="starling.events.EnterFrameEvent")]
   [Event(name="removedFromStage",type="starling.events.Event")]
   [Event(name="removed",type="starling.events.Event")]
   [Event(name="addedToStage",type="starling.events.Event")]
   [Event(name="added",type="starling.events.Event")]
   public class DisplayObject extends EventDispatcher
   {
      
      private static var sAncestors:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private static var sHelperPoint:Point = new Point();
      
      private static var sHelperPoint3D:Vector3D = new Vector3D();
      
      private static var sHelperRect:Rectangle = new Rectangle();
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperMatrixAlt:Matrix = new Matrix();
      
      private static var sHelperMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sHelperMatrixAlt3D:Matrix3D = new Matrix3D();
       
      
      private var mX:Number;
      
      private var mY:Number;
      
      private var mPivotX:Number;
      
      private var mPivotY:Number;
      
      private var mScaleX:Number;
      
      private var mScaleY:Number;
      
      private var mSkewX:Number;
      
      private var mSkewY:Number;
      
      private var mRotation:Number;
      
      private var mAlpha:Number;
      
      private var mVisible:Boolean;
      
      private var mTouchable:Boolean;
      
      private var mBlendMode:String;
      
      private var mName:String;
      
      private var mUseHandCursor:Boolean;
      
      private var mParent:DisplayObjectContainer;
      
      private var mTransformationMatrix:Matrix;
      
      private var mTransformationMatrix3D:Matrix3D;
      
      private var mOrientationChanged:Boolean;
      
      private var mFilter:FragmentFilter;
      
      private var mIs3D:Boolean;
      
      private var mMask:DisplayObject;
      
      private var mIsMask:Boolean;
      
      public function DisplayObject()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObject")
         {
            throw new AbstractClassError();
         }
         this.mX = this.mY = this.mPivotX = this.mPivotY = this.mRotation = this.mSkewX = this.mSkewY = 0;
         this.mScaleX = this.mScaleY = this.mAlpha = 1;
         this.mVisible = this.mTouchable = true;
         this.mBlendMode = BlendMode.AUTO;
         this.mTransformationMatrix = new Matrix();
         this.mOrientationChanged = this.mUseHandCursor = false;
      }
      
      public function dispose() : void
      {
         if(this.mFilter)
         {
            this.mFilter.dispose();
         }
         if(this.mMask)
         {
            this.mMask.dispose();
         }
         this.removeEventListeners();
         this.mask = null;
      }
      
      public function removeFromParent(param1:Boolean = false) : void
      {
         if(this.mParent)
         {
            this.mParent.removeChild(this,param1);
         }
         else if(param1)
         {
            this.dispose();
         }
      }
      
      public function getTransformationMatrix(param1:DisplayObject, param2:Matrix = null) : Matrix
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         if(param2)
         {
            param2.identity();
         }
         else
         {
            param2 = new Matrix();
         }
         if(param1 == this)
         {
            return param2;
         }
         if(param1 == this.mParent || param1 == null && this.mParent == null)
         {
            param2.copyFrom(this.transformationMatrix);
            return param2;
         }
         if(param1 == null || param1 == this.base)
         {
            _loc4_ = this;
            while(_loc4_ != param1)
            {
               param2.concat(_loc4_.transformationMatrix);
               _loc4_ = _loc4_.mParent;
            }
            return param2;
         }
         if(param1.mParent == this)
         {
            param1.getTransformationMatrix(this,param2);
            param2.invert();
            return param2;
         }
         _loc3_ = this.findCommonParent(this,param1);
         _loc4_ = this;
         while(_loc4_ != _loc3_)
         {
            param2.concat(_loc4_.transformationMatrix);
            _loc4_ = _loc4_.mParent;
         }
         if(_loc3_ == param1)
         {
            return param2;
         }
         sHelperMatrix.identity();
         _loc4_ = param1;
         while(_loc4_ != _loc3_)
         {
            sHelperMatrix.concat(_loc4_.transformationMatrix);
            _loc4_ = _loc4_.mParent;
         }
         sHelperMatrix.invert();
         param2.concat(sHelperMatrix);
         return param2;
      }
      
      public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         throw new AbstractMethodError();
      }
      
      public function hitTest(param1:Point, param2:Boolean = false) : DisplayObject
      {
         if(param2 && (!this.mVisible || !this.mTouchable))
         {
            return null;
         }
         if(Boolean(this.mMask) && !this.hitTestMask(param1))
         {
            return null;
         }
         if(this.getBounds(this,sHelperRect).containsPoint(param1))
         {
            return this;
         }
         return null;
      }
      
      public function hitTestMask(param1:Point) : Boolean
      {
         if(this.mMask)
         {
            if(this.mMask.stage)
            {
               this.getTransformationMatrix(this.mMask,sHelperMatrixAlt);
            }
            else
            {
               sHelperMatrixAlt.copyFrom(this.mMask.transformationMatrix);
               sHelperMatrixAlt.invert();
            }
            MatrixUtil.transformPoint(sHelperMatrixAlt,param1,sHelperPoint);
            return this.mMask.hitTest(sHelperPoint,true) != null;
         }
         return true;
      }
      
      public function localToGlobal(param1:Point, param2:Point = null) : Point
      {
         if(this.is3D)
         {
            sHelperPoint3D.setTo(param1.x,param1.y,0);
            return this.local3DToGlobal(sHelperPoint3D,param2);
         }
         this.getTransformationMatrix(this.base,sHelperMatrixAlt);
         return MatrixUtil.transformPoint(sHelperMatrixAlt,param1,param2);
      }
      
      public function globalToLocal(param1:Point, param2:Point = null) : Point
      {
         if(this.is3D)
         {
            this.globalToLocal3D(param1,sHelperPoint3D);
            return MathUtil.intersectLineWithXYPlane(this.stage.cameraPosition,sHelperPoint3D,param2);
         }
         this.getTransformationMatrix(this.base,sHelperMatrixAlt);
         sHelperMatrixAlt.invert();
         return MatrixUtil.transformPoint(sHelperMatrixAlt,param1,param2);
      }
      
      public function render(param1:RenderSupport, param2:Number) : void
      {
         throw new AbstractMethodError();
      }
      
      public function get hasVisibleArea() : Boolean
      {
         return this.mAlpha != 0 && this.mVisible && !this.mIsMask && this.mScaleX != 0 && this.mScaleY != 0;
      }
      
      public function alignPivot(param1:String = "center", param2:String = "center") : void
      {
         var _loc3_:Rectangle = this.getBounds(this);
         this.mOrientationChanged = true;
         if(param1 == HAlign.LEFT)
         {
            this.mPivotX = _loc3_.x;
         }
         else if(param1 == HAlign.CENTER)
         {
            this.mPivotX = _loc3_.x + _loc3_.width / 2;
         }
         else
         {
            if(param1 != HAlign.RIGHT)
            {
               throw new ArgumentError("Invalid horizontal alignment: " + param1);
            }
            this.mPivotX = _loc3_.x + _loc3_.width;
         }
         if(param2 == VAlign.TOP)
         {
            this.mPivotY = _loc3_.y;
         }
         else if(param2 == VAlign.CENTER)
         {
            this.mPivotY = _loc3_.y + _loc3_.height / 2;
         }
         else
         {
            if(param2 != VAlign.BOTTOM)
            {
               throw new ArgumentError("Invalid vertical alignment: " + param2);
            }
            this.mPivotY = _loc3_.y + _loc3_.height;
         }
      }
      
      public function getTransformationMatrix3D(param1:DisplayObject, param2:Matrix3D = null) : Matrix3D
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         if(param2)
         {
            param2.identity();
         }
         else
         {
            param2 = new Matrix3D();
         }
         if(param1 == this)
         {
            return param2;
         }
         if(param1 == this.mParent || param1 == null && this.mParent == null)
         {
            param2.copyFrom(this.transformationMatrix3D);
            return param2;
         }
         if(param1 == null || param1 == this.base)
         {
            _loc4_ = this;
            while(_loc4_ != param1)
            {
               param2.append(_loc4_.transformationMatrix3D);
               _loc4_ = _loc4_.mParent;
            }
            return param2;
         }
         if(param1.mParent == this)
         {
            param1.getTransformationMatrix3D(this,param2);
            param2.invert();
            return param2;
         }
         _loc3_ = this.findCommonParent(this,param1);
         _loc4_ = this;
         while(_loc4_ != _loc3_)
         {
            param2.append(_loc4_.transformationMatrix3D);
            _loc4_ = _loc4_.mParent;
         }
         if(_loc3_ == param1)
         {
            return param2;
         }
         sHelperMatrix3D.identity();
         _loc4_ = param1;
         while(_loc4_ != _loc3_)
         {
            sHelperMatrix3D.append(_loc4_.transformationMatrix3D);
            _loc4_ = _loc4_.mParent;
         }
         sHelperMatrix3D.invert();
         param2.append(sHelperMatrix3D);
         return param2;
      }
      
      public function local3DToGlobal(param1:Vector3D, param2:Point = null) : Point
      {
         var _loc3_:Stage = this.stage;
         if(_loc3_ == null)
         {
            throw new IllegalOperationError("Object not connected to stage");
         }
         this.getTransformationMatrix3D(_loc3_,sHelperMatrixAlt3D);
         MatrixUtil.transformPoint3D(sHelperMatrixAlt3D,param1,sHelperPoint3D);
         return MathUtil.intersectLineWithXYPlane(_loc3_.cameraPosition,sHelperPoint3D,param2);
      }
      
      public function globalToLocal3D(param1:Point, param2:Vector3D = null) : Vector3D
      {
         var _loc3_:Stage = this.stage;
         if(_loc3_ == null)
         {
            throw new IllegalOperationError("Object not connected to stage");
         }
         this.getTransformationMatrix3D(_loc3_,sHelperMatrixAlt3D);
         sHelperMatrixAlt3D.invert();
         return MatrixUtil.transformCoords3D(sHelperMatrixAlt3D,param1.x,param1.y,0,param2);
      }
      
      internal function setParent(param1:DisplayObjectContainer) : void
      {
         var _loc2_:DisplayObject = param1;
         while(_loc2_ != this && _loc2_ != null)
         {
            _loc2_ = _loc2_.mParent;
         }
         if(_loc2_ == this)
         {
            throw new ArgumentError("An object cannot be added as a child to itself or one " + "of its children (or children\'s children, etc.)");
         }
         this.mParent = param1;
      }
      
      internal function setIs3D(param1:Boolean) : void
      {
         this.mIs3D = param1;
      }
      
      internal function get isMask() : Boolean
      {
         return this.mIsMask;
      }
      
      final private function isEquivalent(param1:Number, param2:Number, param3:Number = 0.0001) : Boolean
      {
         return param1 - param3 < param2 && param1 + param3 > param2;
      }
      
      final private function findCommonParent(param1:DisplayObject, param2:DisplayObject) : DisplayObject
      {
         var _loc3_:DisplayObject = param1;
         while(_loc3_)
         {
            sAncestors[sAncestors.length] = _loc3_;
            _loc3_ = _loc3_.mParent;
         }
         _loc3_ = param2;
         while(Boolean(_loc3_) && sAncestors.indexOf(_loc3_) == -1)
         {
            _loc3_ = _loc3_.mParent;
         }
         sAncestors.length = 0;
         if(_loc3_)
         {
            return _loc3_;
         }
         throw new ArgumentError("Object not connected to target");
      }
      
      override public function dispatchEvent(param1:Event) : void
      {
         if(param1.type == Event.REMOVED_FROM_STAGE && this.stage == null)
         {
            return;
         }
         super.dispatchEvent(param1);
      }
      
      override public function addEventListener(param1:String, param2:Function) : void
      {
         if(param1 == Event.ENTER_FRAME && !hasEventListener(param1))
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.addEnterFrameListenerToStage);
            this.addEventListener(Event.REMOVED_FROM_STAGE,this.removeEnterFrameListenerFromStage);
            if(this.stage)
            {
               this.addEnterFrameListenerToStage();
            }
         }
         super.addEventListener(param1,param2);
      }
      
      override public function removeEventListener(param1:String, param2:Function) : void
      {
         super.removeEventListener(param1,param2);
         if(param1 == Event.ENTER_FRAME && !hasEventListener(param1))
         {
            this.removeEventListener(Event.ADDED_TO_STAGE,this.addEnterFrameListenerToStage);
            this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removeEnterFrameListenerFromStage);
            this.removeEnterFrameListenerFromStage();
         }
      }
      
      override public function removeEventListeners(param1:String = null) : void
      {
         if((param1 == null || param1 == Event.ENTER_FRAME) && hasEventListener(Event.ENTER_FRAME))
         {
            this.removeEventListener(Event.ADDED_TO_STAGE,this.addEnterFrameListenerToStage);
            this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removeEnterFrameListenerFromStage);
            this.removeEnterFrameListenerFromStage();
         }
         super.removeEventListeners(param1);
      }
      
      private function addEnterFrameListenerToStage() : void
      {
         Starling.current.stage.addEnterFrameListener(this);
      }
      
      private function removeEnterFrameListenerFromStage() : void
      {
         Starling.current.stage.removeEnterFrameListener(this);
      }
      
      public function get transformationMatrix() : Matrix
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(this.mOrientationChanged)
         {
            this.mOrientationChanged = false;
            if(this.mSkewX == 0 && this.mSkewY == 0)
            {
               if(this.mRotation == 0)
               {
                  this.mTransformationMatrix.setTo(this.mScaleX,0,0,this.mScaleY,this.mX - this.mPivotX * this.mScaleX,this.mY - this.mPivotY * this.mScaleY);
               }
               else
               {
                  _loc1_ = Math.cos(this.mRotation);
                  _loc2_ = Math.sin(this.mRotation);
                  _loc3_ = this.mScaleX * _loc1_;
                  _loc4_ = this.mScaleX * _loc2_;
                  _loc5_ = this.mScaleY * -_loc2_;
                  _loc6_ = this.mScaleY * _loc1_;
                  _loc7_ = this.mX - this.mPivotX * _loc3_ - this.mPivotY * _loc5_;
                  _loc8_ = this.mY - this.mPivotX * _loc4_ - this.mPivotY * _loc6_;
                  this.mTransformationMatrix.setTo(_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,_loc8_);
               }
            }
            else
            {
               this.mTransformationMatrix.identity();
               this.mTransformationMatrix.scale(this.mScaleX,this.mScaleY);
               MatrixUtil.skew(this.mTransformationMatrix,this.mSkewX,this.mSkewY);
               this.mTransformationMatrix.rotate(this.mRotation);
               this.mTransformationMatrix.translate(this.mX,this.mY);
               if(this.mPivotX != 0 || this.mPivotY != 0)
               {
                  this.mTransformationMatrix.tx = this.mX - this.mTransformationMatrix.a * this.mPivotX - this.mTransformationMatrix.c * this.mPivotY;
                  this.mTransformationMatrix.ty = this.mY - this.mTransformationMatrix.b * this.mPivotX - this.mTransformationMatrix.d * this.mPivotY;
               }
            }
         }
         return this.mTransformationMatrix;
      }
      
      public function set transformationMatrix(param1:Matrix) : void
      {
         var _loc2_:Number = Math.PI / 4;
         this.mOrientationChanged = false;
         this.mTransformationMatrix.copyFrom(param1);
         this.mPivotX = this.mPivotY = 0;
         this.mX = param1.tx;
         this.mY = param1.ty;
         this.mSkewX = Math.atan(-param1.c / param1.d);
         this.mSkewY = Math.atan(param1.b / param1.a);
         if(this.mSkewX != this.mSkewX)
         {
            this.mSkewX = 0;
         }
         if(this.mSkewY != this.mSkewY)
         {
            this.mSkewY = 0;
         }
         this.mScaleY = this.mSkewX > -_loc2_ && this.mSkewX < _loc2_ ? param1.d / Math.cos(this.mSkewX) : -param1.c / Math.sin(this.mSkewX);
         this.mScaleX = this.mSkewY > -_loc2_ && this.mSkewY < _loc2_ ? param1.a / Math.cos(this.mSkewY) : param1.b / Math.sin(this.mSkewY);
         if(this.isEquivalent(this.mSkewX,this.mSkewY))
         {
            this.mRotation = this.mSkewX;
            this.mSkewX = this.mSkewY = 0;
         }
         else
         {
            this.mRotation = 0;
         }
      }
      
      public function get transformationMatrix3D() : Matrix3D
      {
         if(this.mTransformationMatrix3D == null)
         {
            this.mTransformationMatrix3D = new Matrix3D();
         }
         return MatrixUtil.convertTo3D(this.transformationMatrix,this.mTransformationMatrix3D);
      }
      
      public function get is3D() : Boolean
      {
         return this.mIs3D;
      }
      
      public function get useHandCursor() : Boolean
      {
         return this.mUseHandCursor;
      }
      
      public function set useHandCursor(param1:Boolean) : void
      {
         if(param1 == this.mUseHandCursor)
         {
            return;
         }
         this.mUseHandCursor = param1;
         if(this.mUseHandCursor)
         {
            this.addEventListener(TouchEvent.TOUCH,this.onTouch);
         }
         else
         {
            this.removeEventListener(TouchEvent.TOUCH,this.onTouch);
         }
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         Mouse.cursor = param1.interactsWith(this) ? MouseCursor.BUTTON : MouseCursor.AUTO;
      }
      
      public function get bounds() : Rectangle
      {
         return this.getBounds(this.mParent);
      }
      
      public function get width() : Number
      {
         return this.getBounds(this.mParent,sHelperRect).width;
      }
      
      public function set width(param1:Number) : void
      {
         this.scaleX = 1;
         var _loc2_:Number = this.width;
         if(_loc2_ != 0)
         {
            this.scaleX = param1 / _loc2_;
         }
      }
      
      public function get height() : Number
      {
         return this.getBounds(this.mParent,sHelperRect).height;
      }
      
      public function set height(param1:Number) : void
      {
         this.scaleY = 1;
         var _loc2_:Number = this.height;
         if(_loc2_ != 0)
         {
            this.scaleY = param1 / _loc2_;
         }
      }
      
      public function get x() : Number
      {
         return this.mX;
      }
      
      public function set x(param1:Number) : void
      {
         if(this.mX != param1)
         {
            this.mX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get y() : Number
      {
         return this.mY;
      }
      
      public function set y(param1:Number) : void
      {
         if(this.mY != param1)
         {
            this.mY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get pivotX() : Number
      {
         return this.mPivotX;
      }
      
      public function set pivotX(param1:Number) : void
      {
         if(this.mPivotX != param1)
         {
            this.mPivotX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get pivotY() : Number
      {
         return this.mPivotY;
      }
      
      public function set pivotY(param1:Number) : void
      {
         if(this.mPivotY != param1)
         {
            this.mPivotY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get scaleX() : Number
      {
         return this.mScaleX;
      }
      
      public function set scaleX(param1:Number) : void
      {
         if(this.mScaleX != param1)
         {
            this.mScaleX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get scaleY() : Number
      {
         return this.mScaleY;
      }
      
      public function set scaleY(param1:Number) : void
      {
         if(this.mScaleY != param1)
         {
            this.mScaleY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get skewX() : Number
      {
         return this.mSkewX;
      }
      
      public function set skewX(param1:Number) : void
      {
         param1 = MathUtil.normalizeAngle(param1);
         if(this.mSkewX != param1)
         {
            this.mSkewX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get skewY() : Number
      {
         return this.mSkewY;
      }
      
      public function set skewY(param1:Number) : void
      {
         param1 = MathUtil.normalizeAngle(param1);
         if(this.mSkewY != param1)
         {
            this.mSkewY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get rotation() : Number
      {
         return this.mRotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         param1 = MathUtil.normalizeAngle(param1);
         if(this.mRotation != param1)
         {
            this.mRotation = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get alpha() : Number
      {
         return this.mAlpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         this.mAlpha = param1 < 0 ? 0 : (param1 > 1 ? 1 : param1);
      }
      
      public function get visible() : Boolean
      {
         return this.mVisible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.mVisible = param1;
      }
      
      public function get touchable() : Boolean
      {
         return this.mTouchable;
      }
      
      public function set touchable(param1:Boolean) : void
      {
         this.mTouchable = param1;
      }
      
      public function get blendMode() : String
      {
         return this.mBlendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         this.mBlendMode = param1;
      }
      
      public function get name() : String
      {
         return this.mName;
      }
      
      public function set name(param1:String) : void
      {
         this.mName = param1;
      }
      
      public function get filter() : FragmentFilter
      {
         return this.mFilter;
      }
      
      public function set filter(param1:FragmentFilter) : void
      {
         this.mFilter = param1;
      }
      
      public function get mask() : DisplayObject
      {
         return this.mMask;
      }
      
      public function set mask(param1:DisplayObject) : void
      {
         if(this.mMask != param1)
         {
            if(this.mMask)
            {
               this.mMask.mIsMask = false;
            }
            if(param1)
            {
               param1.mIsMask = true;
            }
            this.mMask = param1;
         }
      }
      
      public function get parent() : DisplayObjectContainer
      {
         return this.mParent;
      }
      
      public function get base() : DisplayObject
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_.mParent)
         {
            _loc1_ = _loc1_.mParent;
         }
         return _loc1_;
      }
      
      public function get root() : DisplayObject
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_.mParent)
         {
            if(_loc1_.mParent is Stage)
            {
               return _loc1_;
            }
            _loc1_ = _loc1_.parent;
         }
         return null;
      }
      
      public function get stage() : Stage
      {
         return this.base as Stage;
      }
   }
}
