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
   
   public class GuiCartPicker_Gp
   {
       
      
      private var gplayer:int;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var cmd_a:Cmd;
      
      private var cmd_b:Cmd;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var cart_picker:GuiCartPicker;
      
      public function GuiCartPicker_Gp(param1:GuiCartPicker)
      {
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.cmd_a = new Cmd("cmd_cartpicker_a",this.cmdfunc_a);
         this.cmd_b = new Cmd("cmd_cartpicker_b",this.cmdfunc_b);
         this.cmd_l1 = new Cmd("cmd_cartpicker_l1",this.cmdfunc_l1);
         this.cmd_r1 = new Cmd("cmd_cartpicker_r1",this.cmdfunc_r1);
         super();
         this.cart_picker = param1;
         this.cart_picker.addChild(this.gp_a);
         this.cart_picker.addChild(this.gp_l1);
         this.cart_picker.addChild(this.gp_r1);
      }
      
      public function activate() : void
      {
         this.gplayer = GpBinder.gpbinder.createLayer("GuiCartPicker");
         this.gp_a.gplayer = this.gp_r1.gplayer = this.gp_l1.gplayer = this.gplayer;
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_a);
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
         this.gp_a.visible = true;
         this.gp_l1.visible = true;
         this.gp_r1.visible = true;
         this.cmd_a.global = true;
         this.cmd_b.global = true;
         GuiGp.placeIcon(this.cart_picker.button$confirm,null,this.gp_a,GuiGpAlignH.C,GuiGpAlignV.S_DOWN);
         GuiGp.placeIcon(this.cart_picker.button$left,null,this.gp_l1,GuiGpAlignH.C,GuiGpAlignV.S_DOWN);
         GuiGp.placeIcon(this.cart_picker.button$right,null,this.gp_r1,GuiGpAlignH.C,GuiGpAlignV.S_DOWN);
      }
      
      public function deactivate() : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         GpBinder.gpbinder.unbind(this.cmd_a);
         GpBinder.gpbinder.unbind(this.cmd_b);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         GpBinder.gpbinder.unbind(this.cmd_l1);
      }
      
      public function cleanup() : void
      {
         this.cmd_a.cleanup();
         this.cmd_b.cleanup();
         this.cmd_r1.cleanup();
         this.cmd_l1.cleanup();
         GuiGp.releasePrimaryBitmap(this.gp_a);
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
      }
      
      private function cmdfunc_a(param1:CmdExec) : void
      {
         this.gp_a.pulse();
         this.cart_picker.button$confirm.press();
      }
      
      private function cmdfunc_b(param1:CmdExec) : void
      {
         this.cart_picker.button$close.press();
      }
      
      private function cmdfunc_l1(param1:CmdExec) : void
      {
         this.gp_l1.pulse();
         this.cart_picker.button$left.press();
      }
      
      private function cmdfunc_r1(param1:CmdExec) : void
      {
         this.gp_r1.pulse();
         this.cart_picker.button$right.press();
      }
   }
}
