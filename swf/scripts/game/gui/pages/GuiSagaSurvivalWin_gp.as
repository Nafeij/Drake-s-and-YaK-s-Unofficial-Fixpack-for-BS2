package game.gui.pages
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.gui.GuiGpNavButtonGlowy;
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public class GuiSagaSurvivalWin_gp
   {
       
      
      private var gui:GuiSagaSurvivalWin;
      
      private var context:IGuiContext;
      
      private var nav:GuiGpNav;
      
      private var layer:int;
      
      private var cmd_close:Cmd;
      
      private var cmd_denav:Cmd;
      
      private var _readyToNav:Boolean;
      
      private var gp_dpad:GuiGpBitmap;
      
      private var gp_a:GuiGpBitmap;
      
      public function GuiSagaSurvivalWin_gp()
      {
         this.cmd_close = new Cmd("cmd_survival_win_gp_close",this.cmdfunc_close);
         this.cmd_denav = new Cmd("cmd_survival_win_gp_denav",this.cmdfunc_denav);
         this.gp_dpad = GuiGp.ctorPrimaryBitmap(GpControlButton.DPAD,true);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         super();
      }
      
      public function get readyToNav() : Boolean
      {
         return this._readyToNav;
      }
      
      public function set readyToNav(param1:Boolean) : void
      {
         this._readyToNav = param1;
         this.updateNav();
      }
      
      public function cleanup() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_close);
         GpBinder.gpbinder.unbind(this.cmd_denav);
         this.gp_dpad.cleanup();
         this.gp_a.cleanup();
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         GpBinder.gpbinder.removeLayer(this.layer);
         this.layer = 0;
         this.gui = null;
         this.context = null;
      }
      
      public function init(param1:GuiSagaSurvivalWin) : void
      {
         this.gui = param1;
         this.context = param1.context;
         this.updateNav();
         param1.addChild(this.gp_a);
         this.gp_a.visible = false;
         GuiGp.placeIcon(param1._button$close,null,this.gp_a,GuiGpAlignH.E_RIGHT,GuiGpAlignV.C,0,0);
         param1.addChild(this.gp_dpad);
         this.gp_dpad.visible = false;
      }
      
      public function showClose() : void
      {
         this.gp_a.visible = true;
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(Boolean(this.nav) && !param1)
         {
            this.nav.deactivate();
         }
         if(!this.gui)
         {
            return;
         }
         GpBinder.gpbinder.removeLayer(this.layer);
         if(param1)
         {
            this.layer = GpBinder.gpbinder.createLayer("win");
            this.gp_a.gplayer = this.layer;
            if(this.nav)
            {
               this.nav.activate();
            }
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_close);
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_denav);
         }
         else
         {
            GpBinder.gpbinder.unbind(this.cmd_denav);
            GpBinder.gpbinder.unbind(this.cmd_close);
         }
      }
      
      private function cmdfunc_close(param1:CmdExec) : void
      {
         if(this.gui.speedThroughResults())
         {
            return;
         }
         this.gui._button$close.press();
      }
      
      private function cmdfunc_denav(param1:CmdExec) : void
      {
         var _loc2_:MovieClip = null;
         if(this.gui.speedThroughResults())
         {
            return;
         }
         if(!this.nav)
         {
            return;
         }
         _loc2_ = this.nav.selected as MovieClip;
         if(!_loc2_)
         {
            return;
         }
         this.gp_a.visible = true;
         this.gp_dpad.visible = true;
         this.nav.selected = null;
         var _loc3_:GuiGpNavButtonGlowy = _loc2_ as GuiGpNavButtonGlowy;
         if(_loc3_)
         {
            this.gui.unhoverRibbon();
         }
         else
         {
            this.gui._acv.setHoverAcvPlaceholder(null,false);
         }
      }
      
      public function updateNav() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:GuiSagaSurvivalWin_Trio = null;
         if(this.nav)
         {
            this.nav.cleanup();
         }
         if(!this._readyToNav)
         {
            return;
         }
         this.nav = new GuiGpNav(this.context,"survival_win",this.gui.parent);
         this.nav.setCallbackPress(this.navPressHandler);
         this.nav.pressOnNavigate = true;
         this.nav.alwaysHintNav = true;
         for each(_loc1_ in this.gui._acv.acv_placeholders)
         {
            if(_loc1_.visible)
            {
               this.nav.add(_loc1_);
            }
         }
         for each(_loc2_ in this.gui._trioList)
         {
            this.nav.add(_loc2_.ribbon);
         }
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.nav.activate();
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_close);
         this.placeFakeGpNavIcon();
      }
      
      private function placeFakeGpNavIcon() : void
      {
         this.gp_dpad.visible = true;
         if(this.gui._acv.acv_icons.length)
         {
            GuiGp.placeIcon(this.gui._$ss_win_acv,null,this.gp_dpad,GuiGpAlignH.E_RIGHT,GuiGpAlignV.C_DOWN,0,0);
         }
         else
         {
            GuiGp.placeIcon(this.gui._$ss_win_acv,null,this.gp_dpad,GuiGpAlignH.E_RIGHT,GuiGpAlignV.C_DOWN,0,0);
         }
      }
      
      private function navPressHandler(param1:MovieClip, param2:Boolean) : void
      {
         this.context.logger.info("nav press " + param1);
         this.gp_dpad.visible = false;
         this.gp_a.visible = false;
         var _loc3_:GuiGpNavButtonGlowy = param1 as GuiGpNavButtonGlowy;
         if(_loc3_)
         {
            this.gui._acv.setHoverAcvPlaceholder(null,false);
         }
         else
         {
            this.gui._acv.setHoverAcvPlaceholder(param1,true);
         }
      }
   }
}
