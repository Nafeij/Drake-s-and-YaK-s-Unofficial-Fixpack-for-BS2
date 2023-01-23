package game.session.states.tutorial
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
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.BattleTurnOrderEvent;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.sim.IBattleParty;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.scene.model.SceneEvent;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import flash.geom.Point;
   import game.session.states.SceneState;
   import game.view.TutorialTooltip;
   
   public class TutorialBattleState extends SceneState
   {
       
      
      private var helper:HelperTutorialState;
      
      private var battleFsm:BattleFsm;
      
      private var battleOrder:BattleTurnOrder;
      
      private var battleBoard:IBattleBoard;
      
      private var chieftain0:IBattleEntity;
      
      private var ruffian1:IBattleEntity;
      
      private var ruffian2:IBattleEntity;
      
      private var ruffian3:IBattleEntity;
      
      private var _pageReady:Boolean = false;
      
      public function TutorialBattleState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.helper = new HelperTutorialState(this,[this.mode_setup,this.mode_intro1,this.mode_intro2,this.mode_initiative,this.mode_move_start,this.mode_move_tiles,this.mode_move_click,this.mode_move_shieldbanger_wait,this.mode_attack_target,this.mode_attack_type,this.mode_attack_stats_str,this.mode_attack_stats_arm,this.mode_attack_confirm,this.mode_attack_wait,this.mode_attack_killed_renown,this.mode_next_initiative,this.mode_chieftain_move,this.mode_chieftain_attack_pre,this.mode_chieftain_attack,this.mode_warrior_willpower,this.mode_warrior_move_click,this.mode_move_warhawk_wait,this.mode_warrior_special_click,this.mode_warrior_self_popup,this.mode_warrior_tempest_target,this.mode_warrior_tempest_wait,this.mode_pillage,this.mode_chieftain_rest_pre,this.mode_chieftain_rest,this.mode_click_chieftain,this.mode_popup_chieftain]);
      }
      
      public function mode_setup(param1:Function) : void
      {
         var _loc2_:IBattleBoard = null;
         var _loc3_:IBattleParty = null;
         _loc2_ = battleHandler.fsm.board;
         _loc3_ = _loc2_.getPartyById(config.fsm.credentials.userId.toString());
         var _loc4_:BattleDeploymentArea = _loc2_.def.getDeploymentAreaById(_loc3_.deployment);
         _loc2_.attemptDeploy(_loc3_.getMember(0),_loc4_.facing,_loc4_.area,TileLocation.fetch(5,5));
         _loc2_.attemptDeploy(_loc3_.getMember(1),_loc4_.facing,_loc4_.area,TileLocation.fetch(1,8));
         _loc3_.deployed = true;
         this.helper.next(param1);
      }
      
      public function mode_intro1(param1:Function) : void
      {
         var battleAbilityDef:IBattleAbilityDef;
         var battleAbility:BattleAbility = null;
         var self:Function = param1;
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.chieftain0);
         battleAbilityDef = battleHandler.fsm.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_tutorial_threaten");
         battleAbility = new BattleAbility(this.chieftain0,battleAbilityDef,battleHandler.fsm.board.abilityManager);
         battleHandler.fsm.board.abilityManager.addEventListener(BattleAbilityEvent.ABILITY_POST_COMPLETE,function callback(param1:Event):void
         {
            if(battleAbility.completed)
            {
               battleHandler.fsm.board.abilityManager.removeEventListener(BattleAbilityEvent.ABILITY_POST_COMPLETE,callback);
               helper.next(self);
            }
         });
         battleAbility.execute(null);
      }
      
      public function mode_intro2(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,50,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_intro_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_initiative(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|activeFrame",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_initiative_mode"),true,true,0);
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
         uid = config.fsm.credentials.userId.toString();
         sid = uid + "+0+shieldbanger_tutorial";
         var shieldbanger:IBattleEntity = battleHandler.fsm.board.entities[sid];
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(shieldbanger);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + sid + "|displayObjectWrapper",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.NONE,-64,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_move_start_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_move_tiles(param1:Function) : void
      {
         var self:Function = param1;
         var uid:String = config.fsm.credentials.userId.toString();
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + uid + "+0+shieldbanger_tutorial|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_move_tiles_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_move_click(param1:Function) : void
      {
         var _loc2_:TileLocation = TileLocation.fetch(5,2);
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = _loc2_;
         config.sceneControllerConfig.allowHover = true;
         config.sceneControllerConfig.allowMoveTile = battleHandler.fsm.board.tiles.getTileByLocation(_loc2_);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|underlay|marker|tile",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.NONE,-32,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_move_click_mode"),true,false,0);
      }
      
      public function mode_move_shieldbanger_wait(param1:Function) : void
      {
         config.sceneControllerConfig.allowHover = false;
         config.sceneControllerConfig.allowMoveTile = null;
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = null;
         this.helper.tt = null;
      }
      
      public function mode_attack_target(param1:Function) : void
      {
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.ruffian3);
         config.sceneControllerConfig.allowHover = true;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         config.sceneControllerConfig.allowEntities.push(this.ruffian3);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+3+tutorial_raider|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_attack_target_mode"),true,false,0);
      }
      
      public function mode_attack_type(param1:Function) : void
      {
         var self:Function = param1;
         config.sceneControllerConfig.allowHover = false;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|strength_button_animated|str_damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_type_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_stats_str(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|battle_info_flags|npc+3+tutorial_raider",TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_stats_str_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_stats_arm(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|battle_info_flags|npc+3+tutorial_raider",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_stats_arm_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_attack_confirm(param1:Function) : void
      {
         config.battleHudConfig.enemyPopup = true;
         config.battleHudConfig.enemyPopupStrength = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|strength_button_animated|str_damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_confirm_mode"),true,false,0);
      }
      
      public function mode_attack_wait(param1:Function) : void
      {
         this.helper.tt = null;
      }
      
      public function mode_attack_killed_renown(param1:Function) : void
      {
         var self:Function = param1;
         var uid:String = config.fsm.credentials.userId.toString();
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + uid + "+0+shieldbanger_tutorial|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_attack_killed_renown_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_next_initiative(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|activeFrame",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_next_initiative_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_chieftain_move(param1:Function) : void
      {
         this.helper.tt = null;
         if(battleHandler.fsm.turn.entity == this.chieftain0)
         {
            battleHandler.fsm.turn.move.reset(this.chieftain0.tile);
            battleHandler.fsm.turn.move.addStep(battleHandler.fsm.board.tiles.getTile(4,1));
            battleHandler.fsm.turn.move.addStep(battleHandler.fsm.board.tiles.getTile(4,2));
            battleHandler.fsm.turn.move.addStep(battleHandler.fsm.board.tiles.getTile(4,3));
            battleHandler.fsm.turn.move.setCommitted("tutorial chieftain");
         }
      }
      
      public function mode_chieftain_attack_pre(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+tutorial_chieftain|animSprite|displayObjectWrapper",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_chieftain_attack_pre_mode"),true,true,0);
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
         _loc2_ = config.fsm.credentials.userId.toString();
         var _loc3_:IBattleEntity = battleHandler.fsm.board.entities[_loc2_ + "+0+shieldbanger_tutorial"];
         if(battleHandler.fsm.turn.entity == this.chieftain0)
         {
            _loc4_ = battleHandler.fsm.turn.entity.def.attacks.getAbilityDefById("abl_melee_str");
            _loc5_ = _loc4_.getAbilityDefForLevel(1) as BattleAbilityDef;
            battleHandler.fsm.turn.ability = new BattleAbility(battleHandler.fsm.turn.entity,_loc5_,battleHandler.fsm.board.abilityManager);
            battleHandler.fsm.turn.ability.targetSet.addTarget(_loc3_);
            battleHandler.fsm.turn.committed = true;
         }
      }
      
      public function mode_warrior_willpower(param1:Function) : void
      {
         var self:Function = param1;
         var ap:Point = battleHandler.state.loader.viewSprite.boards.focusedBoardView.getScenePoint(2,5);
         battleHandler.state.loader.scene._camera.drift.anchor = ap;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+2+tutorial_raider|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_willpower_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_warrior_move_click(param1:Function) : void
      {
         var _loc2_:TileLocation = TileLocation.fetch(1,2);
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = _loc2_;
         config.sceneControllerConfig.allowHover = true;
         config.sceneControllerConfig.allowMoveTile = battleHandler.fsm.board.tiles.getTileByLocation(_loc2_);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|underlay|marker|tile",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_move_click_mode"),true,false,0);
      }
      
      public function mode_move_warhawk_wait(param1:Function) : void
      {
         this.helper.tt = null;
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.underlay.marker.tileLocation = null;
         config.sceneControllerConfig.allowHover = false;
         config.sceneControllerConfig.allowMoveTile = null;
      }
      
      public function mode_warrior_special_click(param1:Function) : void
      {
         var _loc2_:String = null;
         _loc2_ = config.fsm.credentials.userId.toString();
         var _loc3_:IBattleEntity = battleHandler.fsm.board.entities[_loc2_ + "+1+warhawk_tutorial"];
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(_loc3_);
         config.sceneControllerConfig.allowHover = true;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         config.sceneControllerConfig.allowEntities.push(_loc3_);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|" + _loc2_ + "+1+warhawk_tutorial|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,32,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_special_click_mode"),true,false,0);
      }
      
      public function mode_warrior_self_popup(param1:Function) : void
      {
         config.battleHudConfig.selfPopup = true;
         config.battleHudConfig.selfPopupSpecial = true;
         config.battleHudConfig.notify();
         config.sceneControllerConfig.allowHover = false;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.self_popup|basic|ability_button",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_self_popup_mode"),true,false,0);
      }
      
      public function mode_warrior_tempest_target(param1:Function) : void
      {
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(this.ruffian2);
         config.sceneControllerConfig.allowHover = true;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         config.sceneControllerConfig.allowEntities.push(this.ruffian1);
         config.sceneControllerConfig.allowEntities.push(this.ruffian2);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+2+tutorial_raider|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_warrior_tempest_target_mode"),true,false,0);
      }
      
      public function mode_warrior_tempest_wait(param1:Function) : void
      {
         config.sceneControllerConfig.allowHover = false;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         this.helper.tt = null;
      }
      
      public function mode_pillage(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.battle_hud|assets.battle_initiative|order|_0",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_pillage_mode"),true,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_chieftain_rest_pre(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+tutorial_chieftain|animSprite|displayObjectWrapper",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_chieftain_rest_pre_mode"),true,true,0);
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
         var _loc2_:String = config.fsm.credentials.userId.toString();
         if(battleHandler.fsm.turn.entity == this.chieftain0)
         {
            _loc3_ = this.chieftain0.def.actives.getAbilityDefById("abl_rest");
            _loc4_ = _loc3_.getAbilityDefForLevel(1) as BattleAbilityDef;
            battleHandler.fsm.turn.ability = new BattleAbility(this.chieftain0,_loc4_,battleHandler.fsm.board.abilityManager);
            battleHandler.fsm.turn.committed = true;
         }
      }
      
      public function mode_click_chieftain(param1:Function) : void
      {
         var _loc2_:IBattleEntity = battleHandler.fsm.board.entities["npc+0+tutorial_chieftain"];
         battleHandler.state.loader.viewSprite.boards.focusedBoardView.centerOnEntity(_loc2_);
         config.sceneControllerConfig.allowHover = true;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         config.sceneControllerConfig.allowEntities.push(_loc2_);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|scene_view|boards|focusedBoardView|entityViews|npc+0+tutorial_chieftain|displayObjectWrapper",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.NONE,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_click_chieftain_mode"),true,false,0);
      }
      
      public function mode_popup_chieftain(param1:Function) : void
      {
         config.battleHudConfig.enemyPopupStrength = true;
         config.battleHudConfig.enemyPopupStars = true;
         config.battleHudConfig.enemyPopupMinStars = 1;
         config.battleHudConfig.notify();
         config.sceneControllerConfig.allowHover = false;
         config.sceneControllerConfig.allowEntities.splice(0,config.sceneControllerConfig.allowEntities.length);
         this.helper.tt = config.tutorialLayer.createTooltip("ScenePage|BattleHudPage|assets.enemy_popup|strength_button_animated|str_damage_flag",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,16,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_battle_popup_chieftain_mode"),true,false,0);
      }
      
      override protected function sceneExitHandler(param1:SceneEvent) : void
      {
         phase = StatePhase.COMPLETED;
      }
      
      override protected function handleCleanup() : void
      {
         BattleFsmConfig.sceneEnableAi = true;
         this.battleFsm.removeEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN,this.battleTurnHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_MOVE_COMMITTED,this.battleTurnMoveCommittedHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_MOVE_EXECUTED,this.battleTurnMoveExecutedHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.battleAbilityExecutingHandler);
         this.battleFsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.battleAbilityHandler);
         this.battleBoard.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
         this.battleOrder.removeEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
         this.battleFsm = null;
         this.battleOrder = null;
         this.battleBoard = null;
         config.battleHudConfig.reset();
         config.sceneControllerConfig.restrictInput = false;
         this.helper.tt = null;
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:BattleRewardData = null;
         gameFsm.updateGameLocation("loc_tutorial");
         super.handleEnteredState();
         this.chieftain0 = battleHandler.fsm.board.entities["npc+0+tutorial_chieftain"];
         this.ruffian1 = battleHandler.fsm.board.entities["npc+1+tutorial_raider"];
         this.ruffian2 = battleHandler.fsm.board.entities["npc+2+tutorial_raider"];
         this.ruffian3 = battleHandler.fsm.board.entities["npc+3+tutorial_raider"];
         if(!this.chieftain0 || !this.ruffian1 || !this.ruffian2 || !this.ruffian3)
         {
            logger.error("Unable to load all tutorial npcs!");
         }
         this.battleFsm = battleHandler.fsm;
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
         this.battleBoard.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
         this.battleOrder.addEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
         chatEnabled = false;
         scene.allClickablesDisabled = true;
         config.alerts.enabled = false;
         config.battleHudConfig.escape = false;
         config.battleHudConfig.showHorn = false;
         config.battleHudConfig.initiative = false;
         config.battleHudConfig.enemyPopup = false;
         config.battleHudConfig.enemyPopupStars = false;
         config.battleHudConfig.enemyPopupStrength = false;
         config.battleHudConfig.enemyPopupArmor = false;
         config.battleHudConfig.selfPopup = false;
         config.battleHudConfig.selfPopupAttack = false;
         config.battleHudConfig.selfPopupEnd = false;
         config.battleHudConfig.selfPopupMove = false;
         config.battleHudConfig.selfPopupSpecial = false;
         config.battleHudConfig.notify();
         config.sceneControllerConfig.restrictInput = true;
         var _loc1_:BattleFinishedData = new BattleFinishedData();
         _loc1_.victoriousTeam = config.fsm.credentials.userId.toString();
         var _loc2_:int = 0;
         while(_loc2_ < this.battleFsm.board.numParties)
         {
            _loc3_ = this.battleFsm.board.getParty(_loc2_);
            _loc4_ = new BattleRewardData();
            if(_loc2_ == this.battleFsm.localBattleOrder)
            {
               _loc4_.awards[BattleRenownAwardType.KILLS] = 4;
               _loc4_.awards[BattleRenownAwardType.WIN] = 1;
               _loc4_.total_renown = 5;
            }
            _loc1_.rewards.push(_loc4_);
            _loc2_++;
         }
         this.battleFsm.setFinishedData(_loc1_);
         this.battleFsm.current.data.setValue(BattleStateDataEnum.FINISHED,_loc1_);
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
         if(this.helper.mode == this.mode_attack_confirm || this.helper.mode == this.mode_popup_chieftain)
         {
            this.helper.next(null);
         }
      }
      
      private function battleInteractHandler(param1:BattleFsmEvent) : void
      {
         if(this.helper.mode == this.mode_attack_target || this.helper.mode == this.mode_warrior_tempest_target || this.helper.mode == this.mode_click_chieftain || this.helper.mode == this.mode_warrior_special_click)
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
      
      override public function handlePageReady() : void
      {
         super.handlePageReady();
         this._pageReady = true;
         this.checkStartTutorial();
      }
      
      private function battleFsmCurrentHandler(param1:FsmEvent) : void
      {
         this.checkStartTutorial();
      }
      
      private function checkStartTutorial() : void
      {
         if(this._pageReady && this.battleFsm.currentClass == BattleStateDeploy)
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
         if(battleHandler.fsm.turn.number > 2)
         {
         }
      }
   }
}
