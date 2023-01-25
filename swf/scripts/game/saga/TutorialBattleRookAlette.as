package game.saga
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.FsmEvent;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.saga.IBattleTutorial;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.session.GameFsm;
   import game.session.GameState;
   import game.session.states.SceneState;
   import game.session.states.SceneStateBattleHandler;
   import game.session.states.tutorial.HelperTutorialState;
   import game.view.TutorialTooltip;
   
   public class TutorialBattleRookAlette implements IBattleTutorial
   {
       
      
      private var helper:HelperTutorialState;
      
      private var sceneState:SceneState;
      
      private var gameFsm:GameFsm;
      
      private var battleHandler:SceneStateBattleHandler;
      
      private var logger:ILogger;
      
      private var config:GameConfig;
      
      private var scene:Scene;
      
      private var battleFsm:BattleFsm;
      
      private var battleOrder:BattleTurnOrder;
      
      private var battleBoard:IBattleBoard;
      
      private var en:int = 0;
      
      private var _started:Boolean;
      
      public function TutorialBattleRookAlette(param1:SceneState)
      {
         super();
         this.sceneState = param1;
         this.gameFsm = param1.fsm as GameFsm;
         this.battleHandler = param1.battleHandler;
         this.logger = param1.logger;
         this.config = param1.config;
         this.scene = param1.scene;
         this.helper = new HelperTutorialState(param1,[this.mode_setup,this.mode_click_portrait,this.mode_wait_turn_attack,this.mode_turn_attack]);
         this.handleEnteredState();
      }
      
      public function get isActive() : Boolean
      {
         return Boolean(this.helper) && this.helper.isActive;
      }
      
      public function cleanup() : void
      {
         BattleFsmConfig.sceneEnableAi = true;
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.battleFsmTurnAttackHandler);
         this.battleFsm.removeEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
         this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.sceneState.removeEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
         this.battleHandler.removeEventListener(SceneStateBattleHandler.EVENT_UNIT_INFO_SHOWN,this.battleHandlerUnitInfoHandler);
         this.battleHandler = null;
         this.battleFsm = null;
         this.battleOrder = null;
         this.battleBoard = null;
         this.sceneState.config.battleHudConfig.reset();
         this.sceneState.config.sceneControllerConfig.restrictInput = false;
         this.helper.cleanup();
         this.helper = null;
      }
      
      private function getUnit(param1:String, param2:String) : IBattleEntity
      {
         var _loc3_:IBattleEntity = this.battleHandler.fsm.board.entities[param1 + "+" + this.en + "+" + param2];
         if(!_loc3_)
         {
            this.logger.error("TutorialBattleRookAlette: Battle party (" + param1 + ") member: " + param2 + " not found at party position " + this.en);
         }
         ++this.en;
         return _loc3_;
      }
      
      private function handleEnteredState() : void
      {
         this.gameFsm.updateGameLocation("loc_tutorial");
         this.battleFsm = this.battleHandler.fsm;
         this.battleBoard = this.battleFsm.board;
         this.battleOrder = this.battleFsm.order as BattleTurnOrder;
         this.scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.battleFsm.addEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
         this.battleHandler.addEventListener(SceneStateBattleHandler.EVENT_UNIT_INFO_SHOWN,this.battleHandlerUnitInfoHandler);
         this.sceneState.addEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
         this.pageReadyHandler(null);
      }
      
      public function mode_setup(param1:Function) : void
      {
         this.logger.info("TutorialBattleRookAlette mode_setup");
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|deploymentTimer",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_rook_alette_deploy"),true,false,1);
         this.checkBattleStarted();
      }
      
      public function mode_click_portrait(param1:Function) : void
      {
         var self:Function = param1;
         this.logger.info("TutorialBattleRookAlette mode_click_portrait");
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|activeFrame",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_rook_alette_portrait"),true,true,1);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_wait_turn_attack(param1:Function) : void
      {
         this.logger.info("TutorialBattleRookAlette mode_wait_attack_mode");
         this.helper.clearToolTip();
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.battleFsmTurnAttackHandler);
         this.battleFsmTurnAttackHandler(null);
      }
      
      public function mode_turn_attack(param1:Function) : void
      {
         var e:IBattleEntity;
         var eid:String;
         var lid:String;
         var msg:String;
         var self:Function = param1;
         this.logger.info("TutorialBattleRookAlette mode_turn_attack");
         e = this.battleFsm.turn.entity;
         eid = String(e.id);
         lid = "tut_battle_rook_alette_attack";
         msg = this.config.context.locale.translate(LocaleCategory.TUTORIAL,lid);
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + eid + "|indicator|displayObjectWrapper",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.NONE,-128,msg,false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      private function battleFsmTurnAttackHandler(param1:BattleFsmEvent) : void
      {
         if(!this.battleFsm.turn.attackMode)
         {
            return;
         }
         var _loc2_:IBattleEntity = this.battleFsm.turn.entity;
         if(_loc2_.isEnemy)
         {
            return;
         }
         if(this.helper.mode == this.mode_wait_turn_attack)
         {
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.battleFsmTurnAttackHandler);
            this.helper.next(null);
         }
      }
      
      private function pageReadyHandler(param1:Event) : void
      {
         this.logger.info("TutorialBattleRookAlette pageReadyHandler " + this.sceneState.pageReady);
         if(this.sceneState.pageReady)
         {
            this.sceneState.removeEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
            this.checkStartTutorial();
         }
      }
      
      private function battleFsmCurrentHandler(param1:FsmEvent) : void
      {
         this.checkStartTutorial();
         this.checkBattleStarted();
      }
      
      private function checkBattleStarted() : void
      {
         this.logger.info("TutorialBattleRookAlette checkBattleStarted ready=" + this.scene.ready + ", turn=" + this.battleFsm.turn + " setup=" + (this.helper.mode == this.mode_setup));
         if(this.helper && this.scene.ready && this.battleFsm.turn && this.helper.mode == this.mode_setup)
         {
            this.helper.next(null);
         }
      }
      
      private function checkStartTutorial() : void
      {
         if(this._started || !this.helper)
         {
            return;
         }
         this.logger.info("TutorialBattleRookAlette checkStartTutorial pr=" + this.sceneState.pageReady + ", cc=" + this.battleFsm.currentClass);
         if(this.sceneState.pageReady && this.scene.ready && this.battleFsm.currentClass == BattleStateDeploy)
         {
            this._started = true;
            this.helper.next(null);
         }
      }
      
      private function sceneReadyHandler(param1:SceneEvent) : void
      {
         if(this.scene.ready)
         {
            this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
            this.checkStartTutorial();
         }
      }
      
      private function battleHandlerUnitInfoHandler(param1:Event) : void
      {
         if(Boolean(this.helper) && this.helper.mode == this.mode_click_portrait)
         {
            this.battleHandler.removeEventListener(SceneStateBattleHandler.EVENT_UNIT_INFO_SHOWN,this.battleHandlerUnitInfoHandler);
            this.helper.next(null);
         }
      }
   }
}
