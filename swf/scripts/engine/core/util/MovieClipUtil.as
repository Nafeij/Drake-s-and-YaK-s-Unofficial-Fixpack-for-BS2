package engine.core.util
{
   import engine.core.logging.ILogger;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class MovieClipUtil
   {
       
      
      private var _mc:MovieClip;
      
      private var start:int = -1;
      
      private var end:int = -1;
      
      private var _callback:Function;
      
      private var _looping:Boolean;
      
      public var logger:ILogger;
      
      public var prevFrame:int;
      
      private var labels:Dictionary;
      
      private var initFrame;
      
      public function MovieClipUtil(param1:MovieClip, param2:ILogger, param3:* = null)
      {
         super();
         param1.mouseEnabled = false;
         param1.mouseChildren = false;
         this._mc = param1;
         this.logger = param2;
         this.initFrame = param3;
         if(!param2)
         {
            throw new ArgumentError("no logger? shame.");
         }
         this.init();
      }
      
      public static function stopRecursive(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         param1.stop();
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc2_) as MovieClip;
            if(_loc3_)
            {
               stopRecursive(_loc3_);
            }
            _loc2_++;
         }
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function init() : void
      {
         this._mc.removeEventListener(Event.ENTER_FRAME,this.enterFrameHander);
         if(this.initFrame != null)
         {
            this._mc.gotoAndStop(this.initFrame);
         }
         else
         {
            this._mc.stop();
         }
      }
      
      public function cleanup() : void
      {
         this._callback = null;
         this._mc.removeEventListener(Event.ENTER_FRAME,this.enterFrameHander);
         this.stop();
         this._mc = null;
      }
      
      private function cacheLabels() : void
      {
         var _loc1_:FrameLabel = null;
         if(this.labels)
         {
            return;
         }
         this.labels = new Dictionary();
         for each(_loc1_ in this._mc.currentLabels)
         {
            this.labels[_loc1_.name] = _loc1_.frame;
         }
      }
      
      public function getFrameAtLabel(param1:String) : int
      {
         this.cacheLabels();
         var _loc2_:* = this.labels[param1];
         if(_loc2_ != undefined)
         {
            return int(_loc2_);
         }
         return -1;
      }
      
      public function playLabelRange(param1:String, param2:String, param3:Function) : void
      {
         var _loc4_:int = this.getFrameAtLabel(param1);
         var _loc5_:int = this.getFrameAtLabel(param2);
         this.playRange(_loc4_,_loc5_,param3);
      }
      
      public function playRange(param1:int, param2:int, param3:Function) : void
      {
         this._callback = param3;
         this._mc.addEventListener(Event.ENTER_FRAME,this.enterFrameHander);
         this.start = param1;
         if(param2 < 0)
         {
            param2 = this._mc.framesLoaded;
         }
         this.end = param2;
         this.prevFrame = param1 - 1;
         this._mc.gotoAndPlay(param1);
      }
      
      public function playOnce(param1:Function) : void
      {
         this.looping = false;
         this.playRange(1,this._mc.framesLoaded,param1);
      }
      
      public function playLooping(param1:Function) : void
      {
         this.looping = true;
         this.playRange(1,this._mc.framesLoaded,param1);
      }
      
      protected function enterFrameHander(param1:Event) : void
      {
         if(this._mc.currentFrame == this.end || this.prevFrame >= this._mc.currentFrame)
         {
            if(this.looping)
            {
               this._mc.gotoAndPlay(this.start);
            }
            else
            {
               this.stop();
            }
            if(this._callback != null)
            {
               this._callback(this);
            }
         }
      }
      
      public function get looping() : Boolean
      {
         return this._looping;
      }
      
      public function set looping(param1:Boolean) : void
      {
         this._looping = param1;
      }
      
      public function stop() : void
      {
         this._mc.removeEventListener(Event.ENTER_FRAME,this.enterFrameHander);
         this._mc.stop();
      }
      
      public function restart(param1:Function) : void
      {
         if(this.start < 0)
         {
            this.playRange(1,this._mc.framesLoaded,param1);
         }
         else
         {
            this.playRange(this.start,this.end,param1);
         }
      }
      
      public function get complete() : Boolean
      {
         return !this._mc.isPlaying || this._mc.currentFrame == this.end;
      }
      
      public function get isPlaying() : Boolean
      {
         return this._mc.isPlaying;
      }
      
      public function get visible() : Boolean
      {
         return this._mc.visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._mc.visible = param1;
      }
      
      public function getChildByName(param1:String) : DisplayObject
      {
         return this._mc.getChildByName(param1);
      }
   }
}
