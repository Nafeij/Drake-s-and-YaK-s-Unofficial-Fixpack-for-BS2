package game.gui.battle
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import engine.battle.board.model.BattleScenario;
   import engine.battle.board.model.IBattleScenario;
   import engine.battle.fsm.BattleRewardData;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.WarOutcome;
   import engine.saga.WarOutcomeType;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiIcon;
   import game.gui.IGuiContext;
   
   public class GuiMatchResolution extends GuiBase implements IGuiMatchResolution, IGuiMatchResolution_PanelContainer, IGuiMatchResolutionListener
   {
       
      
      public var _victory:MovieClip;
      
      public var _obj_complete:MovieClip;
      
      public var _obj_failed:MovieClip;
      
      public var _rewardsTitle:MovieClip;
      
      public var _consequencesTitle:MovieClip;
      
      public var _rewards:GuiMatchResolution_Rewards;
      
      public var _items:GuiMatchResolution_Items;
      
      public var _retreat:MovieClip;
      
      public var _renownTotal:MovieClip;
      
      public var _renownGrows:TextField;
      
      public var _promotion:MovieClip;
      
      public var _injury:MovieClip;
      
      public var _warRenownClansmen:MovieClip;
      
      public var _killsAndBonuses:GuiKillsAndBonuses;
      
      public var _guiWarOutcome:GuiWarOutcome;
      
      public var _guiObjectiveResults:GuiObjectiveResults;
      
      public var _defeat:MovieClip;
      
      public var _button$continue:ButtonWithIndex;
      
      public var _button_survival$continue:ButtonWithIndex;
      
      public var _button_survival$survival_reload:ButtonWithIndex;
      
      public var _background_victory:MovieClip;
      
      public var _background_victory_torn:MovieClip;
      
      public var _background_defeat:MovieClip;
      
      public var _background_defeat_torn:MovieClip;
      
      public var _backdrop_banner:MovieClip;
      
      public var _backdrop_banner_torn:MovieClip;
      
      public var victor:Boolean;
      
      public var back_button:ButtonWithIndex;
      
      public var victoryOrDefeatMovieClip:MovieClip;
      
      public var renownGrowsStartingY:Number;
      
      public var victoryOrDefeatStartingY:Number;
      
      public var rewardsTitleStartingY:Number;
      
      public var consequencesTitleStartingY:Number;
      
      public var promotionStartingY:Number;
      
      public var injuryStartingY:Number;
      
      public var warRenownStartingY:Number;
      
      public var promotionPortrait:MovieClip;
      
      public var injuryPortrait:MovieClip;
      
      public var promotionName:TextField;
      
      public var injuryName:TextField;
      
      public var _war_renown_desc:TextField;
      
      public var _war_renown_text:TextField;
      
      public var listener:IGuiMatchPageListener;
      
      public var battleRewardData:BattleRewardData;
      
      public var unitsReadyToPromote:Vector.<String>;
      
      public var unitsInjured:Vector.<String>;
      
      public var promotionNameStartingY:Number;
      
      public var injuryNameStartingY:Number;
      
      public var injuryNameStartingWidth:Number;
      
      public var unitsReadyToPromoteIndex:int;
      
      public var unitsInjuredIndex:int;
      
      public var spears:MovieClip;
      
      public var renownTotalText:TextField;
      
      public var renownCount:Number;
      
      public var renownTargetCount:Number = 10;
      
      public var renownTotalBanner:MovieClip;
      
      public var outcome:WarOutcome;
      
      public var _finished:Boolean;
      
      public var showStats:Boolean;
      
      private var gp_cross:GuiGpBitmap;
      
      private var gp_x:GuiGpBitmap;
      
      private var _scenario:BattleScenario;
      
      private var _gameover:MovieClip;
      
      private var _text_gameover_desc:TextField;
      
      private var _injury_panel_injury:MovieClip;
      
      private var _injury_panel_dead:MovieClip;
      
      private var _panel:IGuiMatchResolution_Panel;
      
      private var _matchPageDoneAnimating:Boolean;
      
      private var renownTotalTextCenter:Point;
      
      private var isSurvivalFinalizingSpears:Boolean;
      
      private var renownCounterDelay:Number = 0.3;
      
      public function GuiMatchResolution()
      {
         this.unitsReadyToPromote = new Vector.<String>();
         this.unitsInjured = new Vector.<String>();
         this.gp_cross = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_x = GuiGp.ctorPrimaryBitmap(GpControlButton.X,true);
         this.renownTotalTextCenter = new Point();
         super();
         addChild(this.gp_cross);
         this.gp_cross.visible = false;
         addChild(this.gp_x);
         this.gp_x.visible = false;
         name = "match_resolution";
         this.visible = false;
         this._victory = getChildByName("victory") as MovieClip;
         this._obj_complete = getChildByName("obj_complete") as MovieClip;
         this._obj_failed = getChildByName("obj_failed") as MovieClip;
         this._rewardsTitle = getChildByName("rewardsTitle") as MovieClip;
         this._consequencesTitle = getChildByName("consequencesTitle") as MovieClip;
         var _loc1_:TextField = this._rewardsTitle.getChildByName("$mr_rewards") as TextField;
         registerScalableTextfield(_loc1_);
         var _loc2_:TextField = this._rewardsTitle.getChildByName("$mr_consequences") as TextField;
         registerScalableTextfield(_loc2_);
         this._rewards = new GuiMatchResolution_Rewards(this,getChildByName("rewards") as MovieClip,this.rewardsFinished);
         this._items = new GuiMatchResolution_Items(this,getChildByName("items") as MovieClip,this.itemsFinished);
         this._retreat = getChildByName("retreat") as MovieClip;
         this._renownTotal = getChildByName("renownTotal") as MovieClip;
         this._renownGrows = getChildByName("renownGrows") as TextField;
         this._promotion = getChildByName("promotion") as MovieClip;
         this._injury = getChildByName("injury") as MovieClip;
         this._warRenownClansmen = getChildByName("warRenownClansmen") as MovieClip;
         this._killsAndBonuses = getChildByName("killsAndBonuses") as GuiKillsAndBonuses;
         this._guiWarOutcome = getChildByName("guiWarOutcome") as GuiWarOutcome;
         this._guiObjectiveResults = getChildByName("guiObjectiveResults") as GuiObjectiveResults;
         this._defeat = getChildByName("defeat") as MovieClip;
         this._button$continue = getChildByName("button$continue") as ButtonWithIndex;
         this._button_survival$continue = requireGuiChild("button_survival$continue") as ButtonWithIndex;
         this._button_survival$survival_reload = requireGuiChild("button_survival$survival_reload") as ButtonWithIndex;
         this._background_victory = getChildByName("background_victory") as MovieClip;
         this._background_victory_torn = getChildByName("background_victory_torn") as MovieClip;
         this._background_defeat = getChildByName("background_defeat") as MovieClip;
         this._background_defeat_torn = getChildByName("background_defeat_torn") as MovieClip;
         this._backdrop_banner = getChildByName("backdrop_banner") as MovieClip;
         this._backdrop_banner_torn = getChildByName("backdrop_banner_torn") as MovieClip;
         this._gameover = getChildByName("gameover") as MovieClip;
         this._text_gameover_desc = getChildByName("text_gameover_desc") as TextField;
         this._rewardsTitle.mouseEnabled = this._rewardsTitle.mouseChildren = false;
         this._consequencesTitle.mouseEnabled = this._consequencesTitle.mouseChildren = false;
         this._victory.mouseEnabled = this._victory.mouseChildren = false;
         this._obj_complete.mouseEnabled = this._obj_complete.mouseChildren = false;
         this._obj_failed.mouseEnabled = this._obj_failed.mouseChildren = false;
         this._gameover.mouseEnabled = false;
         this._text_gameover_desc.mouseEnabled = false;
         this._gameover.visible = false;
         this._text_gameover_desc.visible = false;
         this._retreat.mouseEnabled = this._retreat.mouseChildren = false;
         this._renownTotal.mouseEnabled = this._renownTotal.mouseChildren = false;
         this._promotion.mouseEnabled = this._promotion.mouseChildren = false;
         this._injury.mouseEnabled = this._injury.mouseChildren = false;
         this._warRenownClansmen.mouseEnabled = this._warRenownClansmen.mouseChildren = false;
         this._killsAndBonuses.mouseEnabled = this._killsAndBonuses.mouseChildren = false;
         this._guiWarOutcome.mouseEnabled = this._guiWarOutcome.mouseChildren = false;
         this._guiObjectiveResults.mouseEnabled = this._guiObjectiveResults.mouseChildren = false;
         this._defeat.mouseEnabled = this._defeat.mouseChildren = false;
         this._background_victory.mouseEnabled = this._background_victory.mouseChildren = false;
         this._background_defeat.mouseEnabled = this._background_defeat.mouseChildren = false;
         this._renownGrows.mouseEnabled = false;
         this._injury_panel_injury = this._injury.getChildByName("panel_injury") as MovieClip;
         this._injury_panel_dead = this._injury.getChildByName("panel_dead") as MovieClip;
         this._injury_panel_injury.visible = false;
         this._injury_panel_dead.visible = false;
      }
      
      public function init(param1:IGuiMatchPageListener, param2:IBattleScenario, param3:WarOutcome, param4:BattleRewardData, param5:Vector.<String>, param6:Vector.<String>, param7:Boolean, param8:IGuiContext, param9:Boolean) : void
      {
         this._scenario = param2 as BattleScenario;
         this.showStats = param9;
         this.unitsReadyToPromote = param5;
         this.unitsInjured = param6;
         this.listener = param1;
         this.battleRewardData = param4;
         this.outcome = param3;
         this.victor = param7;
         initGuiBase(param8);
         var _loc10_:MovieClip = this._injury_panel_injury.getChildByName("censor") as MovieClip;
         var _loc11_:MovieClip = this._injury_panel_dead.getChildByName("censor") as MovieClip;
         GuiUtil.performCensor(_loc10_,_context.censorId,logger);
         GuiUtil.performCensor(_loc11_,_context.censorId,logger);
         _context.removeAllTooltips();
         this._victory.visible = false;
         this._obj_complete.visible = false;
         this._obj_failed.visible = false;
         this._defeat.visible = false;
         this._retreat.visible = false;
         this.rewardsTitleStartingY = this._rewardsTitle.y;
         this._rewardsTitle.y -= this._rewardsTitle.height;
         this._rewardsTitle.visible = false;
         this.consequencesTitleStartingY = this._consequencesTitle.y;
         this._consequencesTitle.y -= this._consequencesTitle.height;
         this._consequencesTitle.visible = false;
         this._rewards.init(param8);
         this._items.init(param8);
         this._guiWarOutcome.init(param8,this,this.outcome,param4);
         this._guiObjectiveResults.init(param8,this._scenario,this);
         this._killsAndBonuses.init(param8,this,param4);
         this._renownGrows.visible = false;
         this.renownGrowsStartingY = this._renownGrows.y;
         if(param2)
         {
            if(param2.complete)
            {
               this.showMatchResolution(true);
               this.victoryOrDefeatMovieClip = this._obj_complete;
            }
            else
            {
               this.showMatchResolution(false);
               this.victoryOrDefeatMovieClip = this._obj_failed;
            }
         }
         else if(Boolean(this.outcome) && this.outcome.type == WarOutcomeType.RETREAT)
         {
            this.showMatchResolution(false);
            this.victoryOrDefeatMovieClip = this._retreat;
         }
         else if(param7)
         {
            this.showMatchResolution(true);
            this.victoryOrDefeatMovieClip = this._victory;
         }
         else
         {
            this.showMatchResolution(false);
            this.victoryOrDefeatMovieClip = this._defeat;
         }
         this.victoryOrDefeatStartingY = this.victoryOrDefeatMovieClip.y;
         this.victor = param7;
         this._promotion.visible = false;
         this._injury.visible = false;
         this._warRenownClansmen.visible = false;
         this.promotionStartingY = this._promotion.y;
         this.promotionPortrait = this._promotion.getChildByName("promotePortrait") as MovieClip;
         this.promotionPortrait.mouseEnabled = this.promotionPortrait.mouseChildren = false;
         this.promotionName = this._promotion.getChildByName("unitName") as TextField;
         this.promotionNameStartingY = this.promotionName.y;
         var _loc12_:TextField = this._promotion.getChildByName("$mr_promotion_desc1") as TextField;
         var _loc13_:TextField = this._promotion.getChildByName("$mr_promotion_desc2") as TextField;
         registerScalableTextfield(_loc12_);
         registerScalableTextfield(_loc13_);
         this.injuryStartingY = this._injury.y;
         this.injuryPortrait = this._injury.getChildByName("injuryPortrait") as MovieClip;
         this.injuryPortrait.mouseEnabled = this.injuryPortrait.mouseChildren = false;
         this.injuryName = this._injury.getChildByName("unitName") as TextField;
         this.injuryNameStartingY = this.injuryName.y;
         this.injuryNameStartingWidth = this.injuryName.width;
         this.warRenownStartingY = this._warRenownClansmen.y;
         this._war_renown_desc = this._warRenownClansmen.getChildByName("war_renown_desc") as TextField;
         this._war_renown_text = this._warRenownClansmen.getChildByName("war_renown_text") as TextField;
         registerScalableTextfield(this._war_renown_desc);
         registerScalableTextfield(this._war_renown_text);
         this._renownTotal = getChildByName("renownTotal") as MovieClip;
         this._renownTotal.visible = false;
         this._renownTotal.stop();
         this._renownTotal.mouseEnabled = this._renownTotal.mouseChildren = false;
         this.renownTotalBanner = this._renownTotal.getChildByName("banner") as MovieClip;
         this.renownTotalBanner.gotoAndStop(1);
         this.renownTotalBanner.mouseEnabled = this.renownTotalBanner.mouseChildren = false;
         this.spears = this._renownTotal.getChildByName("spears") as MovieClip;
         this.spears.gotoAndStop(1);
         this.spears.mouseEnabled = this.spears.mouseChildren = false;
         this._rewards.setupAwards(param4);
         this._items.setupAwards(param4);
         this._button$continue.guiButtonContext = _context;
         this._button$continue.visible = false;
         this.gp_cross.visible = false;
         this.gp_x.visible = false;
         this._button$continue.setDownFunction(this.onQuitOrTownButtonDown);
         this._button_survival$continue.setDownFunction(this.survivalContinueButtonHandler);
         this._button_survival$survival_reload.setDownFunction(this.survivalReloadButtonHandler);
         this._button_survival$continue.visible = false;
         this._button_survival$survival_reload.visible = false;
         this._button_survival$continue.guiButtonContext = _context;
         this._button_survival$survival_reload.guiButtonContext = _context;
         this.startAnimatingMatchResolution();
         this.checkButtonVisibility();
      }
      
      private function showMatchResolution(param1:Boolean) : void
      {
         var _loc2_:Boolean = context.saga.getVarBool(SagaVar.VAR_MATCH_RESOLUTION_BANNER_TORN);
         if(_loc2_)
         {
            this._backdrop_banner.visible = false;
            this._background_victory.visible = false;
            this._background_defeat.visible = false;
            this._backdrop_banner_torn.visible = true;
            this._background_victory_torn.visible = param1;
            this._background_defeat_torn.visible = !param1;
         }
         else
         {
            this._backdrop_banner_torn.visible = false;
            this._background_victory_torn.visible = false;
            this._background_defeat_torn.visible = false;
            this._backdrop_banner.visible = true;
            this._background_victory.visible = param1;
            this._background_defeat.visible = !param1;
         }
      }
      
      private function survivalContinueButtonHandler(param1:ButtonWithIndex) : void
      {
         this.listener.quitGameButtonClickHandler(param1);
      }
      
      private function survivalReloadButtonHandler(param1:ButtonWithIndex) : void
      {
         _context.saga.survivalReload();
      }
      
      private function onQuitOrTownButtonDown(param1:ButtonWithIndex) : void
      {
         _context.logger.info("GuiMatchResolution.onQuitOrTownButtonDown [" + param1 + "]");
         if(param1.name == "newGameButton")
         {
            this.listener.newGameButtonClickHandler(param1);
         }
         else
         {
            this.listener.quitGameButtonClickHandler(param1);
         }
      }
      
      public function cleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this.gp_cross);
         this.gp_cross = null;
         GuiGp.releasePrimaryBitmap(this.gp_x);
         this.gp_x = null;
         TweenMax.killDelayedCallsTo(this.hideWarRenownClansmen);
         TweenMax.killDelayedCallsTo(this.showInjuries);
         TweenMax.killDelayedCallsTo(this.displayInjury);
         TweenMax.killDelayedCallsTo(this.displayPromotion);
         TweenMax.killTweensOf(this._warRenownClansmen);
         TweenMax.killTweensOf(this);
         TweenMax.killTweensOf(this.victoryOrDefeatMovieClip);
         TweenMax.killTweensOf(this._renownGrows);
         TweenMax.killTweensOf(this._rewardsTitle);
         TweenMax.killTweensOf(this._consequencesTitle);
         TweenMax.killTweensOf(this._promotion);
         TweenMax.killTweensOf(this._injury);
         TweenMax.killDelayedCallsTo(this.renownGrowsStartAnimating);
         TweenMax.killDelayedCallsTo(this.killsAndBonusesStartAnimating);
         TweenMax.killDelayedCallsTo(this.noStatsFinishRenownGrows);
         TweenMax.killDelayedCallsTo(this.onKillsAndbonusesComplete);
         TweenMax.killDelayedCallsTo(this.showRenownCounter);
         TweenMax.killChildTweensOf(this);
         if(this.renownTotalBanner)
         {
            this.renownTotalBanner.removeEventListener(Event.EXIT_FRAME,this.renownTotalAnimating);
            this.renownTotalBanner.removeEventListener(Event.EXIT_FRAME,this.renownTotalDoneAnimating);
         }
         if(_context)
         {
            _context.logger.info("GuiMatchResolution.cleanup");
         }
         this._button$continue.cleanup();
         this._button$continue = null;
         if(this._rewards)
         {
            this._rewards.cleanup();
            this._rewards = null;
         }
         if(this._items)
         {
            this._items.cleanup();
            this._items = null;
         }
         this._killsAndBonuses.cleanup();
         this._killsAndBonuses = null;
         this._guiWarOutcome.cleanup();
         this._guiWarOutcome = null;
         this._guiObjectiveResults.cleanup();
         this._guiObjectiveResults = null;
         this.outcome = null;
         this.battleRewardData = null;
         this.listener = null;
         this.unitsReadyToPromote = null;
         this.unitsInjured = null;
         this._promotion = null;
         this._warRenownClansmen = null;
         if(this.back_button)
         {
            this.back_button.cleanup();
            this.back_button = null;
         }
         this._button_survival$continue.cleanup();
         this._button_survival$survival_reload.cleanup();
         this._button_survival$continue = null;
         this._button_survival$survival_reload = null;
         super.cleanupGuiBase();
      }
      
      private function checkButtonVisibility() : void
      {
         var _loc1_:Boolean = this.finished;
         if(!_context)
         {
         }
         var _loc2_:Boolean = Boolean(_context.saga) && _context.saga.isSurvival;
         this.gp_cross.visible = _loc1_;
         this.gp_x.visible = _loc1_ && _loc2_;
         this._button$continue.visible = !_loc2_ && _loc1_;
         if(this._button$continue.visible)
         {
            GuiGp.placeIconRight(this._button$continue,this.gp_cross);
         }
         this._button_survival$continue.visible = _loc2_ && _loc1_;
         this._button_survival$survival_reload.visible = _loc2_ && _loc1_;
         if(this._button_survival$continue.visible)
         {
            GuiGp.placeIconRight(this._button_survival$continue,this.gp_cross);
            GuiGp.placeIconLeft(this._button_survival$survival_reload,this.gp_x);
         }
      }
      
      private function startAnimatingMatchResolution() : void
      {
         context.playSound("ui_stats_lo");
         var _loc1_:Number = this.y;
         this.y -= this.height;
         this.visible = true;
         TweenMax.to(this,0.6,{
            "y":_loc1_,
            "onComplete":this.matchPageDoneAnimatingHandler
         });
      }
      
      private function matchPageDoneAnimatingHandler() : void
      {
         this._matchPageDoneAnimating = true;
         this._rewardsTitle.visible = false;
         this._consequencesTitle.visible = false;
         this._rewards.hideRewards();
         this._items.hideItems();
         this._killsAndBonuses.visible = false;
         this._guiWarOutcome.visible = false;
         this._guiObjectiveResults.visible = false;
         this._renownGrows.visible = false;
         this.checkButtonVisibility();
         this.victoryOrDefeatMovieClip.y = this.victoryOrDefeatStartingY - this.victoryOrDefeatMovieClip.height - 140;
         this.victoryOrDefeatMovieClip.visible = true;
         TweenMax.to(this.victoryOrDefeatMovieClip,0.4,{
            "delay":0.4,
            "y":this.victoryOrDefeatStartingY,
            "onComplete":this.victoryOrDefeatDoneAnimating
         });
      }
      
      private function victoryOrDefeatDoneAnimating() : void
      {
         if(_context.saga.isSurvival)
         {
            if(!this.victor)
            {
               TweenMax.delayedCall(0.6,this.renownGrowsDoneAnimating);
               return;
            }
         }
         TweenMax.delayedCall(0.6,this.renownGrowsStartAnimating);
      }
      
      private function renownGrowsStartAnimating() : void
      {
         if(!context)
         {
            return;
         }
         if(Boolean(this.outcome) && this.outcome.type == WarOutcomeType.RETREAT)
         {
            if(this.outcome.threat > 10)
            {
               this._renownGrows.htmlText = context.translate("mr_retreat_tactical");
            }
            else
            {
               this._renownGrows.htmlText = context.translate("mr_retreat_coward");
            }
         }
         else
         {
            this._renownGrows.htmlText = context.translate("mr_renown_grows");
         }
         if(Boolean(context) && Boolean(context.locale))
         {
            context.locale.fixTextFieldFormat(this._renownGrows);
         }
         this._renownGrows.y = this.renownGrowsStartingY - this._renownGrows.height * 2.5;
         this._renownGrows.visible = true;
         TweenMax.to(this._renownGrows,0.4,{
            "y":this.renownGrowsStartingY,
            "onComplete":this.renownGrowsDoneAnimating
         });
      }
      
      private function renownGrowsDoneAnimating() : void
      {
         if(Boolean(this._scenario) && Boolean(this._scenario.objectives.length))
         {
            this.animateOutRenownGrows();
            this._guiObjectiveResults.displayAndPlay();
         }
         else if(this.showStats)
         {
            TweenMax.delayedCall(0.6,this.killsAndBonusesStartAnimating);
         }
         else
         {
            TweenMax.delayedCall(0.6,this.noStatsFinishRenownGrows);
         }
      }
      
      public function handleObjectiveResultsComplete() : void
      {
         if(this.showStats)
         {
            TweenMax.delayedCall(0.6,this.killsAndBonusesStartAnimating);
         }
         else
         {
            TweenMax.delayedCall(0.5,this.onKillsAndbonusesComplete);
         }
      }
      
      private function noStatsFinishRenownGrows() : void
      {
         if(!context)
         {
            return;
         }
         this.animateOutRenownGrows();
         TweenMax.delayedCall(0.5,this.onKillsAndbonusesComplete);
      }
      
      private function animateOutRenownGrows() : void
      {
         var _loc1_:Number = 0.5;
         TweenMax.to(this._renownGrows,1,{
            "delay":_loc1_,
            "y":this.y + this.height
         });
         TweenMax.to(this.victoryOrDefeatMovieClip,1,{
            "delay":_loc1_,
            "y":this.y + this.height
         });
      }
      
      private function killsAndBonusesStartAnimating() : void
      {
         if(!context)
         {
            return;
         }
         this.animateOutRenownGrows();
         if(this.outcome)
         {
            this._guiWarOutcome.displayAndPlay();
         }
         else
         {
            this._killsAndBonuses.displayAndPlay();
         }
      }
      
      public function onKillsAndbonusesComplete() : void
      {
         if(!context)
         {
            return;
         }
         if(Boolean(this.outcome) && Boolean(this.outcome.renown_clansmen))
         {
            this.showRewardTitle(this.displayWarRenownClansmen);
         }
         else if(!this._rewards.empty)
         {
            this.showRewardTitle(this._rewards.displayAwards);
         }
         else if(!this._items.empty)
         {
            this.showRewardTitle(this._items.displayItems);
         }
         else if(Boolean(this.unitsReadyToPromote) && this.unitsReadyToPromote.length > 0)
         {
            this.showRewardTitle(this.displayPromotion);
         }
         else if(Boolean(this.unitsInjured) && this.unitsInjured.length > 0)
         {
            this.showInjuries();
         }
         else
         {
            this.playRenownTotal();
         }
      }
      
      private function showRewardTitle(param1:Function) : void
      {
         scaleTextfields();
         this._rewardsTitle.visible = true;
         this._consequencesTitle.visible = false;
         if(this._rewardsTitle.y == this.rewardsTitleStartingY)
         {
            param1();
         }
         else
         {
            this._rewardsTitle.y = this.rewardsTitleStartingY - this._rewardsTitle.height;
            TweenMax.to(this._rewardsTitle,0.4,{
               "y":this.rewardsTitleStartingY,
               "onComplete":param1
            });
         }
      }
      
      private function showInjuries() : void
      {
         var _loc1_:int = 0;
         _context.logger.info("GuiMatchResolution.showInjuries");
         scaleTextfields();
         this._consequencesTitle.visible = false;
         if(this._rewardsTitle.visible)
         {
            context.playSound("ui_stats_wipes_minor");
            _loc1_ = this.y + this.height * 0.2;
            _context.logger.info("GuiMatchResolution.showInjuries TWEENING to y=" + _loc1_);
            TweenMax.to(this._rewardsTitle,0.6,{
               "y":_loc1_,
               "onComplete":this._startDisplayInjuries
            });
            return;
         }
         this._startDisplayInjuries();
      }
      
      private function _startDisplayInjuries() : void
      {
         var _loc1_:int = 0;
         _context.logger.info("GuiMatchResolution._startDisplayInjuries");
         this._consequencesTitle.visible = true;
         if(this._consequencesTitle.y == this.consequencesTitleStartingY)
         {
            this.displayInjury();
         }
         else
         {
            this._consequencesTitle.y = this.consequencesTitleStartingY - this._consequencesTitle.height;
            _loc1_ = this.consequencesTitleStartingY;
            _context.logger.info("GuiMatchResolution._startDisplayInjuries TWEENING to y=" + _loc1_);
            TweenMax.to(this._consequencesTitle,0.4,{
               "y":_loc1_,
               "onComplete":this.displayInjury
            });
         }
      }
      
      private function hideRewardTitle(param1:int = 2) : void
      {
         this._panel = null;
         context.playSound("ui_stats_wipes_minor");
         TweenMax.to(this._rewardsTitle,0.6,{
            "delay":param1,
            "y":this.y + this.height * 0.2,
            "onComplete":this.playRenownTotal
         });
      }
      
      private function rewardsFinished() : void
      {
         if(!this._items.empty)
         {
            this._rewards.slideOut(this._items.displayItems);
         }
         else
         {
            this.itemsFinished();
         }
      }
      
      private function _slideOutAndDisplayNext(param1:Function) : void
      {
         if(this._panel)
         {
            this._panel.slideOut(param1);
         }
         else if(param1 != null)
         {
            param1();
         }
      }
      
      private function itemsFinished() : void
      {
         if(Boolean(this.unitsReadyToPromote) && this.unitsReadyToPromote.length > 0)
         {
            this._slideOutAndDisplayNext(this.displayPromotion);
         }
         else if(Boolean(this.unitsInjured) && this.unitsInjured.length > 0)
         {
            this._slideOutAndDisplayNext(this.showInjuries);
         }
         else
         {
            this._slideOutAndDisplayNext(null);
            this.hideRewardTitle();
         }
      }
      
      private function displayPromotion() : void
      {
         context.playSound("ui_stats_promote");
         var _loc1_:IEntityDef = context.legend.roster.getEntityDefById(this.unitsReadyToPromote[this.unitsReadyToPromoteIndex]);
         if(!_loc1_)
         {
            return;
         }
         this.promotionName.scaleX = this.promotionName.scaleY = 1;
         this.promotionName.y = this.promotionNameStartingY;
         this.promotionName.text = _loc1_.name;
         if(this.promotionPortrait.numChildren > 1)
         {
            this.promotionPortrait.removeChildAt(this.promotionPortrait.numChildren - 1);
         }
         var _loc2_:GuiIcon = _context.getEntityVersusPortrait(_loc1_);
         if(_loc2_)
         {
            this.promotionPortrait.addChild(_loc2_);
         }
         _context.locale.fixTextFieldFormat(this.promotionName,null,null,true);
         GuiUtil.scaleTextToFit(this.promotionName,this.promotionName.width);
         this._promotion.y = this.promotionStartingY - this._promotion.height;
         this._promotion.visible = true;
         scaleTextfields();
         TweenMax.to(this._promotion,0.4,{
            "y":this.promotionStartingY,
            "onComplete":this.hidePromotion
         });
         ++this.unitsReadyToPromoteIndex;
      }
      
      private function displayInjury() : void
      {
         context.playSound("ui_stats_promote");
         var _loc1_:String = this.unitsInjured[this.unitsInjuredIndex];
         var _loc2_:IEntityDef = _context.legend.roster.getEntityDefById(_loc1_);
         _context.logger.info("GuiMatchResolution.displayInjury " + this.unitsInjuredIndex + " " + _loc1_ + " " + _loc2_);
         if(!_loc2_)
         {
            _context.logger.info("GuiMatchResolution.displayInjury NO ENTITY [" + _loc1_ + "]!");
            ++this.unitsInjuredIndex;
            this.hideInjury();
            return;
         }
         var _loc3_:Saga = _context.saga;
         var _loc4_:Boolean = _loc3_.isSurvival;
         this._injury_panel_injury.visible = !_loc4_;
         this._injury_panel_dead.visible = _loc4_;
         this.injuryName.scaleX = this.injuryName.scaleY = 1;
         this.injuryName.y = this.injuryNameStartingY;
         this.injuryName.width = this.injuryNameStartingWidth;
         this.injuryName.text = _loc2_.name;
         _context.locale.fixTextFieldFormat(this.injuryName);
         if(this.injuryPortrait.numChildren > 1)
         {
            this.injuryPortrait.removeChildAt(this.injuryPortrait.numChildren - 1);
         }
         var _loc5_:GuiIcon = _context.getEntityVersusPortrait(_loc2_);
         if(_loc5_)
         {
            this.injuryPortrait.addChild(_loc5_);
         }
         GuiUtil.scaleTextToFit(this.injuryName,this.injuryName.width);
         this.injuryName.height += 10;
         this._injury.y = this.injuryStartingY - this._injury.height;
         this._injury.visible = true;
         scaleTextfields();
         TweenMax.to(this._injury,0.4,{
            "y":this.injuryStartingY,
            "onComplete":this.hideInjury
         });
         ++this.unitsInjuredIndex;
      }
      
      private function displayWarRenownClansmen() : void
      {
         context.playSound("ui_stats_promote");
         var _loc1_:String = String(context.translate("mr_war_renown_clansmen_desc"));
         var _loc2_:String = StringUtil.formatCommaInteger(this.outcome.clansmen_saved);
         _loc1_ = _loc1_.replace("$NUM_CLANSMEN",_loc2_);
         this._war_renown_desc.htmlText = _loc1_;
         var _loc3_:String = "+" + this.outcome.renown_clansmen;
         this._war_renown_text.htmlText = _loc3_;
         _context.locale.fixTextFieldFormat(this._war_renown_desc);
         _context.locale.fixTextFieldFormat(this._war_renown_text);
         scaleTextfields();
         this._war_renown_desc.height = 200;
         this._warRenownClansmen.y = this.warRenownStartingY - this._warRenownClansmen.height;
         this._warRenownClansmen.visible = true;
         TweenMax.to(this._warRenownClansmen,0.4,{
            "y":this.warRenownStartingY,
            "onComplete":this.shownWarRenownClansmen
         });
      }
      
      private function shownWarRenownClansmen() : void
      {
         TweenMax.delayedCall(3,this.hideWarRenownClansmen);
      }
      
      private function hideWarRenownClansmen() : void
      {
         if(!context)
         {
            return;
         }
         TweenMax.to(this._warRenownClansmen,0.4,{"y":this._warRenownClansmen.y + 600});
         if(!this._rewards.empty)
         {
            this.showRewardTitle(this._rewards.displayAwards);
         }
         else if(!this._items.empty)
         {
            this.showRewardTitle(this._items.displayItems);
         }
         else if(Boolean(this.unitsReadyToPromote) && this.unitsReadyToPromote.length > 0)
         {
            this.showRewardTitle(this.displayPromotion);
         }
         else if(Boolean(this.unitsInjured) && this.unitsInjured.length > 0)
         {
            this.showInjuries();
         }
         else
         {
            this.hideRewardTitle(0);
         }
      }
      
      private function hidePromotion() : void
      {
         if(!context)
         {
            return;
         }
         if(this.unitsReadyToPromoteIndex >= this.unitsReadyToPromote.length)
         {
            TweenMax.to(this._promotion,0.4,{
               "delay":2,
               "y":this.promotionStartingY + this._promotion.height
            });
            if(Boolean(this.unitsInjured) && this.unitsInjured.length > 0)
            {
               TweenMax.delayedCall(2.2,this.showInjuries);
            }
            else
            {
               this.hideRewardTitle();
            }
         }
         else
         {
            TweenMax.to(this._promotion,0.4,{
               "delay":2,
               "y":this.promotionStartingY + this._promotion.height,
               "onComplete":this.displayPromotion
            });
         }
      }
      
      private function hideInjury() : void
      {
         if(!_context)
         {
            return;
         }
         _context.logger.info("GuiMatchResolution.hideInjury");
         var _loc1_:int = 0;
         if(this.unitsInjuredIndex >= this.unitsInjured.length)
         {
            TweenMax.to(this._injury,0.6,{
               "delay":2.5,
               "y":this.injuryStartingY + this._injury.height
            });
            _loc1_ = this.injuryStartingY + this._injury.height;
            _context.logger.info("GuiMatchResolution.hideInjury END TWEENING to " + _loc1_);
            TweenMax.to(this._consequencesTitle,0.8,{
               "delay":2.7,
               "y":_loc1_,
               "onComplete":this.playRenownTotal
            });
         }
         else
         {
            _loc1_ = this.injuryStartingY + this._injury.height;
            _context.logger.info("GuiMatchResolution.hideInjury NEXT TWEENING to " + _loc1_);
            TweenMax.to(this._injury,0.6,{
               "delay":2.5,
               "y":_loc1_,
               "onComplete":this.displayInjury
            });
         }
      }
      
      private function playRenownTotal() : void
      {
         _context.logger.info("GuiMatchResolution.playRenownTotal");
         this.renownCount = 0;
         this._renownTotal.visible = true;
         var _loc1_:Boolean = _context.saga.isSurvival && !this.victor;
         this.renownTotalBanner.visible = !_loc1_;
         if(this.renownTotalBanner.visible)
         {
            this.renownTotalBanner.gotoAndPlay(1);
            this.renownTotalBanner.addEventListener(Event.EXIT_FRAME,this.renownTotalAnimating);
         }
         else
         {
            this.playSurvivalSpears();
         }
      }
      
      private function renownTotalAnimating(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         if(!context)
         {
            return;
         }
         if(this.renownTotalBanner.currentFrame >= 15)
         {
            _loc2_ = Boolean(_context.saga) && _context.saga.isSurvival && !this.victor;
            if(_loc2_)
            {
               if(!this.isSurvivalFinalizingSpears)
               {
                  this.playSurvivalSpears();
               }
            }
            else if(!this.renownTotalText)
            {
               this.renownTotalText = this.renownTotalBanner.getChildByName("total") as TextField;
               this.renownTotalBanner.removeEventListener(Event.EXIT_FRAME,this.renownTotalAnimating);
               this.renownTotalBanner.addEventListener(Event.EXIT_FRAME,this.renownTotalDoneAnimating);
               this.renownTotalTextCenter.setTo(this.renownTotalText.x + this.renownTotalText.width / 2,this.renownTotalText.y + this.renownTotalText.height / 2);
               context.translateDisplayObjects(LocaleCategory.GUI,this.renownTotalBanner);
               this.renownCounterSchedule();
            }
         }
      }
      
      private function playSurvivalSpears() : void
      {
         this.isSurvivalFinalizingSpears = true;
         this.renownTotalBanner.visible = false;
         context.playSound("ui_stats_total");
         GuiUtil.playStopOnLastFrame(this.spears,this.survivalSpearsCompleteHandler);
      }
      
      private function survivalSpearsCompleteHandler() : void
      {
         this._gameover.visible = true;
         this._gameover.alpha = 0;
         this._gameover.scaleX = this._gameover.scaleY = 0.5;
         context.translateDisplayObjects(LocaleCategory.GUI,this._gameover);
         TweenMax.to(this._gameover,0.5,{
            "alpha":1,
            "scaleX":1,
            "scaleY":1,
            "onComplete":this.survivalGameoverCompleteHandler
         });
      }
      
      private function survivalGameoverCompleteHandler() : void
      {
         this._text_gameover_desc.visible = true;
         var _loc1_:String = String(_context.translate("mr_gameover_progress"));
         _loc1_ = _loc1_.replace("{CURRENT}",_context.saga.survivalProgress.toString());
         _loc1_ = _loc1_.replace("{TOTAL}",_context.saga.survivalTotal.toString());
         this._text_gameover_desc.htmlText = _loc1_;
         _context.currentLocale.fixTextFieldFormat(this._text_gameover_desc);
         this.finished = true;
      }
      
      private function renownTotalDoneAnimating(param1:Event) : void
      {
         if(this.renownTotalBanner.totalFrames == this.renownTotalBanner.currentFrame)
         {
            this.renownTotalBanner.stop();
            this.renownTotalBanner.removeEventListener(Event.EXIT_FRAME,this.renownTotalDoneAnimating);
         }
      }
      
      private function renownCounterSchedule() : void
      {
         TweenMax.delayedCall(this.renownCounterDelay,this.showRenownCounter);
         this.renownCounterDelay = Math.max(0.01,this.renownCounterDelay - 0.02);
      }
      
      private function showRenownCounter() : void
      {
         ++this.renownCount;
         if(!context)
         {
            return;
         }
         context.playSound("ui_stats_glisten");
         var _loc1_:int = !!this.battleRewardData ? this.battleRewardData.total_renown : 0;
         _loc1_ += !!this.outcome ? this.outcome.renown : 0;
         if(_loc1_ == 0)
         {
            GuiUtil.playStopOnLastFrame(this.spears,null);
            this.finished = true;
            return;
         }
         this.renownTotalText.text = "+" + Math.min(_loc1_,this.renownCount).toString();
         this.renownTotalText.width = this.renownTotalText.textWidth + 10;
         this.renownTotalText.x = this.renownTotalTextCenter.x - this.renownTotalText.width / 2;
         this.renownTotalText.y = this.renownTotalTextCenter.y - this.renownTotalText.height / 2;
         var _loc2_:* = this.renownCount >= _loc1_;
         var _loc3_:Number = _loc2_ ? 1.2 : 1;
         var _loc4_:Number = _loc2_ ? 0.4 : this.renownCounterDelay;
         var _loc5_:Number = this.renownTotalTextCenter.x - _loc3_ * this.renownTotalText.width / 2;
         var _loc6_:Number = this.renownTotalTextCenter.y - _loc3_ * this.renownTotalText.height / 2;
         TweenMax.fromTo(this.renownTotalText,_loc4_,{
            "alpha":0,
            "scaleX":0.9,
            "scaleY":0.9
         },{
            "alpha":1,
            "scaleX":_loc3_,
            "scaleY":_loc3_,
            "x":_loc5_,
            "y":_loc6_,
            "ease":Back.easeOut
         });
         if(this.renownCount >= _loc1_)
         {
            context.playSound("ui_stats_total");
            GuiUtil.playStopOnLastFrame(this.spears,null);
            this.finished = true;
         }
         else
         {
            this.renownCounterSchedule();
         }
      }
      
      public function get finished() : Boolean
      {
         return this._finished;
      }
      
      public function set finished(param1:Boolean) : void
      {
         if(this._finished == param1)
         {
            return;
         }
         this._finished = param1;
         this.checkButtonVisibility();
      }
      
      public function setPanel(param1:IGuiMatchResolution_Panel, param2:Boolean) : void
      {
         if(param2)
         {
            this._panel = param1;
         }
         else if(this._panel == param1)
         {
            this._panel = null;
         }
      }
   }
}
