package game.gui.pages
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpTextHelper;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiBitmapHolderHelper;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.IGuiGpConfig;
   
   public class GuiGpConfig extends GuiBase implements IGuiGpConfig
   {
      
      public static var mcClazz_state:Class;
       
      
      public var _button_close:ButtonWithIndex;
      
      public var _button$confirm:ButtonWithIndex;
      
      public var _button$cancel:ButtonWithIndex;
      
      public var _button$gp_cfg_reset:ButtonWithIndex;
      
      public var _text_error:TextField;
      
      public var _divider:MovieClip;
      
      public var cursor:int = -1;
      
      private var bmpholderHelper:GuiBitmapHolderHelper;
      
      private var guiGpErrorTextHelper:GuiGpTextHelper;
      
      public var states:Vector.<GuiGpConfig_State>;
      
      private var configState:GuiGpConfig_State;
      
      public var device:GpDevice;
      
      private var gplayer:int;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_y:GuiGpBitmap;
      
      private var _gp_chooser:MovieClip;
      
      private var gp_dpad_left_right:GuiGpBitmap;
      
      private var gp_dpad_up:GuiGpBitmap;
      
      private var originalVisualCategory:String;
      
      private var _visualSelectionMode:Boolean;
      
      private var _visualSelectionTypes:Array;
      
      private var _visualSelectionIcons:Array;
      
      private var _visualSelectionButtons:Array;
      
      private var _visualDpadIndex:int = -1;
      
      private var _visualButtonFilters:Array;
      
      private var _nullFilters:Array;
      
      private var _complete:Boolean;
      
      private var _nextStaging:Boolean;
      
      private var _readyForNextStage:Boolean;
      
      private var dialog:IGuiDialog;
      
      private var _gracePeriodFrameStart:int;
      
      private var _gracePeriodTimeStartMs:int;
      
      private var GRACE_PERIOD_FRAME_LENGTH:int = 2;
      
      private var GRACE_PERIOD_TIME_LENGTH_MS:int = 200;
      
      private var _gracePeriodActive:Boolean = true;
      
      private var _waitingForNextStage:Boolean;
      
      private var _waitsForZeroCount:int;
      
      private var _waitsForZero:Dictionary;
      
      public function GuiGpConfig()
      {
         this.states = new Vector.<GuiGpConfig_State>();
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B,true);
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         this.gp_dpad_left_right = GuiGp.ctorPrimaryBitmap(GpControlButton.D_LR,true);
         this.gp_dpad_up = GuiGp.ctorPrimaryBitmap(GpControlButton.D_U,true);
         this._visualSelectionTypes = ["ps4","ps3","xbo","x360","switch"];
         this._visualSelectionButtons = [];
         this._visualButtonFilters = [new GlowFilter(16777215,1,8,8,2,2)];
         this._nullFilters = [];
         this._waitsForZero = new Dictionary();
         super();
         super.visible = false;
         this.gp_a.visible = this.gp_b.visible = this.gp_y.visible = false;
         this.gp_a.scale = this.gp_b.scale = this.gp_y.scale = 1.5;
         this.gp_dpad_left_right.scale = this.gp_dpad_up.scale = 1.5;
         addChild(this.gp_a);
         addChild(this.gp_b);
         addChild(this.gp_y);
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this._button$confirm = getChildByName("button$confirm") as ButtonWithIndex;
         this._button$cancel = getChildByName("button$cancel") as ButtonWithIndex;
         this._button$gp_cfg_reset = getChildByName("button$gp_cfg_reset") as ButtonWithIndex;
         this._button_close = getChildByName("button_close") as ButtonWithIndex;
         this._gp_chooser = getChildByName("gp_chooser") as MovieClip;
         this._gp_chooser.visible = false;
         this._button$confirm.visible = false;
         this._button$cancel.visible = false;
         this._button$gp_cfg_reset.visible = false;
         this._gp_chooser.addChild(this.gp_dpad_left_right);
         this._gp_chooser.addChild(this.gp_dpad_up);
         this._text_error = getChildByName("error_text") as TextField;
         this._divider = getChildByName("divider") as MovieClip;
         this.showError(null,null);
         this._button$confirm.guiButtonContext = param1;
         this._button$cancel.guiButtonContext = param1;
         this._button$gp_cfg_reset.guiButtonContext = param1;
         this._button_close.guiButtonContext = param1;
         this._button$confirm.setDownFunction(this.buttonConfirmHandler);
         this._button$cancel.setDownFunction(this.buttonCancelHandler);
         this._button$gp_cfg_reset.setDownFunction(this.buttonResetHandler);
         this._button_close.setDownFunction(this.buttonCloseHandler);
      }
      
      public function tearup() : void
      {
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_dpad",null,GpControlButton.DPAD).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_dpad_up",GpControlButton.D_U).setCanAxisButton(null)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_dpad_down",GpControlButton.D_D).setCanAxisButton(GpControlButton.D_U)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_dpad_left",GpControlButton.D_L).setCanAxisButton(null)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_dpad_right",GpControlButton.D_R).setCanAxisButton(GpControlButton.D_L)).setCompletionCallback(this.dpadCompleteHandler));
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_cluster",null,GpControlButton.BUTTON_CLUSTER).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_cluster_bottom",GpControlButton.A)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_cluster_right",GpControlButton.B)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_cluster_left",GpControlButton.X)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_cluster_top",GpControlButton.Y)).setCompletionCallback(this.clusterCompleteHandler));
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_vlstick",GpControlButton.LSTICK).setKeyboardOnly(true));
         var _loc1_:GuiGpConfig_State = GuiGpConfig_State.ctor(this,"gp_cfg_state_lstick",null,GpControlButton.LSTICK).setKeyboardOmit(true).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_lstick_left",GpControlButton.AXIS_LEFT_H,GpControlButton.LSTICK_LEFT).setAxis(-1)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_lstick_right",GpControlButton.AXIS_LEFT_H,GpControlButton.LSTICK_RIGHT).setAxis(1)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_lstick_up",GpControlButton.AXIS_LEFT_V,GpControlButton.LSTICK_UP).setAxis(-1)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_lstick_down",GpControlButton.AXIS_LEFT_V,GpControlButton.LSTICK_DOWN).setAxis(1));
         if(GpControlButton.HAS_STICK_BUTTONS)
         {
            _loc1_.addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_l3",GpControlButton.L3).setOptional(true));
         }
         this.states.push(_loc1_);
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_vrstick",GpControlButton.RSTICK).setKeyboardOnly(true));
         var _loc2_:GuiGpConfig_State = GuiGpConfig_State.ctor(this,"gp_cfg_state_rstick",null,GpControlButton.RSTICK).setKeyboardOmit(true).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_rstick_left",GpControlButton.AXIS_RIGHT_H,GpControlButton.RSTICK_LEFT).setAxis(-1)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_rstick_right",GpControlButton.AXIS_RIGHT_H,GpControlButton.RSTICK_RIGHT).setAxis(1)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_rstick_up",GpControlButton.AXIS_RIGHT_V,GpControlButton.RSTICK_UP).setAxis(-1)).addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_rstick_down",GpControlButton.AXIS_RIGHT_V,GpControlButton.RSTICK_DOWN).setAxis(1));
         if(GpControlButton.HAS_STICK_BUTTONS)
         {
            _loc2_.addChildStage(GuiGpConfig_State.ctor(this,"gp_cfg_state_r3",GpControlButton.R3).setOptional(true));
         }
         this.states.push(_loc2_);
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_l1",GpControlButton.L1));
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_r1",GpControlButton.R1));
         if(GpControlButton.REPLACE_MENU_BUTTON == GpControlButton.MENU)
         {
            this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_menu",GpControlButton.MENU));
         }
         this.states.push(GuiGpConfig_State.ctor(this,"gp_cfg_state_start",GpControlButton.START));
      }
      
      public function teardown() : void
      {
         var _loc1_:GuiGpConfig_State = null;
         for each(_loc1_ in this.states)
         {
            _loc1_.cleanup();
         }
         this.states.splice(0,this.states.length);
      }
      
      private function localeChangedHandler(param1:GuiContextEvent) : void
      {
         var _loc3_:GuiGpConfig_State = null;
         var _loc2_:String = !!this.device ? this.device.type.visualCategory : null;
         for each(_loc3_ in this.states)
         {
            _loc3_.updateLocalization(_loc2_);
         }
         this.updateGui();
      }
      
      private function cacheVisualSelectionIcons() : void
      {
         var _loc2_:String = null;
         var _loc3_:GuiGpBitmap = null;
         if(this._visualSelectionIcons)
         {
            return;
         }
         this._visualSelectionIcons = [];
         var _loc1_:int = 0;
         while(_loc1_ < this._visualSelectionTypes.length)
         {
            _loc2_ = String(this._visualSelectionTypes[_loc1_]);
            _loc3_ = GuiGp.ctorBitmapForVisualCategory(_loc2_,GpControlButton.BUTTON_CLUSTER);
            _loc3_.alwaysHint = true;
            _loc3_.scale = 1.5;
            this._visualSelectionIcons.push(_loc3_);
            _loc1_++;
         }
      }
      
      private function confirmVisualDpadIndex() : void
      {
         if(!this._visualSelectionMode)
         {
            return;
         }
         this._visualSelectionMode = false;
         this._gp_chooser.visible = false;
         this.localeChangedHandler(null);
         this._waitingForNextStage = true;
         this.startGracePeriod();
         this.updateGui();
      }
      
      public function dpadCompleteHandler() : void
      {
         var _loc2_:String = null;
         var _loc3_:MovieClip = null;
         var _loc4_:TextField = null;
         var _loc5_:GuiGpBitmap = null;
         this.cacheVisualSelectionIcons();
         this._visualSelectionMode = true;
         this._gp_chooser.visible = true;
         this.gp_dpad_left_right.gplayer = this.gplayer;
         this.gp_dpad_up.gplayer = this.gplayer;
         var _loc1_:int = 0;
         while(_loc1_ < this._visualSelectionTypes.length)
         {
            _loc2_ = String(this._visualSelectionTypes[_loc1_]);
            _loc3_ = this._gp_chooser.getChildByName("gp_icon" + _loc1_.toString()) as MovieClip;
            if(_loc3_)
            {
               _loc4_ = _loc3_.getChildByName("text") as TextField;
               if(_loc4_)
               {
                  _loc4_.htmlText = context.translateCategory("vis_" + _loc2_,LocaleCategory.GP);
                  _loc5_ = this._visualSelectionIcons[_loc1_];
                  if(!_loc5_.parent)
                  {
                     _loc3_.addChild(_loc5_);
                     _loc5_.x = -_loc5_.width / 2;
                  }
                  _loc5_.gplayer = this.gplayer;
                  _loc5_.visible = true;
                  if(this._visualSelectionButtons.length < this._visualSelectionTypes.length)
                  {
                     this._visualSelectionButtons.push(_loc3_);
                  }
               }
            }
            _loc1_++;
         }
         this.selectVisualDpadIndex(0,false);
      }
      
      private function selectVisualDpadIndex(param1:int, param2:Boolean) : Boolean
      {
         var _loc4_:MovieClip = null;
         var _loc5_:String = null;
         param1 = Math.max(0,Math.min(this._visualSelectionButtons.length - 1,param1));
         if(param1 == this._visualDpadIndex)
         {
            if(param2)
            {
               context.playSound("ui_error");
            }
            return false;
         }
         this._visualDpadIndex = param1;
         var _loc3_:int = 0;
         while(_loc3_ < this._visualSelectionButtons.length)
         {
            _loc4_ = this._visualSelectionButtons[_loc3_];
            if(_loc3_ == this._visualDpadIndex)
            {
               if(!_loc4_.filters || _loc4_.filters.length == 0)
               {
                  _loc4_.filters = this._visualButtonFilters;
               }
               this.gp_dpad_left_right.x = _loc4_.x - this.gp_dpad_left_right.width;
               this.gp_dpad_left_right.y = _loc4_.y + 210;
               this.gp_dpad_up.x = _loc4_.x;
               this.gp_dpad_up.y = _loc4_.y + 210;
               this.gp_dpad_left_right.createCaption(context,GuiGpBitmap.CAPTION_LEFT).setToken("cfg_change_selection");
               this.gp_dpad_up.createCaption(context,GuiGpBitmap.CAPTION_RIGHT).setToken("cfg_confirm");
               this.gp_dpad_left_right.updateCaptionPlacement();
               this.gp_dpad_up.updateCaptionPlacement();
               _loc5_ = String(this._visualSelectionTypes[_loc3_]);
               this.device.type.visualCategory = _loc5_;
               GuiGp.handlePrimaryDeviceChanged();
            }
            else if(Boolean(_loc4_.filters) && _loc4_.filters.length > 0)
            {
               _loc4_.filters = this._nullFilters;
            }
            _loc3_++;
         }
         if(param2)
         {
            context.playSound("ui_generic");
         }
         return true;
      }
      
      public function clusterCompleteHandler() : void
      {
         GuiGp.placeIconLeft(this._button$cancel,this.gp_b);
         GuiGp.placeIconLeft(this._button$gp_cfg_reset,this.gp_y);
         this._button$cancel.visible = true;
         this._button$gp_cfg_reset.visible = true;
         this.gp_a.gplayer = this.gp_b.gplayer = this.gp_y.gplayer = this.gplayer;
         this.gp_y.visible = true;
         this.gp_b.visible = true;
      }
      
      public function cleanup() : void
      {
         context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this._button_close.cleanup();
         this._button$cancel.cleanup();
         this._button$gp_cfg_reset.cleanup();
         this._button$confirm.cleanup();
         this.visible = false;
      }
      
      public function readyForNextStage() : void
      {
         this._waitingForNextStage = false;
         this.updateGui();
         this._readyForNextStage = true;
      }
      
      public function nextStage() : void
      {
         if(this._nextStaging)
         {
            return;
         }
         if(this._visualSelectionMode)
         {
            return;
         }
         this._readyForNextStage = false;
         this._nextStaging = true;
         if(this.configState)
         {
            this.configState.next();
            if(!this.configState.complete)
            {
               this._nextStaging = false;
               this.updateGui();
               return;
            }
         }
         if(this._visualSelectionMode)
         {
            this._nextStaging = false;
            this.updateGui();
            return;
         }
         while(this.cursor < this.states.length)
         {
            ++this.cursor;
            if(this.cursor >= this.states.length)
            {
               this.configState = null;
               this.complete = true;
               break;
            }
            this.configState = this.states[this.cursor];
            if(this.configState.keyboardOmit && this.device.type.isKeyboard || this.configState.keyboardOnly && !this.device.type.isKeyboard)
            {
               this.configState.ignore();
            }
            else
            {
               this.configState.start();
            }
            if(!this.configState.complete)
            {
               break;
            }
            if(this._visualSelectionMode)
            {
               break;
            }
         }
         this._nextStaging = false;
         this.updateGui();
      }
      
      private function updateGui() : void
      {
         var _loc7_:GuiGpConfig_State = null;
         var _loc1_:int = 2;
         var _loc2_:int = -440;
         var _loc3_:int = -900;
         var _loc4_:int = -840;
         var _loc5_:int = -740;
         this._divider.visible = !this.complete;
         this.showError(null,null);
         var _loc6_:int = 0;
         while(_loc6_ <= this.cursor && _loc6_ < this.states.length)
         {
            _loc7_ = this.states[_loc6_];
            if(this.cursor == _loc6_)
            {
               this._divider.x = _loc4_;
               this._divider.y = _loc2_;
               _loc2_ += 50;
            }
            _loc7_.updateGui(this.device.type.visualCategory);
            if(_loc7_.visible)
            {
               _loc7_.y = _loc2_;
               _loc7_.x = _loc3_;
               _loc2_ += _loc7_.height;
               _loc2_ += _loc1_;
            }
            _loc6_++;
         }
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         context.logger.info("**GpConfig INIT** GuiGpConfig.buttonCloseHandler");
         this.resetConfig("close button");
         if(this.device)
         {
            this.device.type.uncacheMapping();
            this.device.type.visualCategory = this.originalVisualCategory;
            GuiGp.handlePrimaryDeviceChanged();
            this.device = null;
         }
         this.visible = false;
         if(Boolean(GpSource.primaryDevice) && GpSource.primaryDevice.type.unknown)
         {
            if(!PlatformInput.isGp)
            {
               GpSource.primaryDevice = null;
            }
         }
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function buttonConfirmHandler(param1:ButtonWithIndex) : void
      {
         context.logger.info("**GpConfig INIT** GuiGpConfig.buttonConfirmHandler");
         this.device.type.unknown = false;
         this.device.type.userCfg = true;
         dispatchEvent(new Event(Event.COMPLETE));
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function buttonCancelHandler(param1:ButtonWithIndex) : void
      {
         context.logger.info("**GpConfig INIT** GuiGpConfig.buttonCancelHandler");
         this.buttonCloseHandler(param1);
      }
      
      private function buttonResetHandler(param1:ButtonWithIndex) : void
      {
         context.logger.info("**GpConfig INIT** GuiGpConfig.buttonResetHandler");
         this.resetConfig("reset button");
         this.device.type.resetMapping();
         this.device.type.visualCategory = this.originalVisualCategory;
         GuiGp.handlePrimaryDeviceChanged();
         this.readyForNextStage();
      }
      
      private function setDevice(param1:GpDevice) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:GpDevice = this.device;
         if(this.device == param1 && Boolean(param1))
         {
            return;
         }
         this.device = param1;
         this.resetConfig("changed device to [" + param1 + "]");
         if(this.dialog)
         {
            this.dialog.closeDialog(null);
         }
         var _loc5_:String = String(context.translate("ok"));
         if(param1)
         {
            param1.type.cacheMapping();
            this.originalVisualCategory = param1.type.visualCategory;
            GpDevice.allwatcher = this.gpDeviceInputHandler;
            if(param1.type.unknown)
            {
               _loc3_ = String(context.translateCategory("cfg_dialog_unknown_body",LocaleCategory.GP));
               _loc3_ = _loc3_.replace("$DESC",param1.desc);
               _loc4_ = String(context.translateCategory("cfg_dialog_unknown_title",LocaleCategory.GP));
               this.dialog = context.createDialog();
               this.dialog.openDialog(_loc4_,_loc3_,null,this.dialogCloseHandler);
               this.dialog.setCloseButtonVisible(true);
            }
            else if(_loc2_)
            {
               _loc3_ = String(context.translateCategory("cfg_dialog_changed_body",LocaleCategory.GP));
               _loc3_ = _loc3_.replace("$DESC",param1.desc);
               _loc4_ = String(context.translateCategory("cfg_dialog_changed_title",LocaleCategory.GP));
               this.dialog = context.createDialog();
               this.dialog.openDialog(_loc4_,_loc3_,null,this.dialogCloseHandler);
               this.dialog.setCloseButtonVisible(true);
            }
            else
            {
               this.dialogCloseHandler(null);
            }
            this.localeChangedHandler(null);
            return;
         }
         GpDevice.allwatcher = null;
         param1 = null;
         this.dialog = context.createDialog();
         _loc4_ = String(context.translateCategory("cfg_dialog_no_gamepad_title",LocaleCategory.GP));
         _loc3_ = String(context.translateCategory("cfg_dialog_no_gamepad_body",LocaleCategory.GP));
         this.dialog.openDialog(_loc4_,_loc3_,_loc5_,this.dialogCloseHandler);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            this.tearup();
            GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
            this.gplayer = GpBinder.gpbinder.createLayer("GuiGpConfig");
            this.bmpholderHelper = new GuiBitmapHolderHelper(context.resourceManager,null);
            this.bmpholderHelper.loadGuiBitmaps(this);
            this._divider.visible = false;
            context.addEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
            this.primaryDeviceHandler(null);
            this.localeChangedHandler(null);
         }
         else
         {
            this.teardown();
            this.device = null;
            if(context)
            {
               context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
            }
            GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
            GpBinder.gpbinder.removeLayer(this.gplayer);
            this.gplayer = 0;
            GpDevice.allwatcher = null;
            if(this.bmpholderHelper)
            {
               this.bmpholderHelper.cleanup();
               this.bmpholderHelper = null;
            }
         }
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.setDevice(GpSource.primaryDevice);
      }
      
      private function dialogCloseHandler(param1:String) : void
      {
         this.dialog = null;
         if(Boolean(this.device) && !param1)
         {
            this.device.type.resetMapping();
            this.resetConfig("dialog closed");
            this.readyForNextStage();
         }
         else
         {
            this.buttonCloseHandler(null);
         }
      }
      
      private function resetConfig(param1:String) : void
      {
         var _loc2_:GuiGpConfig_State = null;
         if(Boolean(context) && Boolean(context.logger))
         {
            context.logger.info("**GpConfig INIT** GuiGpConfig.resetConfig [" + param1 + "]");
         }
         for each(_loc2_ in this.states)
         {
            _loc2_.resetConfigStage();
         }
         this._waitsForZero = new Dictionary();
         this._waitsForZeroCount = 0;
         this.showError(null,null);
         this._divider.visible = false;
         this._button$confirm.visible = false;
         this._button$cancel.visible = false;
         this._button$gp_cfg_reset.visible = false;
         this.gp_a.visible = this.gp_b.visible = this.gp_y.visible = false;
         this._visualSelectionMode = false;
         this._gp_chooser.visible = false;
         this.configState = null;
         this.cursor = -1;
         this.complete = false;
         this.startGracePeriod();
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      public function closeGpConfig() : Boolean
      {
         if(this.visible)
         {
            this.visible = false;
            return true;
         }
         return false;
      }
      
      private function handleVisualSelectionModeInput(param1:String, param2:Number) : void
      {
         var _loc3_:GpControlButton = this.device.type.getControl(param1);
         switch(_loc3_)
         {
            case GpControlButton.D_L:
               this.selectVisualDpadIndex(this._visualDpadIndex - 1,true);
               break;
            case GpControlButton.D_R:
               this.selectVisualDpadIndex(this._visualDpadIndex + 1,true);
               break;
            case GpControlButton.D_U:
               this.confirmVisualDpadIndex();
         }
      }
      
      private function startGracePeriod() : void
      {
         this._gracePeriodActive = true;
         this._gracePeriodFrameStart = context.logger.frameNumber;
         this._gracePeriodTimeStartMs = getTimer();
      }
      
      private function checkGracePeriod() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this._gracePeriodActive)
         {
            if(this._waitsForZeroCount)
            {
               return false;
            }
            _loc1_ = int(context.logger.frameNumber);
            if(_loc1_ - this._gracePeriodFrameStart < this.GRACE_PERIOD_FRAME_LENGTH)
            {
               return false;
            }
            _loc2_ = getTimer();
            if(_loc2_ - this._gracePeriodTimeStartMs < this.GRACE_PERIOD_TIME_LENGTH_MS)
            {
               return false;
            }
            this._gracePeriodActive = false;
         }
         return true;
      }
      
      private function gpDeviceInputHandler(param1:GpDevice, param2:String, param3:Number) : void
      {
         var _loc9_:String = null;
         var _loc10_:* = false;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:GpControlButton = null;
         var _loc16_:Vector.<String> = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         if(param3 < 0.85 && param3 > -0.85)
         {
            if(param3 < 0.25 && param3 > -0.25)
            {
               if(this._waitsForZero[param2])
               {
                  delete this._waitsForZero[param2];
                  --this._waitsForZeroCount;
               }
            }
            return;
         }
         if(this._gracePeriodActive)
         {
            return;
         }
         if(this._waitingForNextStage)
         {
            return;
         }
         if(this.device != param1)
         {
            if(param1)
            {
               GpSource.primaryDevice = param1;
            }
            return;
         }
         if(this.dialog)
         {
            if(this._waitsForZeroCount)
            {
               return;
            }
            this.dialog.closeDialog(null);
            return;
         }
         if(this._visualSelectionMode)
         {
            this.handleVisualSelectionModeInput(param2,param3);
            return;
         }
         var _loc4_:GpControlButton = this.device.type.getControl(param2);
         if(_loc4_ == GpControlButton.Y)
         {
            this.buttonResetHandler(null);
            return;
         }
         if(_loc4_ == GpControlButton.B)
         {
            this.buttonCloseHandler(this._button$cancel);
            return;
         }
         if(_loc4_ == GpControlButton.A)
         {
            if(this.complete)
            {
               this.buttonConfirmHandler(null);
               return;
            }
         }
         if(this._waitsForZeroCount)
         {
            return;
         }
         var _loc5_:GuiGpConfig_State = !!this.configState ? this.configState.leafState : null;
         if(Boolean(_loc5_) && _loc5_.complete)
         {
            return;
         }
         if(_loc4_ == GpControlButton.X)
         {
            if(_loc5_)
            {
               _loc5_.skipped = true;
            }
            this.readyForNextStage();
            return;
         }
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:* = param2.indexOf("BUTTON_AXIS") == 0;
         var _loc7_:* = param2.indexOf("BUTTON") == 0;
         var _loc8_:* = param2.indexOf("AXIS") == 0;
         if(_loc5_.isAxis)
         {
            if(param2.indexOf("AXIS") != 0)
            {
               return;
            }
            _loc13_ = GpDevice.getButtonAxis(param2,param3);
            _loc14_ = GpDevice.getButtonAxis(param2,-param3);
            _loc15_ = this.device.type.getControl(_loc13_);
            if(!_loc15_)
            {
               _loc15_ = this.device.type.getControl(_loc14_);
            }
            if(_loc15_)
            {
               this.showError("cfg_control_already_bound",_loc15_);
               return;
            }
         }
         if(!_loc5_.isAxis)
         {
            if(!_loc7_)
            {
               return;
            }
         }
         if(_loc5_.canAxisButtonOpposite)
         {
            _loc16_ = this.device.type.getControlIds(_loc5_.canAxisButtonOpposite);
            for each(_loc17_ in _loc16_)
            {
               _loc18_ = GpDevice.getOpposite(_loc17_);
               if(Boolean(_loc18_) && _loc18_ != param2)
               {
                  this.showError("cfg_control_incompatible",_loc5_.canAxisButtonOpposite);
                  return;
               }
               if(!_loc18_ && _loc6_)
               {
                  context.logger.info("GuiGpConfig ignoring button axis [" + param2 + "] as opposite of [" + _loc17_ + "] for state [" + _loc5_.control + "]");
                  return;
               }
            }
         }
         else if(_loc5_.canAxisButton)
         {
            if(_loc6_)
            {
               if(!_loc5_.canAxisButtonNeg && param2.indexOf("_NEG") == param2.length - 4)
               {
                  return;
               }
               if(!_loc5_.canAxisButtonPos && param2.indexOf("_POS") == param2.length - 4)
               {
                  return;
               }
            }
         }
         else if(_loc6_)
         {
            return;
         }
         _loc10_ = param3 == -_loc5_.expectedValue;
         var _loc11_:Vector.<String> = this.device.type.getControlIds(_loc5_.bindingButton);
         if(Boolean(_loc11_) && _loc11_.length > 0)
         {
            if(_loc11_.indexOf(param2) < 0)
            {
               this.showError("cfg_control_incompatible",_loc5_.bindingButton);
               return;
            }
         }
         if(_loc4_)
         {
            if(_loc5_.bindingButton != _loc4_)
            {
               this.showError("cfg_control_already_bound",_loc4_);
               return;
            }
            if(_loc10_ != this.device.type.isControlInverted(_loc4_))
            {
               this.showError("cfg_control_conflicts",_loc4_);
               return;
            }
         }
         this.showError(null,null);
         _loc4_ = _loc5_.bindingButton;
         context.logger.info("GuiGpConfig Binding [" + param2 + "] to " + _loc4_ + " inverted=" + _loc10_);
         this.device.type.addControl(param2,_loc4_);
         if(_loc10_)
         {
            this.device.type.setInverted(_loc4_,true);
         }
         var _loc12_:String = param2;
         if(_loc6_)
         {
            _loc12_ = GpDevice.getAxisIdFromButtonAxis(param2);
         }
         if(!this._waitsForZero[param2])
         {
            this._waitsForZero[_loc12_] = true;
            ++this._waitsForZeroCount;
         }
         _loc5_.complete = true;
         this._waitingForNextStage = true;
         this.startGracePeriod();
         this.updateGui();
      }
      
      private function getControlString(param1:GpControlButton, param2:String) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc3_:String = param1.getLocName(context.locale,param2);
         return _loc3_ + " <<GP." + param1.name + ">>";
      }
      
      private function showError(param1:String, param2:GpControlButton) : void
      {
         if(this.guiGpErrorTextHelper)
         {
            this.guiGpErrorTextHelper.cleanup();
            this.guiGpErrorTextHelper = null;
         }
         if(!param1 || !this.device)
         {
            this._text_error.visible = false;
            return;
         }
         var _loc3_:String = String(context.translateCategory(param1,LocaleCategory.GP));
         var _loc4_:String = this.getControlString(param2,this.device.type.visualCategory);
         if(_loc4_)
         {
            _loc3_ = _loc3_.replace("$CONTROL",_loc4_);
            this.guiGpErrorTextHelper = new GuiGpTextHelper(context.locale,context.logger);
            _loc3_ = this.guiGpErrorTextHelper.preProcessText(_loc3_,context.logger);
         }
         this._text_error.visible = true;
         this._text_error.htmlText = _loc3_;
         this._text_error.x = this.configState.x;
         this._text_error.y = this.configState.y + this.configState.height;
         if(this.guiGpErrorTextHelper)
         {
            this.guiGpErrorTextHelper.finishProcessing(this._text_error);
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function set complete(param1:Boolean) : void
      {
         if(this._complete == param1)
         {
            return;
         }
         this._complete = param1;
         if(this._complete)
         {
            GuiGp.placeIconLeft(this._button$confirm,this.gp_a);
            this._button$confirm.visible = true;
            this.gp_a.visible = true;
            this.gp_a.gplayer = this.gplayer;
            if(Boolean(this.device) && this.device.type.isKeyboard)
            {
               this.createDefaultKeyMapping(Keyboard.UP,GpControlButton.D_U);
               this.createDefaultKeyMapping(Keyboard.DOWN,GpControlButton.D_D);
               this.createDefaultKeyMapping(Keyboard.LEFT,GpControlButton.D_L);
               this.createDefaultKeyMapping(Keyboard.RIGHT,GpControlButton.D_R);
               this.createDefaultKeyMapping(Keyboard.ENTER,GpControlButton.A);
               this.createDefaultKeyMapping(Keyboard.SPACE,GpControlButton.A);
               this.createDefaultKeyMapping(Keyboard.BACKSLASH,GpControlButton.B);
               this.createDefaultKeyMapping(Keyboard.QUOTE,GpControlButton.X);
               this.createDefaultKeyMapping(Keyboard.RIGHTBRACKET,GpControlButton.Y);
            }
         }
      }
      
      private function createDefaultKeyMapping(param1:uint, param2:GpControlButton) : void
      {
         var _loc3_:String = "BUTTON_" + param1.toString();
         var _loc4_:GpControlButton = this.device.type.getControl(_loc3_);
         if(!_loc4_)
         {
            this.device.type.addControl(_loc3_,param2);
         }
      }
      
      public function update(param1:int) : void
      {
         if(!this.checkGracePeriod())
         {
            return;
         }
         if(this._waitingForNextStage && !this._waitsForZeroCount)
         {
            this.readyForNextStage();
            return;
         }
         if(this._readyForNextStage)
         {
            this.nextStage();
         }
      }
   }
}
