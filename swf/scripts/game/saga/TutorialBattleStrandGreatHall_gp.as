package game.saga
{
   import engine.ability.IAbilityDef;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleDeploymentArea;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.BattleTurnOrderEvent;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.sim.IBattleParty;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.FsmEvent;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.session.GameFsm;
   import game.session.GameState;
   import game.session.states.SceneState;
   import game.session.states.SceneStateBattleHandler;
   import game.session.states.tutorial.HelperTutorialState;
   import game.view.TutorialTooltip;
   
   public class TutorialBattleStrandGreatHall_gp
   {
       
      
      private var helper:HelperTutorialState;
      
      private var sceneState:SceneState;
      
      private var gameFsm:GameFsm;
      
      private var battleHandler:SceneStateBattleHandler;
      
      private var logger:ILogger;
      
      private var config:GameConfig;
      
      private var cmd_end_tutorial:Cmd;
      
      private var battleFsm:BattleFsm;
      
      private var battleOrder:BattleTurnOrder;
      
      private var battleBoard:IBattleBoard;
      
      private var chieftain0:IBattleEntity;
      
      private var ruffian1:IBattleEntity;
      
      private var ruffian2:IBattleEntity;
      
      private var ruffian3:IBattleEntity;
      
      private var saga:Saga;
      
      private var mode_click_chieftain_ready:Boolean;
      
      public function TutorialBattleStrandGreatHall_gp(param1:SceneState)
      {
         this.cmd_end_tutorial = new Cmd("end_tutorial",this.cmdFuncEndTutorial,this);
         super();
         this.sceneState = param1;
         this.gameFsm = param1.fsm as GameFsm;
         this.battleHandler = param1.battleHandler;
         this.logger = param1.logger;
         this.config = param1.config;
         this.config.keybinder.disableBindsFromGroup(KeyBindGroup.COMBAT);
         this.config.keybinder.bind(true,false,true,Keyboard.K,this.cmd_end_tutorial,"Tutorial");
         this.helper = new HelperTutorialState(param1,[this.mode_setup,this.mode_intro1,this.mode_intro2,this.mode_initiative,this.mode_move_start,this.mode_move_tiles,this.mode_move_click,this.mode_move_shieldbanger_wait,this.mode_attack_target,this.mode_attack_type,this.mode_attack_stats_str,this.mode_attack_stats_arm,this.mode_attack_confirm,this.mode_attack_wait,this.mode_attack_killed_renown,this.mode_next_initiative,this.mode_chieftain_move,this.mode_chieftain_attack_pre,this.mode_chieftain_attack,this.mode_warrior_willpower,this.mode_warrior_move_click,this.mode_move_warhawk_wait,this.mode_warrior_special_click,this.mode_warrior_self_popup,this.mode_warrior_tempest_target,this.mode_warrior_tempest_wait,this.mode_pillage,this.mode_chieftain_rest_pre,this.mode_chieftain_rest,this.mode_click_chieftain,this.mode_popup_chieftain]);
         this.handleEnteredState();
      }
      
      public function get isActive() : Boolean
      {
         return Boolean(this.helper) && this.helper.isActive;
      }
      
      private function cmdFuncEndTutorial(param1:CmdExec) : void
      {
         var _loc2_:TutorialBattleStrandGreatHall_gp = null;
         if(this.battleHandler)
         {
            _loc2_ = param1.cmd.config as TutorialBattleStrandGreatHall_gp;
            _loc2_.cleanup();
         }
      }
      
      public function cleanup() : void
      {
         this.config.keybinder.unbind(this.cmd_end_tutorial);
         BattleFsmConfig.sceneEnableAi = true;
         if(this.battleFsm)
         {
            this.battleFsm.removeEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN,this.battleTurnHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN_MOVE_COMMITTED,this.battleTurnMoveCommittedHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN_MOVE_EXECUTED,this.battleTurnMoveExecutedHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.battleAbilityExecutingHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.battleAbilityHandler);
            this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.battleAttackHandler);
         }
         if(this.battleBoard)
         {
            this.battleBoard.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
         }
         if(this.battleOrder)
         {
            this.battleOrder.removeEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
         }
         if(Boolean(this.battleFsm) && !this.battleFsm.battleFinished)
         {
            this.battleHandler.fsm.abortBattle(true);
         }
         this.battleFsm = null;
         this.battleOrder = null;
         this.battleBoard = null;
         this.battleHandler = null;
         this.config.keybinder.enableBindsFromGroup(KeyBindGroup.COMBAT);
         this.sceneState.config.battleHudConfig.reset(false);
         if(this.saga)
         {
            this.saga.handleHudHornEnabled();
         }
         this.sceneState.config.battleHudConfig.notify();
         this.sceneState.config.sceneControllerConfig.restrictInput = false;
         this.config.sceneControllerConfig.notify();
         this.helper.tt = null;
      }
      
      private function handleEnteredState() : void
      {
         this.gameFsm.updateGameLocation("loc_tutorial");
         if(!this.battleHandler.fsm)
         {
            this.logger.error("Battle did not prepare for tutorial!");
            return;
         }
         this.chieftain0 = this.battleHandler.fsm.board.entities["npc+0+tutorial_chieftain"];
         this.ruffian1 = this.battleHandler.fsm.board.entities["npc+1+tutorial_raider"];
         this.ruffian2 = this.battleHandler.fsm.board.entities["npc+2+tutorial_raider"];
         this.ruffian3 = this.battleHandler.fsm.board.entities["npc+3+tutorial_raider"];
         if(!this.chieftain0 || !this.ruffian1 || !this.ruffian2 || !this.ruffian3)
         {
            this.logger.error("Unable to load all tutorial npcs!");
         }
         this.saga = this.config.saga;
         this.battleFsm = this.battleHandler.fsm;
         this.battleBoard = this.battleFsm.board;
         this.battleOrder = this.battleFsm.order as BattleTurnOrder;
         BattleFsmConfig.sceneEnableAi = false;
         this.battleFsm.addEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN,this.battleTurnHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_MOVE_COMMITTED,this.battleTurnMoveCommittedHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_MOVE_EXECUTED,this.battleTurnMoveExecutedHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.battleAbilityExecutingHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.battleAbilityHandler);
         this.battleFsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.battleAttackHandler);
         this.battleBoard.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
         this.battleOrder.addEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
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
         this.config.battleHudConfig.keyboard = false;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.restrictInput = true;
         this.sceneState.addEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
         this.pageReadyHandler(null);
      }
      
      public function mode_setup(param1:Function) : void
      {
         var _loc2_:IBattleBoard = null;
         var _loc3_:IBattleParty = null;
         _loc2_ = this.battleHandler.fsm.board;
         _loc3_ = _loc2_.getPartyById(this.config.fsm.credentials.userId.toString());
         var _loc4_:BattleDeploymentArea = _loc2_.def.getDeploymentAreaById(_loc3_.deployment);
         _loc3_.deployed = true;
         this.helper.next(param1);
      }
      
      public function mode_intro1(param1:Function) : void
      {
         var battleAbilityDef:IBattleAbilityDef;
         var battleAbility:BattleAbility = null;
         var self:Function = param1;
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.chieftain0);
         battleAbilityDef = this.battleHandler.fsm.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_tutorial_threaten");
         battleAbility = new BattleAbility(this.chieftain0,battleAbilityDef,this.battleHandler.fsm.board.abilityManager);
         this.battleHandler.fsm.board.abilityManager.addEventListener(BattleAbilityEvent.ABILITY_POST_COMPLETE,function callback(param1:Event):void
         {
            if(battleAbility.completed)
            {
               if(battleHandler)
               {
                  battleHandler.fsm.board.abilityManager.removeEventListener(BattleAbilityEvent.ABILITY_POST_COMPLETE,callback);
                  helper.next(self);
               }
            }
         });
         battleAbility.execute(null);
      }
      
      public function mode_intro2(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,50,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_intro_mode_gp"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_initiative(param1:Function) : void
      {
         var self:Function = param1;
         if(this.saga)
         {
            this.saga.setVar(SagaVar.VAR_ACHIEVEMENTS_SUPPRESSED,true);
         }
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|activeFrame",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_initiative_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_move_start(param1:Function) : void
      {
         var uid:String = null;
         var sid:String = null;
         var self:Function = param1;
         uid = this.config.fsm.credentials.userId.toString();
         sid = uid + "+0+shieldbanger_tut";
         var shieldbanger:IBattleEntity = this.battleHandler.fsm.board.entities[sid];
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(shieldbanger);
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + sid + "|shadowBitmapWrapper",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.NONE,-64,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_move_start_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_move_tiles(param1:Function) : void
      {
         var self:Function = param1;
         var uid:String = this.config.fsm.credentials.userId.toString();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + uid + "+0+shieldbanger_tut|shadowBitmapWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_move_tiles_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_move_click(param1:Function) : void
      {
         var _loc2_:TileLocation = TileLocation.fetch(5,2);
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = _loc2_;
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowMoveTile = this.battleHandler.fsm.board.tiles.getTileByLocation(_loc2_);
         this.config.sceneControllerConfig.notify();
         this.battleHandler.board.selectedTile = this.battleHandler.fsm.turn.entity.tile;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|underlay|marker|tile",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.NONE,-32,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_move_click_mode_gp"),true,false,0);
      }
      
      public function mode_move_shieldbanger_wait(param1:Function) : void
      {
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.allowMoveTile = null;
         this.config.sceneControllerConfig.notify();
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = null;
         this.helper.tt = null;
      }
      
      public function mode_attack_target(param1:Function) : void
      {
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.ruffian3);
         this.config.battleHudConfig.selfPopup = true;
         this.config.battleHudConfig.selfPopupAttack = true;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.allowEntities.push(this.ruffian3);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.self_popup|basic|button$attack",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,48,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_attack_mode_gp"),true,false,0);
      }
      
      public function mode_attack_type(param1:Function) : void
      {
         var self:Function = param1;
         this.config.battleHudConfig.enemyPopup = true;
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.notify();
         this.config.battleHudConfig.enemyPopupWangler = false;
         this.config.battleHudConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|button_str|damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_type_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_stats_str(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|battle_info_flags|npc+3+tutorial_raider",TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_stats_str_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_stats_arm(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|battle_info_flags|npc+3+tutorial_raider",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_stats_arm_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_confirm(param1:Function) : void
      {
         this.config.battleHudConfig.enemyPopup = true;
         this.config.battleHudConfig.enemyPopupArmor = false;
         this.config.battleHudConfig.enemyPopupStrength = true;
         this.config.battleHudConfig.enemyPopupWangler = true;
         this.config.battleHudConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|button_str|damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_confirm_mode_gp"),true,false,0);
      }
      
      public function mode_attack_wait(param1:Function) : void
      {
         this.config.battleHudConfig.selfPopup = false;
         this.config.battleHudConfig.enemyPopup = false;
         this.config.battleHudConfig.notify();
         this.helper.tt = null;
      }
      
      public function mode_attack_killed_renown(param1:Function) : void
      {
         var uid:String;
         var self:Function = param1;
         if(this.saga)
         {
            this.saga.trackPageView("tutorial_attack1");
         }
         uid = this.config.fsm.credentials.userId.toString();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + uid + "+0+shieldbanger_tut|indicator|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_killed_renown_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_next_initiative(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|activeFrame",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_next_initiative_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_chieftain_move(param1:Function) : void
      {
         this.helper.tt = null;
         if(this.battleHandler.fsm.turn.entity == this.chieftain0)
         {
            this.battleHandler.fsm.turn.move.reset(this.chieftain0.tile);
            this.battleHandler.fsm.turn.move.addStep(this.battleHandler.fsm.board.tiles.getTile(4,1));
            this.battleHandler.fsm.turn.move.addStep(this.battleHandler.fsm.board.tiles.getTile(4,2));
            this.battleHandler.fsm.turn.move.addStep(this.battleHandler.fsm.board.tiles.getTile(4,3));
            this.battleHandler.fsm.turn.move.setCommitted("tutorial chieftain");
         }
      }
      
      public function mode_chieftain_attack_pre(param1:Function) : void
      {
         var self:Function = param1;
         this.battleFsm.interact = this.chieftain0;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+tutorial_chieftain|animSprite|displayObjectWrapper",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_chieftain_attack_pre_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_chieftain_attack(param1:Function) : void
      {
         var _loc2_:String = null;
         var _loc4_:IAbilityDef = null;
         var _loc5_:BattleAbilityDef = null;
         this.helper.tt = null;
         _loc2_ = this.config.fsm.credentials.userId.toString();
         var _loc3_:IBattleEntity = this.battleHandler.fsm.board.entities[_loc2_ + "+0+shieldbanger_tut"];
         if(this.battleHandler.fsm.turn.entity == this.chieftain0)
         {
            _loc4_ = this.battleHandler.fsm.turn.entity.def.attacks.getAbilityDefById("abl_melee_str");
            _loc5_ = _loc4_.getAbilityDefForLevel(1) as BattleAbilityDef;
            this.battleHandler.fsm.turn.ability = new BattleAbility(this.battleHandler.fsm.turn.entity,_loc5_,this.battleHandler.fsm.board.abilityManager);
            this.battleHandler.fsm.turn.ability.targetSet.addTarget(_loc3_);
            this.battleHandler.fsm.turn.committed = true;
         }
      }
      
      public function mode_warrior_willpower(param1:Function) : void
      {
         var self:Function = param1;
         var ap:Point = this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.getScenePoint(2,5);
         this.battleHandler.state.loader.scene._camera.drift.anchor = ap;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+2+tutorial_raider|indicator|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,16,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_willpower_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_warrior_move_click(param1:Function) : void
      {
         var _loc2_:TileLocation = TileLocation.fetch(1,2);
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = _loc2_;
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowMoveTile = this.battleHandler.fsm.board.tiles.getTileByLocation(_loc2_);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|underlay|marker|tile",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,48,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_move_click_mode_gp"),true,false,0);
      }
      
      public function mode_move_warhawk_wait(param1:Function) : void
      {
         this.helper.tt = null;
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = null;
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.allowMoveTile = null;
         this.config.sceneControllerConfig.notify();
      }
      
      public function mode_warrior_special_click(param1:Function) : void
      {
         var uid:String = null;
         var self:Function = param1;
         uid = this.config.fsm.credentials.userId.toString();
         var warhawk:IBattleEntity = this.battleHandler.fsm.board.entities[uid + "+1+warhawk_tut"];
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(warhawk);
         this.config.battleHudConfig.selfPopup = true;
         this.config.battleHudConfig.selfPopupAttack = false;
         this.config.battleHudConfig.selfPopupSpecial = false;
         this.config.battleHudConfig.selfPopupWangler = false;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.allowEntities.push(warhawk);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.self_popup|basic|ability_button",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,30,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_special_click_mode_gp"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_warrior_self_popup(param1:Function) : void
      {
         this.config.battleHudConfig.selfPopup = true;
         this.config.battleHudConfig.selfPopupAttack = false;
         this.config.battleHudConfig.selfPopupSpecial = true;
         this.config.battleHudConfig.selfPopupWangler = true;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.self_popup|basic|ability_button|placeholder",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_self_popup_mode_gp"),true,false,0);
      }
      
      public function mode_warrior_tempest_target(param1:Function) : void
      {
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.ruffian2);
         this.config.battleHudConfig.initiative = true;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.allowEntities.push(this.ruffian1);
         this.config.sceneControllerConfig.allowEntities.push(this.ruffian2);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+2+tutorial_raider|indicator|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_tempest_target_mode_gp"),true,false,0);
      }
      
      public function mode_warrior_tempest_wait(param1:Function) : void
      {
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.notify();
         this.helper.tt = null;
      }
      
      public function mode_pillage(param1:Function) : void
      {
         var self:Function = param1;
         if(this.saga)
         {
            this.saga.trackPageView("tutorial_tempest");
         }
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|order|_0",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_pillage_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_chieftain_rest_pre(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+tutorial_chieftain|animSprite|displayObjectWrapper",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_chieftain_rest_pre_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_chieftain_rest(param1:Function) : void
      {
         var _loc3_:IAbilityDef = null;
         var _loc4_:BattleAbilityDef = null;
         this.helper.tt = null;
         var _loc2_:String = this.config.fsm.credentials.userId.toString();
         if(this.battleHandler.fsm.turn.entity == this.chieftain0)
         {
            _loc3_ = this.chieftain0.def.actives.getAbilityDefById("abl_rest");
            _loc4_ = _loc3_.getAbilityDefForLevel(1) as BattleAbilityDef;
            this.battleHandler.fsm.turn.ability = new BattleAbility(this.chieftain0,_loc4_,this.battleHandler.fsm.board.abilityManager);
            this.battleHandler.fsm.turn.committed = true;
         }
      }
      
      public function mode_click_chieftain(param1:Function) : void
      {
         this.battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.chieftain0);
         this.config.battleHudConfig.selfPopupWangler = true;
         this.config.battleHudConfig.selfPopup = true;
         this.config.battleHudConfig.selfPopupAttack = true;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = true;
         this.config.sceneControllerConfig.allowEntities.splice(0,this.config.sceneControllerConfig.allowEntities.length);
         this.config.sceneControllerConfig.allowEntities.push(this.chieftain0);
         this.config.sceneControllerConfig.notify();
         var _loc2_:String = this.config.fsm.credentials.userId.toString();
         var _loc3_:* = _loc2_ + "+0+shieldbanger_tut";
         var _loc4_:IBattleEntity = this.battleHandler.fsm.board.entities[_loc3_];
         this.battleHandler.fsm.interact = _loc4_;
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.self_popup|basic|button$attack",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,48,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_click_chieftain_mode_gp"),true,false,0);
         this.mode_click_chieftain_ready = true;
      }
      
      public function mode_popup_chieftain(param1:Function) : void
      {
         this.config.battleHudConfig.enemyPopup = true;
         this.config.battleHudConfig.enemyPopupStrength = true;
         this.config.battleHudConfig.enemyPopupStars = true;
         this.config.battleHudConfig.enemyPopupMinStars = 1;
         this.config.battleHudConfig.notify();
         this.config.sceneControllerConfig.allowHover = false;
         this.config.sceneControllerConfig.notify();
         this.helper.tt = this.config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|strength_button_animated|str_damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,this.config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_popup_chieftain_mode_gp"),true,false,0);
      }
      
      private function pillageHandler(param1:BattleTurnOrderEvent) : void
      {
         if(this.helper.mode == this.mode_warrior_tempest_wait)
         {
            this.helper.next(null);
         }
      }
      
      private function battleAbilityHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_warrior_self_popup)
         {
            this.helper.next(null);
         }
      }
      
      private function boardEntityAliveHandler(param1:BattleBoardEvent) : void
      {
      }
      
      private function battleAbilityExecutingHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_attack_confirm || this.helper.mode == this.mode_popup_chieftain || this.helper.mode == this.mode_warrior_tempest_target)
         {
            this.helper.next(null);
         }
      }
      
      private function battleAttackHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_attack_target)
         {
            this.battleFsm.interact = this.ruffian3;
         }
         else if(this.helper.mode == this.mode_click_chieftain)
         {
            this.battleFsm.interact = this.chieftain0;
         }
      }
      
      private function battleInteractHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_attack_target)
         {
            this.helper.next(null);
         }
         else if(this.helper.mode == this.mode_click_chieftain && this.mode_click_chieftain_ready)
         {
            this.helper.next(null);
         }
      }
      
      private function battleTurnMoveExecutedHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_move_shieldbanger_wait || this.helper.mode == this.mode_move_warhawk_wait || this.helper.mode == this.mode_chieftain_move)
         {
            this.helper.next(null);
         }
      }
      
      private function battleTurnMoveCommittedHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_move_click || this.helper.mode == this.mode_warrior_move_click)
         {
            this.helper.next(null);
         }
      }
      
      private function pageReadyHandler(param1:Event) : void
      {
         if(this.sceneState.pageReady)
         {
            this.sceneState.removeEventListener(GameState.EVENT_PAGE_READY,this.pageReadyHandler);
            this.checkStartTutorial();
         }
      }
      
      private function battleFsmCurrentHandler(param1:FsmEvent) : void
      {
         this.checkStartTutorial();
      }
      
      private function checkStartTutorial() : void
      {
         if(this.sceneState.pageReady && this.battleFsm.currentClass == BattleStateDeploy)
         {
            this.helper.next(null);
         }
      }
      
      private function battleTurnHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_chieftain_attack || this.helper.mode == this.mode_attack_wait || this.helper.mode == this.mode_chieftain_rest)
         {
            this.helper.next(null);
         }
         if(this.battleHandler.fsm.turn.number > 2)
         {
         }
      }
   }
}
