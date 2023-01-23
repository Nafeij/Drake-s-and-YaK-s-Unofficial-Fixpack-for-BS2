package game.saga
{
   import com.greensock.TweenMax;
   import engine.ability.IAbilityDef;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurnOrder;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.battle.sim.IBattleParty;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.FsmEvent;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.saga.IBattleTutorial;
   import engine.saga.SagaVar;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import engine.scene.view.SceneViewSprite;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.session.GameFsm;
   import game.session.GameState;
   import game.session.states.SceneState;
   import game.session.states.SceneStateBattleHandler;
   import game.session.states.tutorial.HelperTutorialState;
   import game.view.TutorialTooltip;
   
   public class TutorialBattleVedrfell_gp implements IBattleTutorial
   {
       
      
      private var helper:HelperTutorialState;
      
      private var sceneState:SceneState;
      
      private var gameFsm:GameFsm;
      
      private var battleHandler:SceneStateBattleHandler;
      
      private var logger:ILogger;
      
      private var config:GameConfig;
      
      private var scene:Scene;
      
      private var dredge0:IBattleEntity;
      
      private var ludin:IBattleEntity;
      
      private var hakon:IBattleEntity;
      
      private var mogr:IBattleEntity;
      
      private var gunnulf:IBattleEntity;
      
      private var battleFsm:BattleFsm;
      
      private var battleOrder:BattleTurnOrder;
      
      private var battleBoard:IBattleBoard;
      
      private var en:int = 0;
      
      private var _abl_attack_ludin:BattleAbility;
      
      private var _numRunIns:int = 0;
      
      private var _started:Boolean;
      
      public function TutorialBattleVedrfell_gp(param1:SceneState)
      {
         super();
         this.sceneState = param1;
         this.gameFsm = param1.fsm as GameFsm;
         this.battleHandler = param1.battleHandler;
         this.logger = param1.logger;
         this.config = param1.config;
         this.scene = param1.scene;
         this.helper = new HelperTutorialState(param1,[this.mode_setup,this.mode_move_waypoint_1,this.mode_move_waypoint_2,this.mode_move_wait,this.mode_statbanners,this.mode_attack_target,this.mode_attack_confirm,this.mode_attack_wait,this.mode_attacked_target,this.mode_dredge_move,this.mode_dredge_attack,this.mode_arrive_party,this.mode_wait_for_horn,this.mode_show_horn]);
         this.handleEnteredState();
      }
      
      public function get isActive() : Boolean
      {
         return Boolean(this.helper) && this.helper.isActive;
      }
      
      public function cleanup() : void
      {
         if(this._abl_attack_ludin)
         {
            this._abl_attack_ludin.removeEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.ludinAttackedCompleteHandler);
            this._abl_attack_ludin = null;
         }
         BattleFsmConfig.sceneEnableAi = true;
         this.battleFsm.removeEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN,this.battleTurnHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.battleAttackHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.battleAbilityExecutingHandler);
         this.battleBoard.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
         this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
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
            this.logger.error("TutorialBattleVedrfell: Battle party (" + param1 + ") member: " + param2 + " not found at party position " + this.en);
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
         this.dredge0 = this.getUnit("npc","dredge_scourge_tutorial_vedrfell");
         if(!this.dredge0)
         {
            this.logger.error("TutorialBattleVedrfell: Battle failed to find required enemies");
         }
         this.en = 0;
         var _loc1_:String = this.config.fsm.credentials.userId.toString();
         this.ludin = this.getUnit(_loc1_,"ludin");
         this.hakon = this.getUnit(_loc1_,"hakon");
         this.mogr = this.getUnit(_loc1_,"mogr");
         this.gunnulf = this.getUnit(_loc1_,"gunnulf");
         if(!this.ludin || !this.hakon || !this.mogr || !this.gunnulf)
         {
            this.logger.error("TutorialBattleVedrfell: Failed to find all 4 party members, cannot continue");
            return;
         }
         this.hakon.enabled = false;
         this.mogr.enabled = false;
         this.gunnulf.enabled = false;
         BattleFsmConfig.sceneEnableAi = false;
         this.scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.battleFsm.addEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN,this.battleTurnHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.battleAbilityExecutingHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.battleAttackHandler);
         this.battleBoard.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
         this.sceneState.chatEnabled = false;
         this.sceneState.scene.allClickablesDisabled = true;
         this.config.alerts.enabled = false;
         this.config.battleHudConfig.escape = false;
         this.config.battleHudConfig.showHorn = false;
         this.config.battleHudConfig.initiative = false;
         this.config.battleHudConfig.enemyPopup = false;
         this.config.battleHudConfig.enemyPopupStars = false;
         this.config.battleHudConfig.enemyPopupStrength = false;
         this.config.battleHudConfig.enemyPopupArmor = false;
         this.config.battleHudConfig.selfPopup = false;
         this.config.battleHudConfig.selfPopupAttack = false;
         this.config.battleHudConfig.selfPopupEnd = false;
         this.config.battleHudConfig.selfPopupMove = false;
         this.config.battleHudConfig.selfPopupSpecial = false;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.restrictInput = true;
         this.sceneState.addEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
         this.pageReadyHandler(null);
      }
      
      public function mode_setup(param1:Function) : void
      {
         var _loc2_:IBattleBoard = null;
         this.logger.info("TutorialBattleVedrfell mode_setup");
         _loc2_ = this.battleHandler.fsm.board;
         var _loc3_:IBattleParty = _loc2_.getPartyById(this.config.fsm.credentials.userId.toString());
         _loc3_.deployed = true;
         this.hakon.enabled = false;
         this.mogr.enabled = false;
         this.gunnulf.enabled = false;
         _loc3_.deployed = true;
         this.checkBattleStarted();
      }
      
      public function mode_move_waypoint_1(param1:Function) : void
      {
         var _loc2_:TileLocation = TileLocation.fetch(6,8);
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = _loc2_;
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileWidth = 1;
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowWaypointTile = this.battleHandler.fsm.board.tiles.getTileByLocation(_loc2_);
         this.config.sceneControllerConfig.allowMoveTile = null;
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|underlay|marker|tile",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.NONE,-32,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_ludin_waypoint_1_gp"),true,false,0);
         if(!this.battleHandler.fsm.turn)
         {
            this.logger.error("Not started battle?");
            return;
         }
         var _loc3_:IBattleMove = this.battleHandler.fsm.turn.move;
         _loc3_.suppressCommit = true;
         _loc3_.addEventListener(BattleMoveEvent.WAYPOINT,this.moveWaypointHandler);
      }
      
      public function mode_move_waypoint_2(param1:Function) : void
      {
         this.logger.info("TutorialBattleVedrfell mode_move_waypoint_2");
         var _loc2_:TileLocation = TileLocation.fetch(8,8);
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = _loc2_;
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileWidth = 1;
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowWaypointTile = null;
         this.config.sceneControllerConfig.allowMoveTile = this.battleHandler.fsm.board.tiles.getTileByLocation(_loc2_);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|underlay|marker|tile",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_ludin_waypoint_2_gp"),true,false,0);
         var _loc3_:IBattleMove = this.battleHandler.fsm.turn.move;
         _loc3_.suppressCommit = false;
         _loc3_.addEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
      }
      
      public function mode_move_wait(param1:Function) : void
      {
         this.helper.clearToolTip();
         var _loc2_:IBattleMove = this.battleHandler.fsm.turn.move;
         if(!_loc2_.executed)
         {
            _loc2_.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         }
         else
         {
            this.helper.next(null);
         }
      }
      
      public function mode_statbanners(param1:Function) : void
      {
         var self:Function = param1;
         var sv:SceneViewSprite = this.battleHandler.state.loader.viewSprite;
         sv.boards.focusedBoardView.centerOnEntity(this.dredge0);
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+dredge_scourge_tutorial_vedrfell|isoSprite|container",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,96,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_statbanner_gp"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_target(param1:Function) : void
      {
         var _loc2_:SceneViewSprite = this.battleHandler.state.loader.viewSprite;
         _loc2_.boards.focusedBoardView.centerOnEntity(this.dredge0);
         this.config.battleHudConfig.selfPopup = true;
         this.config.battleHudConfig.selfPopupAttack = true;
         this.config.battleHudConfig.enemyPopup = true;
         this.config.battleHudConfig.enemyPopupArmor = false;
         this.config.battleHudConfig.enemyPopupStrength = true;
         this.config.battleHudConfig.enemyPopupWangler = false;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.allowEntities.push(this.dredge0);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+dredge_scourge_tutorial_vedrfell|shadowBitmapWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,64,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_target_enemy_gp"),true,false,0);
      }
      
      public function mode_attack_confirm(param1:Function) : void
      {
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.notify();
         this.config.battleHudConfig.enemyPopupWangler = true;
         this.config.battleHudConfig.enemyPopup = true;
         this.config.battleHudConfig.enemyPopupStrength = true;
         this.config.battleHudConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|button_str|damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_str_attack"),true,false,0);
      }
      
      public function mode_attack_wait(param1:Function) : void
      {
         this.ludin.stats.setBase(StatType.ALWAYS_MISS,1);
         this.helper.clearToolTip();
      }
      
      public function mode_attacked_target(param1:Function) : void
      {
         var self:Function = param1;
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.dredge0);
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+dredge_scourge_tutorial_vedrfell|shadowBitmapWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,16,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_str_attacked"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_dredge_move(param1:Function) : void
      {
         var _loc2_:Tile = null;
         this.helper.clearToolTip();
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.dredge0);
         if(this.battleHandler.fsm.turn.entity == this.dredge0)
         {
            _loc2_ = this.battleBoard.tiles.getTile(9,7);
            this.battleHandler.fsm.turn.move.addStep(_loc2_);
            this.battleHandler.fsm.turn.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.battleHandler.fsm.turn.move.setCommitted("mode_dredge_move");
         }
      }
      
      public function mode_dredge_attack(param1:Function) : void
      {
         var _loc2_:IAbilityDef = null;
         var _loc3_:BattleAbilityDef = null;
         var _loc4_:BattleAbility = null;
         this.ludin.stats.removeStat(StatType.ALWAYS_MISS);
         this.helper.clearToolTip();
         BattleTurnCmdAction.SUPPRESS_TURN_END = true;
         BattleStateTurnBase.SUPPRESS_DEATH_CHECK = true;
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.dredge0);
         this.ludin.skipInjury = true;
         if(this.battleHandler.fsm.turn.entity == this.dredge0)
         {
            _loc2_ = this.battleHandler.fsm.turn.entity.def.attacks.getAbilityDefById("abl_melee_str");
            _loc3_ = _loc2_.getAbilityDefForLevel(3) as BattleAbilityDef;
            _loc4_ = new BattleAbility(this.battleHandler.fsm.turn.entity,_loc3_,this.battleHandler.fsm.board.abilityManager);
            _loc4_.targetSet.addTarget(this.ludin);
            _loc4_.addEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.ludinAttackedCompleteHandler);
            this._abl_attack_ludin = _loc4_;
            this.battleHandler.fsm.turn.ability = _loc4_;
            this.battleHandler.fsm.turn.committed = true;
         }
      }
      
      private function ludinAttackedCompleteHandler(param1:BattleAbilityEvent) : void
      {
         this._abl_attack_ludin.removeEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.ludinAttackedCompleteHandler);
         this._abl_attack_ludin = null;
         this.ludin.skipInjury = false;
         this.helper.next(null);
      }
      
      public function mode_arrive_party(param1:Function) : void
      {
         var self:Function = param1;
         this.runIn(this.mogr);
         TweenMax.delayedCall(4,function():void
         {
            runIn(hakon);
         });
         TweenMax.delayedCall(2,function():void
         {
            runIn(gunnulf);
         });
      }
      
      private function runIn(param1:IBattleEntity) : void
      {
         var _loc6_:Tile = null;
         param1.enabled = true;
         this.battleBoard.fsm.order.addEntity(param1);
         var _loc2_:int = int(param1.stats.getValue(StatType.MOVEMENT));
         var _loc3_:Tile = this.battleBoard.tiles.getTile(param1.x,Number(param1.y) - _loc2_);
         param1.enabled = true;
         var _loc4_:BattleMove = new BattleMove(param1);
         var _loc5_:int = param1.y - 1;
         while(_loc5_ >= _loc3_.y)
         {
            _loc6_ = this.battleBoard.tiles.getTile(_loc3_.x,_loc5_);
            _loc4_.addStep(_loc6_);
            _loc5_--;
         }
         _loc4_.setCommitted("runIn");
         _loc4_.addEventListener(BattleMoveEvent.EXECUTED,this.runInMoveExecutedHandler);
         param1.mobility.executeMove(_loc4_);
      }
      
      private function runInMoveExecutedHandler(param1:BattleMoveEvent) : void
      {
         if(!this.battleHandler)
         {
            return;
         }
         if(param1.mv.entity == this.battleHandler.fsm.turn.entity)
         {
            this.battleHandler.fsm.turn.move.reset(param1.mv.entity.tile);
         }
         param1.mv.removeEventListener(BattleMoveEvent.EXECUTED,this.runInMoveExecutedHandler);
         ++this._numRunIns;
         if(this._numRunIns >= 3)
         {
            this.helper.next(null);
         }
      }
      
      public function mode_wait_for_horn(param1:Function) : void
      {
         var _loc2_:IBattleFsm = this.battleBoard.fsm;
         var _loc3_:IBattleTurnOrder = !!_loc2_ ? _loc2_.order : null;
         if(_loc3_)
         {
            _loc3_.resetTurnOrder();
         }
         BattleTurnCmdAction.SUPPRESS_TURN_END = false;
         BattleStateTurnBase.SUPPRESS_DEATH_CHECK = false;
         this.helper.clearToolTip();
         this.sceneState.config.battleHudConfig.reset();
         this.sceneState.config.sceneControllerConfig.restrictInput = false;
         this.sceneState.config.sceneControllerConfig.notify();
         this.sceneState.config.battleHudConfig.showHorn = false;
         this.config.battleHudConfig.escape = true;
         this.sceneState.config.battleHudConfig.notify();
         BattleFsmConfig.sceneEnableAi = true;
         var _loc4_:IBattleEntity = Boolean(_loc2_) && Boolean(_loc2_.turn) ? _loc2_.turn.entity : null;
         if(_loc4_)
         {
            _loc4_.endTurn(true,"tutorial",false);
         }
      }
      
      public function mode_show_horn(param1:Function) : void
      {
         var self:Function = param1;
         if(this.sceneState.config.saga)
         {
            this.sceneState.config.saga.setVar(SagaVar.VAR_HUD_HORN_ENABLED,true);
         }
         this.sceneState.config.battleHudConfig.showHorn = true;
         this.sceneState.config.battleHudConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.gui_horn",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,4,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_vedrfell_horn"),false,true,1);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         param1.mv.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         if(this.helper)
         {
            this.helper.next(null);
         }
      }
      
      private function moveWaypointHandler(param1:BattleMoveEvent) : void
      {
         param1.mv.removeEventListener(BattleMoveEvent.WAYPOINT,this.moveWaypointHandler);
         if(this.helper)
         {
            this.helper.next(null);
         }
      }
      
      private function moveCommittedHandler(param1:BattleMoveEvent) : void
      {
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = null;
         param1.mv.removeEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
         if(this.helper)
         {
            this.helper.next(null);
         }
      }
      
      private function pageReadyHandler(param1:Event) : void
      {
         this.logger.info("TutorialBattleVedrfell pageReadyHandler " + this.sceneState.pageReady);
         if(this.sceneState.pageReady)
         {
            this.sceneState.removeEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
            this.checkStartTutorial();
         }
      }
      
      private function battleInteractHandler(param1:BattleFsmEvent) : void
      {
         if(Boolean(this.helper) && this.helper.mode == this.mode_attack_target)
         {
            this.helper.next(null);
         }
      }
      
      private function battleFsmCurrentHandler(param1:FsmEvent) : void
      {
         this.checkStartTutorial();
      }
      
      private function battleAbilityExecutingHandler(param1:BattleFsmEvent) : void
      {
         if(Boolean(this.helper) && this.helper.mode == this.mode_attack_confirm)
         {
            this.helper.next(null);
         }
      }
      
      private function checkBattleStarted() : void
      {
         this.logger.info("TutorialBattleVedrfell checkBattleStarted ready=" + this.scene.ready + ", turn=" + this.battleFsm.turn + " setup=" + (this.helper.mode == this.mode_setup));
         if(this.helper && this.scene.ready && this.battleFsm.turn && this.helper.mode == this.mode_setup)
         {
            this.helper.next(null);
         }
      }
      
      private function battleAttackHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_attack_target)
         {
            this.battleFsm.interact = this.dredge0;
         }
      }
      
      private function battleTurnHandler(param1:BattleFsmEvent) : void
      {
         this.logger.info("TutorialBattleVedrfell battleTurnHandler");
         this.checkBattleStarted();
         if(Boolean(this.helper) && this.helper.mode == this.mode_attack_wait)
         {
            this.helper.next(null);
         }
      }
      
      private function boardEntityAliveHandler(param1:BattleBoardEvent) : void
      {
         if(Boolean(this.helper) && this.helper.mode == this.mode_wait_for_horn)
         {
            if(param1.entity.isEnemy)
            {
               this.helper.next(null);
            }
         }
      }
      
      private function checkStartTutorial() : void
      {
         if(this._started || !this.helper)
         {
            return;
         }
         this.logger.info("TutorialBattleVedrfell checkStartTutorial pr=" + this.sceneState.pageReady + ", cc=" + this.battleFsm.currentClass);
         if(this.sceneState.pageReady && this.battleFsm.currentClass == BattleStateDeploy)
         {
            this._started = true;
            this.helper.next(null);
         }
      }
      
      private function sceneReadyHandler(param1:SceneEvent) : void
      {
         this.checkBattleStarted();
      }
   }
}
