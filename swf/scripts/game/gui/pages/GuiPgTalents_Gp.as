package game.gui.pages
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpNav;
   import flash.display.DisplayObject;
   import game.gui.IGuiContext;
   
   public class GuiPgTalents_Gp
   {
       
      
      private var talents:GuiPgTalents;
      
      private var context:IGuiContext;
      
      private var cmd_cancel:Cmd;
      
      private var nav:GuiGpNav;
      
      private var gplayer:int;
      
      public function GuiPgTalents_Gp()
      {
         this.cmd_cancel = new Cmd("pg_talents_cancel",this.cmdfunc_cancel);
         super();
      }
      
      public function init(param1:GuiPgTalents) : void
      {
         this.talents = param1;
         this.context = param1.context;
         this.nav = new GuiGpNav(this.context,"pgtal",param1);
         this.nav.setCallbackPress(this.navControlPressHandler);
         this.nav.scale = 1.5;
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S);
         this.nav.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N);
         this.nav.add(param1._button$close);
         this.nav.add(param1._button_left);
         this.nav.add(param1._button_right);
         this.nav.add(param1._button_minus);
         this.nav.add(param1._button_plus);
      }
      
      public function cleanup() : void
      {
         this.cmd_cancel.cleanup();
         this.cmd_cancel = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.talents = null;
         this.context = null;
      }
      
      public function handleActivateTalents() : void
      {
         if(this.gplayer)
         {
            GpBinder.gpbinder.removeLayer(this.gplayer);
         }
         this.gplayer = GpBinder.gpbinder.createLayer("GuiPgTalents_Gp");
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_cancel);
         this.nav.activate();
         this.nav.autoSelect();
      }
      
      public function handleDeactivateTalents() : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         GpBinder.gpbinder.unbind(this.cmd_cancel);
         this.nav.deactivate();
      }
      
      private function navControlPressHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         if(param1 == this.talents._button$close)
         {
            this.talents._button$close.press();
         }
         else if(param1 == this.talents._button_left)
         {
            this.talents._button_left.press();
         }
         else if(param1 == this.talents._button_right)
         {
            this.talents._button_right.press();
         }
         else if(param1 == this.talents._button_minus)
         {
            this.talents._button_minus.press();
            this.nav.autoSelect();
         }
         else if(param1 == this.talents._button_plus)
         {
            this.talents._button_plus.press();
            this.nav.autoSelect();
         }
         return true;
      }
      
      public function cmdfunc_cancel(param1:CmdExec) : void
      {
         this.talents._button$close.press();
      }
   }
}
