package game.gui.battle
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import flash.errors.IllegalOperationError;
   import flash.events.MouseEvent;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiStarsContainer extends GuiBase
   {
       
      
      private var _showing:int = -1;
      
      private var stars:Vector.<GuiStar>;
      
      private var _autoCenterH:Boolean = true;
      
      private var starWidth:int = 49;
      
      private var starSelectedCallback:Function = null;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var bmp_l1:GuiGpBitmap;
      
      private var bmp_r1:GuiGpBitmap;
      
      private var _largeStarCount:int;
      
      public function GuiStarsContainer()
      {
         this.stars = new Vector.<GuiStar>();
         this.cmd_l1 = new Cmd("starscont_cmd_l1",this.func_cmd_l1);
         this.cmd_r1 = new Cmd("starscont_cmd_r1",this.func_cmd_r1);
         this.bmp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.bmp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         super();
         this.addChild(this.bmp_l1);
         this.addChild(this.bmp_r1);
         this.bmp_l1.scale = this.bmp_r1.scale = 0.75;
         this.bmp_l1.visible = false;
         this.bmp_r1.visible = false;
         this.cmd_l1.enabled = false;
         this.cmd_r1.enabled = false;
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
         this.mouseEnabled = false;
         this.mouseChildren = true;
      }
      
      public function init(param1:IGuiContext, param2:Function) : void
      {
         var _loc4_:GuiStar = null;
         initGuiBase(param1);
         var _loc3_:int = 0;
         while(_loc3_ < numChildren)
         {
            _loc4_ = getChildAt(_loc3_) as GuiStar;
            if(_loc4_)
            {
               _loc4_.init(param1,null);
               this.stars.push(_loc4_);
            }
            _loc3_++;
         }
         this.showing(0);
         this.starSelectedCallback = param2;
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiStar = null;
         GuiGp.releasePrimaryBitmap(this.bmp_l1);
         GuiGp.releasePrimaryBitmap(this.bmp_r1);
         GpBinder.gpbinder.unbind(this.cmd_l1);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         this.cmd_l1.cleanup();
         this.cmd_r1.cleanup();
         for each(_loc1_ in this.stars)
         {
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onStarClick);
            _loc1_.cleanup();
         }
         this.stars = null;
         this.starSelectedCallback = null;
         super.cleanupGuiBase();
      }
      
      public function selectedStars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._showing && _loc2_ < this.stars.length)
         {
            if(this.stars[_loc2_].selected)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function handleStarClick(param1:GuiStar) : void
      {
         if(!param1.clickable)
         {
            throw new IllegalOperationError("Nope, not clickable star");
         }
         var _loc2_:int = this.stars.indexOf(param1);
         var _loc3_:int = 0;
         if(param1.selected)
         {
            _loc3_ = _loc2_;
            while(_loc2_ < this.stars.length)
            {
               this.stars[_loc2_].selected = false;
               _loc2_++;
            }
         }
         else
         {
            while(_loc2_ > -1)
            {
               if(param1.clickable)
               {
                  this.stars[_loc2_].selected = true;
                  _loc3_++;
               }
               _loc2_--;
            }
         }
         context.playSound("ui_willpower_select");
         if(this.starSelectedCallback != null)
         {
            this.starSelectedCallback(_loc3_);
         }
      }
      
      private function onStarClick(param1:MouseEvent) : void
      {
         var _loc2_:GuiStar = param1.currentTarget as GuiStar;
         if(!_loc2_.clickable)
         {
            return;
         }
         this.handleStarClick(_loc2_);
      }
      
      public function restart() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.stars.length)
         {
            this.stars[_loc1_].selected = false;
            this.stars[_loc1_].setShowing(false,false);
            _loc1_++;
         }
         this._showing = -1;
         this.bmp_l1.visible = false;
         this.bmp_r1.visible = false;
         this.cmd_l1.enabled = false;
         this.cmd_r1.enabled = false;
      }
      
      public function showing(param1:int, param2:int = 0) : void
      {
         var _loc8_:GuiStar = null;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         if(param1 == this._showing && this._largeStarCount == param2)
         {
            return;
         }
         this._showing = param1;
         this._largeStarCount = param2;
         var _loc3_:int = 0;
         var _loc4_:Number = Number.MAX_VALUE;
         var _loc5_:Number = -Number.MAX_VALUE;
         var _loc6_:int = this._showing - this._largeStarCount;
         var _loc7_:int = 0;
         while(_loc7_ < this.stars.length)
         {
            _loc8_ = this.stars[_loc7_];
            if(!param2 || _loc7_ < _loc6_)
            {
               _loc8_.clickable = false;
               _loc8_.selected = true;
            }
            else
            {
               _loc8_.clickable = true;
               _loc8_.addEventListener(MouseEvent.CLICK,this.onStarClick);
               _loc8_.selected = false;
            }
            if(_loc7_ < this._showing)
            {
               _loc9_ = this.starWidth * _loc8_.scaleX / 2;
               _loc3_ += _loc9_;
               _loc8_.x = _loc3_;
               _loc3_ += _loc9_;
               _loc4_ = Math.min(_loc8_.x,_loc4_);
               _loc5_ = Math.max(_loc8_.x,_loc5_);
               _loc8_.setShowing(true,!_loc8_.clickable);
            }
            else
            {
               this.stars[_loc7_].setShowing(false,false);
               _loc8_.removeEventListener(MouseEvent.CLICK,this.onStarClick);
            }
            _loc7_++;
         }
         if(this._autoCenterH && this._showing > 0)
         {
            _loc10_ = (_loc5_ + _loc4_) / 2;
            x = -_loc10_ * scaleX;
         }
         this.showGp();
      }
      
      public function triggerCallback() : void
      {
         if(this.starSelectedCallback != null)
         {
            this.starSelectedCallback(this.selectedStars());
         }
      }
      
      private function showGp() : void
      {
         var _loc1_:GuiStar = null;
         var _loc2_:GuiStar = null;
         if(this._showing > 0 && this._largeStarCount > 0)
         {
            _loc1_ = this.stars[0];
            _loc2_ = this.stars[this._showing - 1];
            this.bmp_l1.visible = true;
            this.bmp_r1.visible = true;
            this.bmp_l1.x = _loc1_.x - _loc1_.width / 2 - this.bmp_l1.width;
            this.bmp_l1.y = _loc1_.y - this.bmp_l1.height / 2;
            this.bmp_r1.x = _loc2_.x + _loc2_.width / 2;
            this.bmp_r1.y = _loc2_.y - this.bmp_r1.height / 2;
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
      
      private function func_cmd_l1(param1:CmdExec) : void
      {
         this.bmp_l1.pulse();
         var _loc2_:int = this.selectedStars();
         var _loc3_:int = this._showing - this._largeStarCount;
         if(this._showing > 0 && this._largeStarCount > 0 && _loc2_ > _loc3_)
         {
            this.handleStarClick(this.stars[_loc2_ - 1]);
         }
         else
         {
            context.playSound("ui_error");
         }
      }
      
      private function func_cmd_r1(param1:CmdExec) : void
      {
         this.bmp_r1.pulse();
         var _loc2_:int = this.selectedStars();
         var _loc3_:int = this._showing - this._largeStarCount;
         if(this._showing > 0 && this._largeStarCount > 0 && _loc2_ < this._showing)
         {
            this.handleStarClick(this.stars[_loc2_]);
         }
         else
         {
            context.playSound("ui_error");
         }
      }
      
      public function starsMod(param1:int) : void
      {
         if(param1 > 0)
         {
            this.func_cmd_r1(null);
         }
         else if(param1 < 0)
         {
            this.func_cmd_l1(null);
         }
      }
   }
}
