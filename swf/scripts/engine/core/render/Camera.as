package engine.core.render
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class Camera extends EventDispatcher
   {
      
      public static const EVENT_CAMERA_MOVED:String = "EVENT_CAMERA_MOVED";
      
      public static const EVENT_CAMERA_VIEW_CHANGED:String = "EVENT_CAMERA_VIEW_CHANGED";
      
      public static const EVENT_ANCHOR_REACHED:String = "EVENT_ANCHOR_REACHED";
      
      public static const EVENT_CAMERA_SIZE_CHANGED:String = "EVENT_CAMERA_SIZE_CHANGED";
      
      public static var ALLOW_ZOOM:Boolean = true;
       
      
      protected var pos:Point;
      
      public var _width:Number = 0;
      
      public var _height:Number = 0;
      
      private var _zoom:Number = 1;
      
      protected var _innerScale:Number = 1;
      
      protected var _outerScale:Number = 1;
      
      public var drift:CameraDrifter;
      
      public var _pause:Boolean;
      
      public var logger:ILogger;
      
      public var caravanCameraLocked:Boolean = false;
      
      public var scale:Number = 1;
      
      public var oo_scale:Number = 1;
      
      public var oo_zoom:Number = 1;
      
      public var viewChangeCounter:uint;
      
      public var name:String;
      
      public function Camera(param1:String, param2:ILogger)
      {
         this.pos = new Point();
         super();
         this.name = param1;
         this.logger = param2;
         this.drift = new CameraDrifter(this);
      }
      
      public function cleanup() : void
      {
         if(this.drift)
         {
            this.drift.cleanup();
            this.drift = null;
         }
      }
      
      public function get y() : Number
      {
         return this.pos.y;
      }
      
      public function set y(param1:Number) : void
      {
         if(param1 != this.pos.y)
         {
            this.pos.y = param1;
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_MOVED));
         }
      }
      
      public function get x() : Number
      {
         return this.pos.x;
      }
      
      public function set x(param1:Number) : void
      {
         if(param1 != this.pos.x)
         {
            this.pos.x = param1;
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_MOVED));
         }
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         if(param1 != this.pos.x || param2 != this.pos.y)
         {
            this.pos.setTo(param1,param2);
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_MOVED));
         }
      }
      
      protected function set innerScale(param1:Number) : void
      {
         if(this._innerScale != param1)
         {
            this._innerScale = param1;
            this.scale = this._innerScale * this._zoom * this._outerScale;
            if(this.scale != 0)
            {
               this.oo_scale = 1 / this.scale;
            }
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_VIEW_CHANGED));
         }
      }
      
      protected function get innerScale() : Number
      {
         return this._innerScale;
      }
      
      protected function set outerScale(param1:Number) : void
      {
         if(this._outerScale != param1)
         {
            this._outerScale = param1;
            this.scale = this._outerScale * this._zoom * this._innerScale;
            if(this.scale != 0)
            {
               this.oo_scale = 1 / this.scale;
            }
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_VIEW_CHANGED));
         }
      }
      
      protected function get outerScale() : Number
      {
         return this._outerScale;
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function setSize(param1:Number, param2:Number) : Boolean
      {
         if(this._width != param1 || this._height != param2)
         {
            this._width = param1;
            this._height = param2;
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_VIEW_CHANGED));
            dispatchEvent(new Event(EVENT_CAMERA_SIZE_CHANGED));
            return true;
         }
         return false;
      }
      
      public function set width(param1:Number) : void
      {
         if(this._width != param1)
         {
            this._width = param1;
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_VIEW_CHANGED));
            dispatchEvent(new Event(EVENT_CAMERA_SIZE_CHANGED));
         }
      }
      
      public function set height(param1:Number) : void
      {
         if(this._height != param1)
         {
            this._height = param1;
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_VIEW_CHANGED));
            dispatchEvent(new Event(EVENT_CAMERA_SIZE_CHANGED));
         }
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function get zoom() : Number
      {
         return this._zoom;
      }
      
      public function set zoom(param1:Number) : void
      {
         if(!ALLOW_ZOOM)
         {
            return;
         }
         if(this._zoom != param1)
         {
            this._zoom = param1;
            if(this._zoom != 0)
            {
               this.oo_zoom = 1 / this._zoom;
            }
            this.scale = this._innerScale * this._zoom * this._outerScale;
            if(this.scale != 0)
            {
               this.oo_scale = 1 / this.scale;
            }
            ++this.viewChangeCounter;
            dispatchEvent(new Event(EVENT_CAMERA_VIEW_CHANGED));
         }
      }
      
      public function get enableDrift() : Boolean
      {
         return this.drift != null;
      }
      
      public function set enableDrift(param1:Boolean) : void
      {
         if(param1 && this.drift == null)
         {
            this.drift = new CameraDrifter(this);
         }
         else if(!param1 && Boolean(this.drift))
         {
            this.drift.cleanup();
            this.drift = null;
         }
      }
      
      public function get pause() : Boolean
      {
         return this._pause;
      }
      
      public function set pause(param1:Boolean) : void
      {
         if(this._pause != param1)
         {
            this._pause = param1;
            if(this.drift)
            {
               this.drift.pause = this._pause;
            }
         }
      }
      
      public function get panClampedX() : Number
      {
         return this.x;
      }
      
      public function get panClampedY() : Number
      {
         return this.y;
      }
      
      public function set panClampedX(param1:Number) : void
      {
         this.x = param1;
      }
      
      public function set panClampedY(param1:Number) : void
      {
         this.y = param1;
      }
      
      public function update(param1:int) : void
      {
         if(this.drift)
         {
            this.drift.update(param1);
         }
      }
   }
}
