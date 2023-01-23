package engine.core.render
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   
   public class BoundedCamera extends Camera
   {
      
      public static const EVENT_MATTE_CHANGED:String = "EVENT_MATTE_CHANGED";
      
      public static const EVENT_BOUNDARY_CHANGED:String = "EVENT_BOUNDARY_CHANGED";
      
      public static const UI_AUTHOR_WIDTH:int = 1024;
      
      public static const UI_AUTHOR_HEIGHT:int = 768;
      
      public static var BOUNDS_ADJUST_DISABLED:Boolean = false;
      
      public static const DP_TO_PIXEL:Number = 160;
      
      private static var TILT_EPSILON:Number = 0.1;
      
      public static var dpiFingerScale:Number = 1;
      
      public static var FULL_SCREEN_WIDTH:Number = Capabilities.screenResolutionX;
      
      public static var FULL_SCREEN_HEIGHT:Number = Capabilities.screenResolutionY;
       
      
      private var m_boundary:Rectangle;
      
      public var unclamped:Point;
      
      public var clamped:Point;
      
      private var m_boundsDisabled:Boolean = false;
      
      private var panoutEnabled:Boolean;
      
      private var _minWidth:Number = 2048;
      
      private var _minHeight:Number = 1161.9858156028367;
      
      private var _maxWidth:Number = 2730.6666666666665;
      
      private var _maxHeight:Number = 1161.9858156028367;
      
      private var _cinemascope:Boolean;
      
      public var vbar:int;
      
      public var hbar:int;
      
      public var viewWidth:Number = 0;
      
      public var viewHeight:Number = 0;
      
      public var adjustedBoundary:Rectangle;
      
      private var _boundaryAdjustmentFactor:Number = 1;
      
      public var compensateScaleDefault:Boolean = true;
      
      public var disableRefit:Boolean;
      
      private var _disableBoundsAdjust:Boolean;
      
      private var _disableTilt:Boolean;
      
      public var guiPage:Boolean;
      
      public var _clampParallax:Boolean = true;
      
      public var actualTiltOffset:Point;
      
      public var _tiltOffset:Point;
      
      private var fc:FitConstraints;
      
      private var fd:FitData;
      
      public var panClamped:Point;
      
      public var tiltedUnclamped:Point;
      
      public function BoundedCamera(param1:String, param2:ILogger, param3:Rectangle, param4:Boolean)
      {
         this.unclamped = new Point();
         this.clamped = new Point();
         this.adjustedBoundary = new Rectangle();
         this.actualTiltOffset = new Point();
         this._tiltOffset = new Point();
         this.fc = new FitConstraints();
         this.fd = new FitData();
         this.panClamped = new Point();
         this.tiltedUnclamped = new Point();
         super(param1,param2);
         this.boundary = param3;
         this._disableBoundsAdjust = param4;
      }
      
      public static function doAdjustBoundary(param1:Rectangle, param2:Rectangle, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : void
      {
         var _loc8_:Number = (param4 - param5) / 2;
         var _loc9_:Number = (param6 - param7) / 2;
         param1.copyFrom(param2);
         var _loc10_:Number = 1 - 1 / param3;
         param1.left += _loc8_ * _loc10_;
         param1.right -= _loc8_ * _loc10_;
         param1.top += _loc9_ * _loc10_;
         param1.bottom -= _loc9_ * _loc10_;
      }
      
      public static function computeFitScale(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = param1 / param3;
         var _loc6_:Number = param2 / param4;
         var _loc7_:Number = Math.min(_loc5_,_loc6_);
         var _loc8_:Number = Math.min(Platform.textScale,_loc7_);
         return Math.max(0.5,_loc8_);
      }
      
      public static function computeDpiScaling(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param2 / UI_AUTHOR_HEIGHT;
         var _loc4_:Number = param1 / UI_AUTHOR_WIDTH;
         var _loc5_:Number = Math.min(_loc3_,_loc4_);
         var _loc6_:Number = Math.min(Platform.textScale,_loc5_);
         return Math.max(0.5,_loc6_);
      }
      
      public static function computeDpiFingerScale() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(PlatformInput.isTouch)
         {
            _loc1_ = FULL_SCREEN_WIDTH / UI_AUTHOR_HEIGHT;
            _loc2_ = FULL_SCREEN_HEIGHT / UI_AUTHOR_WIDTH;
            _loc3_ = Math.min(_loc1_,_loc2_);
            _loc4_ = _loc3_;
            dpiFingerScale = _loc4_;
         }
         return dpiFingerScale;
      }
      
      public function get disableTilt() : Boolean
      {
         return this._disableTilt;
      }
      
      public function set disableTilt(param1:Boolean) : void
      {
         if(this._disableTilt == param1)
         {
            return;
         }
         this._disableTilt = param1;
         if(!this._disableTilt)
         {
            this.setTiltOffset(0,0);
         }
      }
      
      public function setTiltOffset(param1:Number, param2:Number) : void
      {
         if(this._disableTilt)
         {
            param1 = 0;
            param2 = 0;
         }
         if(Math.abs(param1 - this._tiltOffset.x) > TILT_EPSILON || Math.abs(param2 - this._tiltOffset.y) > TILT_EPSILON)
         {
            this._tiltOffset.setTo(param1,param2);
            this.reclamp();
         }
      }
      
      public function set boundary(param1:Rectangle) : void
      {
         this.m_boundary = param1.clone();
         this.adjustBoundary();
      }
      
      public function set boundsDisabled(param1:Boolean) : void
      {
         this.m_boundsDisabled = param1;
      }
      
      public function get boundsDisabled() : Boolean
      {
         return this.m_boundsDisabled;
      }
      
      private function adjustBoundary() : void
      {
         if(this._boundaryAdjustmentFactor <= 1 || BOUNDS_ADJUST_DISABLED || this._disableBoundsAdjust)
         {
            if(!this.adjustedBoundary.equals(this.m_boundary))
            {
               this.adjustedBoundary.copyFrom(this.m_boundary);
               dispatchEvent(new Event(EVENT_BOUNDARY_CHANGED));
            }
            return;
         }
         var _loc1_:Number = this.adjustedBoundary.left;
         var _loc2_:Number = this.adjustedBoundary.right;
         var _loc3_:Number = this.adjustedBoundary.top;
         var _loc4_:Number = this.adjustedBoundary.bottom;
         doAdjustBoundary(this.adjustedBoundary,this.m_boundary,this._boundaryAdjustmentFactor,this._maxWidth,width,this._maxHeight,height);
         if(this.adjustedBoundary.left != _loc1_ || this.adjustedBoundary.right != _loc2_ || this.adjustedBoundary.top != _loc3_ || this.adjustedBoundary.bottom != _loc4_)
         {
            dispatchEvent(new Event(EVENT_BOUNDARY_CHANGED));
         }
      }
      
      override public function set y(param1:Number) : void
      {
         if(this.unclamped.y != param1)
         {
            this.unclamped.y = param1;
            this.tiltedUnclamped.y = this.unclamped.y + this.actualTiltOffset.y;
            this.clamped.y = this.clampY(this.tiltedUnclamped.y);
            this.panClamped.y = this.panClampY(this.tiltedUnclamped.y,this.clamped.y);
            if(super.y != this.clamped.y)
            {
               super.y = this.clamped.y;
            }
            else
            {
               ++viewChangeCounter;
               dispatchEvent(new Event(EVENT_CAMERA_MOVED));
            }
         }
      }
      
      override public function set x(param1:Number) : void
      {
         if(this.unclamped.x != param1)
         {
            this.unclamped.x = param1;
            this.tiltedUnclamped.x = this.unclamped.x + this.actualTiltOffset.x;
            this.clamped.x = this.clampX(this.tiltedUnclamped.x,this.compensateScaleDefault);
            this.panClamped.x = this.panClampX(this.tiltedUnclamped.x,this.clamped.x);
            if(super.x != this.clamped.x)
            {
               super.x = this.clamped.x;
            }
            else
            {
               ++viewChangeCounter;
               dispatchEvent(new Event(EVENT_CAMERA_MOVED));
            }
         }
      }
      
      private function reclamp() : void
      {
         this.adjustBoundary();
         this.actualTiltOffset.setTo(this._tiltOffset.x / scale,this._tiltOffset.y / scale);
         this.tiltedUnclamped.x = this.unclamped.x + this.actualTiltOffset.x;
         this.tiltedUnclamped.y = this.unclamped.y + this.actualTiltOffset.y;
         var _loc1_:Number = this.clampX(this.tiltedUnclamped.x,this.compensateScaleDefault);
         var _loc2_:Number = this.clampY(this.tiltedUnclamped.y,this.compensateScaleDefault);
         this.panClamped.x = this.panClampX(this.tiltedUnclamped.x,_loc1_);
         this.panClamped.y = this.panClampY(this.tiltedUnclamped.y,_loc2_);
         this.clamped.setTo(_loc1_,_loc2_);
         if(this.clamped.x != pos.x || this.clamped.y != pos.y)
         {
            super.setPosition(this.clamped.x,this.clamped.y);
         }
         else
         {
            ++viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_MOVED));
         }
      }
      
      override public function setPosition(param1:Number, param2:Number) : void
      {
         if(this.unclamped.x != param1 || this.unclamped.y != param2)
         {
            this.unclamped.setTo(param1,param2);
            this.reclamp();
         }
      }
      
      override public function get x() : Number
      {
         if(this.m_boundsDisabled == true)
         {
            return this.tiltedUnclamped.x;
         }
         return super.x;
      }
      
      override public function get y() : Number
      {
         if(this.m_boundsDisabled == true)
         {
            return this.tiltedUnclamped.y;
         }
         return super.y;
      }
      
      override public function set zoom(param1:Number) : void
      {
         if(super.zoom != param1)
         {
            super.zoom = param1;
            this.refitCamera();
            this.reclamp();
         }
      }
      
      override protected function set innerScale(param1:Number) : void
      {
         if(super.innerScale != param1)
         {
            super.innerScale = param1;
            this.reclamp();
         }
      }
      
      override public function setSize(param1:Number, param2:Number) : Boolean
      {
         if(super.setSize(param1,param2))
         {
            this.reclamp();
            return true;
         }
         return false;
      }
      
      public function clampX(param1:Number, param2:Boolean) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(this.adjustedBoundary.width <= 0)
         {
            return param1;
         }
         var _loc3_:Number = width / 2;
         if(param2 && scale < 1)
         {
            _loc3_ /= scale;
            _loc3_ = Math.max(this._minWidth / 2,_loc3_);
            _loc3_ = Math.min(this._maxWidth / 2,_loc3_);
         }
         var _loc4_:Number = param1;
         if(this._clampParallax)
         {
            _loc5_ = this.adjustedBoundary.left + _loc3_;
            _loc6_ = this.adjustedBoundary.right - _loc3_;
            _loc4_ = Math.max(_loc4_,_loc5_);
            _loc4_ = Math.min(_loc4_,_loc6_);
         }
         return _loc4_;
      }
      
      public function panClampX(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = Math.max(0,(width - this.viewWidth / scale) / 2);
         if(param1 < param2)
         {
            return Math.max(param1,param2 - _loc3_);
         }
         return Math.min(param1,param2 + _loc3_);
      }
      
      public function clampY(param1:Number, param2:Boolean = true) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(this.adjustedBoundary.height <= 0)
         {
            return param1;
         }
         var _loc3_:Number = height / 2;
         if(param2 && scale < 1)
         {
            _loc3_ /= scale;
            _loc3_ = Math.max(this._minHeight / 2,_loc3_);
            _loc3_ = Math.min(this._maxHeight / 2,_loc3_);
         }
         var _loc4_:Number = param1;
         if(this._clampParallax)
         {
            _loc5_ = this.adjustedBoundary.top + _loc3_;
            _loc6_ = this.adjustedBoundary.bottom - _loc3_;
            _loc4_ = Math.max(_loc4_,_loc5_);
            _loc4_ = Math.min(_loc4_,_loc6_);
         }
         return _loc4_;
      }
      
      public function panClampY(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = Math.max(0,(height - this.viewHeight / scale) / 2);
         if(param1 < param2)
         {
            return Math.max(param1,param2 - _loc3_);
         }
         return Math.min(param1,param2 + _loc3_);
      }
      
      public function fitCamera(param1:Number, param2:Number) : void
      {
         if(!param1 || !param2)
         {
            return;
         }
         if(this.viewWidth == param1 && this.viewHeight == param2)
         {
            return;
         }
         this.viewHeight = param2;
         this.viewWidth = param1;
         this.refitCamera();
      }
      
      public function refitCamera() : void
      {
         if(!this.viewWidth || !this.viewHeight)
         {
            return;
         }
         if(this.disableRefit)
         {
            return;
         }
         this.fc.cinemascope = this._cinemascope;
         this.fc.maxHeight = this._maxHeight;
         this.fc.minHeight = this._minHeight;
         this.fc.maxWidth = this._maxWidth;
         this.fc.minWidth = this._minWidth;
         this.fc.height = height;
         this.fc.width = width;
         if(this.guiPage)
         {
            ScreenAspectHelper.fitCameraGuiPage(this.viewWidth,this.viewHeight,this.fc,this.fd);
         }
         else
         {
            ScreenAspectHelper.fitCamera(this.viewWidth,this.viewHeight,this.fc,this.fd);
         }
         if(this._outerScale == this.fd.outerScale && this._innerScale == this.fd.innerScale && this.height == this.fd.height && this.width == this.fd.height)
         {
            return;
         }
         this.outerScale = this.fd.outerScale;
         this.innerScale = this.fd.innerScale;
         this.setSize(this.fd.width,this.fd.height);
         this.frameMatte(this.viewWidth,this.viewHeight);
         dispatchEvent(new Event(EVENT_MATTE_CHANGED));
      }
      
      private function frameMatte(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = scale;
         var _loc4_:Number = _width / _loc3_;
         var _loc5_:Number = _height / _loc3_;
         _loc4_ = Math.min(this.maxWidth,_loc4_);
         _loc5_ = Math.min(this.maxHeight,_loc5_);
         _loc4_ = Math.max(this.minWidth,_loc4_);
         _loc5_ = Math.max(this.minHeight,_loc5_);
         _loc3_ *= _outerScale;
         _loc4_ *= _loc3_;
         _loc5_ *= _loc3_;
         this.hbar = Math.ceil(Math.max(0,(param2 - _loc5_) / 2));
         this.vbar = Math.ceil(Math.max(0,(param1 - _loc4_) / 2));
         if(logger.isDebugEnabled)
         {
         }
      }
      
      public function get cinemascope() : Boolean
      {
         return this._cinemascope;
      }
      
      public function set cinemascope(param1:Boolean) : void
      {
         if(this._cinemascope != param1)
         {
            this._cinemascope = param1;
            this.fitCamera(this.viewWidth,this.viewHeight);
         }
      }
      
      public function get minWidth() : Number
      {
         return this._minWidth;
      }
      
      public function set minWidth(param1:Number) : void
      {
         this._minWidth = param1;
         this.fitCamera(this.viewWidth,this.viewHeight);
         this.reclamp();
      }
      
      public function get minHeight() : Number
      {
         return this._minHeight;
      }
      
      public function set minHeight(param1:Number) : void
      {
         this._minHeight = param1;
         if(!this.viewWidth || !this.viewHeight)
         {
            return;
         }
         this.fitCamera(this.viewWidth,this.viewHeight);
         this.reclamp();
      }
      
      public function get maxWidth() : Number
      {
         return this._maxWidth;
      }
      
      public function set maxWidth(param1:Number) : void
      {
         this._maxWidth = param1;
         if(!this.viewWidth || !this.viewHeight)
         {
            return;
         }
         this.fitCamera(this.viewWidth,this.viewHeight);
         this.reclamp();
      }
      
      public function get maxHeight() : Number
      {
         return this._maxHeight;
      }
      
      public function set maxHeight(param1:Number) : void
      {
         this._maxHeight = param1;
         this.fitCamera(this.viewWidth,this.viewHeight);
         this.reclamp();
      }
      
      public function get boundaryAdjustmentFactor() : Number
      {
         return this._boundaryAdjustmentFactor;
      }
      
      public function set boundaryAdjustmentFactor(param1:Number) : void
      {
         if(this._boundaryAdjustmentFactor == param1)
         {
            return;
         }
         this._boundaryAdjustmentFactor = param1;
         this.adjustBoundary();
      }
      
      override public function get panClampedX() : Number
      {
         return this.panClamped.x;
      }
      
      override public function get panClampedY() : Number
      {
         return this.panClamped.y;
      }
      
      public function get unclampedX() : Number
      {
         return this.unclamped.x;
      }
      
      public function get unclampedY() : Number
      {
         return this.unclamped.y;
      }
      
      public function set unclampedX(param1:Number) : void
      {
         this.x = param1;
      }
      
      public function set unclampedY(param1:Number) : void
      {
         this.y = param1;
      }
   }
}
