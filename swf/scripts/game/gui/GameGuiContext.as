package game.gui
{
   import engine.ability.IAbilityDef;
   import engine.achievement.AchievementDef;
   import engine.battle.SceneListDef;
   import engine.core.RunMode;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.analytic.GaConfig;
   import engine.core.analytic.GaOptState;
   import engine.core.gp.GpBinder;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.EntitiesMetadata;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.ITitleDef;
   import engine.gui.BattleHudConfig;
   import engine.gui.GuiContextEvent;
   import engine.heraldry.Heraldry;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.session.IIapManager;
   import engine.sound.ISoundDriver;
   import engine.sound.view.ISound;
   import engine.sound.view.ISoundController;
   import engine.tourney.TourneyDefList;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import game.cfg.AccountInfoDef;
   import game.cfg.GameAssetsDef;
   import game.cfg.GameConfig;
   import game.view.IDialogLayer;
   import game.view.TutorialTooltip;
   import tbs.srv.data.FriendData;
   import tbs.srv.data.FriendsData;
   import tbs.srv.util.PurchaseCounts;
   import tbs.srv.util.Tourney;
   import tbs.srv.util.TourneyProgressData;
   import tbs.srv.util.TourneyWinnerData;
   import tbs.srv.util.UnlockData;
   
   public class GameGuiContext extends EventDispatcher implements IGuiContext
   {
      
      private static var symbols:Dictionary;
       
      
      public var _logger:ILogger;
      
      private var soundController:ISoundController;
      
      private var resman:ResourceManager;
      
      private var _accountInfo:AccountInfoDef;
      
      private var dialogClazz:Class;
      
      private var callback:Function;
      
      private var assets:GameAssetsDef;
      
      private var dialogLayer:IDialogLayer;
      
      public var eaten:MouseEvent;
      
      public var config:GameConfig;
      
      private var _currencySymbol:String;
      
      private var gameTipQueue:GameTipQueue;
      
      private var _gaOptStateDialogListener:IGaOptStateDialogListener;
      
      public function GameGuiContext(param1:ILogger, param2:ResourceManager, param3:ISoundController, param4:AccountInfoDef, param5:Class, param6:IDialogLayer, param7:GameConfig)
      {
         super();
         if(!param3)
         {
            throw new ArgumentError("null soundController");
         }
         this.gameTipQueue = new GameTipQueue(this);
         this.config = param7;
         this._logger = param1;
         this.resman = param2;
         this.accountInfo = param4;
         this.soundController = param3;
         this.assets = this.assets;
         this.dialogLayer = param6;
         this.dialogClazz = param5;
      }
      
      private static function getCurrencySymbol(param1:String, param2:ILogger) : String
      {
         if(!symbols)
         {
            symbols = new Dictionary();
            symbols["USD"] = "$";
            symbols["EUR"] = "€";
            symbols["GBP"] = "£";
            symbols["RUB"] = "p.";
            symbols["BRL"] = "R$";
         }
         var _loc3_:String = String(symbols[param1]);
         if(!_loc3_)
         {
            param2.error("Invalid currency: " + param1);
            return "¿";
         }
         return _loc3_;
      }
      
      public function isClassAvailable(param1:String) : Boolean
      {
         return this.config.runMode.isClassAvailable(param1);
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function playSound(param1:String) : void
      {
         if(!this.config || !this.config.soundSystem)
         {
            return;
         }
         if(!this.config.soundSystem.mixer.sfxEnabled)
         {
            return;
         }
         if(!this.soundController)
         {
            return;
         }
         if(!this.soundController.library)
         {
            return;
         }
         if(!this.soundController.complete)
         {
            return;
         }
         var _loc2_:ISound = this.soundController.getSound(param1,null);
         if(!_loc2_)
         {
            this.logger.error("GameGuiContext.playSound INVALID " + param1);
            return;
         }
         _loc2_.start();
      }
      
      public function getFriendAvatar(param1:FriendData, param2:int) : GuiIcon
      {
         var _loc3_:String = null;
         if(param2 >= 128)
         {
            _loc3_ = param1.avatar128;
         }
         if(!_loc3_ || param2 >= 64)
         {
            _loc3_ = param1.avatar64;
         }
         if(!_loc3_)
         {
            _loc3_ = param1.avatar32;
         }
         var _loc4_:IResource = this.resman.getResource(_loc3_,BitmapResource,null);
         return new GuiIcon(_loc4_,this,GuiIconLayoutType.ACTUAL);
      }
      
      public function getEntityIconAtAppIndex(param1:IEntityClassDef, param2:EntityIconType, param3:int) : GuiIcon
      {
         var _loc4_:IEntityAppearanceDef = param1.getEntityClassAppearanceDef(param3);
         var _loc5_:String = _loc4_.getIconUrl(param2);
         var _loc6_:IResource = this.resman.getResource(_loc5_,BitmapResource,null);
         return new GuiIcon(_loc6_,this,GuiIconLayoutType.ACTUAL);
      }
      
      public function getAwardIcon(param1:String) : GuiIcon
      {
         if(!param1)
         {
            this.logger.error("Null Award Icon requested");
            return null;
         }
         var _loc2_:IResource = this.resman.getResource(param1,BitmapResource,null);
         return new GuiIcon(_loc2_,this,GuiIconLayoutType.ACTUAL);
      }
      
      public function getAchievementDef(param1:String) : AchievementDef
      {
         return this.config.achievementListDef.fetch(param1);
      }
      
      public function get resourceManager() : ResourceManager
      {
         return this.resman;
      }
      
      public function getEntityIcon(param1:IEntityDef, param2:EntityIconType) : GuiIcon
      {
         var url:String = null;
         var r:IResource = null;
         var icon:GuiIcon = null;
         var entityDef:IEntityDef = param1;
         var type:EntityIconType = param2;
         try
         {
            url = entityDef.appearance.getIconUrl(type);
            if(url == "")
            {
               this.logger.debug("GameGuiContext.getEntityIcon - No icon of type [" + type + "] for entity [" + entityDef + "]");
               return null;
            }
            r = this.resman.getResource(url,BitmapResource,null);
            icon = new GuiIcon(r,this,GuiIconLayoutType.ACTUAL);
            return icon;
         }
         catch(e:Error)
         {
            logger.error("GameGuiContext.getEntityIcon [" + entityDef + "] [" + type + "] failed:\n" + e.getStackTrace());
            return null;
         }
      }
      
      public function getEntityClassPortrait(param1:IEntityDef, param2:Boolean) : GuiIcon
      {
         var _loc5_:IResource = null;
         var _loc3_:IEntityAppearanceDef = param1.appearance;
         var _loc4_:String = _loc3_.portraitUrl;
         _loc5_ = this.resman.getResource(_loc4_,AnimClipResource,null);
         return new GuiIcon(_loc5_,this,GuiIconLayoutType.ACTUAL);
      }
      
      public function getAnimClip(param1:String) : GuiIcon
      {
         var _loc2_:IResource = this.resman.getResource(param1,AnimClipResource,null);
         return new GuiIcon(_loc2_,this,GuiIconLayoutType.ACTUAL);
      }
      
      public function getEntityVersusPortrait(param1:IEntityDef) : GuiIcon
      {
         var _loc4_:IResource = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:IEntityAppearanceDef = param1.appearance;
         var _loc3_:String = _loc2_.versusPortraitUrl;
         if(_loc3_)
         {
            _loc4_ = this.resman.getResource(_loc3_,BitmapResource,null);
            return new GuiIcon(_loc4_,this,GuiIconLayoutType.ACTUAL);
         }
         return null;
      }
      
      public function getEntityAppearancePromotePortrait(param1:IEntityAppearanceDef) : GuiIcon
      {
         var _loc2_:IResource = this.resman.getResource(param1.promotePortraitUrl,BitmapResource,null);
         return new GuiIcon(_loc2_,this,GuiIconLayoutType.ACTUAL);
      }
      
      public function getEntityClassPromotePortraitAtAppIndex(param1:IEntityClassDef, param2:int) : GuiIcon
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:IEntityAppearanceDef = param1.getEntityClassAppearanceDef(param2);
         return this.getEntityAppearancePromotePortrait(_loc3_);
      }
      
      public function getEntityPromotePortrait(param1:IEntityDef) : GuiIcon
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:IEntityAppearanceDef = param1.appearance;
         return this.getEntityAppearancePromotePortrait(_loc2_);
      }
      
      public function getAbilityDefById(param1:String) : IAbilityDef
      {
         return this.config.abilityFactory.fetch(param1);
      }
      
      public function getAbilityBuffIcon(param1:IAbilityDef) : GuiIcon
      {
         var _loc2_:IResource = null;
         if(param1.iconBuffUrl)
         {
            _loc2_ = this.resman.getResource(param1.iconBuffUrl,BitmapResource,null);
            return new GuiIcon(_loc2_,this,GuiIconLayoutType.ACTUAL);
         }
         this.logger.error("No icon for " + param1);
         return null;
      }
      
      public function getTitleBuffIcon(param1:ITitleDef) : GuiIcon
      {
         var _loc2_:IResource = null;
         if(Boolean(param1) && Boolean(param1.iconBuffUrl))
         {
            _loc2_ = this.resman.getResource(param1.iconBuffUrl,BitmapResource,null);
            return new GuiIcon(_loc2_,this,GuiIconLayoutType.ACTUAL);
         }
         return null;
      }
      
      public function getAbilityIcon(param1:IAbilityDef) : GuiIcon
      {
         var _loc2_:String = null;
         if(Boolean(param1) && Boolean(param1.iconUrl))
         {
            _loc2_ = param1.iconUrl;
         }
         else
         {
            _loc2_ = "common/ability/icon/icon_no_special.png";
         }
         if(_loc2_)
         {
            return this.getIcon(_loc2_);
         }
         this.logger.error("No icon for " + _loc2_);
         return null;
      }
      
      public function getLargeAbilityIcon(param1:IAbilityDef) : GuiIcon
      {
         var _loc2_:IResource = null;
         if(param1.iconLargeUrl)
         {
            _loc2_ = this.resman.getResource(param1.iconLargeUrl,BitmapResource,null);
            return new GuiIcon(_loc2_,this,GuiIconLayoutType.ACTUAL);
         }
         this.logger.error("No icon for " + param1);
         return null;
      }
      
      public function getIcon(param1:String) : GuiIcon
      {
         return this.getIconResourceGroup(param1,null);
      }
      
      public function getIconResourceGroup(param1:String, param2:ResourceGroup) : GuiIcon
      {
         var _loc3_:IResource = this.resman.getResource(param1,BitmapResource,param2);
         var _loc4_:* = param2 == null;
         return new GuiIcon(_loc3_,this,GuiIconLayoutType.ACTUAL,0,false,_loc4_);
      }
      
      public function get legend() : ILegend
      {
         return this.config.legend;
      }
      
      public function get accountInfo() : AccountInfoDef
      {
         return this._accountInfo;
      }
      
      public function getAbilityDef(param1:String) : IAbilityDef
      {
         return this.config.abilityFactory.fetch(param1);
      }
      
      public function set accountInfo(param1:AccountInfoDef) : void
      {
         if(this._accountInfo == param1)
         {
            return;
         }
         if(this._accountInfo)
         {
            this._accountInfo.removeEventListener(AccountInfoDef.CURRENCY,this.currencyHandler);
            this._accountInfo.removeEventListener(AccountInfoDef.UNLOCKS,this.unlocksHandler);
            this._accountInfo.purchases.removeEventListener(Event.CHANGE,this.purchasesHandler);
         }
         this._accountInfo = param1;
         if(this._accountInfo)
         {
            this._accountInfo.addEventListener(AccountInfoDef.CURRENCY,this.currencyHandler);
            this._accountInfo.addEventListener(AccountInfoDef.UNLOCKS,this.unlocksHandler);
            this._accountInfo.purchases.addEventListener(Event.CHANGE,this.purchasesHandler);
            this.unlocksHandler(null);
            this.currencyHandler(null);
            this.purchasesHandler(null);
         }
      }
      
      private function currencyHandler(param1:Event) : void
      {
         this._currencySymbol = getCurrencySymbol(this._accountInfo.currency,this.logger);
         dispatchEvent(new GuiContextEvent(GuiContextEvent.CURRENCY));
      }
      
      private function unlocksHandler(param1:Event) : void
      {
         dispatchEvent(new GuiContextEvent(GuiContextEvent.UNLOCKS));
      }
      
      private function purchasesHandler(param1:Event) : void
      {
         dispatchEvent(new GuiContextEvent(GuiContextEvent.PURCHASES));
      }
      
      public function notifyLocaleChange() : void
      {
         dispatchEvent(new GuiContextEvent(GuiContextEvent.LOCALE));
      }
      
      public function notifySagaPausedChange() : void
      {
         dispatchEvent(new GuiContextEvent(GuiContextEvent.PAUSE));
      }
      
      public function notifyShowingOptionsChange() : void
      {
         dispatchEvent(new GuiContextEvent(GuiContextEvent.OPTIONS));
      }
      
      public function get dialog() : IGuiDialog
      {
         return this.dialogLayer.dialog;
      }
      
      public function createDialog() : IGuiDialog
      {
         var _loc1_:IGuiDialog = null;
         if(this.dialogClazz)
         {
            _loc1_ = new this.dialogClazz() as IGuiDialog;
            _loc1_.init(this);
            this.dialogLayer.addDialog(_loc1_);
         }
         return _loc1_;
      }
      
      public function removeDialog(param1:IGuiDialog) : void
      {
         this.dialogLayer.removeDialog(param1);
      }
      
      public function eatEvent(param1:MouseEvent) : void
      {
      }
      
      public function isEventEaten(param1:MouseEvent) : Boolean
      {
         return this.config.eater.isEventEaten(param1);
      }
      
      public function get username() : String
      {
         return this.config.fsm.credentials.vbb_name;
      }
      
      public function get displayname() : String
      {
         return this.config.fsm.credentials.displayName;
      }
      
      public function reportUserAbuse(param1:String) : void
      {
         this.logger.info("TODO REPORTING USER ABUSE: " + param1);
      }
      
      public function setPref(param1:String, param2:*) : void
      {
         this.config.globalPrefs.setPref(param1,param2);
      }
      
      public function getPref(param1:String) : *
      {
         return this.config.globalPrefs.getPref(param1);
      }
      
      public function translateCategory(param1:String, param2:LocaleCategory) : String
      {
         return this.config.context.locale.translate(param2,param1);
      }
      
      public function translateCategoryRaw(param1:String, param2:LocaleCategory) : String
      {
         return this.config.context.locale.translate(param2,param1,true);
      }
      
      public function translate(param1:String) : String
      {
         return this.config.context.locale.translate(LocaleCategory.GUI,param1);
      }
      
      public function translateDisplayObjects(param1:LocaleCategory, param2:DisplayObject) : void
      {
         var _loc3_:ILogger = this.config.logger;
         var _loc4_:Locale = this.config.context.locale;
         return _loc4_.translateDisplayObjects(param1,param2,_loc3_);
      }
      
      public function translateRaw(param1:String) : String
      {
         return this.config.context.locale.translate(LocaleCategory.GUI,param1,true);
      }
      
      public function replaceTranslatedTokens(param1:String, param2:Array) : String
      {
         return this.config.context.locale.replaceTranslatedTokens(param1,param2);
      }
      
      public function get randomMaleName() : String
      {
         return !!this.config.factions ? this.config.factions.namegen.randomMale : "unknown_name";
      }
      
      public function get randomFemaleName() : String
      {
         return !!this.config.factions ? this.config.factions.namegen.randomFemale : "unknown_name";
      }
      
      public function get statCosts() : UnitStatCosts
      {
         return this.config.statCosts;
      }
      
      public function getCrownChitIcon() : GuiIcon
      {
         var _loc1_:IResource = null;
         if(this.config.factions)
         {
            if(this.config.accountInfo.crownChitIconUrl)
            {
               _loc1_ = this.resman.getResource(this.config.accountInfo.crownChitIconUrl,BitmapResource,null);
               return new GuiIcon(_loc1_,this,GuiIconLayoutType.ACTUAL);
            }
         }
         else if(!this.config.saga)
         {
         }
         return null;
      }
      
      public function getCrownIcon() : GuiIcon
      {
         var _loc1_:IResource = null;
         if(this.config.factions)
         {
            if(this.config.accountInfo.crownIconUrl)
            {
               _loc1_ = this.resman.getResource(this.config.accountInfo.crownIconUrl,BitmapResource,null);
               return new GuiIcon(_loc1_,this,GuiIconLayoutType.ACTUAL);
            }
         }
         else if(this.config.saga)
         {
            _loc1_ = this.resman.getResource(Saga.crownIconUrl,BitmapResource,null);
            return new GuiIcon(_loc1_,this,GuiIconLayoutType.ACTUAL);
         }
         return null;
      }
      
      public function get friends() : FriendsData
      {
         return this.config.friends;
      }
      
      public function get account_id() : int
      {
         return this.config.fsm.credentials.userId;
      }
      
      public function get sceneList() : SceneListDef
      {
         return !!this.config.factions ? this.config.factions.sceneListDef : null;
      }
      
      public function translateTaunt(param1:String) : String
      {
         return this.config.context.locale.translate(LocaleCategory.TAUNT,param1);
      }
      
      public function getTaunts() : Localizer
      {
         return this.config.context.locale.getLocalizer(LocaleCategory.TAUNT);
      }
      
      public function get iap() : IIapManager
      {
         if(this.config.factions)
         {
            return this.config.factions.iapManager;
         }
         return null;
      }
      
      public function get currencySymbol() : String
      {
         return this._currencySymbol;
      }
      
      public function get currencyCode() : String
      {
         return this.accountInfo.currency;
      }
      
      public function hasUnlock(param1:String) : Boolean
      {
         return this.accountInfo.hasUnlock(param1);
      }
      
      public function get purchases() : PurchaseCounts
      {
         return this.accountInfo.purchases;
      }
      
      public function getUnlock(param1:String) : UnlockData
      {
         return this.accountInfo.getUnlockById(param1);
      }
      
      public function showMarket(param1:Boolean, param2:String, param3:String, param4:Function) : void
      {
         this.config.pageManager.marketplace.showMarketplace(true,param2,param3,param4);
      }
      
      public function get battleHudConfig() : BattleHudConfig
      {
         return this.config.battleHudConfig;
      }
      
      public function tutorialMode() : Boolean
      {
         return this.config.accountInfo.tutorial;
      }
      
      public function get tourney() : Tourney
      {
         if(this.config.factions)
         {
            return this.config.factions.tourneys.tourney;
         }
         return null;
      }
      
      public function get tourneyWinner() : TourneyWinnerData
      {
         if(this.config.factions)
         {
            return this.config.factions.tourneys.tourneyWinner;
         }
         return null;
      }
      
      public function get tourneyProgress() : TourneyProgressData
      {
         if(this.config.factions)
         {
            return this.config.factions.tourneys.tourneyProgress;
         }
         return null;
      }
      
      public function joinTourney(param1:int, param2:Function) : void
      {
         if(this.config.factions)
         {
            this.config.factions.tourneys.joinTourney(param1,param2);
         }
      }
      
      public function get tourneyDefList() : TourneyDefList
      {
         if(this.config.factions)
         {
            return this.config.factions.tourneyDefList;
         }
         return null;
      }
      
      public function get runMode() : RunMode
      {
         return this.config.runMode;
      }
      
      public function get entitiesMetadata() : EntitiesMetadata
      {
         return this.config.classes.meta;
      }
      
      public function get heraldry() : Heraldry
      {
         return !!this.config.heraldrySystem ? this.config.heraldrySystem.selectedHeraldry : null;
      }
      
      public function hasShownGameTip(param1:String) : Boolean
      {
         return this.gameTipQueue.hasShownTip(this.config.saga,param1);
      }
      
      public function showGameTip(param1:String, param2:String, param3:String) : void
      {
         this.gameTipQueue.showTip(this.config.saga,param1,param2,param3);
      }
      
      public function generateTextBitmap(param1:String, param2:int, param3:uint, param4:*, param5:String, param6:int) : BitmapData
      {
         return this.config.textBitmapGenerator.generateTextBitmap(param1,param2,param3,param4,param5,param6);
      }
      
      public function createTutorialPopup(param1:DisplayObject, param2:String, param3:TutorialTooltipAlign, param4:TutorialTooltipAnchor, param5:Boolean, param6:Boolean, param7:Function) : int
      {
         if(!param1)
         {
            return 0;
         }
         var _loc8_:DisplayObject = param1;
         var _loc9_:String = "";
         while(_loc8_)
         {
            if(StringUtil.startsWith(_loc8_.name,"wrapper_"))
            {
               break;
            }
            if(_loc9_)
            {
               _loc9_ = "|" + _loc9_;
            }
            _loc9_ = _loc8_.name + _loc9_;
            _loc8_ = _loc8_.parent;
         }
         var _loc10_:TutorialTooltip = this.config.tutorialLayer.createTooltip(_loc9_,param3,param4,0,param2,param5,param6,0);
         _loc10_.autoclose = true;
         _loc10_.buttonCallback = param7;
         return _loc10_.id;
      }
      
      public function setTutorialPopupVisible(param1:int, param2:Boolean) : void
      {
         if(Boolean(this.config) && Boolean(this.config.tutorialLayer))
         {
            this.config.tutorialLayer.setTooltipVisibleById(param1,param2);
         }
      }
      
      public function removeAllTooltips() : void
      {
         if(Boolean(this.config) && Boolean(this.config.tutorialLayer))
         {
            this.config.tutorialLayer.removeAllTooltips();
         }
      }
      
      public function removeTutorialTooltip(param1:int) : void
      {
         if(Boolean(this.config) && Boolean(this.config.tutorialLayer))
         {
            this.config.tutorialLayer.removeTooltipByHandle(param1);
         }
      }
      
      public function setTutorialTooltipNeverClamp(param1:int, param2:Boolean) : void
      {
         if(Boolean(this.config) && Boolean(this.config.tutorialLayer))
         {
            this.config.tutorialLayer.setTooltipNeverClamp(param1,param2);
         }
      }
      
      public function get numLocales() : int
      {
         return this.config.context.appInfo.locales.length;
      }
      
      public function get locale() : Locale
      {
         return this.config.context.locale;
      }
      
      public function getLocale(param1:int) : String
      {
         return this.config.context.appInfo.locales[param1];
      }
      
      public function get currentLocale() : Locale
      {
         return this.config.context.locale;
      }
      
      public function get isSagaStartPage() : Boolean
      {
         return Boolean(this.config.saga) && this.config.saga.isStartScene;
      }
      
      public function get saga() : Saga
      {
         return this.config.saga;
      }
      
      public function get iSaga() : ISaga
      {
         return this.config.saga as ISaga;
      }
      
      public function showOptions() : void
      {
         this.config.pageManager.showOptions();
      }
      
      public function get isShowingOptions() : Boolean
      {
         return this.config.pageManager.isShowingOptions();
      }
      
      public function get censorId() : String
      {
         return this.config.censorId;
      }
      
      public function get isSagaPaused() : Boolean
      {
         return Boolean(this.saga) && this.saga.paused;
      }
      
      public function showGaOptStateDialog(param1:IGaOptStateDialogListener) : void
      {
         this._gaOptStateDialogListener = param1;
         var _loc2_:IGuiDialog = this.createDialog();
         var _loc3_:String = this.translate("ga_optstate_dialog_title");
         var _loc4_:String = this.translate("ga_optstate_dialog_body");
         var _loc5_:String = "";
         if(GaConfig.optState != GaOptState.QUERY)
         {
            _loc5_ = "\n\n" + this.translate("ga_optstate_dialog_body_" + GaConfig.optState.name.toLowerCase());
         }
         var _loc6_:String = _loc4_ + _loc5_;
         var _loc7_:String = this.translate("ga_optstate_dialog_btn_out");
         var _loc8_:String = this.translate("ga_optstate_dialog_btn_in");
         _loc2_.disableEscape = true;
         _loc2_.openTwoBtnDialog(_loc3_,_loc6_,_loc8_,_loc7_,this._gaOptStateCallback);
         GpBinder.ALLOW_INPUT_DURING_LOAD = true;
      }
      
      private function _gaOptStateCallback(param1:String) : void
      {
         var _loc2_:String = this.translate("ga_optstate_dialog_btn_in");
         if(param1 == _loc2_)
         {
            GaConfig.optState = GaOptState.IN;
         }
         else
         {
            GaConfig.optState = GaOptState.OUT;
         }
         this.setPref(GaConfig.PREF_GA_OPTSTATE,GaConfig.optState.name);
         if(this._gaOptStateDialogListener)
         {
            this._gaOptStateDialogListener.gaOptStateDialogClosed();
         }
         this._gaOptStateDialogListener = null;
         GpBinder.ALLOW_INPUT_DURING_LOAD = false;
      }
      
      public function get soundDriver() : ISoundDriver
      {
         return this.config.soundSystem.driver;
      }
   }
}
