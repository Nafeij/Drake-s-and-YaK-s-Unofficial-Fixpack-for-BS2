package game.gui
{
   import com.greensock.TweenMax;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Legend;
   import engine.gui.GuiButtonState;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import engine.gui.IGuiButton;
   import engine.gui.core.LocaleAlignableTextField;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.stat.def.StatPurchaseInfo;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.talent.Talent;
   import engine.talent.Talents;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.page.GuiCharacterStatsConfig;
   import game.gui.page.IGuiCharacterStats;
   import game.gui.page.IGuiCharacterStatsListener;
   import game.gui.page.IGuiPgAbilityPopup;
   import game.gui.pages.GuiPgTalents;
   
   public class GuiCharacterStats extends MovieClip implements IGuiCharacterStats
   {
      
      private static var _statTypes:Array = [null,StatType.ARMOR,StatType.STRENGTH,StatType.WILLPOWER,StatType.EXERTION,StatType.ARMOR_BREAK];
       
      
      private var banners:Array;
      
      private var currentCharacter:IEntityDef;
      
      private var context:IGuiContext;
      
      private var available_points:MovieClip;
      
      private var available_points_text:TextField;
      
      private var available_points_glow:MovieClip;
      
      private var label_points:LocaleAlignableTextField;
      
      public var confirm_button:ButtonWithIndex;
      
      public var cancel_button:ButtonWithIndex;
      
      private var tempStats:Stats;
      
      private var _tempRenown:int;
      
      private var currentStatRanges:StatRanges;
      
      private var changedStats:Array;
      
      private var renown:ButtonWithIndex;
      
      private var playerSetStatTotal:int;
      
      public var _abilityButton:ButtonWithIndex;
      
      private var listener:IGuiCharacterStatsListener;
      
      public var abilityPopup:IGuiPgAbilityPopup;
      
      private var guiConfig:GuiCharacterStatsConfig;
      
      public var _pg_stat_cost:MovieClip;
      
      public var text_stat_cost:TextField;
      
      private var theStage:Stage;
      
      public var _guiTalents:GuiPgTalents;
      
      public var _statDisplays:Vector.<GuiPgStatDisplay>;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_dpad_left:GuiGpBitmap;
      
      private var gp_dpad_right:GuiGpBitmap;
      
      private var cmd_b:Cmd;
      
      private var _callbackActivationGp:Function;
      
      private var _talentsMod:Talents;
      
      private var _talentsOrig:Talents;
      
      public var saga:Saga;
      
      public var talentDisplayCallback:Function;
      
      public var abilityDisplayCallback:Function;
      
      private var setStatStruct:Object;
      
      private var _confirmCancelCanBeVisible:Boolean;
      
      public var visibilityChangeOrdinal:int;
      
      private var wasVisible:Dictionary;
      
      private var gplayer:int;
      
      private var tutorial_id:int;
      
      private var showing_tip_heroes_points:Boolean;
      
      private var showing_tip_heroes_talent:Boolean;
      
      private var showing_tip_heroes_ability:Boolean;
      
      public function GuiCharacterStats()
      {
         this.banners = new Array();
         this._statDisplays = new Vector.<GuiPgStatDisplay>();
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.gp_dpad_left = GuiGp.ctorPrimaryBitmap(GpControlButton.D_L);
         this.gp_dpad_right = GuiGp.ctorPrimaryBitmap(GpControlButton.D_R);
         this.cmd_b = new Cmd("cmd_pg_stats_b",this.cmdfunc_b);
         this.setStatStruct = {
            "statType":StatType,
            "button":ButtonWithIndex,
            "statValue":int,
            "bannerIndex":int,
            "guiDisplayName":String
         };
         this.wasVisible = new Dictionary();
         super();
         GuiUtil.attemptStopAllMovieClips(this);
         this._pg_stat_cost = getChildByName("pg_stat_cost") as MovieClip;
         addChild(this.gp_a);
         addChild(this.gp_b);
         addChild(this.gp_dpad_left);
         addChild(this.gp_dpad_right);
         this._guiTalents = getChildByName("talents") as GuiPgTalents;
         this.gp_a.scale = this.gp_b.scale = this.gp_dpad_left.scale = this.gp_dpad_right.scale = 1.5;
         super.visible = false;
      }
      
      private function localeChangedHandler(param1:Event) : void
      {
         this.setAvailablePointsText();
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiPgStatDisplay = null;
         GuiGp.releasePrimaryBitmap(this.gp_a);
         GuiGp.releasePrimaryBitmap(this.gp_b);
         GuiGp.releasePrimaryBitmap(this.gp_dpad_left);
         GuiGp.releasePrimaryBitmap(this.gp_dpad_right);
         this.gp_a = null;
         this.gp_b = null;
         this.gp_dpad_left = null;
         this.gp_dpad_right = null;
         GpBinder.gpbinder.unbind(this.cmd_b);
         this._guiTalents.cleanup();
         this._guiTalents = null;
         this.cmd_b.cleanup();
         this.cmd_b = null;
         TweenMax.killTweensOf(this.available_points_glow);
         this.removedFromStageHandler(null);
         this.context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this.deactivateGp();
         this.banners = null;
         this.currentCharacter = null;
         for each(_loc1_ in this._statDisplays)
         {
            _loc1_.cleanup();
         }
         this._statDisplays = null;
         if(this.abilityPopup)
         {
            if(this.abilityPopup.mc.parent)
            {
               this.abilityPopup.mc.parent.removeChild(this.abilityPopup.mc);
            }
            this.abilityPopup.removeEventListener(Event.CLOSE,this.handleAbilityVisibilityChanged);
            this.abilityPopup.removeEventListener(Event.OPEN,this.handleAbilityVisibilityChanged);
            this.abilityPopup.cleanup();
            this.abilityPopup = null;
         }
         if(this.renown)
         {
            this.renown.cleanup();
            this.renown = null;
         }
         if(this.cancel_button)
         {
            this.cancel_button.cleanup();
            this.cancel_button = null;
         }
         if(this.confirm_button)
         {
            this.confirm_button.cleanup();
            this.confirm_button = null;
         }
         this.currentStatRanges = null;
         this._abilityButton = null;
         this._pg_stat_cost = null;
         this.text_stat_cost = null;
         this.tempStats = null;
         this.wasVisible = null;
         this._callbackActivationGp = null;
         this.context = null;
         this.listener = null;
         this.guiConfig = null;
      }
      
      public function get tempRenown() : int
      {
         return this._tempRenown;
      }
      
      public function set tempRenown(param1:int) : void
      {
         this._tempRenown = param1;
         if(this.renown)
         {
            this.renown.buttonText = this._tempRenown.toString();
         }
      }
      
      public function init(param1:IGuiContext, param2:IGuiCharacterStatsListener, param3:IGuiPgAbilityPopup, param4:GuiCharacterStatsConfig, param5:IGuiButton, param6:Function) : void
      {
         this._callbackActivationGp = param6;
         this.context = param1;
         this.guiConfig = param4;
         this.listener = param2;
         this.saga = param1.saga;
         this._guiTalents.init(param1,this.talentVisibleHandler,this.talentPointsAllocatorHandler);
         this.available_points = getChildByName("available_points") as MovieClip;
         this.confirm_button = getChildByName("button$confirm") as ButtonWithIndex;
         this.confirm_button.setDownFunction(this.onConfirmButtonClicked);
         this.confirm_button.guiButtonContext = param1;
         this.cancel_button = getChildByName("button$cancel") as ButtonWithIndex;
         this.cancel_button.setDownFunction(this.onCancelButtonClicked);
         this.cancel_button.guiButtonContext = param1;
         this.text_stat_cost = this._pg_stat_cost.getChildByName("text_stat_cost") as TextField;
         this.available_points_text = this.available_points.getChildByName("text") as TextField;
         this.available_points_glow = this.available_points.getChildByName("glow") as MovieClip;
         this.available_points_glow.alpha = 0;
         this.label_points = LocaleAlignableTextField.ctor(this.available_points.getChildByName("label_points") as TextField);
         this.renown = param5 as ButtonWithIndex;
         if(this.renown)
         {
         }
         this.abilityPopup = param3;
         this.abilityPopup.addEventListener(Event.CLOSE,this.handleAbilityVisibilityChanged);
         this.abilityPopup.addEventListener(Event.OPEN,this.handleAbilityVisibilityChanged);
         if(param3)
         {
            addChild(param3.mc);
            param1.translateDisplayObjects(LocaleCategory.GUI,param3.mc);
            param3.init(param1);
         }
         var _loc7_:int = 0;
         while(_loc7_ < _statTypes.length)
         {
            this.banners[_loc7_] = getChildByName("_" + _loc7_) as MovieClip;
            if(!this.banners[_loc7_])
            {
               throw new ArgumentError("no banner " + _loc7_);
            }
            this.banners[_loc7_]._banner.gotoAndStop(_loc7_ + 1);
            _loc7_++;
         }
         this.initStatDisplays();
         if(param1.legend.roster.numCombatants > 0)
         {
            this.setCurrentCharacterIndex(param1.legend.roster.getEntityDef(0));
         }
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this.localeChangedHandler(null);
      }
      
      private function initStatDisplays() : void
      {
         var _loc2_:GuiPgStatDisplay = null;
         var _loc3_:StatType = null;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as GuiPgStatDisplay;
            if(_loc2_)
            {
               if(this._statDisplays.length >= _statTypes.length)
               {
                  throw new IllegalOperationError("bad stat displays, too many");
               }
               _loc3_ = _statTypes[this._statDisplays.length];
               this._statDisplays.push(_loc2_);
               _loc2_.init(this.context,_loc3_,this._talentsMod,this.statDisplayModifyHandler,this.statDisplayStatHandler,this.statDisplayButtonVisibilityHandler);
               if(_loc2_.statType == null)
               {
                  this._abilityButton = _loc2_._buttonStat;
                  this._abilityButton.setDownFunction(this.onAbilityButtonClick);
               }
            }
            _loc1_++;
         }
      }
      
      public function onAbilityButtonClick(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled)
         {
            return;
         }
         this.context.saga.setVar(SagaVar.VAR_TUT_HEROES_ABILITY,true);
         this._hideTipHeroesAbility();
         this.context.setPref(GuiGamePrefs.PREF_PG_ABILITY_FIRST_TIME,false);
         this.resetStats();
         this.theStage = this.stage;
         this.theStage.addEventListener(MouseEvent.MOUSE_DOWN,this.hideAbilityPopup,true);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.setAbilityPopupVisible(true);
      }
      
      private function removedFromStageHandler(param1:Event) : void
      {
         if(this.theStage)
         {
            this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideAbilityPopup,true);
         }
         this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.theStage = null;
      }
      
      private function hideAbilityPopup(param1:MouseEvent) : void
      {
         if(!this.abilityPopup)
         {
            return;
         }
         if(!this.abilityPopup.hitTestAbilityPopup(param1.stageX,param1.stageY))
         {
            if(this.stage)
            {
               this.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideAbilityPopup);
            }
         }
      }
      
      private function resetStats() : void
      {
         this.deactivateGp();
         if(!this.currentCharacter)
         {
            return;
         }
         var _loc1_:int = int(this.currentCharacter.stats.getValue(StatType.RANK));
         var _loc2_:int = this.context.statCosts.getTotalCost(_loc1_,1);
         this._pg_stat_cost.visible = false;
         this.text_stat_cost.text = _loc2_.toString();
         this.changedStats = [];
         this.tempStats = this.currentCharacter.stats.clone(null);
         this._talentsOrig = this.currentCharacter.talents;
         if(!this._talentsOrig)
         {
            this._talentsOrig = new Talents(this.currentCharacter.id + "_gui_orig");
         }
         this._talentsMod = this._talentsOrig.clone();
         this.updateStatDisplaysAvailableTalents();
         this.setConfirmCancelVisiblity(false);
         this.currentStatRanges = this.currentCharacter.statRanges;
         this.playerSetStatTotal = this.tempStats.GetTotalUpgrades(this.currentStatRanges);
         this.setAllStats();
         this.setAvailablePointsText();
         this.tempRenown = int(this.context.legend.renown);
      }
      
      private function setAvailablePointsText() : void
      {
         if(!this.currentCharacter)
         {
            return;
         }
         var _loc1_:int = this.currentCharacter.getMaxUpgrades(this.context.entitiesMetadata,this.context.statCosts);
         var _loc2_:int = !!this._talentsMod ? this._talentsMod.totalRanks : 0;
         var _loc3_:int = _loc1_ - this.playerSetStatTotal - _loc2_;
         this.available_points_text.text = _loc3_.toString();
         if(_loc3_ == 1)
         {
            this.label_points.text = this.context.translate("points_available_sing");
         }
         else
         {
            this.label_points.text = this.context.translate("points_available_plur");
         }
         if(!this.currentCharacter.isSurvivalPromotable)
         {
            _loc3_ = 0;
         }
         this._guiTalents.setPointsAvailable(_loc3_);
         this.updateStatDisplaysAvailablePoints(_loc3_);
         this.context.currentLocale.fixTextFieldFormat(this.label_points.textField);
         this.label_points.realign(this.context.locale);
      }
      
      public function setCurrentCharacterIndex(param1:IEntityDef) : void
      {
         this.currentCharacter = param1;
         this.resetStats();
         if(this.abilityPopup)
         {
            if(this.currentCharacter)
            {
               if(this.abilityPopup.mc.visible)
               {
                  this.setAbilityPopupVisible(true);
               }
            }
            else
            {
               this.setAbilityPopupVisible(false);
            }
         }
         if(!this.currentCharacter)
         {
            this._guiTalents.talents = null;
            this._guiTalents.visible = false;
            this.talentVisibleHandler();
         }
         this._guiTalents.entity = param1;
         this._hideTipHeroesPoints(false);
         this._hideTipHeroesTalent(false);
         this.attemptShowTip();
      }
      
      private function checkStats(param1:int, param2:int, param3:StatType, param4:int) : Boolean
      {
         if(this.tempRenown - param1 < 0)
         {
            this.context.playSound("ui_players_turn");
            if(this.renown)
            {
               this.renown.setStateForCertainTimeframe(GuiButtonState.HOVER,20);
            }
            return true;
         }
         if(param2 > this.currentCharacter.getMaxUpgrades(this.context.entitiesMetadata,this.context.statCosts))
         {
            this.context.playSound("ui_error");
            return true;
         }
         if(param2 < 0 || param4 < this.currentStatRanges.getStatRange(param3).min || this.currentStatRanges.getStatRange(param3).max < param4)
         {
            return true;
         }
         return false;
      }
      
      private function setConfirmCancelVisiblity(param1:Boolean) : void
      {
         var _loc3_:* = false;
         this._confirmCancelCanBeVisible = param1;
         var _loc2_:Boolean = param1 && (Boolean(this._guiTalents) && !this._guiTalents.visible);
         _loc3_ = this.confirm_button.visible != _loc2_;
         _loc3_ = _loc3_ || this.cancel_button.visible != (_loc2_ || this.gplayer);
         this.confirm_button.visible = _loc2_;
         this.cancel_button.visible = _loc2_ || Boolean(this.gplayer);
         this.gp_a.visible = _loc2_;
         this.gp_b.visible = this.cancel_button.visible;
         if(_loc3_)
         {
            ++this.visibilityChangeOrdinal;
         }
      }
      
      protected function onCancelButtonClicked(param1:Object) : void
      {
         this.cancel_button.setStateToNormal();
         this.setCurrentCharacterIndex(this.currentCharacter);
         this.deactivateGp();
      }
      
      protected function onConfirmButtonClicked(param1:Object) : void
      {
         this.confirm_button.setStateToNormal();
         this.purchaseStats();
         this.deactivateGp();
      }
      
      public function update(param1:int) : void
      {
         if(Boolean(this.abilityPopup) && this.abilityPopup.mc.visible)
         {
            this.abilityPopup.update(param1);
         }
      }
      
      private function statDisplayButtonVisibilityHandler(param1:GuiPgStatDisplay) : void
      {
         ++this.visibilityChangeOrdinal;
      }
      
      private function statDisplayStatHandler(param1:GuiPgStatDisplay) : void
      {
         if(!param1)
         {
            return;
         }
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(!Talents.ENABLED)
         {
            return;
         }
         var _loc2_:Point = param1._buttonStat.localToGlobal(new Point(0,0));
         this._guiTalents.showTalentsForStat(param1.statType);
      }
      
      private function statDisplayModifyHandler(param1:GuiPgStatDisplay, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(!param1 || !this.currentCharacter)
         {
            return;
         }
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(param2 > 0)
         {
            _loc3_ = this.currentCharacter.getMaxUpgrades(this.context.entitiesMetadata,this.context.statCosts);
            _loc4_ = !!this._talentsMod ? this._talentsMod.totalRanks : 0;
            _loc5_ = _loc3_ - this.playerSetStatTotal - _loc4_;
            if(!this.currentCharacter.isSurvivalPromotable)
            {
               _loc5_ = 0;
            }
            if(_loc5_ <= 0)
            {
               this.pulseAvailablePointsGlow();
               return;
            }
         }
         else if(param2 < 0)
         {
            _loc6_ = this.tempStats.getValue(param1.statType);
            _loc7_ = int(this.currentCharacter.stats.getValue(param1.statType));
            if(_loc6_ + param2 < _loc7_)
            {
               this.context.playSound("ui_error");
               return;
            }
         }
         this._hideTipHeroesPoints(true);
         this.updateStatValue(param1.statType,param2);
      }
      
      private function updateStatValue(param1:StatType, param2:int) : void
      {
         var _loc3_:int = this.tempStats.getValue(param1);
         var _loc4_:int = this.playerSetStatTotal;
         _loc3_ += param2;
         _loc4_ += param2;
         var _loc5_:int = _loc3_ - this.tempStats.getValue(param1);
         var _loc6_:int = this.context.statCosts.getTotalCost(this.currentCharacter.stats.rank,_loc5_);
         if(this.checkStats(_loc6_,_loc4_,param1,_loc3_))
         {
            this.context.playSound("ui_error");
            return;
         }
         this.context.playSound("ui_stats");
         this.playerSetStatTotal = _loc4_;
         this.setTempStats(_loc3_,param1,_loc6_);
         this.confirmCancelVisiblity();
      }
      
      private function setStat(param1:StatType) : void
      {
         var _loc6_:GuiPgStatDisplay = null;
         var _loc2_:StatRange = this.currentStatRanges.getStatRange(param1);
         var _loc3_:int = this.tempStats.getValue(param1);
         var _loc4_:int = _statTypes.indexOf(param1);
         var _loc5_:MovieClip = this.banners[_loc4_];
         if(param1 == null)
         {
            _loc5_.gotoAndStop(1);
            _loc6_ = this._statDisplays[_loc4_];
            _loc6_.setStatValue(0,0,0,0,0);
            return;
         }
         _loc5_.gotoAndStop(_loc3_ + 2);
         this.tempStats.setBase(param1,_loc3_);
         var _loc7_:int = int(this.currentCharacter.stats.GetTotalUpgrades(this.currentStatRanges));
         var _loc8_:int = !!this._talentsOrig ? this._talentsOrig.totalRanks : 0;
         var _loc9_:int = int(this.currentCharacter.stats.getValue(param1));
         _loc6_ = this._statDisplays[_loc4_];
         var _loc10_:int = this.currentCharacter.getMaxUpgrades(this.context.entitiesMetadata,this.context.statCosts);
         var _loc11_:int = !!this._talentsMod ? this._talentsMod.totalRanks : 0;
         var _loc12_:int = _loc10_ - this.playerSetStatTotal - _loc11_;
         var _loc13_:int = _loc10_ - _loc7_ - _loc8_;
         if(!this.currentCharacter.isSurvivalPromotable)
         {
            _loc12_ = _loc13_ = 0;
         }
         _loc6_.setStatValue(_loc3_,_loc9_,_loc2_.max,_loc12_,_loc13_);
         this._guiTalents.setStatValue(param1,_loc3_,_loc9_,_loc2_.max,_loc12_,_loc13_);
      }
      
      public function setAllStats() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _statTypes.length)
         {
            this.setStat(_statTypes[_loc1_]);
            _loc1_++;
         }
         this.setAvailablePointsText();
         this._guiTalents.updateUpgradable();
      }
      
      private function confirmCancelVisiblity() : void
      {
         var _loc2_:GuiPgStatDisplay = null;
         var _loc1_:int = 0;
         while(_loc1_ < _statTypes.length)
         {
            _loc2_ = this._statDisplays[_loc1_];
            if(_loc2_.modified)
            {
               this.setConfirmCancelVisiblity(true);
               return;
            }
            _loc1_++;
         }
         if(Boolean(this._talentsMod) && this._talentsMod.totalRanks > this._talentsOrig.totalRanks)
         {
            this.setConfirmCancelVisiblity(true);
            return;
         }
         this.setConfirmCancelVisiblity(false);
      }
      
      public function setTempStats(param1:int, param2:StatType, param3:int) : void
      {
         var _loc5_:Talent = null;
         var _loc4_:int = int(this.currentCharacter.stats.getValue(param2));
         this.tempStats.setBase(param2,param1);
         if(this.changedStats.indexOf(param2) < 0)
         {
            this.changedStats.push(param2);
         }
         if(_loc4_ == param1)
         {
            this.tempRenown += Math.max(0,-param3);
         }
         else if(_loc4_ <= param1)
         {
            this.tempRenown += -param3;
         }
         if(param1 < this.currentStatRanges.getStatRange(param2).max)
         {
            _loc5_ = this._talentsMod.getTalentByParentStatType(param2);
            this._talentsMod.removeTalent(_loc5_);
         }
         this.setAllStats();
      }
      
      private function purchaseStats() : void
      {
         var _loc2_:StatType = null;
         var _loc3_:Legend = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc1_:Vector.<StatPurchaseInfo> = new Vector.<StatPurchaseInfo>();
         for each(_loc2_ in this.changedStats)
         {
            _loc5_ = int(this.currentCharacter.stats.getValue(_loc2_));
            _loc6_ = this.tempStats.getValue(_loc2_);
            _loc7_ = _loc6_ - _loc5_;
            _loc1_.push(new StatPurchaseInfo(_loc2_,_loc7_));
         }
         _loc3_ = this.context.legend as Legend;
         _loc4_ = String(this.currentCharacter.id);
         _loc3_.purchaseStats(_loc4_,_loc1_);
         this.currentCharacter.talents = this._talentsMod;
         this.listener.onPurchaseStats();
         this.setCurrentCharacterIndex(this.currentCharacter);
         this.attemptShowTip();
      }
      
      public function handleHelpEnabled() : void
      {
         this.setAbilityPopupVisible(false);
      }
      
      private function setAbilityPopupVisible(param1:Boolean) : void
      {
         if(param1)
         {
            this.abilityPopup.activateAbilityPopup(this.currentCharacter);
         }
         else
         {
            this.abilityPopup.deactivateAbilityPopup();
         }
      }
      
      private function handleAbilityVisibilityChanged(param1:Event) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:Boolean = this.abilityPopup.mc.visible;
         if(this.abilityDisplayCallback != null)
         {
            this.abilityDisplayCallback(_loc2_);
         }
         if(_loc2_ && !this.wasVisible)
         {
            this.wasVisible = new Dictionary();
         }
         var _loc3_:int = 0;
         while(_loc3_ < numChildren)
         {
            _loc4_ = getChildAt(_loc3_);
            if(_loc2_)
            {
               if(_loc4_.visible && _loc4_ != this.abilityPopup)
               {
                  this.wasVisible[_loc4_] = true;
               }
               _loc4_.visible = _loc4_ == this.abilityPopup;
            }
            else if(this.wasVisible[_loc4_])
            {
               _loc4_.visible = true;
            }
            _loc3_++;
         }
         this.attemptShowTip();
      }
      
      private function pulseAvailablePointsGlow() : void
      {
         this.context.playSound("ui_error");
         TweenMax.killTweensOf(this.available_points_glow);
         this.available_points_glow.alpha = 1;
         TweenMax.to(this.available_points_glow,0.4,{
            "delay":0.1,
            "alpha":0
         });
      }
      
      private function updateStatDisplaysAvailablePoints(param1:int) : void
      {
         var _loc2_:GuiPgStatDisplay = null;
         for each(_loc2_ in this._statDisplays)
         {
            _loc2_.availablePoints = param1;
         }
      }
      
      private function updateStatDisplaysAvailableTalents() : void
      {
         var _loc1_:GuiPgStatDisplay = null;
         for each(_loc1_ in this._statDisplays)
         {
            _loc1_.talents = this._talentsMod;
         }
         this._guiTalents.talents = this._talentsMod;
      }
      
      private function deactivateGp() : void
      {
         if(!this.gplayer)
         {
            return;
         }
         if(this.gplayer)
         {
            GpBinder.gpbinder.unbind(this.cmd_b);
            GpBinder.gpbinder.removeLayer(this.gplayer);
            this.gplayer = 0;
         }
         this._callbackActivationGp();
      }
      
      public function isActivatedGp() : Boolean
      {
         return this.gplayer != 0;
      }
      
      private function selectGpStatDisplay(param1:GuiPgStatDisplay) : void
      {
         var _loc2_:GuiPgStatDisplay = null;
         this.gp_dpad_left.visible = this.gp_dpad_right.visible = false;
         for each(_loc2_ in this._statDisplays)
         {
            if(_loc2_ == param1)
            {
               _loc2_.activateGp(this.gp_dpad_left,this.gp_dpad_right);
            }
            else
            {
               _loc2_.deactivateGp();
            }
         }
      }
      
      private function navPressHandler(param1:ButtonWithIndex, param2:Boolean) : Boolean
      {
         var _loc3_:GuiPgStatDisplay = param1.parent as GuiPgStatDisplay;
         if(param2)
         {
            this.selectGpStatDisplay(_loc3_);
         }
         else
         {
            this.confirm_button.press();
         }
         return true;
      }
      
      private function cmdfunc_b(param1:CmdExec) : void
      {
         this.cancel_button.press();
      }
      
      public function handleGpCancel() : Boolean
      {
         if(this.cancel_button.visible)
         {
            this.cancel_button.press();
            return true;
         }
         return false;
      }
      
      private function talentPointsAllocatorHandler() : void
      {
         this.setAvailablePointsText();
      }
      
      private function talentVisibleHandler() : void
      {
         var _loc1_:GuiPgStatDisplay = null;
         var _loc2_:MovieClip = null;
         if(this.talentDisplayCallback != null)
         {
            this.talentDisplayCallback(this._guiTalents.visible);
         }
         this._hideTipHeroesTalent(Boolean(this._guiTalents) && this._guiTalents.visible);
         for each(_loc1_ in this._statDisplays)
         {
            _loc1_.visible = !this._guiTalents.visible;
         }
         for each(_loc2_ in this.banners)
         {
            _loc2_.visible = !this._guiTalents.visible;
         }
         this.confirmCancelVisiblity();
         this.checkTipVisibility();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            this.attemptShowTip();
         }
         this.checkTipVisibility();
      }
      
      private function checkTipVisibility() : void
      {
         if(this.tutorial_id)
         {
            this.context.setTutorialPopupVisible(this.tutorial_id,this.visible && !this._guiTalents.visible);
         }
      }
      
      private function _showTipHeroesTalent(param1:GuiPgStatDisplay) : void
      {
         var _loc2_:String = String(this.context.translateCategory("tut_heroes_talent",LocaleCategory.TUTORIAL));
         this.tutorial_id = this.context.createTutorialPopup(param1._buttonStat,_loc2_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,false,null);
         this.showing_tip_heroes_talent = true;
      }
      
      private function _hideTipHeroesTalent(param1:Boolean) : void
      {
         if(param1)
         {
            this.context.saga.setVar(SagaVar.VAR_TIP_HEROES_TALENT,true);
         }
         if(this.showing_tip_heroes_talent)
         {
            this.context.removeAllTooltips();
            this.tutorial_id = 0;
            this.showing_tip_heroes_talent = false;
         }
      }
      
      private function _hideTipHeroesAbility() : void
      {
         if(this.showing_tip_heroes_ability)
         {
            this.context.removeAllTooltips();
            this.tutorial_id = 0;
            this.showing_tip_heroes_ability = false;
         }
      }
      
      private function _showTipHeroesPoints(param1:GuiPgStatDisplay) : void
      {
         var _loc2_:String = "tut_heroes_points";
         if(!Talents.ENABLED)
         {
            _loc2_ = "tut_heroes_points_notalents";
         }
         var _loc3_:String = String(this.context.translateCategory(_loc2_,LocaleCategory.TUTORIAL));
         this.tutorial_id = this.context.createTutorialPopup(this.available_points,_loc3_,TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,true,false,null);
         this.showing_tip_heroes_points = true;
      }
      
      private function _showTipHeroesAbility() : void
      {
         var _loc1_:String = String(this.context.translateCategory("tut_heroes_ability",LocaleCategory.TUTORIAL));
         this.tutorial_id = this.context.createTutorialPopup(this._abilityButton,_loc1_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,false,null);
         this.showing_tip_heroes_ability = true;
      }
      
      private function _hideTipHeroesPoints(param1:Boolean) : void
      {
         if(param1)
         {
            this.context.saga.setVar(SagaVar.VAR_TIP_HEROES_POINTS,true);
         }
         if(this.showing_tip_heroes_points)
         {
            this.context.removeAllTooltips();
            this.tutorial_id = 0;
            this.showing_tip_heroes_points = false;
         }
      }
      
      public function attemptShowTip() : Boolean
      {
         if(!this.context || !visible || !this.saga || this.saga.isSurvival)
         {
            return false;
         }
         return this.attemptShowTipHeroesAbility() || this.attemptShowTipHeroesPoints() || this.attemptShowTipHeroesTalent();
      }
      
      public function attemptShowTipHeroesAbility() : Boolean
      {
         if(this.tutorial_id || !visible || !this.saga || this.saga.isSurvival)
         {
            return false;
         }
         if(!this.context || !this.context.saga)
         {
            return false;
         }
         var _loc1_:Boolean = this.context.saga.getVarBool(SagaVar.VAR_TUT_HEROES_ABILITY);
         if(_loc1_)
         {
            return false;
         }
         this._showTipHeroesAbility();
         return true;
      }
      
      public function attemptShowTipHeroesTalent() : Boolean
      {
         var _loc3_:GuiPgStatDisplay = null;
         var _loc4_:StatType = null;
         if(this.tutorial_id || !visible || !this.saga || this.saga.isSurvival)
         {
            return false;
         }
         if(this._guiTalents._pointsAvailable <= 0 || this.currentCharacter == null)
         {
            return false;
         }
         var _loc1_:Boolean = this.context.saga.getVarBool(SagaVar.VAR_TIP_HEROES_TALENT);
         if(_loc1_)
         {
            return false;
         }
         var _loc2_:Talents = this.currentCharacter.talents;
         if(!_loc2_)
         {
            return false;
         }
         for each(_loc3_ in this._statDisplays)
         {
            _loc4_ = _loc3_.statType;
            if(_loc4_)
            {
               if(_loc3_._buttonStat.isUpgradable)
               {
                  this._showTipHeroesTalent(_loc3_);
                  return true;
               }
            }
         }
         return false;
      }
      
      public function attemptShowTipHeroesPoints() : Boolean
      {
         var _loc2_:GuiPgStatDisplay = null;
         var _loc3_:StatType = null;
         var _loc4_:StatRange = null;
         var _loc5_:int = 0;
         if(this.tutorial_id || !visible || !this.currentCharacter || !this.saga || this.saga.isSurvival)
         {
            return false;
         }
         if(this._guiTalents._pointsAvailable <= 0 || this.currentCharacter == null)
         {
            return false;
         }
         var _loc1_:Boolean = this.context.saga.getVarBool(SagaVar.VAR_TIP_HEROES_POINTS);
         if(_loc1_)
         {
            return false;
         }
         for each(_loc2_ in this._statDisplays)
         {
            _loc3_ = _loc2_.statType;
            if(_loc3_)
            {
               _loc4_ = this.currentCharacter.statRanges.getStatRange(_loc3_);
               _loc5_ = int(this.currentCharacter.stats.getValue(_loc3_));
               if(_loc5_ < _loc4_.max)
               {
                  this._showTipHeroesPoints(_loc2_);
                  return true;
               }
            }
         }
         return false;
      }
   }
}
