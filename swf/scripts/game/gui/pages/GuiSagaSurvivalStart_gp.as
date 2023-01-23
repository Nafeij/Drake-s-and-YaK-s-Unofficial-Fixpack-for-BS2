package game.gui.pages
{
   import com.greensock.TweenMax;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public class GuiSagaSurvivalStart_gp
   {
       
      
      private var gui:GuiSagaSurvivalStart;
      
      private var context:IGuiContext;
      
      private var acvNav:GuiGpNav;
      
      private var diffNav:GuiGpNav;
      
      private var layer:int;
      
      private var cmd_welcome:Cmd;
      
      private var cmd_back:Cmd;
      
      private var cmd_resume:Cmd;
      
      private var cmd_start:Cmd;
      
      private var cmd_acv:Cmd;
      
      private var cmd_lb:Cmd;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_x:GuiGpBitmap;
      
      private var gp_y:GuiGpBitmap;
      
      private var gp_d_r:GuiGpBitmap;
      
      public function GuiSagaSurvivalStart_gp()
      {
         this.cmd_welcome = new Cmd("cmd_survival_welcome",this.cmdfunc_welcome);
         this.cmd_back = new Cmd("cmd_survival_back",this.cmdfunc_back);
         this.cmd_resume = new Cmd("cmd_survival_resume",this.cmdfunc_resume);
         this.cmd_start = new Cmd("cmd_survival_start",this.cmdfunc_start);
         this.cmd_acv = new Cmd("cmd_survival_acv",this.cmdfunc_acv);
         this.cmd_lb = new Cmd("cmd_survival_lb",this.cmdfunc_lb);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B,true);
         this.gp_x = GuiGp.ctorPrimaryBitmap(GpControlButton.X,true);
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         this.gp_d_r = GuiGp.ctorPrimaryBitmap(GpControlButton.D_R,true);
         super();
      }
      
      public function cleanup() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_welcome);
         GpBinder.gpbinder.unbind(this.cmd_back);
         GpBinder.gpbinder.unbind(this.cmd_resume);
         GpBinder.gpbinder.unbind(this.cmd_start);
         GpBinder.gpbinder.unbind(this.cmd_acv);
         GpBinder.gpbinder.unbind(this.cmd_lb);
         TweenMax.killDelayedCallsTo(this._placeIcons);
         this.gp_a.cleanup();
         this.gp_b.cleanup();
         this.gp_x.cleanup();
         this.gp_y.cleanup();
         this.gp_d_r.cleanup();
         if(this.acvNav)
         {
            this.acvNav.cleanup();
            this.acvNav = null;
         }
         if(this.diffNav)
         {
            this.diffNav.cleanup();
            this.diffNav = null;
         }
         GpBinder.gpbinder.removeLayer(this.layer);
         this.layer = 0;
         this.gui = null;
         this.context = null;
      }
      
      public function init(param1:GuiSagaSurvivalStart) : void
      {
         this.gui = param1;
         this.context = param1.context;
         this.updateAcvNav();
         this.updateDiffNav();
         param1.addChild(this.gp_a);
         param1.addChild(this.gp_b);
         param1.addChild(this.gp_x);
         param1.addChild(this.gp_y);
         param1.addChild(this.gp_d_r);
         this.gp_a.scale = this.gp_b.scale = this.gp_x.scale = this.gp_y.scale = this.gp_d_r.scale = 1.25;
         this._placeIcons();
         this.updateDifficulty();
      }
      
      private function _placeIcons() : void
      {
         GuiGp.placeIcon(this.gui._buttonClose,null,this.gp_b,GuiGpAlignH.E_RIGHT,GuiGpAlignV.C,-16,0);
         GuiGp.placeIcon(this.gui._button$ss_lb,null,this.gp_d_r,GuiGpAlignH.W_LEFT,GuiGpAlignV.C,0,0);
         GuiGp.placeIcon(this.gui._$ss_achievements,null,this.gp_y,GuiGpAlignH.W_RIGHT,GuiGpAlignV.C,0,0);
         GuiGp.placeIcon(this.gui._button$ss_resume,null,this.gp_x,GuiGpAlignH.E_RIGHT,GuiGpAlignV.C,0,0);
         GuiGp.placeIcon(this.gui._button$ss_start,null,this.gp_a,GuiGpAlignH.E_RIGHT,GuiGpAlignV.C,0,0);
         if(this.gui.isWelcoming)
         {
            GuiGp.placeIcon(this.gui._button$ss_continue,null,this.gp_a,GuiGpAlignH.E,GuiGpAlignV.C,0,0);
         }
      }
      
      public function get difficulty() : int
      {
         if(!this.context || !this.context.saga)
         {
            return 0;
         }
         return this.context.saga.difficulty;
      }
      
      public function updateDifficulty() : void
      {
         if(!this.gui)
         {
            return;
         }
         if(this.diffNav)
         {
            if(this.gui._button_diff$easy.toggled)
            {
               this.diffNav.setSelected(this.gui._button_diff$easy);
            }
            else if(this.gui._button_diff$hard.toggled)
            {
               this.diffNav.setSelected(this.gui._button_diff$hard);
            }
            else
            {
               this.diffNav.setSelected(this.gui._button_diff$normal);
            }
         }
      }
      
      public function updateAcvNav() : void
      {
         var _loc1_:MovieClip = null;
         this.acvNav = new GuiGpNav(this.context,"survival_start_acv",this.gui.parent);
         this.acvNav.setCallbackPress(this.acvNavPressHandler);
         this.acvNav.pressOnNavigate = true;
         this.acvNav.alwaysHintNav = true;
         for each(_loc1_ in this.gui.acv_placeholders)
         {
            this.acvNav.add(_loc1_);
         }
         this.acvNav.autoSelect();
      }
      
      private function acvNavPressHandler(param1:MovieClip, param2:Boolean) : void
      {
         this.gui.setHoverAcvPlaceholder(param1,true);
      }
      
      public function updateDiffNav() : void
      {
         this.diffNav = new GuiGpNav(this.context,"survival_start_diff",this.gui.parent);
         this.diffNav.orientation = GuiGpNav.ORIENTATION_VERTICAL;
         this.diffNav.pressOnNavigate = true;
         this.diffNav.setCallbackPress(function(param1:Object, param2:Boolean):void
         {
            if(!param2)
            {
               cmdfunc_start();
            }
         });
         this.diffNav.add(this.gui._button_diff$easy);
         this.diffNav.add(this.gui._button_diff$normal);
         this.diffNav.add(this.gui._button_diff$hard);
         this.diffNav.autoSelect();
         this.diffNav.activate();
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(Boolean(this.acvNav) && !param1)
         {
            this.acvNav.deactivate();
         }
         if(this.diffNav)
         {
            if(param1)
            {
               this.diffNav.activate();
            }
            else
            {
               this.diffNav.deactivate();
            }
         }
         if(!this.gui)
         {
            return;
         }
         GpBinder.gpbinder.removeLayer(this.layer);
         this.gp_d_r.visible = this.gp_x.visible = this.gp_y.visible = this.gp_a.visible = param1;
         if(param1)
         {
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_back);
            GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_acv);
            if(this.gui._button$ss_resume.visible)
            {
               GpBinder.gpbinder.bindPress(GpControlButton.X,this.cmd_resume);
            }
            else
            {
               GpBinder.gpbinder.unbind(this.cmd_resume);
               this.gp_x.visible = false;
            }
            if(this.gui._button$ss_lb.visible)
            {
               GpBinder.gpbinder.bindPress(GpControlButton.D_R,this.cmd_lb);
            }
            else
            {
               GpBinder.gpbinder.unbind(this.cmd_lb);
               this.gp_d_r.visible = false;
            }
            if(this.gui.isWelcoming)
            {
               this.layer = GpBinder.gpbinder.createLayer("survival_welcome");
               GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_welcome);
               GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_welcome);
               this.gp_a.gplayer = this.layer;
            }
            this._placeIcons();
            TweenMax.delayedCall(0,this._placeIcons);
         }
         else
         {
            GpBinder.gpbinder.unbind(this.cmd_welcome);
            GpBinder.gpbinder.unbind(this.cmd_back);
            GpBinder.gpbinder.unbind(this.cmd_start);
            GpBinder.gpbinder.unbind(this.cmd_resume);
            GpBinder.gpbinder.unbind(this.cmd_acv);
            GpBinder.gpbinder.unbind(this.cmd_lb);
         }
      }
      
      private function cmdfunc_welcome(param1:CmdExec) : void
      {
         this.gui.closeWelcoming();
      }
      
      public function handleWelcomeClosed() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_welcome);
         GpBinder.gpbinder.removeLayer(this.layer);
         this.layer = 0;
         this._placeIcons();
      }
      
      private function cmdfunc_back(param1:CmdExec) : void
      {
         this.deactivateAcv();
         this.gp_b.pulse();
         this.gui._buttonClose.press();
      }
      
      private function cmdfunc_resume(param1:CmdExec) : void
      {
         this.deactivateAcv();
         this.gp_x.pulse();
         this.gui._button$ss_resume.press();
      }
      
      private function cmdfunc_start(param1:CmdExec = null) : void
      {
         this.deactivateAcv();
         this.gp_a.pulse();
         this.gui._button$ss_start.press();
      }
      
      private function cmdfunc_acv(param1:CmdExec) : void
      {
         if(this.deactivateAcv())
         {
            return;
         }
         this.acvNav.activate();
         this.acvNav.autoSelect();
         var _loc2_:DisplayObjectContainer = this.acvNav.selected as DisplayObjectContainer;
         this.gui.setHoverAcvPlaceholder(_loc2_,true);
         this.gp_d_r.visible = this.gp_x.visible = this.gp_a.visible = false;
         this.context.logger.info("survival start gp acvNav ACTIVATE " + this.acvNav.isActivated);
         this.diffNav.deactivate();
      }
      
      private function deactivateAcv() : Boolean
      {
         if(this.acvNav.isActivated)
         {
            this.gp_y.pulse();
            this.gp_a.visible = true;
            this.gp_x.visible = this.gui._button$ss_resume.visible;
            this.gp_d_r.visible = this.gui._button$ss_lb.visible;
            this.acvNav.deactivate();
            this.gui.setHoverAcvPlaceholder(null,false);
            this.context.logger.info("survival start gp acvNav DEACTIVATE " + this.acvNav.isActivated);
            this.diffNav.activate();
            return true;
         }
         return false;
      }
      
      private function cmdfunc_lb(param1:CmdExec) : void
      {
         if(this.gui._leaderboards.visible)
         {
            return;
         }
         if(this.acvNav.isActivated)
         {
            return;
         }
         this.deactivateAcv();
         this.gp_d_r.pulse();
         this.gui._button$ss_lb.press();
      }
   }
}
