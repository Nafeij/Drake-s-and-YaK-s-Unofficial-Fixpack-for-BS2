package starling.display
{
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.filters.FragmentFilter;
   import starling.utils.MatrixUtil;
   
   [Event(name="resize",type="starling.events.ResizeEvent")]
   public class Stage extends DisplayObjectContainer
   {
      
      private static var sHelperMatrix:Matrix3D = new Matrix3D();
       
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mColor:uint;
      
      private var mFieldOfView:Number;
      
      private var mProjectionOffset:Point;
      
      private var mCameraPosition:Vector3D;
      
      private var mEnterFrameEvent:EnterFrameEvent;
      
      private var mEnterFrameListeners:Vector.<DisplayObject>;
      
      public function Stage(param1:int, param2:int, param3:uint = 0)
      {
         super();
         this.mWidth = param1;
         this.mHeight = param2;
         this.mColor = param3;
         this.mFieldOfView = 1;
         this.mProjectionOffset = new Point();
         this.mCameraPosition = new Vector3D();
         this.mEnterFrameEvent = new EnterFrameEvent(Event.ENTER_FRAME,0);
         this.mEnterFrameListeners = new Vector.<DisplayObject>(0);
      }
      
      public function advanceTime(param1:Number) : void
      {
         this.mEnterFrameEvent.starling_internal::reset(Event.ENTER_FRAME,false,param1);
         broadcastEvent(this.mEnterFrameEvent);
      }
      
      override public function hitTest(param1:Point, param2:Boolean = false) : DisplayObject
      {
         if(param2 && (!visible || !touchable))
         {
            return null;
         }
         if(param1.x < 0 || param1.x > this.mWidth || param1.y < 0 || param1.y > this.mHeight)
         {
            return null;
         }
         var _loc3_:DisplayObject = super.hitTest(param1,param2);
         if(_loc3_ == null)
         {
            _loc3_ = this;
         }
         return _loc3_;
      }
      
      public function drawToBitmapData(param1:BitmapData = null, param2:Boolean = true) : BitmapData
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:RenderSupport = new RenderSupport();
         var _loc4_:Starling = Starling.current;
         if(param1 == null)
         {
            _loc5_ = _loc4_.backBufferWidth * _loc4_.backBufferPixelsPerPoint;
            _loc6_ = _loc4_.backBufferHeight * _loc4_.backBufferPixelsPerPoint;
            param1 = new BitmapData(_loc5_,_loc6_,param2);
         }
         _loc3_.renderTarget = null;
         _loc3_.setProjectionMatrix(0,0,this.mWidth,this.mHeight,this.mWidth,this.mHeight,this.cameraPosition);
         if(param2)
         {
            _loc3_.clear();
         }
         else
         {
            _loc3_.clear(this.mColor,1);
         }
         render(_loc3_,1);
         _loc3_.finishQuadBatch();
         _loc3_.dispose();
         Starling.current.context.drawToBitmapData(param1);
         Starling.current.context.present();
         return param1;
      }
      
      public function getCameraPosition(param1:DisplayObject = null, param2:Vector3D = null) : Vector3D
      {
         getTransformationMatrix3D(param1,sHelperMatrix);
         return MatrixUtil.transformCoords3D(sHelperMatrix,this.mWidth / 2 + this.mProjectionOffset.x,this.mHeight / 2 + this.mProjectionOffset.y,-this.focalLength,param2);
      }
      
      internal function addEnterFrameListener(param1:DisplayObject) : void
      {
         this.mEnterFrameListeners.push(param1);
      }
      
      internal function removeEnterFrameListener(param1:DisplayObject) : void
      {
         var _loc2_:int = this.mEnterFrameListeners.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.mEnterFrameListeners.splice(_loc2_,1);
         }
      }
      
      override internal function getChildEventListeners(param1:DisplayObject, param2:String, param3:Vector.<DisplayObject>) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param2 == Event.ENTER_FRAME && param1 == this)
         {
            _loc4_ = 0;
            _loc5_ = this.mEnterFrameListeners.length;
            while(_loc4_ < _loc5_)
            {
               param3[param3.length] = this.mEnterFrameListeners[_loc4_];
               _loc4_++;
            }
         }
         else
         {
            super.getChildEventListeners(param1,param2,param3);
         }
      }
      
      override public function set width(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set width of stage");
      }
      
      override public function set height(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set height of stage");
      }
      
      override public function set x(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set x-coordinate of stage");
      }
      
      override public function set y(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set y-coordinate of stage");
      }
      
      override public function set scaleX(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set scaleY(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set rotation(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot rotate stage");
      }
      
      override public function set skewX(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot skew stage");
      }
      
      override public function set skewY(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot skew stage");
      }
      
      override public function set filter(param1:FragmentFilter) : void
      {
         throw new IllegalOperationError("Cannot add filter to stage. Add it to \'root\' instead!");
      }
      
      public function get color() : uint
      {
         return this.mColor;
      }
      
      public function set color(param1:uint) : void
      {
         this.mColor = param1;
      }
      
      public function get stageWidth() : int
      {
         return this.mWidth;
      }
      
      public function set stageWidth(param1:int) : void
      {
         this.mWidth = param1;
      }
      
      public function get stageHeight() : int
      {
         return this.mHeight;
      }
      
      public function set stageHeight(param1:int) : void
      {
         this.mHeight = param1;
      }
      
      public function get focalLength() : Number
      {
         return this.mWidth / (2 * Math.tan(this.mFieldOfView / 2));
      }
      
      public function set focalLength(param1:Number) : void
      {
         this.mFieldOfView = 2 * Math.atan(this.stageWidth / (2 * param1));
      }
      
      public function get fieldOfView() : Number
      {
         return this.mFieldOfView;
      }
      
      public function set fieldOfView(param1:Number) : void
      {
         this.mFieldOfView = param1;
      }
      
      public function get projectionOffset() : Point
      {
         return this.mProjectionOffset;
      }
      
      public function set projectionOffset(param1:Point) : void
      {
         this.mProjectionOffset.setTo(param1.x,param1.y);
      }
      
      public function get cameraPosition() : Vector3D
      {
         return this.getCameraPosition(null,this.mCameraPosition);
      }
   }
}
