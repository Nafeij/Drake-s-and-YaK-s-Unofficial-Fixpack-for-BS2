package game.gui
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PopupIconsGroup extends GuiBase
   {
       
      
      private var amountToPlay:int;
      
      private var groupMovieClip:MovieClip;
      
      private var icons:Vector.<MovieClip>;
      
      private var iconPlaying:int;
      
      private var callback:Function;
      
      private var frameToPlayNext:Number;
      
      private var minX:Number = 0;
      
      private var maxX:Number = 0;
      
      private var amountToStartStacking:int;
      
      public var leftBoundary:Number = 0;
      
      public function PopupIconsGroup()
      {
         this.icons = new Vector.<MovieClip>();
         super();
         this.mouseEnabled = this.mouseChildren = false;
      }
      
      public function init(param1:IGuiContext, param2:int) : void
      {
         var _loc4_:MovieClip = null;
         super.initGuiBase(param1);
         this.stop();
         var _loc3_:int = 1;
         while(_loc3_ <= param2)
         {
            _loc4_ = getChildByName("icon" + _loc3_) as MovieClip;
            if(_loc4_.x < this.minX || _loc3_ == 1)
            {
               this.minX = _loc4_.x;
            }
            if(_loc4_.x > this.maxX || _loc3_ == 1)
            {
               this.maxX = _loc4_.x;
            }
            _loc4_.stop();
            _loc4_.visible = false;
            this.icons.push(_loc4_);
            _loc3_++;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:MovieClip = null;
         this.callback = null;
         for each(_loc1_ in this.icons)
         {
            _loc1_.removeEventListener(Event.EXIT_FRAME,this.nextIconReadyToStart);
         }
         this.icons = null;
         super.cleanupGuiBase();
      }
      
      public function setup(param1:int, param2:Number, param3:int) : void
      {
         this.amountToPlay = param1;
         this.iconPlaying = 0;
         this.frameToPlayNext = param2;
         this.amountToStartStacking = param3;
         if(param1 > param3)
         {
            this.stackIcons();
         }
         if(param1 > 0 && param1 <= this.icons.length)
         {
            this.leftBoundary = this.icons[param1 - 1].x;
         }
      }
      
      private function stackIcons() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Number = this.amountToStartStacking / this.amountToPlay;
         var _loc2_:Number = this.icons[0].x;
         _loc3_ = 1;
         while(_loc3_ < this.icons.length)
         {
            this.icons[_loc3_].x = _loc2_ - this.icons[_loc3_].width * 1.6 * _loc1_;
            _loc2_ = this.icons[_loc3_].x;
            _loc3_++;
         }
      }
      
      public function playAndResetPopups(param1:Function) : void
      {
         this.reset();
         this.callback = param1;
         if(this.amountToPlay == 0)
         {
            param1();
         }
         this.playPopups();
      }
      
      private function playPopups() : void
      {
         if(!context)
         {
            return;
         }
         if(this.iconPlaying < this.amountToPlay)
         {
            context.playSound("ui_stats_glisten");
            if(this.icons.length > this.iconPlaying)
            {
               this.icons[this.iconPlaying].visible = true;
               this.icons[this.iconPlaying].play();
               this.icons[this.iconPlaying].addEventListener(Event.EXIT_FRAME,this.nextIconReadyToStart);
            }
            else
            {
               this.allIconsDoneAnimating();
            }
         }
      }
      
      private function allIconsDoneAnimating() : void
      {
         if(this.callback != null)
         {
            this.callback();
         }
      }
      
      private function iconAnimating(param1:Event) : void
      {
         if(param1.currentTarget.currentFrame == param1.currentTarget.totalFrames)
         {
            param1.currentTarget.removeEventListener(Event.EXIT_FRAME,this.iconAnimating);
            param1.currentTarget.stop();
            if(this.icons.indexOf(param1.currentTarget as MovieClip) + 1 == this.amountToPlay)
            {
               this.allIconsDoneAnimating();
            }
         }
      }
      
      private function nextIconReadyToStart(param1:Event) : void
      {
         if(!context)
         {
            param1.currentTarget.removeEventListener(Event.EXIT_FRAME,this.nextIconReadyToStart);
            return;
         }
         if(param1.currentTarget.currentFrame == this.frameToPlayNext)
         {
            ++this.iconPlaying;
            this.playPopups();
            param1.currentTarget.removeEventListener(Event.EXIT_FRAME,this.nextIconReadyToStart);
            param1.currentTarget.addEventListener(Event.EXIT_FRAME,this.iconAnimating);
         }
      }
      
      public function reset() : void
      {
         var _loc1_:MovieClip = null;
         this.iconPlaying = 0;
         for each(_loc1_ in this.icons)
         {
            _loc1_.visible = false;
            _loc1_.gotoAndStop(1);
         }
      }
   }
}
