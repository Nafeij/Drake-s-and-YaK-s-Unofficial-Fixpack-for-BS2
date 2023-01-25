package game.gui.pages
{
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.ITitleDef;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiUtil;
   import engine.gui.IGuiButton;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.stat.def.StatType;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiBio;
   import game.gui.GuiCharacterStats;
   import game.gui.GuiHeroicTitleButton;
   import game.gui.GuiHeroicTitleTutorial;
   import game.gui.GuiHeroicTitles;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.GuiIconSlot;
   import game.gui.GuiPromotion;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.GuiCharacterStatsConfig;
   import game.gui.page.IGuiBioListener;
   import game.gui.page.IGuiCharacterStatsListener;
   import game.gui.page.IGuiPgAbilityPopup;
   import game.gui.page.IGuiPromotionListener;
   
   public class GuiPgDetails extends GuiBase implements IGuiCharacterStatsListener, IGuiBioListener, IGuiPromotionListener
   {
      
      private static const rLum:Number = 0.7125 / 4;
      
      private static const gLum:Number = 0.7154 / 4;
      
      private static const bLum:Number = 0.7721 / 4;
      
      private static const grayscaleColorFilterMatrix:Array = [rLum,gLum,bLum,0,0,rLum,gLum,bLum,0,0,rLum,gLum,bLum,0,0,0,0,0,1,0];
       
      
      public var _characterStats:GuiCharacterStats;
      
      public var _arrow_bg:MovieClip;
      
      public var _dead:MovieClip;
      
      public var _promotion:GuiPromotion;
      
      public var _promoteBanner:GuiPromoteBanner;
      
      public var _details_item:GuiPgDetailsItem;
      
      public var _button_survival_recruit_hero:ButtonWithIndex;
      
      public var _text_cost_survival_recruit_hero:TextField;
      
      public var _button$survival_funeral_hero:ButtonWithIndex;
      
      public var _text_button$survival_funeral_hero:TextField;
      
      public var _text_name:TextField;
      
      public var _text_rank:TextField;
      
      public var _text_title:TextField;
      
      public var _anchor_titleText:MovieClip;
      
      public var portrait:GuiIcon;
      
      public var buttonLeft:ButtonWithIndex;
      
      public var buttonRight:ButtonWithIndex;
      
      public var guiBio:GuiBio;
      
      public var _button$bio:ButtonWithIndex;
      
      public var guiHeroicTitles:GuiHeroicTitles;
      
      public var guiHeroicTitleTutorial:GuiHeroicTitleTutorial;
      
      public var _button$heroic_titles:GuiHeroicTitleButton;
      
      public var auto_name:Boolean;
      
      public var show_class_id:String;
      
      public var use_unit_name:String;
      
      public var _placeholder_portrait:MovieClip;
      
      public var pg:GuiProvingGrounds;
      
      private var gp:GuiPgDetails_Gp;
      
      public var _kc:GuiPgDetails_KillCounter;
      
      private var guiConfig:GuiCharacterStatsConfig;
      
      private var cmf:ColorMatrixFilter;
      
      private var glow:GlowFilter;
      
      private var _selectedCharacter:IEntityDef;
      
      private var theStage:Stage;
      
      private var _activatedFromParty:Boolean;
      
      private var _cyclingInParty:Boolean;
      
      private var _funeralator:GuiPgDetails_VikingFuneralator;
      
      public function GuiPgDetails()
      {
         this.gp = new GuiPgDetails_Gp();
         this.cmf = new ColorMatrixFilter(grayscaleColorFilterMatrix);
         this.glow = new GlowFilter(10145518,1,12,12,3,2);
         super();
         this._characterStats = getChildByName("characterStats") as GuiCharacterStats;
         this._arrow_bg = getChildByName("arrow_bg") as MovieClip;
         this._dead = getChildByName("dead") as MovieClip;
         this._promotion = getChildByName("promotion") as GuiPromotion;
         this._button$bio = getChildByName("bio") as ButtonWithIndex;
         this._button$heroic_titles = getChildByName("heroicTitlesButton") as GuiHeroicTitleButton;
         this._promoteBanner = getChildByName("promoteBanner") as GuiPromoteBanner;
         this._details_item = getChildByName("details_item") as GuiPgDetailsItem;
         this._placeholder_portrait = getChildByName("placeholder_portrait") as MovieClip;
         this._kc = new GuiPgDetails_KillCounter(this);
         this.visible = false;
      }
      
      public function init(param1:IGuiContext, param2:IGuiPgAbilityPopup, param3:GuiProvingGrounds, param4:IGuiButton, param5:GuiCharacterStatsConfig) : void
      {
         super.initGuiBase(param1);
         this.pg = param3;
         this._kc.init(_context);
         this._details_item.init(param1,this.gp.itemsActivationGpHandler);
         this._characterStats.init(param1,this,param2,param3.guiConfig.characterStats,param4,this.gp.statsDeactivatedGpHandler);
         this._characterStats.talentDisplayCallback = this.talentsDisplayUpdate;
         this._characterStats.abilityDisplayCallback = this.abilitiesDisplayUpdate;
         if(param1.saga.def.survival)
         {
            this._kc.visible = false;
         }
         this._arrow_bg = getChildByName("arrow_bg") as MovieClip;
         this._button_survival_recruit_hero = getChildByName("button$survival_recruit_hero") as ButtonWithIndex;
         this._text_cost_survival_recruit_hero = (this._button_survival_recruit_hero.getChildByName("renownCost") as MovieClip).getChildByName("costText") as TextField;
         this._button_survival_recruit_hero.guiButtonContext = _context;
         this._button_survival_recruit_hero.setDownFunction(this.buttonSurvivalRecruitHeroPressed);
         this._button_survival_recruit_hero.visible = false;
         this._button$survival_funeral_hero = getChildByName("button$survival_funeral_hero") as ButtonWithIndex;
         this._text_button$survival_funeral_hero = (this._button$survival_funeral_hero.getChildByName("renownCost") as MovieClip).getChildByName("costText") as TextField;
         this._button$survival_funeral_hero.guiButtonContext = _context;
         this._button$survival_funeral_hero.setDownFunction(this.buttonSurvivalFuneralHeroPressed);
         this._button$survival_funeral_hero.visible = false;
         this.buttonLeft = getChildByName("button_character_left") as ButtonWithIndex;
         this.buttonLeft.setDownFunction(this.arrowLeftClickHandler);
         this.buttonLeft.guiButtonContext = param1;
         this.buttonRight = getChildByName("button_character_right") as ButtonWithIndex;
         this.buttonRight.setDownFunction(this.arrowRightClickHandler);
         this.buttonRight.guiButtonContext = param1;
         this._promoteBanner.init(param1,param3.guiConfig);
         this._promoteBanner.addEventListener(GuiPromoteBanner.EVENT_PROMOTE,this.promoteBannerHandler);
         this._promoteBanner.addEventListener(Event.CHANGE,this.promoteBannerChangeHandler);
         this._promotion.init(param1,param3.guiConfig.promotion,this,param4);
         this._promotion.visible = false;
         this._placeholder_portrait = getChildByName("placeholder_portrait") as MovieClip;
         this._placeholder_portrait.visible = false;
         this.guiBio = getChildByName("bioPopup") as GuiBio;
         this.guiBio.init(param1,param5.bio,this,this._button$bio);
         this._button$bio.guiButtonContext = param1;
         this._button$bio.setDownFunction(this.onBioHit);
         this.guiHeroicTitles = getChildByName("heroicTitlesPopup") as GuiHeroicTitles;
         this.guiHeroicTitles.init(param1,this);
         this._button$heroic_titles.init(param1);
         this._button$heroic_titles.setDownFunction(this.onHeroicTitlesHit);
         this._button$heroic_titles.clickSound = "ui_heroic_title_enter";
         this.guiHeroicTitleTutorial = getChildByName("heroicTitlesTutorial") as GuiHeroicTitleTutorial;
         this.guiHeroicTitleTutorial.init(param1,this);
         this.guiHeroicTitleTutorial.continueButtonCallback = this.onHeroicTitlesTutorialContinue;
         this.guiHeroicTitleTutorial.backButtonCallback = this.onHeroicTitlesTutorialBack;
         this.guiConfig = param5;
         this.promoteBannerChangeHandler(null);
         this._text_name = getChildByName("text_character_name") as TextField;
         this._text_rank = getChildByName("text_character_rank") as TextField;
         this._text_title = getChildByName("text_character_title") as TextField;
         this._anchor_titleText = getChildByName("anchor_titleText") as MovieClip;
         registerScalableTextfield(this._text_name);
         registerScalableTextfield(this._text_rank);
         registerScalableTextfield(this._text_title);
         this.censorDead();
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this.localeChangedHandler(null);
         this.gp.init(this);
      }
      
      private function censorDead() : void
      {
         var _loc1_:String = null;
         var _loc2_:MovieClip = null;
         if(this._dead)
         {
            _loc1_ = _context.censorId;
            _loc2_ = this._dead.getChildByName("censor") as MovieClip;
            GuiUtil.performCensor(_loc2_,_loc1_,logger);
         }
      }
      
      public function update(param1:int) : void
      {
         if(!visible)
         {
            return;
         }
         if(this.portrait)
         {
            if(Boolean(this._selectedCharacter) && !this._selectedCharacter.isSurvivalDead)
            {
               this.portrait.update(param1);
            }
         }
         if(Boolean(this._promotion) && this._promotion.visible)
         {
            this._promotion.update(param1);
         }
         if(Boolean(this._characterStats) && this._characterStats.visible)
         {
            this._characterStats.update(param1);
         }
         if(this.gp)
         {
            this.gp.update();
         }
      }
      
      private function localeChangedHandler(param1:Event) : void
      {
         this.populateCharacterElements();
         this._promotion.handleLocaleChange();
         if(this._details_item)
         {
            this._details_item.handleLocaleChanged();
         }
         this.setGuiHeroicTitlesVisible(this.guiHeroicTitles.visible);
      }
      
      public function cleanup() : void
      {
         if(context)
         {
            context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         }
         if(this.theStage)
         {
            this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideBio);
         }
         this.hideAll();
         this._promoteBanner.removeEventListener(GuiPromoteBanner.EVENT_PROMOTE,this.promoteBannerHandler);
         this._promoteBanner.removeEventListener(Event.CHANGE,this.promoteBannerChangeHandler);
         this.selectedCharacter = null;
         this._characterStats.cleanup();
         this._characterStats = null;
         this.buttonLeft.cleanup();
         this.buttonLeft = null;
         this.buttonRight.cleanup();
         this.buttonRight = null;
         this.guiHeroicTitles.cleanup();
         this.guiHeroicTitles = null;
         this._button$heroic_titles.cleanup();
         this._button$heroic_titles = null;
         this.guiHeroicTitleTutorial.cleanup();
         this.guiHeroicTitleTutorial = null;
         this._promoteBanner.cleanup();
         this._promoteBanner = null;
         this._promotion.cleanup();
         this._promotion = null;
         this.guiBio.cleanup();
         this.guiBio = null;
         this._button$bio.cleanup();
         this._button$bio = null;
         this._details_item.cleanup();
         this._details_item = null;
         while(numChildren)
         {
            removeChildAt(numChildren - 1);
         }
         this.pg = null;
         if(this.gp)
         {
            this.gp.cleanup();
            this.gp = null;
         }
         this.guiConfig = null;
         super.cleanupGuiBase();
      }
      
      private function promoteBannerChangeHandler(param1:Event) : void
      {
         this.checkDetailsItemVisible();
      }
      
      private function checkDetailsItemVisible() : void
      {
         var _loc1_:Boolean = (!this._promoteBanner.extended || !this._promoteBanner.bannerVisible) && !this._promotion.visible && !this.guiHeroicTitles.visible && !this.guiHeroicTitleTutorial.visible;
         if(_loc1_)
         {
            if(this._selectedCharacter)
            {
               if(!this._selectedCharacter.isSurvivalPromotable)
               {
                  _loc1_ = false;
               }
            }
         }
         this._details_item.visible = _loc1_;
         this.gp.handleDetailsItemVisible();
      }
      
      public function onPurchaseStats() : void
      {
         this._promoteBanner.update();
      }
      
      public function get selectedCharacter() : IEntityDef
      {
         return this._selectedCharacter;
      }
      
      public function set selectedCharacter(param1:IEntityDef) : void
      {
         this._selectedCharacter = param1;
         if(this._characterStats)
         {
            this._characterStats.setCurrentCharacterIndex(param1);
         }
         if(Boolean(this._promotion) && Boolean(param1))
         {
            this.guiPromotionHide();
         }
         if(this._details_item)
         {
            this._details_item.entity = param1;
         }
         if(this.guiHeroicTitles)
         {
            this.guiHeroicTitles.currentCharacter = param1;
         }
         if(Boolean(this._button$heroic_titles) && param1 != null)
         {
            this._button$heroic_titles.updatePlus(param1.stats.titleRank);
            this._button$heroic_titles.visible = this.heroicTitlesAvailable;
         }
         if(this._characterStats._guiTalents.visible)
         {
            this.talentsDisplayUpdate(true);
         }
         if(this._characterStats.abilityPopup.mc.visible)
         {
            this.abilitiesDisplayUpdate(true);
         }
         this.populateCharacterElements();
      }
      
      public function get heroicTitlesAvailable() : Boolean
      {
         return Boolean(this._selectedCharacter) && this._selectedCharacter.stats.rank > 10 + 1;
      }
      
      public function guiPromotionPromote() : void
      {
         this._characterStats.setCurrentCharacterIndex(this.selectedCharacter);
         this.populateCharacterElements();
         this.pg.guiPromotionPromote();
      }
      
      public function displayPromotion() : void
      {
         this._details_item.visible = false;
         this._promotion.visible = true;
         this._characterStats.visible = false;
         this.buttonLeft.visible = false;
         this.buttonRight.visible = false;
         this._arrow_bg.visible = false;
         this._button$bio.visible = false;
         this._button$heroic_titles.visible = false;
         this.guiBio.entity = null;
         this.guiBio.visible = false;
         this._promotion.showPromotionClassId(this.show_class_id,this.use_unit_name);
         this._promotion.autoName = this.auto_name;
         _context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this._promotion,_context.logger);
         this.gp.handleDeactivateDetails();
         this.checkTutorialTooltip();
      }
      
      public function guiPromotionHide() : void
      {
         if(!this._promotion.visible)
         {
            return;
         }
         this._promotion.visible = false;
         this.checkDetailsItemVisible();
         this._characterStats.visible = true;
         if(this.buttonLeft)
         {
            this.buttonLeft.visible = true;
         }
         if(this.buttonRight)
         {
            this.buttonRight.visible = true;
         }
         this._arrow_bg.visible = true;
         this._button$bio.visible = true;
         this._button$heroic_titles.visible = this.heroicTitlesAvailable;
         this.gp.handleActivateDetails();
         this.pg.restorePgGp();
         this._promoteBanner.update();
         this.checkTutorialTooltip();
      }
      
      public function talentsDisplayUpdate(param1:Boolean) : void
      {
         this._button$bio.visible = !param1;
         this._button$heroic_titles.visible = !param1 && this.heroicTitlesAvailable;
      }
      
      public function abilitiesDisplayUpdate(param1:Boolean) : void
      {
         this._button$bio.visible = !param1;
         this._button$heroic_titles.visible = !param1 && this.heroicTitlesAvailable;
      }
      
      public function onBioRenameCharacter() : void
      {
         this.guiBio.entity = null;
         this.guiBio.visible = false;
         this.displayPromotion();
         this._promotion.renameEntity(this._selectedCharacter);
         this.pg.rosterComponent.updateParty();
         this.checkTutorialTooltip();
      }
      
      public function onBioVariation() : void
      {
         this.guiBio.entity = null;
         this.guiBio.visible = false;
         this.displayPromotion();
         this._promotion.bioVariation(this._selectedCharacter);
         this.checkTutorialTooltip();
      }
      
      private function setThingVisible(param1:DisplayObject, param2:Boolean) : void
      {
         if(!this.visible)
         {
            return;
         }
         if(param1)
         {
            param1.visible = param2;
         }
      }
      
      private function hideAll() : void
      {
         this.setThingVisible(this._characterStats,false);
         this.setThingVisible(this.buttonLeft,false);
         this.setThingVisible(this.buttonRight,false);
         this.setThingVisible(this._arrow_bg,false);
         this.setThingVisible(this.guiBio,false);
         this.setThingVisible(this.guiHeroicTitles,false);
         this.setThingVisible(this.guiHeroicTitleTutorial,false);
         if(this.theStage)
         {
            this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideBio);
         }
      }
      
      private function setGuiBioVisible(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         if(!this.visible)
         {
            return;
         }
         if(!param1)
         {
            _loc2_ = Boolean(this._promotion) && this._promotion.visible && Boolean(this._promotion.parent);
            this.setThingVisible(this._characterStats,!_loc2_);
            this.setThingVisible(this.buttonLeft,!_loc2_);
            this.setThingVisible(this.buttonRight,!_loc2_);
            this.setThingVisible(this._arrow_bg,true);
            this.setThingVisible(this._button$heroic_titles,!_loc2_ && this.heroicTitlesAvailable);
            this.setThingVisible(this.guiBio,false);
            if(this.theStage)
            {
               this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideBio);
            }
         }
         else
         {
            if(this.guiBio)
            {
               this.guiBio.entity = this.selectedCharacter;
            }
            this.setThingVisible(this._characterStats,false);
            this.setThingVisible(this.buttonLeft,false);
            this.setThingVisible(this.buttonRight,false);
            this.setThingVisible(this._arrow_bg,false);
            this.setThingVisible(this._button$heroic_titles,false);
            this.setThingVisible(this.guiBio,true);
            this.theStage = this.stage;
            if(this.theStage)
            {
               this.theStage.addEventListener(MouseEvent.MOUSE_DOWN,this.hideBio,true);
            }
         }
         this.checkTutorialTooltip();
      }
      
      private function onBioHit(param1:ButtonWithIndex) : void
      {
         if(this.pg == null || this.pg.guiConfig == null || this.pg.guiConfig.disabled)
         {
            return;
         }
         this.setGuiBioVisible(!this.guiBio.visible);
      }
      
      private function hideBio(param1:MouseEvent) : void
      {
         if(!this.guiBio)
         {
            if(this.theStage)
            {
               this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideBio);
            }
            return;
         }
         if(!this.guiBio.hitTestPoint(param1.stageX,param1.stageY) && !this._button$bio.hitTestPoint(param1.stageX,param1.stageY) && this.guiBio.visible == true)
         {
            this.onBioHit(null);
            if(this.theStage)
            {
               this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideBio);
            }
         }
      }
      
      public function setGuiHeroicTitlesVisible(param1:Boolean) : void
      {
         this.guiHeroicTitles.gp.visible = param1;
         if(!this.visible)
         {
            return;
         }
         if(param1)
         {
            this.setThingVisible(this._characterStats,false);
            this.setThingVisible(this.buttonLeft,false);
            this.setThingVisible(this.buttonRight,false);
            this.setThingVisible(this._arrow_bg,false);
            this.setThingVisible(this._button$bio,false);
            this.setThingVisible(this._promoteBanner,false);
            this.setThingVisible(this._details_item,false);
            this._kc.visible = false;
            this._button$heroic_titles.clickSound = "ui_heroic_title_cancel";
            if(this.guiHeroicTitleTutorial.shouldDisplayTutorial())
            {
               if(this.guiHeroicTitleTutorial.visible)
               {
                  this.setThingVisible(this.guiHeroicTitleTutorial,false);
                  this.setThingVisible(this._characterStats,true);
                  this.setThingVisible(this.buttonLeft,true);
                  this.setThingVisible(this.buttonRight,true);
                  this.setThingVisible(this._arrow_bg,true);
                  this.setThingVisible(this._button$bio,true);
                  this.setThingVisible(this._details_item,true);
                  this.setThingVisible(this.guiHeroicTitles,false);
                  this.setThingVisible(this.guiHeroicTitleTutorial,false);
                  this._promoteBanner.update();
                  this._button$heroic_titles.clickSound = "ui_heroic_title_enter";
                  this._kc.visible = true;
                  this.populateCharacterElements();
               }
               else
               {
                  this.setThingVisible(this.guiHeroicTitleTutorial,true);
               }
            }
            else
            {
               this.setThingVisible(this.guiHeroicTitleTutorial,false);
               this.setThingVisible(this.guiHeroicTitles,true);
               this.guiHeroicTitles.update();
            }
         }
         else
         {
            this.setThingVisible(this._characterStats,true);
            this.setThingVisible(this.buttonLeft,true);
            this.setThingVisible(this.buttonRight,true);
            this.setThingVisible(this._arrow_bg,true);
            this.setThingVisible(this._button$bio,true);
            this.setThingVisible(this.guiHeroicTitles,false);
            this.setThingVisible(this.guiHeroicTitleTutorial,false);
            this.checkDetailsItemVisible();
            this._promoteBanner.update();
            if(this._characterStats.abilityPopup.mc.visible)
            {
               this.abilitiesDisplayUpdate(true);
            }
            this._button$heroic_titles.clickSound = "ui_heroic_title_enter";
            this._kc.visible = true;
            this.populateCharacterElements();
         }
         this.gp.handleDetailsItemVisible();
      }
      
      private function onHeroicTitlesTutorialContinue() : void
      {
         this.setGuiHeroicTitlesVisible(true);
      }
      
      private function onHeroicTitlesTutorialBack() : void
      {
         this.onHeroicTitlesHit(null);
         this.guiHeroicTitles.gp.visible = false;
      }
      
      private function onHeroicTitlesHit(param1:ButtonWithIndex) : void
      {
         if(this.pg.guiConfig.disabled)
         {
            return;
         }
         this.setGuiHeroicTitlesVisible(!this.guiHeroicTitles.visible);
         this._button$heroic_titles.button_clicked();
      }
      
      public function showPromotionClassId(param1:String, param2:String) : void
      {
         this.show_class_id = param1;
         this.use_unit_name = param2;
         this._promotion.showPromotionClassId(this.show_class_id,param2);
      }
      
      public function set autoName(param1:Boolean) : void
      {
         this.auto_name = param1;
         this._promotion.autoName = this.auto_name;
      }
      
      public function guiPromotionNamingAccept() : void
      {
         this.pg.listener.guiProvingGroundsNamingAccept();
      }
      
      public function guiPromotionNamingMode() : void
      {
         this.pg.listener.guiProvingGroundsNamingMode();
      }
      
      public function guiPromotionVariationOpened() : void
      {
         this.pg.listener.guiProvingGroundsVariationOpened();
      }
      
      public function guiPromotionVariationSelected() : void
      {
         this.pg.listener.guiProvingGroundsVariationSelected();
      }
      
      public function onDismiss() : void
      {
         this.populateCharacterElements();
         this.pg.onDismiss();
      }
      
      private function _getCurMemberIndex() : int
      {
         if(!context.legend)
         {
            return -1;
         }
         var _loc1_:IPartyDef = context.legend.party;
         var _loc2_:IEntityListDef = context.legend.roster;
         var _loc3_:int = 0;
         if(this._cyclingInParty)
         {
            _loc3_ = _loc1_.getMemberIndex(this.selectedCharacter.id);
         }
         else
         {
            _loc3_ = _loc1_.numMembers + _loc2_.getCombatantIndex(this.selectedCharacter);
         }
         return _loc3_;
      }
      
      private function _getCurMemberAt(param1:int) : IEntityDef
      {
         if(!context.legend || param1 < 0)
         {
            return null;
         }
         var _loc2_:IPartyDef = context.legend.party;
         var _loc3_:IEntityListDef = context.legend.roster;
         if(this._cyclingInParty)
         {
            return _loc2_.getMember(param1);
         }
         return _loc3_.getCombatantAt(param1 - _loc2_.numMembers);
      }
      
      protected function arrowRightClickHandler(param1:Object) : void
      {
         if(this.pg.guiConfig.disabled || !context.legend || !this.selectedCharacter)
         {
            return;
         }
         var _loc2_:int = this._getCurMemberIndex();
         if(_loc2_ < 0)
         {
            _context.logger.error("No member index for " + this.selectedCharacter);
            return;
         }
         var _loc3_:IPartyDef = context.legend.party;
         var _loc4_:IEntityListDef = context.legend.roster;
         var _loc5_:int = _loc3_.numMembers + _loc4_.numCombatants;
         _loc2_ = ++_loc2_ % _loc5_;
         this._cyclingInParty = _loc2_ < _loc3_.numMembers;
         var _loc6_:IEntityDef = this._getCurMemberAt(_loc2_);
         if(_loc6_ == this._selectedCharacter)
         {
            _loc2_ = ++_loc2_ % _loc5_;
            this._cyclingInParty = _loc2_ < _loc3_.numMembers;
            _loc6_ = this._getCurMemberAt(_loc2_);
         }
         this.selectedCharacter = _loc6_;
         this.populateCharacterElements();
      }
      
      protected function arrowLeftClickHandler(param1:Object) : void
      {
         if(this.pg.guiConfig.disabled || !context.legend || !this.selectedCharacter)
         {
            return;
         }
         var _loc2_:int = this._getCurMemberIndex();
         if(_loc2_ < 0)
         {
            _context.logger.error("No member index for " + this.selectedCharacter);
            return;
         }
         var _loc3_:IPartyDef = context.legend.party;
         var _loc4_:IEntityListDef = context.legend.roster;
         var _loc5_:int = _loc3_.numMembers + _loc4_.numCombatants;
         _loc2_ = (_loc2_ + _loc5_ - 1) % _loc5_;
         this._cyclingInParty = _loc2_ < _loc3_.numMembers;
         var _loc6_:IEntityDef = this._getCurMemberAt(_loc2_);
         if(_loc6_ == this._selectedCharacter)
         {
            _loc2_ = (_loc2_ + _loc5_ - 1) % _loc5_;
            this._cyclingInParty = _loc2_ < _loc3_.numMembers;
            _loc6_ = this._getCurMemberAt(_loc2_);
         }
         this.selectedCharacter = _loc6_;
         this.populateCharacterElements();
      }
      
      private function promoteBannerHandler(param1:Event) : void
      {
         if(this.pg.guiConfig.disabled && !this.pg.guiConfig.allowPromotion)
         {
            return;
         }
         if(this._promotion.visible)
         {
            this.guiPromotionHide();
         }
         else
         {
            this._promotion.characterInfoMode(this.selectedCharacter);
            this.displayPromotion();
            this.pg.listener.guiProvingGroundsDisplayPromotion(this.selectedCharacter);
         }
      }
      
      private function updateKillCounter(param1:IEntityDef) : void
      {
         this._kc.updateKillCounter(param1,_context);
      }
      
      protected function populateCharacterElements() : void
      {
         this.updatePortrait();
         if(!this.selectedCharacter)
         {
            this._promoteBanner.unitId = null;
            return;
         }
         this._dead.visible = false;
         this._button_survival_recruit_hero.visible = false;
         this._button$survival_funeral_hero.visible = false;
         this.populateCharacterTitle();
         this.updateKillCounter(this.selectedCharacter);
         this._promoteBanner.unitId = this.selectedCharacter.id;
         this.checkDetailsItemVisible();
         this.gp.refreshGui();
      }
      
      private function populateCharacterTitle() : void
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         this._text_name.htmlText = this.selectedCharacter.name;
         context.currentLocale.fixTextFieldFormat(this._text_name);
         var _loc1_:int = int(this.selectedCharacter.stats.getValue(StatType.RANK));
         var _loc2_:ITitleDef = this.selectedCharacter.defTitle;
         if(_loc1_ == 1)
         {
            this._text_name.y = this._arrow_bg.y + this._arrow_bg.height * 0.5 - this._text_name.height * 0.5;
            this._text_rank.htmlText = "";
            this._text_rank.visible = true;
            this._text_title.visible = false;
         }
         else if(_loc2_)
         {
            _loc5_ = !!this.selectedCharacter ? this.selectedCharacter.gender : null;
            this._text_rank.visible = true;
            this._text_title.visible = true;
            this._text_title.htmlText = "\"" + _loc2_.getName(_loc5_) + "\"";
            context.currentLocale.fixTextFieldFormat(this._text_title);
         }
         else
         {
            this._text_title.visible = false;
            this._text_rank.visible = true;
         }
         this._text_rank.htmlText = context.translate("rank") + " " + (_loc1_ - 1) + " " + this.selectedCharacter.entityClass.name;
         if(this._selectedCharacter.isSurvivalDead)
         {
            this._text_rank.htmlText += context.translate("survival_dead");
            this._text_rank.visible = true;
            this._text_title.visible = false;
            this._dead.visible = true;
            this._button$survival_funeral_hero.visible = true;
            _loc6_ = this.selectedCharacter.survivalFuneralRewardRenown;
            _loc7_ = this.selectedCharacter.survivalFuneralRewardItemRenown;
            this._text_button$survival_funeral_hero.text = (_loc6_ + _loc7_).toString();
         }
         else if(this._selectedCharacter.isSurvivalRecruitable)
         {
            this._text_rank.htmlText += _context.translate("survival_recruitable");
            this._text_rank.visible = true;
            this._text_title.visible = false;
            this._button_survival_recruit_hero.visible = true;
            this._text_cost_survival_recruit_hero.text = this.selectedCharacter.survivalRecruitCostRenown.toString();
         }
         context.currentLocale.fixTextFieldFormat(this._text_name);
         context.currentLocale.fixTextFieldFormat(this._text_rank);
         context.currentLocale.fixTextFieldFormat(this._text_title);
         scaleTextfields();
         var _loc3_:Number = 0;
         _loc3_ += this._text_name.visible ? this._text_name.height : 0;
         _loc3_ += this._text_rank.visible ? this._text_rank.height : 0;
         _loc3_ += this._text_title.visible ? this._text_title.height : 0;
         var _loc4_:Number = this._anchor_titleText.y - _loc3_ / 2;
         if(this._text_name.visible)
         {
            this._text_name.y = _loc4_;
            _loc4_ += this._text_name.height;
         }
         if(this._text_rank.visible)
         {
            this._text_rank.y = _loc4_;
            _loc4_ += this._text_rank.height;
         }
         if(this._text_title.visible)
         {
            this._text_title.y = _loc4_;
         }
      }
      
      public function deactivateDetails() : void
      {
         this.visible = false;
         if(this.guiBio)
         {
            this.guiBio.visible = false;
         }
         this.setGuiHeroicTitlesVisible(false);
         if(this.guiHeroicTitles)
         {
            this.guiHeroicTitles.curTitleIndex = 0;
         }
         if(this._characterStats)
         {
            this._characterStats.visible = false;
         }
         this.selectedCharacter = null;
         this._characterStats.setCurrentCharacterIndex(null);
         this.gp.handleDeactivateDetails();
         if(this._funeralator)
         {
            this._funeralator.forceFinish();
            this._funeralator = null;
         }
      }
      
      private function checkTutorialTooltip() : void
      {
         var _loc1_:Boolean = true;
         if(Boolean(this.guiBio) && this.guiBio.visible)
         {
            _loc1_ = false;
         }
         else if(Boolean(this._promotion) && this._promotion.visible)
         {
            _loc1_ = false;
         }
         else if(Boolean(this.pg) && this.pg.isQuestionPageVisible)
         {
            _loc1_ = false;
         }
         else if(!this._characterStats || !this._characterStats.visible || !this._characterStats.parent)
         {
            _loc1_ = false;
         }
      }
      
      public function activateDetails(param1:IEntityDef, param2:Boolean) : void
      {
         this._activatedFromParty = param2;
         this._cyclingInParty = param2;
         this.visible = true;
         this.gp.handleActivateDetails();
         this.selectedCharacter = param1;
         if(this._characterStats)
         {
            this._characterStats.visible = true;
         }
         this._promoteBanner.unitId = this.selectedCharacter.id;
         this._characterStats.setCurrentCharacterIndex(param1);
         this.setGuiHeroicTitlesVisible(false);
      }
      
      private function updatePortrait() : void
      {
         var _loc1_:IEntityAppearanceDef = null;
         if(this.portrait)
         {
            if(this._selectedCharacter)
            {
               _loc1_ = this._selectedCharacter.appearance;
               if(Boolean(this.portrait.resource) && this.portrait.resource.url == _loc1_.portraitUrl)
               {
                  return;
               }
            }
            this.portrait.release();
            this.portrait = null;
         }
         if(!this.selectedCharacter)
         {
            return;
         }
         this.portrait = _context.getEntityClassPortrait(this._selectedCharacter,false);
         this.portrait.mouseChildren = false;
         this.portrait.mouseEnabled = false;
         this._placeholder_portrait.parent.addChildAt(this.portrait,this._placeholder_portrait.parent.getChildIndex(this._placeholder_portrait));
         this.portrait.x = this._placeholder_portrait.x;
         this.portrait.layout = GuiIconLayoutType.ACTUAL;
         this.portrait.y = this._placeholder_portrait.y;
         if(this._selectedCharacter.isSurvivalDead)
         {
            this.portrait.filters = [this.cmf,this.glow];
         }
         else
         {
            this.portrait.filters = [];
         }
      }
      
      public function handleHelpEnabled() : void
      {
         this.setGuiBioVisible(false);
         if(!this._promotion.visible)
         {
            this._characterStats.handleHelpEnabled();
         }
         this.checkTutorialTooltip();
      }
      
      public function handleHelpDisabled() : void
      {
         this.checkTutorialTooltip();
      }
      
      public function onGuiBioCloseRequest() : void
      {
         this.setGuiBioVisible(false);
      }
      
      public function handleGpCancel() : Boolean
      {
         GuiIconSlot.cancelAllDrags();
         return this.gp.handleGpCancel();
      }
      
      public function buttonSurvivalFuneralHeroPressed(param1:*) : void
      {
         var _loc3_:IGuiDialog = null;
         var _loc5_:String = null;
         if(!this._selectedCharacter || !this._selectedCharacter.isSurvivalDead)
         {
            return;
         }
         var _loc2_:ILegend = _context.saga.caravan.legend;
         if(!_loc2_ || !_loc2_.roster)
         {
            return;
         }
         if(!_loc2_.roster.getEntityDefById(this._selectedCharacter.id))
         {
            return;
         }
         var _loc4_:String = String(_context.translate("survival_dlg_funeral_title"));
         if(this._selectedCharacter.defItem)
         {
            _loc5_ = String(_context.translate("survival_dlg_funeral_item_body"));
            _loc5_ = _loc5_.replace("{ITEM}",this._selectedCharacter.defItem.def.name);
         }
         else
         {
            _loc5_ = String(_context.translate("survival_dlg_funeral_noitem_body"));
         }
         var _loc6_:int = this.selectedCharacter.survivalFuneralRewardRenown;
         var _loc7_:int = this.selectedCharacter.survivalFuneralRewardItemRenown;
         _loc5_ = _loc5_.replace("{RENOWN}",(_loc6_ + _loc7_).toString());
         var _loc8_:String = String(_context.translate("confirm"));
         var _loc9_:String = String(_context.translate("cancel"));
         _loc3_ = _context.createDialog();
         _loc3_.openTwoBtnDialog(_loc4_,_loc5_,_loc8_,_loc9_,this.survivalFuneralDialogClosedHandler);
      }
      
      private function survivalFuneralDialogClosedHandler(param1:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!this._selectedCharacter || !this._selectedCharacter.isSurvivalDead)
         {
            return;
         }
         var _loc2_:String = String(_context.translate("confirm"));
         var _loc3_:Saga = _context.saga;
         if(param1 == _loc2_)
         {
            _loc4_ = this.selectedCharacter.survivalFuneralRewardRenown;
            _loc5_ = this.selectedCharacter.survivalFuneralRewardItemRenown;
            _loc6_ = _loc4_ + _loc5_;
            _loc3_.incrementGlobalVar(SagaVar.VAR_SURVIVAL_NUM_FUNERALS,1);
            _loc3_.setVar("survival_win_funerals_num",_loc3_.getVarInt(SagaVar.VAR_SURVIVAL_NUM_FUNERALS));
            this._funeralator = new GuiPgDetails_VikingFuneralator(this);
            this._funeralator.startFuneral(this._selectedCharacter,_loc6_,this._funeralCompleteHandler);
         }
      }
      
      private function _funeralCompleteHandler() : void
      {
         this._funeralator.restoreVisualStates();
         this._funeralator = null;
         this.pg.showRoster();
      }
      
      public function buttonSurvivalRecruitHeroPressed(param1:*) : void
      {
         var _loc2_:IGuiDialog = null;
         if(!this._selectedCharacter || !this._selectedCharacter.isSurvivalRecruitable)
         {
            return;
         }
         var _loc3_:String = String(_context.translate("survival_dlg_recruit_title"));
         var _loc4_:String = String(_context.translate("survival_dlg_recruit_body"));
         var _loc5_:int = this._selectedCharacter.survivalRecruitCostRenown;
         _loc4_ = _loc4_.replace("{RENOWN}",_loc5_.toString());
         var _loc6_:String = String(_context.translate("confirm"));
         var _loc7_:String = String(_context.translate("cancel"));
         _loc2_ = _context.createDialog();
         _loc2_.openTwoBtnDialog(_loc3_,_loc4_,_loc6_,_loc7_,this.survivalRecruitDialogClosedHandler);
      }
      
      private function survivalRecruitDialogClosedHandler(param1:String) : void
      {
         var _loc4_:ILegend = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:IGuiDialog = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         if(!this._selectedCharacter || !this._selectedCharacter.isSurvivalRecruitable)
         {
            return;
         }
         var _loc2_:String = String(_context.translate("confirm"));
         var _loc3_:Saga = _context.saga;
         if(param1 == _loc2_)
         {
            _loc4_ = _context.saga.caravan.legend;
            _loc5_ = _loc4_.renown;
            _loc6_ = this._selectedCharacter.survivalRecruitCostRenown;
            if(_loc5_ < _loc6_)
            {
               _loc8_ = String(_context.translate("survival_dlg_recruit_lowrenown_title"));
               _loc9_ = String(_context.translate("survival_dlg_recruit_lowrenown_body"));
               _loc10_ = String(_context.translate("ok"));
               _loc7_ = _context.createDialog();
               _loc7_.openDialog(_loc8_,_loc9_,_loc10_);
               return;
            }
            _loc4_.renown -= _loc6_;
            this._selectedCharacter.isSurvivalRecruited = true;
            _loc3_.incrementGlobalVar(SagaVar.VAR_SURVIVAL_NUM_RECRUITS,1);
            _loc3_.setVar("survival_win_recruits_num",_loc3_.getVarInt(SagaVar.VAR_SURVIVAL_NUM_RECRUITS));
            this.populateCharacterElements();
            _loc4_.roster.sortEntities();
         }
      }
   }
}
