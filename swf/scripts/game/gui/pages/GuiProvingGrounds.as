package game.gui.pages
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.MovieClipAdapter;
   import engine.core.util.MovieClipUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.LegendEvent;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.saga.Saga;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiGamePrefs;
   import game.gui.GuiRoster;
   import game.gui.GuiRosterEvent;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.GuiProvingGroundsConfig;
   import game.gui.page.IGuiPgAbilityPopup;
   import game.gui.page.IGuiProvingGrounds;
   import game.gui.page.IGuiProvingGroundsListener;
   
   public class GuiProvingGrounds extends GuiBase implements IGuiProvingGrounds
   {
       
      
      private var buttonTown:ButtonWithIndex;
      
      private var buttonOptions:ButtonWithIndex;
      
      private var banners:Array;
      
      private var numberOfBanners:int = 6;
      
      private var _selectedCharacter:IEntityDef;
      
      private var buttonRoster:ButtonWithIndex;
      
      private var questionButton:ButtonWithIndex;
      
      private var questionPages:MovieClip;
      
      public var renown:ButtonWithIndex;
      
      private var titleText:TextField;
      
      public var listener:IGuiProvingGroundsListener;
      
      public var rosterComponent:GuiRoster;
      
      public var guiConfig:GuiProvingGroundsConfig;
      
      public var _details:GuiPgDetails;
      
      public var _pg_top_banner:MovieClip;
      
      public var _pg_particle_back:MovieClip;
      
      public var _pg_particle_front:MovieClip;
      
      public var mca_pg_particle_back:MovieClipAdapter;
      
      public var mca_pg_particle_front:MovieClipAdapter;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_menu:GuiGpBitmap;
      
      private var cmd_pg_back:Cmd;
      
      private var cmd_pg_question:Cmd;
      
      private var _helpRenownOriginalY:int;
      
      private var readyPanel:MovieClip;
      
      public var ENABLE_PARTICLES:Boolean = true;
      
      private var gpQuestionLayer:int;
      
      public function GuiProvingGrounds()
      {
         this.banners = new Array();
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.gp_menu = GuiGp.ctorPrimaryBitmap(GpControlButton.REPLACE_MENU_BUTTON,true);
         this.cmd_pg_back = new Cmd("cmd_pg_back",this.cmdBackFunc);
         this.cmd_pg_question = new Cmd("cmd_pg_question",this.cmdQuestionFunc);
         super();
         addChild(this.gp_b);
         addChild(this.gp_menu);
         this.cmd_pg_back.global = true;
         this.gp_b.scale = 1.5;
         this.gp_menu.scale = 1.5;
         name = "gui_proving_grounds";
         this._details = getChildByName("details") as GuiPgDetails;
         this._pg_top_banner = getChildByName("pg_top_banner") as MovieClip;
         this._pg_particle_back = getChildByName("pg_particle_back") as MovieClip;
         this._pg_particle_front = getChildByName("pg_particle_front") as MovieClip;
         this._pg_top_banner.mouseChildren = this._pg_top_banner.mouseEnabled = false;
         this._pg_particle_back.mouseChildren = this._pg_particle_back.mouseEnabled = false;
         this._pg_particle_front.mouseChildren = this._pg_particle_front.mouseEnabled = false;
         MovieClipUtil.stopRecursive(this._pg_particle_back);
         MovieClipUtil.stopRecursive(this._pg_particle_front);
         this._pg_particle_back.visible = false;
         this._pg_particle_front.visible = false;
      }
      
      private function _playSurvivalSetupMusic() : void
      {
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.MUSIC_ONESHOT;
         _loc1_.id = "saga2/music/ch14/12m2-L2";
         _context.saga.executeActionDef(_loc1_,null,null);
      }
      
      public function update(param1:int) : void
      {
         if(Boolean(this._details) && this._details.visible)
         {
            this._details.update(param1);
         }
      }
      
      private function get selectedCharacter() : IEntityDef
      {
         return this._selectedCharacter;
      }
      
      private function set selectedCharacter(param1:IEntityDef) : void
      {
         this._selectedCharacter = param1;
         if(!this._details)
         {
         }
      }
      
      public function init(param1:IGuiContext, param2:GuiProvingGroundsConfig, param3:IGuiProvingGroundsListener, param4:IGuiPgAbilityPopup) : void
      {
         initGuiBase(param1);
         this.listener = param3;
         this.guiConfig = param2;
         this.titleText = this._pg_top_banner.text_pg_title as TextField;
         registerScalableTextfield(this.titleText);
         this._pg_top_banner.mouseEnabled = false;
         this._pg_top_banner.mouseChildren = true;
         this.renown = this._pg_top_banner.getChildByName("renown") as ButtonWithIndex;
         this.renown.setDownFunction(this.renownDownHandler);
         if(this.ENABLE_PARTICLES)
         {
            this.mca_pg_particle_back = new MovieClipAdapter(this._pg_particle_back,30,null,false,param1.logger);
            this.mca_pg_particle_front = new MovieClipAdapter(this._pg_particle_front,30,null,false,param1.logger);
            this._pg_particle_back.visible = true;
            this._pg_particle_front.visible = true;
            this.mca_pg_particle_back.playLooping();
            this.mca_pg_particle_front.playLooping();
         }
         this.renown.enabled = param2.enableRenown;
         var _loc5_:Saga = Saga.instance;
         if(!param2.allowRenown || _loc5_ && _loc5_.isSurvivalSettingUp)
         {
            this.renown.visible = false;
            this.renown = null;
         }
         getGuiChild("roster","rosterComponent");
         this.rosterComponent.addGuiRosterEvent(GuiRosterEvent.DISPLAY_CHARACTER_DETAILS,this.onDisplayCharacterDetails);
         this.rosterComponent.addGuiRosterEvent(GuiRosterEvent.READY,this.rosterReadyHandler);
         this.buttonTown = getChildByName("button_town") as ButtonWithIndex;
         this.buttonTown.setDownFunction(this.townClickHandler);
         this.buttonTown.guiButtonContext = param1;
         this.buttonOptions = getChildByName("button_options") as ButtonWithIndex;
         this.buttonOptions.setDownFunction(this.butonOptionsClickHandler);
         this.buttonOptions.guiButtonContext = param1;
         if(this._details)
         {
            if(!param2.allowDetails)
            {
               this._details.visible = false;
               this._details.selectedCharacter = null;
               this._details.stop();
               this._details = null;
            }
            else
            {
               this._details.init(param1,param4,this,this.renown,param2.characterStats);
            }
         }
         this.setupButtonTown();
         this.readyPanel = getChildByName("readyPanel") as MovieClip;
         this.rosterComponent.init(param1,param2.roster,this.renown,this.readyPanel,this.gpGlobalsUpdateHandler);
         this.titleText.visible = !this.readyPanel.visible;
         this.titleText.cacheAsBitmap = true;
         this.setRenown();
         var _loc6_:ILegend = param1.legend;
         if(_loc6_)
         {
            if(_loc6_.roster.numCombatants > 0)
            {
               this.selectedCharacter = _loc6_.roster.getEntityDef(0);
            }
            _loc6_.addEventListener(LegendEvent.RENOWN,this.renownHandler);
         }
         else
         {
            param1.logger.error("GuiProvingGround no legend available");
         }
         this.showRoster();
         this.questionButton = getChildByName("question_button") as ButtonWithIndex;
         if(param1.getPref(GuiGamePrefs.PREF_PG_HELP_PULSE))
         {
            this.questionButton.pulseHover(500);
         }
         this.questionButton.guiButtonContext = param1;
         this.questionButton.clickSound = "ui_help";
         this.questionButton.setDownFunction(this.onQuestionClick);
         this.questionPages = getChildByName("question_pages") as MovieClip;
         this.questionPages.stop();
         this.questionPages.mouseChildren = false;
         this.questionPages.mouseEnabled = true;
         removeChild(this.questionPages);
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this.localeChangedHandler(null);
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         if(Platform.requiresUiSafeZoneBuffer)
         {
            if(this.renown)
            {
               this.renown.movieClip.y += 20;
            }
            this.questionButton.movieClip.x += 225;
            this.questionButton.movieClip.y -= 70;
         }
         var _loc7_:MovieClip = this.questionPages.getChildByName("question_renown") as MovieClip;
         if(_loc7_)
         {
            this._helpRenownOriginalY = _loc7_.y;
         }
         this.updateGpIcons();
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.updateGpIcons();
      }
      
      private function updateGpIcons() : void
      {
         GuiGp.placeIcon(this.questionButton,null,this.gp_menu,GuiGpAlignH.C,GuiGpAlignV.N);
         this.gp_b.visible = Boolean(this.buttonTown) && this.buttonTown.visible;
         if(this.buttonTown)
         {
            GuiGp.placeIconBottom(this.buttonTown,this.gp_b);
            this.gp_b.y -= 40;
         }
      }
      
      private function setupButtonTown() : void
      {
         var _loc1_:Saga = _context.saga;
         if(!PlatformInput.hasClicker)
         {
            this.buttonTown.visible = false;
         }
         else if(Boolean(_loc1_) && _loc1_.isSurvival)
         {
            this.buttonTown.visible = _loc1_.isSurvivalSettingUp || Boolean(this._details) && this._details.visible;
         }
         else if(!this.guiConfig.allowExit && (!this._details || !this._details.visible))
         {
            this.buttonTown.visible = false;
         }
         else
         {
            this.buttonTown.visible = true;
         }
         this.buttonOptions.visible = !this.buttonTown.visible && PlatformInput.hasClicker;
         this.setupGpbinderLayer();
         this.updateGpIcons();
      }
      
      private function setupGpbinderLayer() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_pg_back);
         GpBinder.gpbinder.unbind(this.cmd_pg_question);
         this.gp_menu.gplayer = this.gp_b.gplayer = GpBinder.gpbinder.lastCmdId;
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_pg_back);
         GpBinder.gpbinder.bindPress(GpControlButton.REPLACE_MENU_BUTTON,this.cmd_pg_question);
      }
      
      private function localeChangedHandler(param1:Event) : void
      {
         if(this.guiConfig.titleText)
         {
            this.titleText.text = context.translate(this.guiConfig.titleText);
            context.currentLocale.fixTextFieldFormat(this.titleText);
         }
         if(this.rosterComponent)
         {
            this.rosterComponent.handleLocaleChanged();
         }
         scaleTextfields();
      }
      
      public function cleanup() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_pg_back);
         GpBinder.gpbinder.unbind(this.cmd_pg_question);
         this.cmd_pg_back.cleanup();
         this.cmd_pg_back = null;
         this.cmd_pg_question.cleanup();
         this.cmd_pg_question = null;
         GuiGp.releasePrimaryBitmap(this.gp_b);
         this.gp_b = null;
         GuiGp.releasePrimaryBitmap(this.gp_menu);
         this.gp_menu = null;
         this.listener = null;
         this.guiConfig = null;
         if(context)
         {
            context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         }
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         if(this.mca_pg_particle_back)
         {
            this.mca_pg_particle_back.cleanup();
            this.mca_pg_particle_back = null;
         }
         if(this.mca_pg_particle_front)
         {
            this.mca_pg_particle_front.cleanup();
            this.mca_pg_particle_front = null;
         }
         if(this.rosterComponent)
         {
            this.rosterComponent.removeGuiRosterEvent(GuiRosterEvent.DISPLAY_CHARACTER_DETAILS,this.onDisplayCharacterDetails);
            this.rosterComponent.removeGuiRosterEvent(GuiRosterEvent.READY,this.rosterReadyHandler);
            this.rosterComponent.cleanup();
            this.rosterComponent = null;
         }
         var _loc1_:ILegend = !!context ? context.legend : null;
         if(_loc1_)
         {
            _loc1_.removeEventListener(LegendEvent.RENOWN,this.renownHandler);
         }
         if(this.questionPages)
         {
            this.questionPages.removeEventListener(MouseEvent.MOUSE_DOWN,this.closeQuestionPages);
         }
         this.selectedCharacter = null;
         if(this._details)
         {
            this._details.cleanup();
            this._details = null;
         }
         super.cleanupGuiBase();
      }
      
      private function renownDownHandler(param1:ButtonWithIndex) : void
      {
         var _loc3_:IGuiDialog = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(this.guiConfig.disabled)
         {
            return;
         }
         var _loc2_:Saga = _context.saga;
         if(Boolean(_loc2_) && _loc2_.isSurvival)
         {
            _loc3_ = context.createDialog();
            _loc4_ = String(_context.translate("survival_tip_renown_title"));
            _loc5_ = String(_context.translate("survival_tip_renown_body"));
            _loc6_ = String(_context.translate("ok"));
            _loc3_.openDialog(_loc4_,_loc5_,_loc6_);
            return;
         }
         context.showMarket(true,null,null,null);
      }
      
      private function renownHandler(param1:Event) : void
      {
         this.setRenown();
      }
      
      public function get isQuestionPageVisible() : Boolean
      {
         return Boolean(this.questionPages) && this.questionPages.visible && Boolean(this.questionPages.parent);
      }
      
      private function closeQuestionPages(param1:MouseEvent) : void
      {
         if(this.questionPages.parent)
         {
            this.questionPages.parent.removeChild(this.questionPages);
         }
         this.questionPages.removeEventListener(MouseEvent.MOUSE_DOWN,this.closeQuestionPages);
         this.listener.guiProvingGroundsCloseQuestionPages();
         if(this.gpQuestionLayer)
         {
            GpBinder.gpbinder.removeLayer(this.gpQuestionLayer);
            this.gpQuestionLayer = 0;
         }
         this.restorePgGp();
         this._details.handleHelpDisabled();
      }
      
      public function restorePgGp() : void
      {
         this.gpGlobalsUpdateHandler();
         this.setupButtonTown();
      }
      
      private function onQuestionClick(param1:ButtonWithIndex) : void
      {
         var _loc2_:MovieClip = null;
         if(this.guiConfig.disabled && !this.guiConfig.allowQuestionMark)
         {
            return;
         }
         if(this.questionPages.parent == null)
         {
            addChild(this.questionPages);
            this.gpQuestionLayer = GpBinder.gpbinder.createLayer("GuiProvingGrounds");
            this.questionPages.addEventListener(MouseEvent.MOUSE_DOWN,this.closeQuestionPages);
            context.setPref(GuiGamePrefs.PREF_PG_HELP_PULSE,false);
            param1.setStateToNormal();
            if(this.questionPages.parent != null)
            {
               if(this._details)
               {
                  this._details.handleHelpEnabled();
               }
            }
            if(this.guiConfig.isSaga)
            {
               if(this.rosterComponent.visible)
               {
                  if(this.guiConfig.roster.allowReady)
                  {
                     this.questionPages.gotoAndStop("ass");
                  }
                  else
                  {
                     this.questionPages.gotoAndStop("roster_saga");
                  }
               }
               else if(Boolean(this._details) && this._details._promotion.visible)
               {
                  this.questionPages.gotoAndStop("promotion_saga");
               }
               else
               {
                  this.questionPages.gotoAndStop("details_saga");
               }
            }
            else if(this.guiConfig.roster.allowReady)
            {
               this.questionPages.gotoAndStop(4);
            }
            else if(this.rosterComponent.visible)
            {
               this.questionPages.gotoAndStop(2);
            }
            else if(Boolean(this._details) && this._details._promotion.visible)
            {
               this.questionPages.gotoAndStop(3);
            }
            else
            {
               this.questionPages.gotoAndStop(1);
            }
            recursiveRegisterScalableTextfields2d(this.questionPages,false);
            _context.translateDisplayObjects(LocaleCategory.GUI,this.questionPages);
            if(Platform.requiresUiSafeZoneBuffer)
            {
               _loc2_ = this.questionPages.getChildByName("question_renown") as MovieClip;
               if(_loc2_)
               {
                  _loc2_.y = this._helpRenownOriginalY + 20;
               }
            }
            scaleTextfields();
            this.listener.guiProvingGroundsQuestionClick();
            return;
         }
         this.closeQuestionPages(null);
      }
      
      private function setRenown() : void
      {
         if(this.renown)
         {
            this.renown.buttonText = context.legend.renown.toString();
         }
      }
      
      public function showRoster() : void
      {
         this.rosterComponent.visible = true;
         this.titleText.visible = !this.readyPanel.visible;
         if(this._details)
         {
            this._details.deactivateDetails();
            this.setupButtonTown();
         }
         if(this._pg_top_banner.parent == this)
         {
            this.removeChild(this._pg_top_banner);
            this.rosterComponent.addChild(this._pg_top_banner);
            this.rosterComponent.setChildIndex(this._pg_top_banner,this.rosterComponent.numChildren - 4);
         }
         if(this.buttonTown)
         {
            this.setChildIndex(this.gp_b,this.numChildren - 1);
            this.setChildIndex(this.buttonTown,this.numChildren - 2);
         }
         if(this.buttonOptions)
         {
            this.setChildIndex(this.buttonOptions,this.numChildren - 2);
         }
         if(_context.saga)
         {
            if(_context.saga.isSurvivalSettingUp)
            {
               this.rosterComponent.survivalAnimateIn();
            }
         }
      }
      
      protected function butonOptionsClickHandler(param1:Object) : void
      {
         _context.showOptions();
      }
      
      protected function townClickHandler(param1:Object) : void
      {
         this.back();
      }
      
      public function back() : void
      {
         var _loc1_:Saga = null;
         var _loc2_:Boolean = false;
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(this._details)
         {
            this._details.deactivateDetails();
         }
         if(this.rosterComponent.visible)
         {
            if(this.listener)
            {
               _loc1_ = _context.saga;
               if(!_loc1_)
               {
                  return;
               }
               if(_loc1_.isSurvival)
               {
                  _loc2_ = _loc1_.isSurvivalSettingUp || Boolean(this._details) && this._details.visible;
               }
               else
               {
                  _loc2_ = this.guiConfig.allowExit && (!!this._details ? !this._details.visible : true);
               }
               if(_loc2_)
               {
                  this.listener.guiProvingGroundsExit();
               }
            }
         }
         else
         {
            this.showRoster();
         }
      }
      
      private function onDisplayCharacterDetails(param1:GuiRosterEvent) : void
      {
         var isParty:Boolean = false;
         var event:GuiRosterEvent = param1;
         this.selectedCharacter = event.selectedCharacter;
         if(!this.guiConfig.allowDetails)
         {
            return;
         }
         if(!this.selectedCharacter)
         {
            if(this._details)
            {
               this._details.deactivateDetails();
               this.setupButtonTown();
            }
            return;
         }
         this.rosterComponent.visible = false;
         this.titleText.visible = !this.readyPanel.visible;
         if(this._details)
         {
            try
            {
               isParty = Boolean(event.slot) && event.slot.parent == this.rosterComponent.partyRow;
               this._details.activateDetails(this.selectedCharacter,isParty);
               this.setupButtonTown();
            }
            catch(e:Error)
            {
               context.logger.error("GuiPgDetails.activateDetails " + selectedCharacter + " error:\n" + e.getStackTrace());
               showRoster();
               return;
            }
         }
         if(this._pg_top_banner.parent == this.rosterComponent)
         {
            this.rosterComponent.removeChild(this._pg_top_banner);
            this.addChild(this._pg_top_banner);
            this.setChildIndex(this._pg_top_banner,2);
         }
         if(this.buttonTown)
         {
            this.setChildIndex(this.gp_b,this.numChildren - 1);
            this.setChildIndex(this.buttonTown,this.numChildren - 2);
         }
         if(this.buttonOptions)
         {
            this.setChildIndex(this.buttonOptions,this.numChildren - 2);
         }
         this.listener.guiProvingGroundsDisplayCharacterDetails(this.selectedCharacter);
         this.setupButtonTown();
      }
      
      public function guiPromotionPromote() : void
      {
         this.rosterComponent.updateParty();
         this.rosterComponent.fillRows(0);
         this.listener.guiProvingGroundsHandlePromotion(this.selectedCharacter);
      }
      
      public function onDismiss() : void
      {
         this.rosterComponent.updateParty();
         this.rosterComponent.fillRows(0);
         this.showRoster();
      }
      
      public function showPromotionClassId(param1:String, param2:String) : void
      {
         if(this._details)
         {
            this._details.showPromotionClassId(param1,param2);
         }
      }
      
      public function set autoName(param1:Boolean) : void
      {
         if(this._details)
         {
            this._details.autoName = param1;
         }
      }
      
      private function rosterReadyHandler(param1:GuiRosterEvent) : void
      {
         this.listener.guiProvingGroundsReady();
      }
      
      private function cmdBackFunc(param1:CmdExec) : void
      {
         if(this.questionPages && this.questionPages.parent && this.questionPages.visible)
         {
            this.closeQuestionPages(null);
            return;
         }
         if(Boolean(this.rosterComponent) && this.rosterComponent.visible)
         {
            if(this.rosterComponent.handleGpCancel())
            {
               return;
            }
         }
         if(Boolean(this._details) && this._details.visible)
         {
            if(this._details.handleGpCancel())
            {
               return;
            }
            this.showRoster();
         }
         else
         {
            this.back();
         }
      }
      
      private function cmdReadyFunc(param1:CmdExec) : void
      {
         if(this.guiConfig.roster.allowReady && this.rosterComponent && this.rosterComponent.visible)
         {
            this.listener.guiProvingGroundsExit();
         }
      }
      
      private function gpGlobalsUpdateHandler() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_pg_back);
         GpBinder.gpbinder.unbind(this.cmd_pg_question);
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_pg_back);
         GpBinder.gpbinder.bindPress(GpControlButton.REPLACE_MENU_BUTTON,this.cmd_pg_question);
         this.gp_menu.gplayer = GpBinder.gpbinder.lastCmdId;
      }
      
      private function cmdQuestionFunc(param1:CmdExec) : void
      {
         this.onQuestionClick(this.questionButton);
         this.gp_menu.pulse();
         this.gpGlobalsUpdateHandler();
      }
      
      public function get canReady() : Boolean
      {
         if(Boolean(this.rosterComponent) && this.rosterComponent.visible)
         {
            return true;
         }
         return false;
      }
      
      public function doReadyButton() : void
      {
         if(Boolean(this.rosterComponent) && this.rosterComponent.visible)
         {
            this.rosterComponent.doReadyButton();
         }
      }
      
      public function doRandomButton() : void
      {
         var _loc6_:int = 0;
         var _loc7_:IEntityDef = null;
         var _loc1_:Saga = _context.saga;
         var _loc2_:ILegend = _loc1_.caravan.legend;
         var _loc3_:IEntityListDef = _loc2_.roster;
         var _loc4_:IPartyDef = _loc2_.party;
         var _loc5_:int = _loc4_.numMembers;
         while(_loc5_ < 6)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc3_.numCombatants)
            {
               _loc7_ = _loc3_.getCombatantAt(_loc6_);
               if(!_loc4_.hasMemberId(_loc7_.id))
               {
                  _loc4_.addMember(_loc7_.id);
                  break;
               }
               _loc6_++;
            }
            _loc5_++;
         }
         this.rosterComponent.updateParty();
      }
   }
}
