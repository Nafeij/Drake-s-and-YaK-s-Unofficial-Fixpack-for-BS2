package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SagaSaveCollection;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiTooltipStatusSurvival;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.IGuiSaveProfile;
   import game.gui.page.IGuiSaveProfileListener;
   
   public class GuiSaveProfile extends GuiBase implements IGuiSaveProfile
   {
      
      public static var SHOW_HELP_BUTTONS:Boolean = true;
       
      
      public var buttons:Vector.<GuiSaveProfileButton>;
      
      public var deleteButtons:Vector.<ButtonWithIndex>;
      
      public var helpButtons:Vector.<ButtonWithIndex>;
      
      public var listener:IGuiSaveProfileListener;
      
      public var _button_close:ButtonWithIndex;
      
      public var nav:GuiGpNav;
      
      public var _iconClose:GuiGpBitmap;
      
      public var _button$load_file:ButtonWithIndex;
      
      public var _text_title:TextField;
      
      public var _tooltip_survival:GuiTooltipStatusSurvival;
      
      private var cmd_profile_1:Cmd;
      
      private var cmd_profile_2:Cmd;
      
      private var cmd_profile_3:Cmd;
      
      private var cmd_profile_4:Cmd;
      
      private var cmd_profile_5:Cmd;
      
      private var cmd_profile_6:Cmd;
      
      private var _guiDialog:IGuiDialog;
      
      private var _hovering:GuiSaveProfileButton;
      
      private var _resumes:Vector.<SagaSaveCollection>;
      
      private var collection_index:int;
      
      public function GuiSaveProfile()
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:GuiSaveProfileButton = null;
         var _loc4_:ButtonWithIndex = null;
         this.buttons = new Vector.<GuiSaveProfileButton>();
         this.deleteButtons = new Vector.<ButtonWithIndex>();
         this.helpButtons = new Vector.<ButtonWithIndex>();
         this._iconClose = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.cmd_profile_1 = new Cmd("profile_1",this.cmdSelectFunc,0);
         this.cmd_profile_2 = new Cmd("profile_2",this.cmdSelectFunc,1);
         this.cmd_profile_3 = new Cmd("profile_3",this.cmdSelectFunc,2);
         this.cmd_profile_4 = new Cmd("profile_4",this.cmdSelectFunc,3);
         this.cmd_profile_5 = new Cmd("profile_5",this.cmdSelectFunc,4);
         this.cmd_profile_6 = new Cmd("profile_6",this.cmdSelectFunc,5);
         super();
         this.visible = false;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_);
            _loc3_ = _loc2_ as GuiSaveProfileButton;
            if(_loc3_)
            {
               this.buttons.push(_loc3_);
            }
            else
            {
               _loc4_ = _loc2_ as ButtonWithIndex;
               if(_loc4_)
               {
                  if(StringUtil.startsWith(_loc4_.name,"delete"))
                  {
                     _loc4_.index = this.deleteButtons.length;
                     this.deleteButtons.push(_loc4_);
                  }
                  if(StringUtil.startsWith(_loc4_.name,"help"))
                  {
                     _loc4_.index = this.helpButtons.length;
                     this.helpButtons.push(_loc4_);
                  }
               }
            }
            _loc1_++;
         }
         if(this.buttons.length <= 0)
         {
            throw new ArgumentError("Invalid profile page: no save profile buttons found!");
         }
         this._button$load_file = requireGuiChild("button$load_file") as ButtonWithIndex;
         this._text_title = requireGuiChild("text_title") as TextField;
         this._tooltip_survival = requireGuiChild("tooltip_survival") as GuiTooltipStatusSurvival;
         addChild(this._iconClose);
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiSaveProfileButton = null;
         var _loc2_:ButtonWithIndex = null;
         this.visible = false;
         for each(_loc1_ in this.buttons)
         {
            _loc1_.removeEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
            _loc1_.cleanup();
         }
         for each(_loc2_ in this.deleteButtons)
         {
            _loc2_.cleanup();
         }
         for each(_loc2_ in this.helpButtons)
         {
            _loc2_.cleanup();
         }
         this.buttons = null;
         this.deleteButtons = null;
         this.helpButtons = null;
         GuiGp.releasePrimaryBitmap(this._iconClose);
         this.nav.cleanup();
         this.unbindKeys();
         this.cmd_profile_1.cleanup();
         this.cmd_profile_2.cleanup();
         this.cmd_profile_3.cleanup();
         this.cmd_profile_4.cleanup();
         this.cmd_profile_5.cleanup();
      }
      
      public function init(param1:IGuiContext, param2:IGuiSaveProfileListener) : void
      {
         var _loc3_:GuiSaveProfileButton = null;
         var _loc4_:ButtonWithIndex = null;
         var _loc5_:Saga = null;
         super.initGuiBase(param1);
         this.listener = param2;
         this._tooltip_survival.init(param1);
         this._button_close = getChildByName("button_close_profile") as ButtonWithIndex;
         for each(_loc3_ in this.buttons)
         {
            _loc3_.init(param1);
            _loc3_.setDownFunction(this.buttonDownHandler);
            _loc3_.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
         }
         for each(_loc4_ in this.deleteButtons)
         {
            _loc4_.guiButtonContext = param1;
            _loc4_.setDownFunction(this.buttonDelDownHandler);
            _loc4_.visible = !param2.isImportOldSagaMode();
         }
         _loc5_ = param1.saga;
         for each(_loc4_ in this.helpButtons)
         {
            _loc4_.guiButtonContext = param1;
            _loc4_.setDownFunction(this.buttonHelpDownHandler);
            _loc4_.visible = false;
         }
         this._button_close.guiButtonContext = param1;
         this._button_close.setDownFunction(this.buttonCloseDownHandler);
         this._button$load_file.setDownFunction(this.buttonLoadFileHandler);
         this._button$load_file.guiButtonContext = param1;
      }
      
      public function setSaveProfileButtonHovering(param1:GuiSaveProfileButton, param2:Boolean) : void
      {
         var _loc4_:SagaSave = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc3_:Saga = _context.saga;
         param2 = param2 && Boolean(_loc3_) && _loc3_.isSurvival;
         if(!param2 && this._hovering != param1)
         {
            return;
         }
         if(param2)
         {
            this._hovering = param1;
         }
         else
         {
            this._hovering = null;
         }
         _loc4_ = !!param1 ? param1.ss : null;
         this._tooltip_survival.visible = Boolean(this._hovering) && Boolean(_loc4_);
         this._tooltip_survival.tooltipSagaSave = _loc4_;
         if(this._tooltip_survival.visible)
         {
            this._tooltip_survival.y = this._hovering.y;
            _loc5_ = "";
            _loc6_ = "";
            _loc5_ += _context.translate("difficulty") + ":\n";
            _loc5_ += _context.translate("survival_progress") + ":\n";
            _loc5_ += _context.translate("survival_reloads") + ":\n";
            _loc5_ += _context.translate("survival_deaths") + ":\n";
            _loc5_ += _context.translate("survival_recruits") + ":\n";
            _loc5_ += _context.translate("survival_elapsed") + ":";
            _loc6_ += _loc3_.getDifficultyStringHtml(_loc4_.getDifficulty(_loc3_)) + "\n";
            _loc6_ += _loc4_.survivalProgress + " / " + _loc3_.survivalTotal + "\n";
            _loc6_ += _loc4_.survivalReloadCount + " / " + _loc3_.survivalReloadLimit + "\n";
            _loc6_ += _loc4_.getVarInt(_loc3_,SagaVar.VAR_SURVIVAL_NUM_DEATHS) + "\n";
            _loc6_ += _loc4_.getVarInt(_loc3_,SagaVar.VAR_SURVIVAL_NUM_RECRUITS) + "\n";
            _loc7_ = _loc4_.getVarInt(_loc3_,SagaVar.VAR_SURVIVAL_ELAPSED_SEC);
            _loc6_ += StringUtil.formatMinSec(_loc7_);
            TweenMax.delayedCall(0,this.listenForTap);
         }
         else
         {
            this.unlistenForTap();
         }
      }
      
      private function listenForTap() : void
      {
         PlatformFlash.stage.addEventListener(TouchEvent.TOUCH_TAP,this.tapHandler,true);
         PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,true);
      }
      
      private function unlistenForTap() : void
      {
         TweenMax.killDelayedCallsTo(this.listenForTap);
         PlatformFlash.stage.removeEventListener(TouchEvent.TOUCH_TAP,this.tapHandler,true);
         PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,true);
      }
      
      private function tapHandler(param1:TouchEvent) : void
      {
         this.setSaveProfileButtonHovering(this._hovering,false);
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.setSaveProfileButtonHovering(this._hovering,false);
      }
      
      private function buttonStateHandler(param1:Event) : void
      {
         var _loc2_:GuiSaveProfileButton = param1.target as GuiSaveProfileButton;
         this.setSaveProfileButtonHovering(_loc2_,_loc2_.isHovering);
      }
      
      private function buttonLoadFileHandler(param1:*) : void
      {
         if(this.listener.isImportOldSagaMode())
         {
            this.listener.guiSaveProfileImportFile();
         }
      }
      
      private function buttonCloseDownHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiSaveProfileClose();
      }
      
      private function buttonAltHandler(param1:ButtonWithIndex) : void
      {
         if(!this.listener.isImportOldSagaMode())
         {
            this.setSaveProfileButtonHovering(this._hovering,false);
            this.listener.guiSaveProfileDelete(param1.index);
         }
      }
      
      private function buttonHelpDownHandler(param1:ButtonWithIndex) : void
      {
         var _loc2_:GuiSaveProfileButton = this.buttons[param1.index];
         this.setSaveProfileButtonHovering(_loc2_,true);
      }
      
      private function buttonDelDownHandler(param1:ButtonWithIndex) : void
      {
         if(!this.listener.isImportOldSagaMode())
         {
            this.setSaveProfileButtonHovering(this._hovering,false);
            this.listener.guiSaveProfileDelete(param1.index);
         }
      }
      
      private function buttonDownHandler(param1:GuiSaveProfileButton) : void
      {
         this.setSaveProfileButtonHovering(this._hovering,false);
         this.listener.guiSaveProfileSelect(this.collection_index,param1.index);
      }
      
      public function setupProfiles(param1:Vector.<SagaSaveCollection>) : void
      {
         this._resumes = param1;
         this._button_close.visible = true;
         this.renderSaveProfilePage();
      }
      
      private function determineWho(param1:SagaSave, param2:Boolean) : String
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:Saga = Saga.instance;
         if(param2)
         {
            if(_loc3_ && _loc3_.def && Boolean(_loc3_.def.importDef))
            {
               return _loc3_.def.importDef.determineWho(param1);
            }
            return null;
         }
         if(_loc3_)
         {
            return _loc3_.def.determineWho(param1);
         }
         return null;
      }
      
      public function renderSaveProfilePage() : void
      {
         var hasGp:Boolean;
         var saga:Saga;
         var showHel:Boolean;
         var ssc:SagaSaveCollection;
         var oldsel:Object = null;
         var del:ButtonWithIndex = null;
         var hel:ButtonWithIndex = null;
         var importing:Boolean = false;
         var i:int = 0;
         var slb:GuiSaveProfileButton = null;
         var ss:SagaSave = null;
         var who:String = null;
         var canDel:Boolean = false;
         if(this.nav)
         {
            oldsel = this.nav.selected;
            this.nav.cleanup();
            this.nav = null;
         }
         this.nav = new GuiGpNav(context,"load",this);
         this.nav.alwaysHintControls = true;
         this.nav.setAlternateButton(GpControlButton.Y,this.buttonAltHandler);
         hasGp = GpSource.primaryDevice != null;
         importing = this.listener.isImportOldSagaMode();
         saga = _context.saga;
         showHel = !!saga ? saga.isSurvival : false;
         showHel = SHOW_HELP_BUTTONS && showHel && !hasGp;
         ssc = null;
         if(this._resumes)
         {
            if(this.collection_index < this._resumes.length)
            {
               ssc = this._resumes[this.collection_index];
            }
         }
         i = 0;
         while(i < this.buttons.length)
         {
            slb = this.buttons[i];
            del = this.deleteButtons[i];
            hel = this.helpButtons[i];
            if(!ssc || i >= ssc.profile_saves.length)
            {
               del.visible = hel.visible = slb.visible = false;
            }
            else
            {
               ss = ssc.profile_saves[i];
               who = this.determineWho(ss,importing);
               if(who)
               {
                  who = String(_context.translateCategory("ent_" + who,LocaleCategory.ENTITY));
               }
               try
               {
                  slb.setupButton(i,ss,who);
               }
               catch(e:Error)
               {
                  context.logger.error("Failed to setup profile button " + i + "\n" + e.getStackTrace());
               }
               slb.enabled = !importing || ss != null;
               if(slb.enabled)
               {
                  this.nav.add(slb);
                  this.nav.setCaptionTokenControl(slb,"ctl_menu_name");
                  canDel = ss != null && !importing;
                  del.visible = canDel && !hasGp;
                  this.nav.setShowAlt(slb,canDel);
                  if(canDel)
                  {
                     this.nav.setCaptionTokenAlt(slb,"save_delete");
                  }
                  hel.visible = canDel && showHel;
               }
               else
               {
                  del.visible = false;
                  hel.visible = false;
               }
            }
            i++;
         }
         this._button_close.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
         this._iconClose.visible = hasGp;
         this._button$load_file.visible = false;
         if(importing)
         {
            this._text_title.htmlText = context.translate("choose_profile_import");
            if(Platform.supportsOSFilePicker)
            {
               this._button$load_file.visible = true;
               this.nav.add(this._button$load_file);
            }
         }
         else
         {
            this._text_title.htmlText = context.translate("choose_profile");
         }
         _context.locale.fixTextFieldFormat(this._text_title);
         if(Boolean(oldsel) && this.nav.canSelect(oldsel))
         {
            this.nav.selected = oldsel;
         }
         else
         {
            this.nav.autoSelect();
         }
         this.nav.activate();
         GuiGp.placeIconCenter(this._button_close,this._iconClose);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
            super.visible = param1;
            if(this.nav)
            {
               if(super.visible)
               {
                  this.nav.activate();
               }
               else
               {
                  this.nav.deactivate();
               }
            }
            if(super.visible)
            {
               this._iconClose.gplayer = GpBinder.gpbinder.topLayer;
               GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
               PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
               this.primaryDeviceHandler(null);
               this.onOperationModeChange(null);
               this.bindKeys();
            }
            else
            {
               PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
               GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
               this.unbindKeys();
               this.unlistenForTap();
            }
         }
      }
      
      private function bindKeys() : void
      {
         var _loc1_:KeyBinder = KeyBinder.keybinder;
         _loc1_.bind(false,false,false,Keyboard.NUMBER_1,this.cmd_profile_1,"");
         _loc1_.bind(false,false,false,Keyboard.NUMPAD_1,this.cmd_profile_1,"");
         _loc1_.bind(false,false,false,Keyboard.NUMBER_2,this.cmd_profile_2,"");
         _loc1_.bind(false,false,false,Keyboard.NUMPAD_2,this.cmd_profile_2,"");
         _loc1_.bind(false,false,false,Keyboard.NUMBER_3,this.cmd_profile_3,"");
         _loc1_.bind(false,false,false,Keyboard.NUMPAD_3,this.cmd_profile_3,"");
         _loc1_.bind(false,false,false,Keyboard.NUMBER_4,this.cmd_profile_4,"");
         _loc1_.bind(false,false,false,Keyboard.NUMPAD_4,this.cmd_profile_4,"");
         _loc1_.bind(false,false,false,Keyboard.NUMBER_5,this.cmd_profile_5,"");
         _loc1_.bind(false,false,false,Keyboard.NUMPAD_5,this.cmd_profile_5,"");
      }
      
      private function unbindKeys() : void
      {
         var _loc1_:KeyBinder = KeyBinder.keybinder;
         if(_loc1_)
         {
            _loc1_.unbind(this.cmd_profile_1);
            _loc1_.unbind(this.cmd_profile_2);
            _loc1_.unbind(this.cmd_profile_3);
            _loc1_.unbind(this.cmd_profile_4);
            _loc1_.unbind(this.cmd_profile_5);
         }
      }
      
      private function cmdSelectFunc(param1:CmdExec) : void
      {
         switch(param1.cmd)
         {
            case this.cmd_profile_1:
               this.buttons[0].press();
               break;
            case this.cmd_profile_2:
               this.buttons[1].press();
               break;
            case this.cmd_profile_3:
               this.buttons[2].press();
               break;
            case this.cmd_profile_4:
               this.buttons[3].press();
               break;
            case this.cmd_profile_5:
               this.buttons[4].press();
         }
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.renderSaveProfilePage();
      }
      
      public function showImportWaitDialog() : void
      {
         this.hideImportWaitDialog();
         this._guiDialog = _context.createDialog();
         this._guiDialog.openNoButtonDialog(_context.translateCategory("cloud_sync_title",LocaleCategory.PLATFORM),_context.translateCategory("cloud_sync_body",LocaleCategory.PLATFORM));
      }
      
      public function hideImportWaitDialog() : void
      {
         if(this._guiDialog)
         {
            this._guiDialog.closeDialog(null);
            this._guiDialog = null;
         }
      }
      
      public function showImportFailedDialog(param1:String, param2:Function) : void
      {
         var _loc3_:String = null;
         this.hideImportWaitDialog();
         this._guiDialog = _context.createDialog();
         switch(param1)
         {
            case "saga1":
            default:
               _loc3_ = "platform_no_save_tbs1";
               break;
            case "saga2":
               _loc3_ = "platform_no_save_tbs2";
         }
         this._guiDialog.openDialog(_context.translateCategory("platform_import_failed",LocaleCategory.PLATFORM),_context.translateCategory(_loc3_,LocaleCategory.PLATFORM),_context.translate("ok"),param2);
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button_close.visible = !PlatformInput.lastInputGp;
      }
      
      public function ensureTopGp() : void
      {
         if(this.nav)
         {
            this.nav.reactivate();
         }
      }
   }
}
