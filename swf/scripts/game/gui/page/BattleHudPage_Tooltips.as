package game.gui.page
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleBoardTriggers;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.battle.sim.BattleParty;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.stat.def.StatType;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.HornHelper;
   import game.view.TutorialTooltip;
   
   public class BattleHudPage_Tooltips
   {
       
      
      private var bhp:BattleHudPage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var _tt:TutorialTooltip;
      
      private var logger:ILogger;
      
      private var _board:BattleBoard;
      
      private var _fsm:IBattleFsm;
      
      private var _delayCheckForTutorialTooltipsMs:int;
      
      private var _checkedMorale:Boolean;
      
      private var _checkedDeploy:Boolean;
      
      private var _checkedDeployReady:Boolean;
      
      private var tt_deploy:TutorialTooltip;
      
      private var tt_deploy_ready:TutorialTooltip;
      
      private var _somebodyCanDeploy:Boolean;
      
      private var _checkedSomebodyCanDeploy:Boolean;
      
      private var _checkedTurnTimer:Boolean;
      
      private var _checkedInjury:Boolean;
      
      private var _checkedInjuryCount:int;
      
      public function BattleHudPage_Tooltips(param1:BattleHudPage)
      {
         super();
         this.bhp = param1;
         this.config = param1.config;
         this.logger = this.config.logger;
         this.saga = Saga.instance;
      }
      
      public function cleanup() : void
      {
         if(this._board)
         {
            this._board.removeEventListener(BattleBoardEvent.DEPLOYMENT_STARTED,this.deploymentStartedHandler);
            this._board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_TILE_CHANGED,this.boardEntityTileChangedHandler);
         }
         if(this._fsm)
         {
            this._fsm.removeEventListener(BattleFsmEvent.INTERACT,this.interactChangedHandler);
         }
         this.tt = null;
         this.config = null;
         this.saga = null;
         this.bhp = null;
      }
      
      public function startTooltips() : void
      {
         this._board = this.bhp._board;
         if(this._board)
         {
            this._board.addEventListener(BattleBoardEvent.DEPLOYMENT_STARTED,this.deploymentStartedHandler);
            this._board.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_TILE_CHANGED,this.boardEntityTileChangedHandler);
            this._fsm = this._board.fsm;
            if(this._fsm)
            {
               this._fsm.addEventListener(BattleFsmEvent.INTERACT,this.interactChangedHandler);
            }
         }
         this.scheduleCheckForTutorialTooltips(0);
      }
      
      private function interactChangedHandler(param1:BattleFsmEvent) : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:* = null;
         if(this.tt_deploy)
         {
            _loc2_ = !!this._fsm ? this._fsm.interact : null;
            if(_loc2_ && _loc2_.isPlayer && !_loc2_.deploymentFinalized)
            {
               _loc3_ = "ScenePage|scene_view|boards|focusedBoardView|entityViews|" + _loc2_.id + "|shadowBitmapWrapper";
               this.tt_deploy.resetPath(_loc3_);
            }
            return;
         }
         if(this._fsm)
         {
            if(!this._board || this._board.boardSetup)
            {
               this._fsm.removeEventListener(BattleFsmEvent.INTERACT,this.interactChangedHandler);
            }
         }
      }
      
      private function deploymentStartedHandler(param1:BattleBoardEvent) : void
      {
         this.checkForTutorialTooltips();
      }
      
      private function boardSetupHandler(param1:BattleBoardEvent) : void
      {
         this.checkClearDeployTooltip();
      }
      
      private function boardEntityTileChangedHandler(param1:BattleBoardEvent) : void
      {
         if(this._board)
         {
            if(this._board.fsm.interact != param1.entity)
            {
               return;
            }
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_TILE_CHANGED,this.boardEntityTileChangedHandler);
         }
         this.checkClearDeployTooltip();
      }
      
      public function set tt(param1:TutorialTooltip) : void
      {
         if(this._tt == param1)
         {
            return;
         }
         if(this._tt)
         {
            this.config.tutorialLayer.removeTooltip(this._tt);
         }
         this.tt_deploy = null;
         this.tt_deploy_ready = null;
         this._tt = param1;
         if(this._tt)
         {
            this._tt.autoclose = true;
         }
      }
      
      public function onNextTurn() : void
      {
         this.tt = null;
      }
      
      public function checkForTutorialTooltips() : Boolean
      {
         if(!this.bhp || this.bhp.cleanedup || !this.bhp._board || !this.config || !this.saga)
         {
            return false;
         }
         if(this.saga.convo && !this.saga.convo.finished || !BattleFsmConfig.guiHudShouldRender || this.config.dialogLayer.isShowingDialog || this.config.pageManager.isShowingOptions() || !this.bhp.visible || !this.bhp.fsm || this.bhp.fsm._finishedData || this.saga.getVarBool("battle_hud_tips_disabled"))
         {
            this.scheduleCheckForTutorialTooltips(4000);
            return false;
         }
         if(!this.config.tutorialLayer.hasTooltips)
         {
            if(!this.checkForTutorialTooltips_deploy())
            {
               if(!this.checkForTutorialTooltips_deploy_ready())
               {
                  if(!this.checkForTutorialTooltips_turn_timer())
                  {
                     if(!this.checkForTutorialTooltips_morale())
                     {
                        if(!this.checkForTutorialTooltips_injury())
                        {
                           if(!this.checkForTutorialTooltips_horn())
                           {
                              if(!this.checkForTutorialTooltips_horn_full())
                              {
                                 if(!this.checkForTutorialTooltips_exhausted())
                                 {
                                    if(this.checkForTutorialTooltips_hazard())
                                    {
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         this.scheduleCheckForTutorialTooltips(2000);
         return false;
      }
      
      private function scheduleCheckForTutorialTooltips(param1:int) : void
      {
         this._delayCheckForTutorialTooltipsMs = param1;
      }
      
      private function checkForTutorialTooltips_morale() : Boolean
      {
         if(this._checkedMorale || !this.bhp.artifactHelper.artifact.artifactVisible || this.saga.isSurvival)
         {
            return false;
         }
         if(this.saga.def.survival)
         {
            return false;
         }
         var _loc1_:int = this.saga.getVarInt(SagaVar.VAR_MORALE_CATEGORY);
         var _loc2_:String = "tip_battle_morale_" + _loc1_;
         if(this.saga.getVarBool(_loc2_))
         {
            this._checkedMorale = true;
            return false;
         }
         if(!this.bhp.artifactHelper.artifact.hornFinishedAnimating)
         {
            return false;
         }
         this._checkedMorale = true;
         this.saga.setVar(_loc2_,1);
         var _loc3_:String = this.config.context.locale.translateGui(_loc2_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.gui_horn|morale|tooltip_marker",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,5,_loc3_,true,true,0,this._tutorialTooltipButtonMorale);
         return true;
      }
      
      private function checkSomebodyCanDeploy() : void
      {
         if(this._checkedSomebodyCanDeploy)
         {
            return;
         }
         var _loc1_:BattleParty = this.bhp._board.getPartyById("0") as BattleParty;
         var _loc2_:int = _loc1_.getNumMembersNotDeploymentFinalized();
         var _loc3_:int = this.bhp._board.def.getDeploymentSizeById(_loc1_.deployment);
         this._somebodyCanDeploy = _loc2_ > 0 && _loc3_ > 0;
         this._checkedSomebodyCanDeploy = true;
      }
      
      private function checkForTutorialTooltips_deploy() : Boolean
      {
         if(this._checkedDeploy || !this._board.boardDeploymentStarted || this._board.boardSetup || this.saga.isSurvival)
         {
            return false;
         }
         var _loc1_:String = "tip_battle_deploy";
         if(this.saga.getVarBool(_loc1_))
         {
            this._checkedDeploy = true;
            return false;
         }
         this._checkedDeploy = true;
         this.checkSomebodyCanDeploy();
         if(!this._somebodyCanDeploy)
         {
            return false;
         }
         var _loc2_:BattleParty = this.bhp._board.getPartyById("0") as BattleParty;
         this.saga.setVar(_loc1_,1);
         var _loc3_:String = this.config.context.locale.translateGui(_loc1_);
         var _loc4_:IBattleEntity = _loc2_.getMemberNearestCentroid(false);
         if(!_loc4_)
         {
            this.logger.info("Unable to find middlest for " + this);
            return false;
         }
         this._board.fsm.interact = _loc4_;
         _loc4_.centerCameraOnEntity();
         var _loc5_:* = "ScenePage|scene_view|boards|focusedBoardView|entityViews|" + _loc4_.id + "|shadowBitmapWrapper";
         this.tt = this.config.tutorialLayer.createTooltip(_loc5_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,64,_loc3_,true,true,0,null);
         this.tt_deploy = this._tt;
         return true;
      }
      
      private function checkForTutorialTooltips_deploy_ready() : Boolean
      {
         if(this._checkedDeployReady || !this._board.boardDeploymentStarted || this._board.boardSetup)
         {
            return false;
         }
         var _loc1_:String = "tip_battle_deploy_ready";
         if(this.saga.getVarBool(_loc1_))
         {
            this._checkedDeployReady = true;
            return false;
         }
         this._checkedDeployReady = true;
         this.checkSomebodyCanDeploy();
         if(!this._somebodyCanDeploy)
         {
            return false;
         }
         this.saga.setVar(_loc1_,1);
         var _loc2_:String = this.config.context.locale.translateGui(_loc1_);
         if(this.saga.isSurvival && Boolean(this.saga.survivalBattleTimerSec))
         {
            _loc2_ = this.config.context.locale.translateGui("ss_tip_battle_deploy_ready");
         }
         var _loc3_:String = "ScenePage|BattleHudPage|assets.battle_hud|deploymentTimer|timerRing";
         this.tt = this.config.tutorialLayer.createTooltip(_loc3_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,5,_loc2_,true,true,0,null);
         this.tt_deploy_ready = this._tt;
         return true;
      }
      
      private function checkForTutorialTooltips_turn_timer() : Boolean
      {
         var _loc3_:String = null;
         if(this._checkedTurnTimer || !this._board.boardSetup)
         {
            return false;
         }
         var _loc1_:String = "tip_battle_turn_timer";
         if(this.saga.getVarBool(_loc1_) || !this.saga.isSurvival)
         {
            this._checkedTurnTimer = true;
            return false;
         }
         var _loc2_:BattleStateTurnLocal = this._board.fsm.current as BattleStateTurnLocal;
         if(!_loc2_ || !_loc2_.timeoutMs)
         {
            return false;
         }
         this._checkedTurnTimer = true;
         this.saga.setVar(_loc1_,1);
         _loc3_ = this.config.context.locale.translateGui("ss_tip_battle_turn_timer");
         _loc3_ = _loc3_.replace("{TIMER}",_loc2_.timeoutMs / 1000);
         var _loc4_:String = "ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|activeFrame";
         this.tt = this.config.tutorialLayer.createTooltip(_loc4_,TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,5,_loc3_,true,true,0,null);
         this.tt_deploy_ready = this._tt;
         return true;
      }
      
      private function checkClearDeployTooltip() : void
      {
         if(!this.tt_deploy && !this.tt_deploy_ready)
         {
            return;
         }
         if(this._board.boardSetup)
         {
            this.tt = null;
            return;
         }
         if(this.tt_deploy)
         {
            this.tt = null;
         }
         if(!this._checkedDeployReady && this._board.boardDeploymentStarted && !this._board.boardSetup)
         {
            this.checkForTutorialTooltips_deploy_ready();
         }
      }
      
      private function _tutorialTooltipButton(param1:Event) : void
      {
         this.scheduleCheckForTutorialTooltips(2000);
      }
      
      private function _tutorialTooltipButtonMorale(param1:int) : void
      {
         if(!this.bhp._turn || !this.bhp._turn.entity || !this.bhp._turn.entity.isPlayer)
         {
            return;
         }
         var _loc2_:int = this.saga.getVarInt(SagaVar.VAR_MORALE_CATEGORY);
         if(_loc2_ == 3)
         {
            return;
         }
         var _loc3_:String = "tip_battle_unit_morale";
         if(this.saga.getVarBool(_loc3_))
         {
            return;
         }
         this.saga.setVar(_loc3_,1);
         var _loc4_:String = this.config.context.locale.translateGui(_loc3_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|statFlags|flagPlayer|textWillpower",TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,5,_loc4_,true,true,0,null);
      }
      
      private function checkForTutorialTooltips_injury() : Boolean
      {
         if(this._checkedInjury || !this.bhp._turn || this.saga.isSurvival)
         {
            return false;
         }
         if(this.saga.def.survival)
         {
            return false;
         }
         var _loc1_:IBattleEntity = this.bhp._turn.entity;
         if(!_loc1_ || !_loc1_.isPlayer)
         {
            return false;
         }
         if(_loc1_.stats.getValue(StatType.INJURY) <= 0)
         {
            ++this._checkedInjuryCount;
            if(this._checkedInjuryCount >= _loc1_.party.numMembers)
            {
               this._checkedInjury = true;
            }
            return false;
         }
         this._checkedInjury = true;
         var _loc2_:String = "tip_battle_unit_injury";
         if(this.saga.getVarBool(_loc2_))
         {
            return false;
         }
         this.saga.setVar(_loc2_,1);
         var _loc3_:String = this.config.context.locale.translateGui(_loc2_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|statFlags|flagPlayer|textStrength",TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,10,_loc3_,true,true,0,null);
         return true;
      }
      
      private function checkForTutorialTooltips_exhausted() : Boolean
      {
         if(!this.bhp._turn || this.bhp._turn.committed || this.saga.isSurvival)
         {
            return false;
         }
         var _loc1_:IBattleEntity = this.bhp._turn.entity;
         if(!_loc1_ || !_loc1_.isPlayer)
         {
            return false;
         }
         if(_loc1_.stats.getValue(StatType.WILLPOWER) > 0)
         {
            return false;
         }
         var _loc2_:String = "tip_battle_unit_exhausted";
         if(this.saga.getVarBool(_loc2_))
         {
            return false;
         }
         this.saga.setVar(_loc2_,1);
         var _loc3_:String = this.config.context.locale.translateGui(_loc2_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|statFlags|flagPlayer|textWillpower",TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,10,_loc3_,true,true,0,null);
         return true;
      }
      
      private function checkForTutorialTooltips_hazard() : Boolean
      {
         if(!this.bhp._turn || this.bhp._turn.committed || this.saga.isSurvival)
         {
            return false;
         }
         var _loc1_:BattleTurn = this.bhp._turn;
         var _loc2_:IBattleMove = _loc1_.move;
         var _loc3_:IBattleEntity = this.bhp._turn.entity;
         if(!_loc3_ || !_loc3_.isPlayer || !_loc2_ || _loc2_.committed || _loc1_.attackMode || Boolean(_loc1_.ability))
         {
            return false;
         }
         var _loc4_:BattleBoard = this.bhp._board;
         var _loc5_:BattleBoardTriggers = _loc4_.triggers as BattleBoardTriggers;
         if(!_loc5_ || !_loc5_.triggers || !_loc5_.triggers.length)
         {
            return false;
         }
         var _loc6_:IBattleBoardTrigger = _loc5_.findClosestEntityHazard(_loc3_,null,true,true);
         if(!_loc6_)
         {
            return false;
         }
         var _loc7_:String = "tip_battle_unit_hazard";
         if(this.saga.getVarBool(_loc7_))
         {
            return false;
         }
         this.saga.setVar(_loc7_,1);
         var _loc8_:String = this.config.context.locale.translateGui(_loc7_);
         var _loc9_:String = "ScenePage|scene_view|boards|focusedBoardView|tile@";
         _loc9_ += _loc6_.rect.loc.x + "," + _loc6_.rect.loc.y;
         this.tt = this.config.tutorialLayer.createTooltip(_loc9_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,30,_loc8_,true,true,0,null);
         return true;
      }
      
      private function checkForTutorialTooltips_horn() : Boolean
      {
         if(!this.bhp._turn || !this.bhp.artifactHelper.artifact.artifactVisible || !this.bhp.artifactHelper.artifact.hornFinishedAnimating || this.saga.isSurvival)
         {
            return false;
         }
         var _loc1_:IBattleEntity = this.bhp._turn.entity;
         if(!_loc1_ || !_loc1_.isPlayer)
         {
            return false;
         }
         if(!this.bhp.artifactHelper.artifact.count)
         {
            return false;
         }
         var _loc2_:int = int(_loc1_.stats.getValue(StatType.WILLPOWER));
         var _loc3_:int = int(_loc1_.def.stats.getValue(StatType.WILLPOWER));
         if(_loc2_ >= _loc3_)
         {
            return false;
         }
         var _loc4_:String = "tip_battle_horn";
         if(this.saga.getVarBool(_loc4_))
         {
            return false;
         }
         this.saga.setVar(_loc4_,1);
         var _loc5_:String = this.config.context.locale.translateGui(_loc4_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.gui_horn|buttonUse",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,5,_loc5_,true,true,20,null);
         return true;
      }
      
      private function checkForTutorialTooltips_horn_full() : Boolean
      {
         if(!this.bhp._turn || !this.bhp.artifactHelper.artifact.artifactVisible || !this.bhp.artifactHelper.artifact.hornFinishedAnimating || this.saga.isSurvival)
         {
            return false;
         }
         var _loc1_:IBattleEntity = this.bhp._turn.entity;
         if(!_loc1_ || !_loc1_.isPlayer)
         {
            return false;
         }
         if(!(this.bhp.artifactHelper is HornHelper) || this.bhp.artifactHelper.artifact.count < 5)
         {
            return false;
         }
         var _loc2_:int = int(_loc1_.stats.getValue(StatType.WILLPOWER));
         var _loc3_:int = int(_loc1_.def.stats.getValue(StatType.WILLPOWER));
         if(_loc2_ >= _loc3_)
         {
            return false;
         }
         var _loc4_:String = "tip_battle_horn_full";
         if(this.saga.getVarBool(_loc4_))
         {
            return false;
         }
         this.saga.setVar(_loc4_,1);
         var _loc5_:String = this.config.context.locale.translateGui(_loc4_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.gui_horn|buttonUse",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,5,_loc5_,true,true,20);
         return true;
      }
      
      public function update(param1:int) : void
      {
         if(this._delayCheckForTutorialTooltipsMs >= 0)
         {
            this._delayCheckForTutorialTooltipsMs -= param1;
            if(this._delayCheckForTutorialTooltipsMs < 0)
            {
               this.checkForTutorialTooltips();
            }
         }
      }
   }
}
