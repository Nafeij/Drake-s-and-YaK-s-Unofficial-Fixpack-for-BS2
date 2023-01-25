package game.gui.battle
{
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGpNav;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   
   public class GuiOptionsGp extends GuiBase implements IGuiOptionsGp
   {
       
      
      private var _text_gp_name:TextField;
      
      private var _button$options_gp_invert_left:ButtonWithIndex;
      
      private var _button$options_gp_invert_right:ButtonWithIndex;
      
      private var _button$options_gp_sens_low:ButtonWithIndex;
      
      private var _button$options_gp_sens_med:ButtonWithIndex;
      
      private var _button$options_gp_sens_hi:ButtonWithIndex;
      
      private var _button$options_gp_rebind:ButtonWithIndex;
      
      private var _buttonClose:ButtonWithIndex;
      
      private var _text$options_gp_stick_sensitivity:TextField;
      
      private var _holder:MovieClip;
      
      public var nav:GuiGpNav;
      
      private var listener:IGuiOptionsGpListener;
      
      public function GuiOptionsGp()
      {
         super();
         super.visible = false;
      }
      
      public function init(param1:IGuiContext, param2:IGuiOptionsGpListener) : void
      {
         initGuiBase(param1);
         this.listener = param2;
         this.nav = new GuiGpNav(param1,"optgp",this);
         this._holder = requireGuiChild("holder") as MovieClip;
         this._text_gp_name = requireGuiChild("text_gp_name") as TextField;
         this._button$options_gp_invert_left = requireGuiChild("button$options_gp_invert_left",this._holder) as ButtonWithIndex;
         this._button$options_gp_invert_right = requireGuiChild("button$options_gp_invert_right",this._holder) as ButtonWithIndex;
         this._button$options_gp_sens_low = requireGuiChild("button$options_gp_sens_low",this._holder) as ButtonWithIndex;
         this._button$options_gp_sens_med = requireGuiChild("button$options_gp_sens_med",this._holder) as ButtonWithIndex;
         this._button$options_gp_sens_hi = requireGuiChild("button$options_gp_sens_hi",this._holder) as ButtonWithIndex;
         this._button$options_gp_rebind = requireGuiChild("button$options_gp_rebind",this._holder) as ButtonWithIndex;
         this._buttonClose = requireGuiChild("buttonClose") as ButtonWithIndex;
         this._text$options_gp_stick_sensitivity = requireGuiChild("text$options_gp_stick_sensitivity",this._holder) as TextField;
         this._button$options_gp_invert_left.guiButtonContext = param1;
         this._button$options_gp_invert_right.guiButtonContext = param1;
         this._button$options_gp_sens_low.guiButtonContext = param1;
         this._button$options_gp_sens_med.guiButtonContext = param1;
         this._button$options_gp_sens_hi.guiButtonContext = param1;
         this._button$options_gp_rebind.guiButtonContext = param1;
         this._buttonClose.guiButtonContext = param1;
         this._button$options_gp_invert_left.isToggle = true;
         this._button$options_gp_invert_right.isToggle = true;
         this._button$options_gp_sens_low.isToggle = true;
         this._button$options_gp_sens_med.isToggle = true;
         this._button$options_gp_sens_hi.isToggle = true;
         this._button$options_gp_sens_med.canToggleUp = false;
         this._button$options_gp_sens_hi.canToggleUp = false;
         this._button$options_gp_sens_low.canToggleUp = false;
         this._button$options_gp_invert_left.setDownFunction(this.buttonInvertHandler);
         this._button$options_gp_invert_right.setDownFunction(this.buttonInvertHandler);
         this._button$options_gp_sens_low.setDownFunction(this.buttonSensitivityHandler);
         this._button$options_gp_sens_med.setDownFunction(this.buttonSensitivityHandler);
         this._button$options_gp_sens_hi.setDownFunction(this.buttonSensitivityHandler);
         this._button$options_gp_rebind.setDownFunction(this.buttonRebindHandler);
         this._buttonClose.setDownFunction(this.buttonCloseHandler);
         this.nav.add(this._button$options_gp_invert_left);
         this.nav.add(this._button$options_gp_invert_right);
         this.nav.add(this._button$options_gp_sens_low);
         this.nav.add(this._button$options_gp_sens_med);
         this.nav.add(this._button$options_gp_sens_hi);
         this.nav.add(this._button$options_gp_rebind);
         this.nav.autoSelect();
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this.localeHandler(null);
         registerScalableTextfield(this._text$options_gp_stick_sensitivity,false);
         scaleTextfields();
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
      }
      
      private function localeHandler(param1:Event) : void
      {
         scaleTextfields();
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.updateGui();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         this.updateGui();
      }
      
      private function updateGui() : void
      {
         var _loc1_:String = null;
         if(!super.visible)
         {
            this.nav.deactivate();
            return;
         }
         this._button$options_gp_invert_left.toggled = GpSource.invertLeftStick;
         this._button$options_gp_invert_right.toggled = GpSource.invertRightStick;
         this._button$options_gp_sens_low.toggled = GpSource.stickSensitivity < GpSource.STICK_SENSITIVITY_MEDIUM;
         this._button$options_gp_sens_med.toggled = GpSource.stickSensitivity == GpSource.STICK_SENSITIVITY_MEDIUM;
         this._button$options_gp_sens_hi.toggled = GpSource.stickSensitivity > GpSource.STICK_SENSITIVITY_MEDIUM;
         var _loc2_:GpDevice = GpSource.primaryDevice;
         if(_loc2_)
         {
            this.nav.activate();
            _loc1_ = _loc2_.desc;
         }
         else
         {
            this.nav.deactivate();
            _loc1_ = String(context.translate("options_gp_name_none"));
         }
         this._holder.visible = _loc2_ != null;
         this._text_gp_name.htmlText = _loc1_;
         scaleTextfields();
      }
      
      private function buttonInvertHandler(param1:ButtonWithIndex) : void
      {
         if(param1 == this._button$options_gp_invert_left)
         {
            GpSource.invertLeftStick = param1.toggled;
         }
         else if(param1 == this._button$options_gp_invert_right)
         {
            GpSource.invertRightStick = param1.toggled;
         }
      }
      
      private function buttonSensitivityHandler(param1:ButtonWithIndex) : void
      {
         this._button$options_gp_sens_med.toggled = this._button$options_gp_sens_med == param1;
         this._button$options_gp_sens_hi.toggled = this._button$options_gp_sens_hi == param1;
         this._button$options_gp_sens_low.toggled = this._button$options_gp_sens_low == param1;
         if(param1 == this._button$options_gp_sens_med)
         {
            GpSource.stickSensitivity = GpSource.STICK_SENSITIVITY_MEDIUM;
         }
         else if(param1 == this._button$options_gp_sens_hi)
         {
            GpSource.stickSensitivity = GpSource.STICK_SENSITIVITY_HIGH;
         }
         else if(param1 == this._button$options_gp_sens_low)
         {
            GpSource.stickSensitivity = GpSource.STICK_SENSITIVITY_LOW;
         }
      }
      
      private function buttonRebindHandler(param1:ButtonWithIndex) : void
      {
         var _loc2_:IGuiDialog = context.createDialog();
         var _loc3_:String = String(context.translate("ok"));
         var _loc4_:String = String(context.translate("cancel"));
         var _loc5_:String = String(context.translate("options_gp_rebind_title"));
         var _loc6_:String = String(context.translate("options_gp_rebind_body"));
         _loc2_.openTwoBtnDialog(_loc5_,_loc6_,_loc3_,_loc4_,this.dialogConfirmHandler);
      }
      
      private function dialogConfirmHandler(param1:String) : void
      {
         var _loc2_:String = String(context.translate("ok"));
         if(param1 == _loc2_)
         {
            this.listener.guiOptionsGpRebind();
         }
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsGpClose();
      }
      
      public function closeOptionsGp() : Boolean
      {
         if(this.visible)
         {
            this.visible = false;
            return true;
         }
         return false;
      }
   }
}
