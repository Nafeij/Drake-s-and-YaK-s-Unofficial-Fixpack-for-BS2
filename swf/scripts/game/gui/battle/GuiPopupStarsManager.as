package game.gui.battle
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import game.gui.IGuiContext;
   
   public class GuiPopupStarsManager
   {
       
      
      private var buttonStars:Vector.<MovieClip>;
      
      private var firstStarPositionX:Array;
      
      private var starChangedFunction:Function;
      
      private var _starsClicked:int = 0;
      
      public var starsAvailable:int = 0;
      
      private const blankStarEndFrame:int = 7;
      
      private const blankStarStartFrame:int = 2;
      
      private const selectStarStartFrame:int = 8;
      
      private const starOffset:Number = 50;
      
      private var minSelectedStars:int;
      
      private var context:IGuiContext;
      
      private var _starsEnabled:Boolean = true;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var bmp_l1:GuiGpBitmap;
      
      private var bmp_r1:GuiGpBitmap;
      
      private var container:DisplayObjectContainer;
      
      public var starLeft:MovieClip;
      
      public var starRight:MovieClip;
      
      private var _hoverStar:MovieClip;
      
      public function GuiPopupStarsManager(param1:DisplayObjectContainer, param2:IGuiContext)
      {
         this.buttonStars = new Vector.<MovieClip>();
         this.cmd_l1 = new Cmd("starsman_cmd_l1",this.func_cmd_l1);
         this.cmd_r1 = new Cmd("starsman_cmd_r1",this.func_cmd_r1);
         this.bmp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.bmp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         super();
         this.context = param2;
         this.container = param1;
         param1.addChild(this.bmp_l1);
         param1.addChild(this.bmp_r1);
         this.bmp_l1.visible = false;
         this.bmp_r1.visible = false;
         this.cmd_l1.enabled = false;
         this.cmd_r1.enabled = false;
         this.bmp_l1.scale = this.bmp_r1.scale = 0.75;
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
      }
      
      public function cleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this.bmp_l1);
         GuiGp.releasePrimaryBitmap(this.bmp_r1);
         GpBinder.gpbinder.unbind(this.cmd_l1);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         this.cmd_l1.cleanup();
         this.cmd_r1.cleanup();
      }
      
      private function func_cmd_l1(param1:CmdExec) : void
      {
         this.bmp_l1.pulse();
         if(this._starsClicked > this.minSelectedStars && this._starsClicked > 0 && this._starsClicked <= this.buttonStars.length)
         {
            this.handleStarButtonDown(this.buttonStars[this._starsClicked - 1]);
         }
         else
         {
            this.context.playSound("ui_error");
         }
      }
      
      private function func_cmd_r1(param1:CmdExec) : void
      {
         this.bmp_r1.pulse();
         if(this._starsClicked < this.starsAvailable && this._starsClicked >= 0 && this._starsClicked < this.buttonStars.length)
         {
            this.handleStarButtonDown(this.buttonStars[this._starsClicked]);
         }
         else
         {
            this.context.playSound("ui_error");
         }
      }
      
      public function get starsClicked() : int
      {
         return Math.max(this.minSelectedStars,this._starsClicked);
      }
      
      public function init(param1:Function, param2:int, param3:Vector.<MovieClip>, param4:Array, param5:int = 0) : void
      {
         var _loc7_:MovieClip = null;
         if(param5 > param2)
         {
            throw new ArgumentError("Failed to set stars");
         }
         this.firstStarPositionX = param4;
         this.starChangedFunction = param1;
         this.starsAvailable = param2;
         this.buttonStars = new Vector.<MovieClip>();
         var _loc6_:int = 0;
         while(_loc6_ < param3.length)
         {
            _loc7_ = param3[_loc6_];
            this.showStarGlow(_loc7_,false);
            _loc7_.addEventListener(MouseEvent.MOUSE_DOWN,this.buttonStarDownHandler);
            _loc7_.addEventListener(MouseEvent.ROLL_OVER,this.buttonStarRollOverHandler);
            _loc7_.addEventListener(MouseEvent.ROLL_OUT,this.buttonStarRollOutHandler);
            this.buttonStars.push(_loc7_);
            _loc6_++;
         }
         this.minSelectedStars = param5;
         this.showStars(param2);
         this.hoverStar = null;
      }
      
      public function resetAllStars() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.buttonStars.length)
         {
            this.buttonStars[_loc1_].gotoAndStop(1);
            _loc1_++;
         }
         this.bmp_l1.visible = false;
         this.bmp_r1.visible = false;
         this.cmd_l1.enabled = false;
         this.cmd_r1.enabled = false;
      }
      
      public function showStars(param1:int) : void
      {
         var _loc3_:MovieClip = null;
         this._starsClicked = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.buttonStars.length)
         {
            _loc3_ = this.buttonStars[_loc2_];
            _loc3_.visible = _loc2_ < param1;
            if(_loc2_ < param1)
            {
               this.starRight = _loc3_;
               if(_loc2_ == 0)
               {
                  this.starLeft = _loc3_;
                  _loc3_.x = this.firstStarPositionX[param1 - 1];
                  _loc3_.play();
               }
               else
               {
                  _loc3_.x = this.buttonStars[_loc2_ - 1].x + this.starOffset;
                  GuiUtil.delayPlay(0.05,_loc3_);
               }
            }
            if(_loc3_.index <= this.minSelectedStars)
            {
               _loc3_.addEventListener(Event.EXIT_FRAME,this.starFrameChanged);
               this._starsClicked += 1;
            }
            _loc2_++;
         }
         this.showGp();
      }
      
      private function showGp() : void
      {
         if(this.starsEnabled && this.starsAvailable > 0 && this.starLeft && Boolean(this.starRight))
         {
            this.bmp_l1.visible = true;
            this.bmp_r1.visible = true;
            this.bmp_l1.x = this.starLeft.x - this.starLeft.width / 2 - this.bmp_l1.width;
            this.bmp_l1.y = this.starLeft.y - this.starLeft.height / 2 - this.bmp_l1.height / 2;
            this.bmp_r1.x = this.starRight.x + this.starRight.width / 2;
            this.bmp_r1.y = this.starLeft.y - this.starRight.height / 2 - this.bmp_r1.height / 2;
            this.cmd_l1.enabled = true;
            this.cmd_r1.enabled = true;
         }
         else
         {
            this.bmp_l1.visible = false;
            this.bmp_r1.visible = false;
            this.cmd_l1.enabled = false;
            this.cmd_r1.enabled = false;
         }
      }
      
      private function selectStars(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         this._starsClicked = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.buttonStars.length)
         {
            _loc3_ = this.buttonStars[_loc2_];
            _loc4_ = param1;
            if(_loc3_.index < _loc4_.index || _loc3_.index <= this.minSelectedStars)
            {
               _loc3_.gotoAndPlay(this.selectStarStartFrame);
               this._starsClicked += 1;
            }
            else if(_loc3_.index > _loc4_.index)
            {
               _loc3_.gotoAndStop(this.blankStarEndFrame);
            }
            else if(_loc3_.currentFrame == this.blankStarEndFrame)
            {
               _loc3_.gotoAndPlay(this.selectStarStartFrame);
               this._starsClicked += 1;
            }
            else
            {
               _loc3_.gotoAndStop(this.blankStarEndFrame);
            }
            _loc2_++;
         }
         if(this.starChangedFunction != null)
         {
            this.starChangedFunction();
         }
      }
      
      public function get hoverStar() : MovieClip
      {
         return this._hoverStar;
      }
      
      public function set hoverStar(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         if(this._hoverStar)
         {
            this.showStarGlow(this._hoverStar,false);
         }
         this._hoverStar = param1;
         if(this._hoverStar)
         {
            this.showStarGlow(this._hoverStar,true);
         }
      }
      
      private function showStarGlow(param1:MovieClip, param2:Boolean) : void
      {
         var _loc3_:MovieClip = null;
         if(param1)
         {
            _loc3_ = param1.getChildByName("star_glow") as MovieClip;
            if(_loc3_)
            {
               _loc3_.visible = param2;
            }
         }
      }
      
      private function buttonStarRollOutHandler(param1:MouseEvent) : void
      {
         if(this._hoverStar == param1.currentTarget)
         {
            this.hoverStar = null;
         }
      }
      
      private function buttonStarRollOverHandler(param1:MouseEvent) : void
      {
         this.hoverStar = param1.currentTarget as MovieClip;
      }
      
      private function buttonStarDownHandler(param1:MouseEvent) : void
      {
         if(!this._starsEnabled)
         {
            return;
         }
         this.handleStarButtonDown(param1.currentTarget as MovieClip);
      }
      
      private function handleStarButtonDown(param1:MovieClip) : void
      {
         this.selectStars(param1);
         this.context.playSound("ui_willpower_select");
      }
      
      private function starFrameChanged(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_.currentFrame == this.blankStarEndFrame)
         {
            _loc2_.play();
            _loc2_.removeEventListener(Event.EXIT_FRAME,this.starFrameChanged);
         }
      }
      
      public function get starsEnabled() : Boolean
      {
         return this._starsEnabled;
      }
      
      public function set starsEnabled(param1:Boolean) : void
      {
         this._starsEnabled = param1;
         if(!param1)
         {
            this.bmp_l1.visible = false;
            this.bmp_r1.visible = false;
            this.cmd_l1.enabled = false;
            this.cmd_r1.enabled = false;
         }
      }
   }
}
