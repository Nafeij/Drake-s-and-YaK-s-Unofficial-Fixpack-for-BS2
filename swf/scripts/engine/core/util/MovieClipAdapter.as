package engine.core.util
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.math.MathUtil;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class MovieClipAdapter
   {
       
      
      private var _mc:MovieClip;
      
      private var start:int = -1;
      
      private var end:int = -1;
      
      private var _looping:Boolean;
      
      public var prevFrame:int;
      
      private var labels:Dictionary;
      
      private var initFrame;
      
      private var totalFrames:int;
      
      public var totalMs:int = 0;
      
      private var playing:Boolean;
      
      private var timer:Timer;
      
      private var fps:Number = 30;
      
      private var frameChangeCallback:Function;
      
      private var _completeCallback:Function;
      
      private var logger:ILogger;
      
      public var loopChildren:Boolean = true;
      
      public var locale:Locale;
      
      public var autoUpdate:Boolean;
      
      private var lastUpdate:int;
      
      private var last_localized_frame:int = 0;
      
      private var next_localize_index:int = 0;
      
      private var relocalizing:Vector.<int>;
      
      public function MovieClipAdapter(param1:MovieClip, param2:Number, param3:*, param4:Boolean, param5:ILogger, param6:Function = null, param7:Function = null, param8:Boolean = true, param9:Locale = null)
      {
         var _loc10_:int = 0;
         this.relocalizing = new Vector.<int>();
         super();
         if(!param1)
         {
            return;
         }
         this.locale = param9;
         this.logger = param5;
         param1.mouseEnabled = false;
         param1.mouseChildren = false;
         this._completeCallback = param7;
         this.autoUpdate = param8;
         this.frameChangeCallback = param6;
         this._mc = param1;
         if(param4)
         {
            param3 = MathUtil.randomInt(0,param1.framesLoaded - 1);
         }
         this.initFrame = param3;
         this.fps = param2;
         if(param8)
         {
            _loc10_ = Math.max(20,1000 / param2 - 5);
            this.timer = new Timer(_loc10_,0);
         }
         MovieClipUtil.stopRecursive(param1);
         if(param9)
         {
            this.cacheLabels();
         }
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this.lastUpdate;
         this.lastUpdate = _loc2_;
         this.update(_loc3_);
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function set completeCallback(param1:Function) : void
      {
         this._completeCallback = param1;
      }
      
      public function cleanup() : void
      {
         if(this._mc.parent)
         {
            this._mc.parent.removeChild(this._mc);
         }
         this.frameChangeCallback = null;
         this.stop();
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
            this.timer = null;
         }
         this._mc = null;
         this.labels = null;
         this.frameChangeCallback = null;
         this._completeCallback = null;
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
            this.labels[_loc1_.name] = _loc1_.frame - 1;
            if(StringUtil.startsWith(_loc1_.name,"@relocalize"))
            {
               this.relocalizing.push(_loc1_.frame - 1);
            }
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
      
      public function playLabelRange(param1:String, param2:String) : void
      {
         var _loc3_:int = this.getFrameAtLabel(param1);
         var _loc4_:int = this.getFrameAtLabel(param2);
         this.playRange(_loc3_,_loc4_);
      }
      
      public function playRange(param1:int, param2:int) : void
      {
         this.playing = true;
         this.lastUpdate = getTimer();
         if(this.autoUpdate)
         {
            this.timer.addEventListener(TimerEvent.TIMER,this.timerHandler);
            this.timer.reset();
            this.timer.start();
         }
         this.start = param1;
         this.end = param2;
         this.prevFrame = param1 - 1;
         this.totalFrames = param1;
         this.totalMs = 1000 * param1 / this.fps;
         this.setClipFrames(this._mc);
      }
      
      public function playOnce() : void
      {
         this.totalMs = 0;
         this.totalFrames = 0;
         this.playRange(0,this._mc.framesLoaded - 1);
      }
      
      public function playLooping() : void
      {
         this.playRange(0,-1);
      }
      
      private function setClipFrames(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         this.setClipFrame(param1);
         if(this.loopChildren)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = param1.getChildAt(_loc2_) as MovieClip;
               if(_loc3_)
               {
                  this.setClipFrames(_loc3_);
               }
               _loc2_++;
            }
         }
      }
      
      private function setClipFrame(param1:MovieClip) : void
      {
         var _loc2_:int = this.totalFrames % param1.framesLoaded;
         param1.gotoAndStop(_loc2_ + 1);
      }
      
      public function update(param1:int) : void
      {
         var _loc6_:int = 0;
         if(!this.playing)
         {
            return;
         }
         this.totalMs += param1;
         var _loc2_:int = this.totalFrames;
         this.totalFrames = this.fps * this.totalMs / 1000;
         if(this.end >= 0)
         {
            this.totalFrames = Math.min(this.end,this.totalFrames);
         }
         this.setClipFrames(this._mc);
         var _loc3_:int = _loc2_ / this._mc.framesLoaded;
         var _loc4_:int = this.totalFrames / this._mc.framesLoaded;
         if(_loc4_ > _loc3_)
         {
            this.last_localized_frame = -1;
            this.next_localize_index = 0;
         }
         var _loc5_:int = this.totalFrames % this._mc.framesLoaded;
         if(_loc5_ > this.last_localized_frame)
         {
            if(this.next_localize_index < this.relocalizing.length)
            {
               _loc6_ = this.relocalizing[this.next_localize_index];
               if(_loc5_ >= _loc6_)
               {
                  this.last_localized_frame = _loc5_;
                  ++this.next_localize_index;
                  this.updateLocalization();
               }
            }
         }
         if(this.totalFrames == this.end)
         {
            this.stop();
         }
         if(_loc2_ != this.totalFrames)
         {
            if(this.frameChangeCallback != null)
            {
               this.frameChangeCallback(this);
            }
         }
      }
      
      public function stop() : void
      {
         if(!this.playing)
         {
            return;
         }
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
            this.timer.stop();
         }
         this.playing = false;
         if(this._completeCallback != null)
         {
            this._completeCallback(this);
         }
      }
      
      public function restart() : void
      {
         this.totalMs = 0;
         this.totalFrames = 0;
         if(this.start < 0)
         {
            this.playRange(0,this.end);
         }
         else
         {
            this.playRange(this.start,this.end);
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
      
      public function lastFrameNumber() : int
      {
         return this._mc.framesLoaded - 1;
      }
      
      public function get y() : Number
      {
         return this._mc.y;
      }
      
      public function updateLocalization() : void
      {
         if(this.locale)
         {
            this.locale.translateDisplayObjects(LocaleCategory.GUI,this._mc,this.logger);
         }
      }
   }
}
