package game.gui.page
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleTargetSet;
   import engine.battle.board.controller.BattleBoardController;
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.model.IBattleScenario;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Assemble;
   import engine.battle.sim.IBattleParty;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.logging.ILogger;
   import engine.gui.BattleHudConfig;
   import engine.gui.GuiGpBitmap;
   import engine.gui.PopupAbilityValidity;
   import engine.gui.StickFlicker;
   import engine.landscape.view.LandscapeViewController;
   import engine.saga.SagaCheat;
   import engine.scene.SceneControllerConfig;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.session.states.SceneState;
   
   public class BattleHudPageInput
   {
       
      
      private var bhp:BattleHudPage;
      
      private var bhc:BattleHudConfig;
      
      private var config:GameConfig;
      
      private var cmd_toggle_hud:Cmd;
      
      private var cmd_toggle_visible:Cmd;
      
      private var cmd_killall:Cmd;
      
      private var cmd_surrender:Cmd;
      
      private var cmd_killtarget:Cmd;
      
      private var cmd_plinkarmor:Cmd;
      
      private var cmd_battle_hud_escape:Cmd;
      
      private var cmd_battle_hud_cancel:Cmd;
      
      private var cmd_battle_hud_menu:Cmd;
      
      private var cmd_toggle_info:Cmd;
      
      private var cmd_toggle_help:Cmd;
      
      private var cmd_move:Cmd;
      
      private var cmd_ability:Cmd;
      
      private var cmd_attack:Cmd;
      
      private var cmd_end_turn:Cmd;
      
      private var cmd_use_horn:Cmd;
      
      private var cmd_ready:Cmd;
      
      private var cmd_stars_plus:Cmd;
      
      private var cmd_stars_minus:Cmd;
      
      private var cmd_interact_prev:Cmd;
      
      private var cmd_interact_next:Cmd;
      
      private var cmd_interact_allies_prev:Cmd;
      
      private var cmd_interact_allies_next:Cmd;
      
      private var cmd_interact_enemies_prev:Cmd;
      
      private var cmd_interact_enemies_next:Cmd;
      
      private var cmd_interact_active:Cmd;
      
      private var cmd_tile_select:Cmd;
      
      private var cmd_tile_alt:Cmd;
      
      private var cmd_y:Cmd;
      
      private var cmd_facing_ne:Cmd;
      
      private var cmd_facing_nw:Cmd;
      
      private var cmd_facing_se:Cmd;
      
      private var cmd_facing_sw:Cmd;
      
      private var fsm:BattleFsm;
      
      private var landscapeController:LandscapeViewController;
      
      private var flicker:StickFlicker;
      
      private var moveTileErrorSounded:Boolean;
      
      private var lastTileDir:Point;
      
      private var tiledir_nw:Boolean = false;
      
      private var tiledir_ne:Boolean = false;
      
      private var tiledir_sw:Boolean = false;
      
      private var tiledir_se:Boolean = false;
      
      private var alt_tiledir_nw:Boolean = false;
      
      private var alt_tiledir_ne:Boolean = false;
      
      private var alt_tiledir_sw:Boolean = false;
      
      private var alt_tiledir_se:Boolean = false;
      
      private var repeating:int = 0;
      
      private var TICK_DELAY_STATIC:int = 100;
      
      private var TICK_DELAY_START:int = 500;
      
      private var TICK_DELAY_REPEAT:int = 200;
      
      private var last_stick_h:Number = 0;
      
      private var last_stick_v:Number = 0;
      
      private var stick_mag:Number = 1;
      
      private var partition_0:int = 22;
      
      private var partition_1:int = 68;
      
      private var partition_2:int = 112;
      
      private var partition_3:int = 158;
      
      public var logger:ILogger;
      
      private var _lastInteractIndex:int = -1;
      
      private var areas:BattleDeploymentAreas;
      
      private var valids:Vector.<BattleAbilityDef>;
      
      public function BattleHudPageInput(param1:BattleHudPage)
      {
         this.cmd_toggle_hud = new Cmd("bhp_toggle_hud",this.cmdFuncToggleHud);
         this.cmd_toggle_visible = new Cmd("bhp_toggle_visible",this.cmdFuncToggleVisible);
         this.cmd_killall = new Cmd("bhp_killall",this.cmdFuncKillall);
         this.cmd_surrender = new Cmd("bhp_suicide",this.cmdFuncSurrender);
         this.cmd_killtarget = new Cmd("bhp_killtarget",this.cmdFuncKillTarget);
         this.cmd_plinkarmor = new Cmd("bhp_plinkarmor",this.cmdFuncPlinkArmor);
         this.cmd_battle_hud_escape = new Cmd("bhp_battle_hud_escape",this.cmdEscapeFunc);
         this.cmd_battle_hud_cancel = new Cmd("bhp_battle_hud_cancel",this.cmdCancelFunc);
         this.cmd_battle_hud_menu = new Cmd("bhp_cmd_battle_hud_menu",this.cmdMenuFunc);
         this.cmd_toggle_info = new Cmd("bhp_toggle_info",this.toggleInfoFunc);
         this.cmd_toggle_help = new Cmd("bhp_toggle_help",this.toggleHelpFunc);
         this.cmd_move = new Cmd("bhp_move",this.moveModeHotKey);
         this.cmd_ability = new Cmd("bhp_ability",this.abilityModeHotKey);
         this.cmd_attack = new Cmd("bhp_attack",this.attackModeHotKey);
         this.cmd_end_turn = new Cmd("bhp_end_turn",this.endTurnHotKey);
         this.cmd_use_horn = new Cmd("bhp_use_horn",this.useHornHotKey);
         this.cmd_ready = new Cmd("bhp_ready",this.cmdFuncReady);
         this.cmd_stars_plus = new Cmd("bhp_stars_plus",this.cmdFuncStarsPlus);
         this.cmd_stars_minus = new Cmd("bhp_stars_minus",this.cmdFuncStarsMinus);
         this.cmd_interact_prev = new Cmd("bhp_cmd_interact_prev",this.cmdFuncInteractPrev);
         this.cmd_interact_next = new Cmd("bhp_cmd_interact_next",this.cmdFuncInteractNext);
         this.cmd_interact_allies_prev = new Cmd("bhp_cmd_interact_prev",this.cmdFuncInteractAlliesPrev);
         this.cmd_interact_allies_next = new Cmd("bhp_cmd_interact_next",this.cmdFuncInteractAlliesNext);
         this.cmd_interact_enemies_prev = new Cmd("bhp_cmd_interact_prev",this.cmdFuncInteractEnemiesPrev);
         this.cmd_interact_enemies_next = new Cmd("bhp_cmd_interact_next",this.cmdFuncInteractEnemiesNext);
         this.cmd_interact_active = new Cmd("bhp_cmd_interact_active",this.cmdFuncInteractActive);
         this.cmd_tile_select = new Cmd("bhp_cmd_tile_select",this.cmdFuncTileSelect);
         this.cmd_tile_alt = new Cmd("bhp_cmd_tile_alt",this.cmdFuncTileAlt);
         this.cmd_y = new Cmd("bhp_cmd_y",this.func_cmd_y);
         this.cmd_facing_ne = new Cmd("bhp_cmd_facing_ne",this.cmdFuncFacing,BattleFacing.NE);
         this.cmd_facing_nw = new Cmd("bhp_cmd_facing_nw",this.cmdFuncFacing,BattleFacing.NW);
         this.cmd_facing_se = new Cmd("bhp_cmd_facing_se",this.cmdFuncFacing,BattleFacing.SE);
         this.cmd_facing_sw = new Cmd("bhp_cmd_facing_sw",this.cmdFuncFacing,BattleFacing.SW);
         this.lastTileDir = new Point();
         this.areas = new BattleDeploymentAreas();
         this.valids = new Vector.<BattleAbilityDef>();
         super();
         this.bhp = param1;
         if(param1.scene.focusedBoard)
         {
            this.fsm = param1.scene.focusedBoard.fsm as BattleFsm;
         }
         this.logger = param1.logger;
         this.config = param1.config;
         this.bhc = this.config.battleHudConfig;
         this.landscapeController = param1.battleHandler.page.controller.landscapeController;
         this.flicker = new StickFlicker(this.flickHandler,false,false,"bhp",this.logger);
         this.bindAll();
         this.fsm.addEventListener(BattleFsmEvent.BATTLE_FINISHED,this.battleFinishedHandler);
         this.fsm.addEventListener(BattleFsmEvent.BATTLE_RESPAWN,this.battleRespawnHandler);
         this.landscapeController.addEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.landscapeClickableHandler);
         this.checkStickFlickerEnabled();
         this.config.sceneControllerConfig.addEventListener(SceneControllerConfig.EVENT_CHANGED,this.sceneControllerConfigHandler);
      }
      
      public function get hornGpBmp() : GuiGpBitmap
      {
         return this.config.gpbinder.getGpBmp(GpControlButton.Y,this.cmd_y);
      }
      
      private function battleFinishedHandler(param1:BattleFsmEvent) : void
      {
         this.unbindAll();
      }
      
      private function battleRespawnHandler(param1:BattleFsmEvent) : void
      {
         this.bindAll();
      }
      
      private function bindAll() : void
      {
         this.config.keybinder.bind(true,false,true,Keyboard.H,this.cmd_toggle_hud,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(true,false,true,Keyboard.T,this.cmd_toggle_visible,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_battle_hud_escape,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_battle_hud_escape,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.TAB,this.cmd_toggle_info,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMBER_1,this.cmd_move,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMPAD_1,this.cmd_move,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMBER_2,this.cmd_ability,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMPAD_2,this.cmd_ability,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.EQUAL,this.cmd_stars_plus,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.MINUS,this.cmd_stars_minus,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMBER_3,this.cmd_attack,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMPAD_3,this.cmd_attack,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMBER_4,this.cmd_end_turn,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMPAD_4,this.cmd_end_turn,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.NUMBER_0,this.cmd_use_horn,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.UP,this.cmd_toggle_info,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.DOWN,this.cmd_interact_active,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.LEFT,this.cmd_interact_prev,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,false,Keyboard.RIGHT,this.cmd_interact_next,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(true,false,false,Keyboard.LEFT,this.cmd_interact_allies_prev,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(true,false,false,Keyboard.RIGHT,this.cmd_interact_allies_next,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,true,Keyboard.LEFT,this.cmd_interact_enemies_prev,KeyBindGroup.COMBAT);
         this.config.keybinder.bind(false,false,true,Keyboard.RIGHT,this.cmd_interact_enemies_next,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.D_U,this.cmd_toggle_info,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.REPLACE_MENU_BUTTON,this.cmd_toggle_help,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.D_L,this.cmd_interact_prev,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.D_R,this.cmd_interact_next,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.D_D,this.cmd_interact_active,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.A,this.cmd_tile_select,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.B,this.cmd_battle_hud_cancel,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.X,this.cmd_tile_alt,KeyBindGroup.COMBAT);
         this.config.gpbinder.bindPress(GpControlButton.Y,this.cmd_y,KeyBindGroup.COMBAT,true);
         if(this.config.saga)
         {
            if(this.config.options.developer)
            {
               this.config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_killall,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(true,false,true,Keyboard.K,this.cmd_killall,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(true,false,true,Keyboard.SEMICOLON,this.cmd_plinkarmor,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(true,false,true,Keyboard.J,this.cmd_killtarget,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(true,false,true,Keyboard.L,this.cmd_surrender,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(false,false,false,Keyboard.I,this.cmd_facing_nw,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(false,false,false,Keyboard.O,this.cmd_facing_ne,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(false,false,false,Keyboard.J,this.cmd_facing_sw,KeyBindGroup.COMBAT);
               this.config.keybinder.bind(false,false,false,Keyboard.K,this.cmd_facing_se,KeyBindGroup.COMBAT);
            }
            this.config.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_ready,KeyBindGroup.COMBAT);
            GpDevBinder.instance.bind(null,GpControlButton.A,1,this.cmdFuncKillall,[null]);
            GpDevBinder.instance.bind(null,GpControlButton.B,1,this.cmdFuncKillTarget,[null]);
            GpDevBinder.instance.bind(null,GpControlButton.X,1,this.cmdFuncPlinkArmor,[null]);
            GpDevBinder.instance.bind(null,GpControlButton.Y,1,this.cmdFuncSurrender,[null]);
         }
      }
      
      private function unbindAll() : void
      {
         this.config.keybinder.unbind(this.cmd_facing_nw);
         this.config.keybinder.unbind(this.cmd_facing_ne);
         this.config.keybinder.unbind(this.cmd_facing_sw);
         this.config.keybinder.unbind(this.cmd_facing_se);
         GpDevBinder.instance.unbind(this.cmdFuncReady);
         GpDevBinder.instance.unbind(this.cmdFuncKillall);
         GpDevBinder.instance.unbind(this.cmdFuncKillTarget);
         GpDevBinder.instance.unbind(this.cmdFuncPlinkArmor);
         GpDevBinder.instance.unbind(this.cmdFuncSurrender);
         this.config.gpbinder.unbind(this.cmd_toggle_info);
         this.config.gpbinder.unbind(this.cmd_toggle_help);
         this.config.gpbinder.unbind(this.cmd_interact_prev);
         this.config.gpbinder.unbind(this.cmd_interact_next);
         this.config.gpbinder.unbind(this.cmd_interact_active);
         this.config.gpbinder.unbind(this.cmd_tile_select);
         this.config.gpbinder.unbind(this.cmd_battle_hud_cancel);
         this.config.gpbinder.unbind(this.cmd_tile_alt);
         this.config.gpbinder.unbind(this.cmd_y);
         this.config.keybinder.unbind(this.cmd_toggle_hud);
         this.config.keybinder.unbind(this.cmd_battle_hud_escape);
         this.config.keybinder.unbind(this.cmd_toggle_info);
         this.config.keybinder.unbind(this.cmd_move);
         this.config.keybinder.unbind(this.cmd_ability);
         this.config.keybinder.unbind(this.cmd_attack);
         this.config.keybinder.unbind(this.cmd_end_turn);
         this.config.keybinder.unbind(this.cmd_use_horn);
         this.config.keybinder.unbind(this.cmd_interact_prev);
         this.config.keybinder.unbind(this.cmd_interact_next);
         this.config.keybinder.unbind(this.cmd_interact_active);
         this.config.keybinder.unbind(this.cmd_killall);
         this.config.keybinder.unbind(this.cmd_plinkarmor);
         this.config.keybinder.unbind(this.cmd_killtarget);
         this.config.keybinder.unbind(this.cmd_surrender);
         this.config.keybinder.unbind(this.cmd_ready);
         this.config.keybinder.unbind(this.cmd_toggle_visible);
         this.config.keybinder.unbind(this.cmd_battle_hud_escape);
         this.config.keybinder.unbind(this.cmd_ability);
         this.config.keybinder.unbind(this.cmd_stars_plus);
         this.config.keybinder.unbind(this.cmd_stars_minus);
         this.config.keybinder.unbind(this.cmd_interact_allies_prev);
         this.config.keybinder.unbind(this.cmd_interact_allies_next);
         this.config.keybinder.unbind(this.cmd_interact_enemies_prev);
         this.config.keybinder.unbind(this.cmd_interact_enemies_next);
      }
      
      private function checkStickFlickerEnabled() : void
      {
         var _loc1_:Boolean = true;
         var _loc2_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         if(Boolean(_loc2_) && Boolean(this.fsm.interact))
         {
            if(Boolean(this.fsm._ability) && this.fsm._ability.def.targetRule.isTile)
            {
               _loc1_ = true;
            }
            else
            {
               _loc1_ = false;
            }
         }
         var _loc3_:SceneControllerConfig = this.config.sceneControllerConfig;
         if(_loc1_ && _loc3_.restrictInput)
         {
            _loc1_ = _loc3_.allowHover || Boolean(_loc3_.allowMoveTile);
         }
         if(_loc1_ && _loc3_.redeployRosterInFocus)
         {
            _loc1_ = false;
         }
         this.flicker.enabled = _loc1_;
      }
      
      private function sceneControllerConfigHandler(param1:Event) : void
      {
         this.checkStickFlickerEnabled();
      }
      
      private function landscapeClickableHandler(param1:Event) : void
      {
         this.checkStickFlickerEnabled();
      }
      
      public function cleanup() : void
      {
         this.config.sceneControllerConfig.removeEventListener(SceneControllerConfig.EVENT_CHANGED,this.sceneControllerConfigHandler);
         this.landscapeController.removeEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.landscapeClickableHandler);
         this.landscapeController = null;
         this.flicker.cleanup();
         this.flicker = null;
         this.fsm.removeEventListener(BattleFsmEvent.BATTLE_FINISHED,this.battleFinishedHandler);
         this.fsm.removeEventListener(BattleFsmEvent.BATTLE_RESPAWN,this.battleRespawnHandler);
         this.fsm = null;
         this.bhc = null;
         this.unbindAll();
         this.cmd_toggle_hud.cleanup();
         this.cmd_killall.cleanup();
         this.cmd_surrender.cleanup();
         this.cmd_killtarget.cleanup();
         this.cmd_plinkarmor.cleanup();
         this.cmd_battle_hud_escape.cleanup();
         this.cmd_battle_hud_cancel.cleanup();
         this.cmd_battle_hud_menu.cleanup();
         this.cmd_toggle_info.cleanup();
         this.cmd_toggle_help.cleanup();
         this.cmd_move.cleanup();
         this.cmd_ability.cleanup();
         this.cmd_attack.cleanup();
         this.cmd_end_turn.cleanup();
         this.cmd_use_horn.cleanup();
         this.cmd_ready.cleanup();
         this.cmd_interact_prev.cleanup();
         this.cmd_interact_next.cleanup();
         this.cmd_interact_active.cleanup();
         this.cmd_tile_select.cleanup();
         this.cmd_tile_alt.cleanup();
         this.cmd_y.cleanup();
         this.cmd_stars_plus.cleanup();
         this.cmd_stars_minus.cleanup();
         this.cmd_interact_allies_prev.cleanup();
         this.cmd_interact_allies_next.cleanup();
         this.cmd_interact_enemies_prev.cleanup();
         this.cmd_interact_enemies_next.cleanup();
         this.cmd_facing_ne.cleanup();
         this.cmd_facing_nw.cleanup();
         this.cmd_facing_se.cleanup();
         this.cmd_facing_sw.cleanup();
         this.cmd_toggle_visible.cleanup();
         this.cmd_toggle_hud = null;
         this.cmd_battle_hud_escape = null;
         this.cmd_toggle_info = null;
         this.cmd_move = null;
         this.cmd_ability = null;
         this.cmd_attack = null;
         this.cmd_end_turn = null;
         this.cmd_use_horn = null;
         this.cmd_killall = null;
         this.cmd_killtarget = null;
         this.cmd_ready = null;
         this.cmd_surrender = null;
         this.cmd_plinkarmor = null;
         this.cmd_stars_plus = null;
         this.cmd_stars_minus = null;
         this.cmd_interact_allies_prev = null;
         this.cmd_interact_allies_next = null;
         this.cmd_interact_enemies_prev = null;
         this.cmd_interact_enemies_next = null;
         this.cmd_facing_ne = null;
         this.cmd_facing_nw = null;
         this.cmd_facing_se = null;
         this.cmd_facing_sw = null;
         this.cmd_toggle_visible = null;
         this.config = null;
      }
      
      private function useHornHotKey(param1:CmdExec) : void
      {
         this.bhp.guiHornUse();
      }
      
      public function get popupEnemyHelper() : PopupEnemyHelper
      {
         return this.bhp.popupEnemyHelper;
      }
      
      public function get popupSelfHelper() : PopupSelfHelper
      {
         return this.bhp.popupSelfHelper;
      }
      
      public function get battleHudPageLoadHelper() : BattleHudPageLoadHelper
      {
         return this.bhp.bhpLoadHelper;
      }
      
      public function get bhpPopupLoadHelper() : BattleHudPagePopupLoadHelper
      {
         return this.bhp.bhpPopupLoadHelper;
      }
      
      public function get turn() : BattleTurn
      {
         return this.bhp.turn;
      }
      
      private function _getIterableUnits() : Vector.<IBattleEntity>
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:int = 0;
         var _loc1_:IBattleBoard = !!this.fsm ? this.fsm.board : null;
         if(!_loc1_)
         {
            return null;
         }
         var _loc2_:Vector.<IBattleEntity> = this.fsm.order.aliveOrder.concat();
         for each(_loc3_ in _loc1_.entities)
         {
            if(_loc3_.party == null || _loc3_.party.id == "prop")
            {
               if(_loc3_.alive && Boolean(_loc3_.visibleToPlayer) && (Boolean(_loc3_.attackable) || Boolean(_loc3_.usable)))
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_];
            if(!_loc3_.visibleToPlayer && !_loc3_.isSubmerged)
            {
               _loc2_.splice(_loc4_,1);
            }
            else
            {
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      private function getNextInteractIndex_deploy() : IBattleEntity
      {
         var _loc1_:int = 0;
         var _loc2_:IBattleParty = this.fsm.board.getPartyById(this.fsm.session.credentials.userId.toString());
         _loc1_ = _loc2_.getMemberIndex(this.fsm.interact);
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         else
         {
            _loc1_ = ++_loc1_ % _loc2_.numMembers;
         }
         if(_loc1_ >= 0 && _loc1_ < _loc2_.numMembers)
         {
            return _loc2_.getMember(_loc1_);
         }
         return null;
      }
      
      private function getPrevInteractIndex_deploy() : IBattleEntity
      {
         var _loc1_:int = 0;
         var _loc2_:IBattleParty = this.fsm.board.getPartyById(this.fsm.session.credentials.userId.toString());
         _loc1_ = _loc2_.getMemberIndex(this.fsm.interact);
         if(_loc1_ <= 0)
         {
            _loc1_ = _loc2_.numMembers - 1;
         }
         else
         {
            _loc1_ = (_loc1_ + _loc2_.numMembers - 1) % _loc2_.numMembers;
         }
         if(_loc1_ >= 0 && _loc1_ < _loc2_.numMembers)
         {
            return _loc2_.getMember(_loc1_);
         }
         return null;
      }
      
      private function getInteractIndex_initiative(param1:Boolean, param2:Boolean, param3:int) : IBattleEntity
      {
         var _loc10_:IBattleEntity = null;
         if(!this.turn)
         {
            return null;
         }
         var _loc4_:Vector.<IBattleEntity> = this._getIterableUnits();
         if(!_loc4_ || _loc4_.length == 0)
         {
            return null;
         }
         var _loc5_:SceneControllerConfig = SceneControllerConfig.instance;
         var _loc6_:int = this._lastInteractIndex;
         if(_loc6_ < 0 || _loc6_ >= _loc4_.length || _loc4_[_loc6_] != this.fsm.interact)
         {
            _loc6_ = _loc4_.indexOf(this.fsm.interact);
         }
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         var _loc7_:IBattleEntity = this.fsm.order.activeEntity;
         var _loc8_:String = !!_loc7_ ? _loc7_.team : null;
         var _loc9_:int = 0;
         for(; _loc9_ < _loc4_.length; _loc9_++)
         {
            _loc6_ = (_loc6_ + param3 + (param3 > 0 ? 0 : _loc4_.length)) % _loc4_.length;
            _loc10_ = _loc4_[_loc6_];
            if(_loc5_.restrictInput)
            {
               if(_loc5_.allowEntities.indexOf(_loc10_) < 0)
               {
                  continue;
               }
            }
            if(!(!param1 && _loc8_ == _loc10_.team))
            {
               if(!(!param2 && _loc8_ != _loc10_.team))
               {
                  this._lastInteractIndex = _loc6_;
                  return _loc10_;
               }
            }
         }
         return null;
      }
      
      public function getInteractIndex_attack(param1:int) : IBattleEntity
      {
         var inRangeTarget:IBattleEntity;
         var iterationDirection:int = param1;
         var units:Vector.<IBattleEntity> = this._getIterableUnits();
         var turn:BattleTurn = this.fsm.turn as BattleTurn;
         if(!turn || !turn.attackMode || !units || units.length == 0)
         {
            return null;
         }
         inRangeTarget = this.GetTargetFromGrouping(iterationDirection,units,function(param1:Vector.<IBattleEntity>, param2:int, param3:Dictionary):Boolean
         {
            return !!param3[param1[param2]] ? true : false;
         },function(param1:BattleHudPageInput, param2:IBattleEntity):Boolean
         {
            return Boolean(param1.turn._inRange[param2]) && !param2.usable ? true : false;
         });
         return inRangeTarget != null ? inRangeTarget : this.fsm.interact;
      }
      
      private function getInteractIndex_ability(param1:int) : IBattleEntity
      {
         var iterationDirection:int = param1;
         var units:Vector.<IBattleEntity> = this._getIterableUnits();
         var turn:BattleTurn = this.fsm.turn as BattleTurn;
         if(!turn || !turn.ability || !units || units.length == 0)
         {
            return null;
         }
         return this.GetTargetFromGrouping(iterationDirection,units,function(param1:Vector.<IBattleEntity>, param2:int, param3:Dictionary):Boolean
         {
            return !!param3[param1[param2]] ? true : false;
         },function(param1:BattleHudPageInput, param2:IBattleEntity):Boolean
         {
            return Boolean(param1.turn._inRange[param2]) && !param2.usable ? true : false;
         });
      }
      
      private function GetTargetFromGrouping(param1:int, param2:Vector.<IBattleEntity>, param3:Function, param4:Function) : IBattleEntity
      {
         var _loc9_:IBattleEntity = null;
         var _loc5_:SceneControllerConfig = SceneControllerConfig.instance;
         var _loc6_:int = 0;
         _loc6_ = param2.indexOf(this.fsm.interact);
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         var _loc7_:Dictionary = new Dictionary();
         _loc7_[this.fsm.interact] = true;
         var _loc8_:int = 0;
         for(; _loc8_ < param2.length; _loc8_++)
         {
            _loc6_ = (_loc6_ + param1 + (param1 > 0 ? 0 : param2.length)) % param2.length;
            _loc9_ = param2[_loc6_];
            if(_loc5_.restrictInput)
            {
               if(_loc5_.allowEntities.indexOf(_loc9_) < 0)
               {
                  continue;
               }
            }
            if(!param3(param2,_loc6_,_loc7_))
            {
               _loc7_[_loc9_] = true;
               if(param4(this,_loc9_))
               {
                  return _loc9_;
               }
            }
         }
         return null;
      }
      
      private function cmdFuncInteractAlliesNext(param1:CmdExec) : void
      {
         this._findInteract(true,false,true);
      }
      
      private function cmdFuncInteractEnemiesNext(param1:CmdExec) : void
      {
         this._findInteract(false,true,true);
      }
      
      private function cmdFuncInteractNext(param1:CmdExec) : void
      {
         this._findInteract(true,true,true);
      }
      
      private function cmdFuncInteractAlliesPrev(param1:CmdExec) : void
      {
         this._findInteract(true,false,false);
      }
      
      private function cmdFuncInteractEnemiesPrev(param1:CmdExec) : void
      {
         this._findInteract(false,true,false);
      }
      
      private function cmdFuncInteractPrev(param1:CmdExec) : void
      {
         this._findInteract(true,true,false);
      }
      
      private function _findInteract(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:IBattleEntity = null;
         var _loc5_:IBattleTurn = null;
         if(!BattleFsmConfig.guiHudEnabled || this.config.sceneControllerConfig.redeployRosterInFocus || !this.bhc.initiative)
         {
            return;
         }
         if(this.fsm.current is IBattleStateUserDeploying)
         {
            _loc4_ = param3 ? this.getNextInteractIndex_deploy() : this.getPrevInteractIndex_deploy();
         }
         else
         {
            _loc5_ = this.fsm.turn;
            if(Boolean(_loc5_) && _loc5_.attackMode)
            {
               _loc4_ = this.getInteractIndex_attack(param3 ? 1 : -1);
            }
            else if(Boolean(_loc5_) && Boolean(_loc5_.ability))
            {
               _loc4_ = this.getInteractIndex_ability(param3 ? 1 : -1);
               if(!_loc4_)
               {
                  return;
               }
            }
            else
            {
               _loc4_ = this.getInteractIndex_initiative(param1,param2,param3 ? 1 : -1);
            }
         }
         this._processInteract(_loc4_);
      }
      
      private function _processInteract(param1:IBattleEntity) : void
      {
         var _loc2_:ScenePage = null;
         this.fsm.interact = param1;
         (this.fsm.board as BattleBoard).selectedTile = null;
         (this.fsm.board as BattleBoard).hoverTile = null;
         if(Boolean(param1) && Boolean(param1.visible))
         {
            this.bhp.view.centerOnEntity(param1);
         }
         this.bhp.config.gameGuiContext.playSound("ui_generic");
         if(Boolean(this.turn) && Boolean(this.turn.ability))
         {
            _loc2_ = this.bhp.battleHandler.page;
            if(_loc2_ && _loc2_.controller && Boolean(_loc2_.controller.boardController))
            {
               _loc2_.controller.boardController.handleAbilityClick();
            }
         }
      }
      
      private function cmdFuncInteractActive(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(!this.bhc.initiative)
         {
            return;
         }
         if(this.fsm.current is IBattleStateUserDeploying)
         {
            return;
         }
         var _loc2_:SceneControllerConfig = SceneControllerConfig.instance;
         if(_loc2_.restrictInput)
         {
            if(_loc2_.allowEntities.indexOf(this.fsm.turn.entity) < 0)
            {
               this.logger.info("SceneControllerConfig prevents selection of " + this.fsm.turn.entity);
               return;
            }
         }
         if(this.fsm.turn)
         {
            this.fsm.interact = this.fsm.turn.entity;
            (this.fsm.board as BattleBoard).selectedTile = null;
            (this.fsm.board as BattleBoard).hoverTile = null;
            this.bhp.view.centerOnEntity(this.fsm.interact);
            this.bhp.config.gameGuiContext.playSound("ui_generic");
         }
      }
      
      private function moveSelectedTile(param1:Number, param2:Number) : Boolean
      {
         if(this.fsm.current is IBattleStateUserDeploying)
         {
            return this.moveSelectedTile_deploy(param1,param2);
         }
         var _loc3_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         if(_loc3_)
         {
            return this.moveSelectedTile_local(_loc3_,param1,param2);
         }
         return true;
      }
      
      private function moveSelectedTile_local(param1:BattleStateTurnLocal, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:IBattleEntity = param1.entity;
         if(!_loc4_ || !_loc4_.tile)
         {
            return false;
         }
         if(Boolean(this.fsm.turn.ability) && this.fsm.turn.ability.def.targetRule.isTile)
         {
            return this.moveSelectedTile_local_ability(param1,param2,param3);
         }
         var _loc5_:IBattleMove = this.fsm.turn.move;
         if(Boolean(_loc5_) || !_loc5_.committed)
         {
            return this.moveSelectedTile_local_move(param1,param2,param3);
         }
         return false;
      }
      
      private function moveSelectedTile_local_move(param1:BattleStateTurnLocal, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:IBattleEntity = param1.entity;
         if(!_loc4_ || !_loc4_.tile)
         {
            return false;
         }
         var _loc5_:IBattleMove = this.fsm.turn.move;
         if(!_loc5_ || _loc5_.committed)
         {
            return true;
         }
         var _loc6_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc7_:Tile = _loc6_.selectedTile;
         if(_loc7_ != _loc5_.wayPointTile && !_loc5_.flood.hasResultKey(_loc7_))
         {
            _loc7_ = null;
         }
         var _loc8_:TileLocation = !!_loc7_ ? _loc7_.location : null;
         if(!_loc8_)
         {
            _loc8_ = _loc4_.tile.location;
         }
         var _loc9_:Point = new Point(param2,param3);
         var _loc10_:Tile = _loc6_.findNextMoveFloodTile(_loc4_,_loc5_,_loc8_,_loc9_);
         if(_loc10_)
         {
            _loc6_.selectedTile = _loc10_;
            _loc6_.hoverTile = _loc10_;
            BattleBoardController.handleMoveHover_static(this.fsm,this.fsm._turn,null,false);
            this.bhp.view.centerOnBoardPoint(_loc10_.x + Number(_loc4_.boardWidth) / 2,_loc10_.y + Number(_loc4_.boardLength) / 2);
            this.bhp.config.gameGuiContext.playSound("ui_tile_select");
            return true;
         }
         return false;
      }
      
      private function moveSelectedTile_local_ability(param1:BattleStateTurnLocal, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:BattleTurn = this.fsm._turn;
         var _loc5_:BattleAbility = _loc4_._ability;
         if(!_loc5_ || !_loc5_.def.targetRule.isTile)
         {
            return false;
         }
         var _loc6_:IBattleEntity = param1.entity;
         if(!_loc6_ || !_loc6_.tile)
         {
            return false;
         }
         var _loc7_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc8_:Tile = _loc7_.selectedTile;
         if(!_loc8_)
         {
            _loc8_ = !!_loc6_ ? _loc6_.tile : null;
         }
         var _loc9_:Tile = this.fsm.findNextRangeTile(_loc8_,param2,param3);
         if(_loc9_)
         {
            _loc7_.selectedTile = _loc9_;
            _loc7_.hoverTile = _loc9_;
            if(!_loc5_.targetSet.baseTile)
            {
            }
            this.bhp.view.centerOnBoardPoint(_loc9_.x + Number(_loc6_.boardWidth) / 2,_loc9_.y + Number(_loc6_.boardLength) / 2);
            this.bhp.config.gameGuiContext.playSound("ui_tile_select");
            return true;
         }
         return false;
      }
      
      private function moveSelectedTile_deploy(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:IBattleEntity = this.fsm.interact;
         if(!_loc3_ || !_loc3_.tile || _loc3_.party.deployed || _loc3_.deploymentFinalized)
         {
            return false;
         }
         var _loc4_:BattleBoard = this.fsm.board as BattleBoard;
         this.areas.clear();
         _loc4_.def.getDeploymentAreasById(_loc3_.party.deployment,this.areas);
         if(this.areas.numTiles == 0)
         {
            return false;
         }
         var _loc5_:Tile = _loc4_.selectedTile;
         var _loc6_:TileLocation = !!_loc5_ ? _loc5_.location : null;
         if(!_loc6_)
         {
            _loc6_ = _loc4_._deploy.findNearestDeploymentLocation(_loc3_,this.areas,_loc3_.tile.location);
            this.logger.i("RESPITE","BHPI TILE= " + _loc6_);
            if(!_loc6_.equals(_loc3_.tile.location))
            {
               param1 = param2 = 0;
            }
         }
         var _loc7_:Point = new Point(param1,param2);
         var _loc8_:Tile = _loc4_._deploy.findNextDeploymentTile(_loc3_,this.areas,_loc6_,_loc7_);
         if(_loc8_)
         {
            _loc4_.selectedTile = _loc8_;
            _loc4_.hoverTile = _loc8_;
            this.bhp.view.centerOnBoardPoint(_loc8_.x + Number(_loc3_.boardWidth) / 2,_loc8_.y + Number(_loc3_.boardLength) / 2);
            this.bhp.config.gameGuiContext.playSound("ui_tile_select");
            return true;
         }
         return false;
      }
      
      private function tickTileDir() : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         var _loc1_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         if(!(this.fsm.current is IBattleStateUserDeploying) && !_loc1_)
         {
            return;
         }
         if(!_loc1_)
         {
         }
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         if(this.tiledir_nw)
         {
            _loc2_--;
         }
         if(this.tiledir_se)
         {
            _loc2_ += 1;
         }
         if(this.tiledir_ne)
         {
            _loc3_--;
         }
         if(this.tiledir_sw)
         {
            _loc3_ += 1;
         }
         if(this.lastTileDir.x != _loc2_ || this.lastTileDir.y != _loc3_)
         {
            this.moveTileErrorSounded = false;
         }
         if(Boolean(_loc2_) || Boolean(_loc3_))
         {
            if(!this.moveSelectedTile(_loc2_,_loc3_))
            {
               _loc4_ = 0;
               _loc5_ = 0;
               if(this.alt_tiledir_nw)
               {
                  _loc4_--;
               }
               if(this.alt_tiledir_se)
               {
                  _loc4_ += 1;
               }
               if(this.alt_tiledir_ne)
               {
                  _loc5_--;
               }
               if(this.alt_tiledir_sw)
               {
                  _loc5_ += 1;
               }
               if(!this.moveSelectedTile(_loc4_,_loc5_))
               {
                  if(!this.moveTileErrorSounded)
                  {
                     this.moveTileErrorSounded = true;
                     this.bhp.config.gameGuiContext.playSound("ui_error");
                  }
               }
            }
            else
            {
               this.moveTileErrorSounded = false;
            }
         }
         this.lastTileDir.setTo(_loc2_,_loc3_);
      }
      
      private function cmdFuncTileAlt(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         var _loc2_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         if(_loc2_)
         {
            this.handleTileAlt_local(_loc2_);
            return;
         }
      }
      
      private function cmdFuncTileSelect(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(this.fsm.current is IBattleStateUserDeploying)
         {
            this.handleTileSelect_deploy();
            return;
         }
         var _loc2_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         if(_loc2_)
         {
            this.handleTileSelect_local(_loc2_);
            return;
         }
      }
      
      private function handleTileSelect_deploy() : void
      {
         var _loc1_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc2_:Tile = _loc1_.selectedTile;
         if(!_loc2_)
         {
            return;
         }
         this.areas.clear();
         var _loc3_:IBattleEntity = this.fsm.interact;
         if(!_loc3_)
         {
            return;
         }
         _loc1_.def.getDeploymentAreasById(_loc3_.party.deployment,this.areas);
         var _loc4_:BattleFacing = this.areas.getLocationFacing(_loc2_.location);
         if(_loc1_.attemptDeploy(_loc3_,_loc4_,this.areas.area,_loc2_.location))
         {
            _loc1_.scene.context.staticSoundController.playSound("ui_movement_button",null);
            return;
         }
      }
      
      private function handleTileSelect_local(param1:BattleStateTurnLocal) : void
      {
         var _loc7_:BattleBoardController = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc3_:Tile = _loc2_.selectedTile;
         var _loc4_:BattleTurn = this.turn;
         var _loc5_:IBattleMove = !!_loc4_ ? _loc4_.move : null;
         if(!_loc4_.entity.isDisabledMove && _loc5_.committed && !_loc5_.executed)
         {
            if(Boolean(_loc5_.entity) && Boolean(_loc5_.entity.mobility))
            {
               _loc5_.entity.mobility.fastForwardMove();
            }
            return;
         }
         var _loc6_:BattleAbility = this.fsm._ability;
         if(_loc6_)
         {
            if(_loc6_.def.targetRule == BattleAbilityTargetRule.FORWARD_ARC)
            {
               if(_loc6_._targetSet.targets.length)
               {
                  this.bhp.doConfirmClickGuiAbilityPopup();
                  return;
               }
            }
            if(_loc6_.def.targetRule.isTile)
            {
               if(_loc3_)
               {
                  if(_loc6_._targetSet.lastTile == _loc3_)
                  {
                     this.bhp.doConfirmClickGuiAbilityPopup();
                     return;
                  }
                  if(_loc4_.hasInRangeTile(_loc3_))
                  {
                     _loc7_ = BattleBoardController.instance;
                     if(_loc7_)
                     {
                        _loc7_.handleAbilityTileClick(_loc3_);
                        return;
                     }
                  }
               }
               return;
            }
         }
         if(Boolean(this.fsm.interact) || _loc5_.committed)
         {
            this.bhp.handleGpButton(GpControlButton.A);
            return;
         }
         if(!_loc3_ || !_loc4_ || !_loc5_ || _loc5_.committed)
         {
            return;
         }
         if(this.config.sceneControllerConfig.restrictInput)
         {
            if(this.config.sceneControllerConfig.allowMoveTile != _loc3_)
            {
               return;
            }
         }
         if(_loc5_.numSteps > 1)
         {
            if(_loc5_.pathEndBlocked)
            {
               this.logger.info("Cannot move to blocked tile [" + _loc5_.last + "] " + _loc5_.lastFacing);
               _loc2_.scene.context.staticSoundController.playSound("ui_error",null);
            }
            else
            {
               _loc5_.setCommitted("handleTileSelect_local");
            }
         }
         else
         {
            this.doCancelEscape(false);
         }
      }
      
      private function handleTileAlt_local(param1:BattleStateTurnLocal) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc3_:Tile = _loc2_.selectedTile;
         var _loc4_:BattleTurn = this.turn;
         var _loc5_:IBattleEntity = _loc4_.entity;
         var _loc6_:IBattleMove = !!_loc4_ ? _loc4_.move : null;
         if(!_loc3_ || !_loc4_ || !_loc6_ || _loc6_.committed || _loc3_ == _loc5_.tile)
         {
            return;
         }
         if(this.config.sceneControllerConfig.restrictInput)
         {
            if(this.config.sceneControllerConfig.allowWaypointTile != _loc3_)
            {
               return;
            }
         }
         if(_loc3_ == _loc6_.wayPointTile)
         {
            return;
         }
         if(!_loc6_.flood.hasResultKey(_loc3_))
         {
            return;
         }
         if(_loc6_.numSteps >= _loc6_.flood.costLimit + _loc6_.wayPointSteps)
         {
            return;
         }
         _loc6_.process(_loc3_,true);
         _loc6_.setWayPoint(_loc3_);
      }
      
      private function cmdFuncReady(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(!this.fsm || !this.bhp || !this.bhp.visible)
         {
            return;
         }
         if(!this.popupSelfHelper || !this.popupEnemyHelper || !this.battleHudPageLoadHelper || !this.bhpPopupLoadHelper.guiMovePopup)
         {
            return;
         }
         if(this.fsm.current is BattleStateDeploy || this.fsm.current is BattleStateWaveRedeploy_Assemble)
         {
            if(!this.bhp.guiBattleHudDeployReady())
            {
               this.bhp.config.gameGuiContext.playSound("ui_error");
            }
            return;
         }
         if(!this.turn || !this.turn.entity || !this.turn.entity.isPlayer)
         {
            return;
         }
         if(this.popupSelfHelper.handleConfirm())
         {
            return;
         }
         if(this.popupEnemyHelper.handleConfirm())
         {
            return;
         }
         if(Boolean(this.bhpPopupLoadHelper.guiMovePopup) && this.bhpPopupLoadHelper.guiMovePopup.handleConfirm())
         {
            return;
         }
         if(this.bhp.bhpAbilityPopup.handleConfirm())
         {
            return;
         }
      }
      
      private function endTurnHotKey(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(!this.turn || this.turn.committed || !this.turn.entity.playerControlled || this.config.accountInfo.tutorial)
         {
            return;
         }
         if(!this.turn.move.committed)
         {
            this.turn.move.reset(this.turn.entity.tile);
         }
         if(!this.bhc.keyboard || !this.bhc.selfPopup || !this.bhc.selfPopupEnd)
         {
            return;
         }
         this.turn.attackMode = false;
         this.bhp.selfPopupLastClicked = false;
         this.turn.ability = null;
         this.turn.attackMode = false;
         this.fsm.interact = this.turn._entity;
         this.popupSelfHelper.selectEndTurn(this.turn);
      }
      
      public function cmdFuncToggleHud(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         this.bhp.visible = !this.bhp.visible;
      }
      
      public function cmdFuncToggleVisible(param1:CmdExec) : void
      {
         BattleFsmConfig.guiVisible = !BattleFsmConfig.guiVisible;
      }
      
      private function cmdFuncSurrender(param1:CmdExec) : void
      {
         if(this.fsm)
         {
            this.fsm.surrender();
         }
      }
      
      private function cmdFuncKillall(param1:CmdExec) : void
      {
         if(this.fsm.current is BattleStateDeploy)
         {
            this.bhp.guiBattleHudDeployReady();
            return;
         }
         SagaCheat.devCheat("ff battlehud");
         var _loc2_:IBattleScenario = Boolean(this.fsm) && Boolean(this.fsm.board) ? this.fsm.board.scenario : null;
         if(Boolean(_loc2_) && !_loc2_.complete)
         {
            _loc2_.doCompleteAll();
         }
         if(this.landscapeController)
         {
            if(this.landscapeController.doFf(true))
            {
               return;
            }
         }
         if(this.fsm)
         {
            if(this.fsm.killall())
            {
               return;
            }
         }
         if(this.bhp.guiBattleHudWaveFlee())
         {
            return;
         }
      }
      
      private function cmdFuncPlinkArmor(param1:CmdExec) : void
      {
         var _loc2_:int = 0;
         if(Boolean(this.fsm) && Boolean(this.fsm.interact))
         {
            _loc2_ = int(this.fsm.interact.stats.getValue(StatType.ARMOR));
            _loc2_ = Math.max(0,_loc2_ / 2);
            this.fsm.interact.stats.setBase(StatType.ARMOR,_loc2_);
         }
      }
      
      private function cmdFuncKillTarget(param1:CmdExec) : void
      {
         if(this.fsm)
         {
            this.fsm.killTurnInteract();
         }
      }
      
      private function handleEscape_deploy(param1:Boolean) : Boolean
      {
         var _loc2_:BattleBoard = null;
         var _loc3_:IBattleParty = null;
         if(this.fsm.current is IBattleStateUserDeploying)
         {
            _loc2_ = this.fsm.board as BattleBoard;
            if(_loc2_.selectedTile)
            {
               _loc2_.selectedTile = null;
               _loc2_.hoverTile = null;
               return true;
            }
            if(!param1)
            {
               this.fsm.interact = null;
               _loc3_ = this.fsm.board.getPartyById(this.fsm.session.credentials.userId.toString());
               this.bhp.view.centerOnPartyById(_loc3_.id);
               return true;
            }
         }
         return false;
      }
      
      private function handleEscape_local(param1:Boolean) : Boolean
      {
         var _loc2_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         if(!_loc2_)
         {
            return false;
         }
         if(this.handleEscape_local_move(_loc2_))
         {
            return true;
         }
         if(this.bhp.handleGpButton(GpControlButton.B))
         {
            return true;
         }
         if(this.handleEscape_local_ability(_loc2_))
         {
            return true;
         }
         if(this.turn.attackMode)
         {
            this.fsm.interact = null;
            this.turn.attackMode = false;
         }
         if(!param1)
         {
            if(this.fsm.interact)
            {
               this.fsm.interact = _loc2_.entity;
               this.fsm.interact = null;
            }
            this.bhp.view.centerOnEntity(_loc2_.entity);
            return true;
         }
         return false;
      }
      
      private function handleEscape_local_move(param1:BattleStateTurnLocal) : Boolean
      {
         var _loc2_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc3_:Tile = !!_loc2_ ? _loc2_.selectedTile : null;
         var _loc4_:IBattleEntity = param1.entity;
         var _loc5_:IBattleTurn = this.fsm.turn;
         if(_loc5_.ability || _loc5_.attackMode || Boolean(this.fsm.interact))
         {
            return false;
         }
         var _loc6_:IBattleMove = !!_loc5_ ? _loc5_.move : null;
         if(!_loc6_ || _loc6_.committed)
         {
            return false;
         }
         if(_loc6_.wayPointSteps > 1)
         {
            _loc6_.reset(_loc6_.first);
            if(_loc3_)
            {
               _loc6_.process(_loc3_,true);
            }
         }
         else
         {
            _loc6_.reset(_loc6_.first);
            this.fsm.interact = null;
            this.fsm.interact = _loc4_;
            this.fsm.board.hoverTile = null;
            this.bhp.view.centerOnEntity(_loc4_);
         }
         return true;
      }
      
      private function handleEscape_local_ability(param1:BattleStateTurnLocal) : Boolean
      {
         var _loc7_:IBattleEntity = null;
         var _loc2_:BattleBoard = this.fsm.board as BattleBoard;
         var _loc3_:IBattleEntity = param1.entity;
         var _loc4_:IBattleTurn = this.fsm.turn;
         var _loc5_:BattleAbility = _loc4_.ability;
         if(!_loc5_ || _loc5_.executing || _loc5_.executed)
         {
            return false;
         }
         var _loc6_:BattleTargetSet = _loc5_.targetSet;
         if(_loc6_.targets.length)
         {
            _loc7_ = _loc6_.targets[_loc6_.targets.length - 1];
            _loc6_.removeTarget(_loc7_);
            _loc4_.notifyTargetsUpdated();
            if(_loc6_.targets.length == 0 && _loc7_ == _loc3_ || !PlatformInput.hasClicker)
            {
               _loc4_.ability = null;
               this.fsm.interact = null;
               if(PlatformInput.lastInputGp)
               {
                  _loc2_.selectedTile = _loc3_.tile;
                  this.bhp.view.centerOnEntity(_loc3_);
               }
            }
            return true;
         }
         if(_loc6_.tiles.length)
         {
            _loc6_.removeTile(_loc6_.tiles[_loc6_.tiles.length - 1]);
            _loc4_.notifyTargetsUpdated();
            return true;
         }
         _loc4_.ability = null;
         this.fsm.interact = _loc3_;
         if(PlatformInput.lastInputGp)
         {
            _loc2_.selectedTile = _loc3_.tile;
            _loc2_.hoverTile = _loc3_.tile;
            this.bhp.view.centerOnEntity(_loc3_);
         }
         return true;
      }
      
      private function cmdMenuFunc(param1:CmdExec) : void
      {
         this.config.pageManager.showOptions();
      }
      
      private function cmdCancelFunc(param1:CmdExec) : void
      {
         this.doCancelEscape(false);
      }
      
      private function cmdEscapeFunc(param1:CmdExec) : void
      {
         this.doCancelEscape(true);
      }
      
      private function doCancelEscape(param1:Boolean) : void
      {
         var _loc3_:BattleBoard = null;
         var _loc4_:Tile = null;
         if(!this.fsm)
         {
            return;
         }
         if(Boolean(this.bhp) && this.bhp.questionMarkHelpEnabled)
         {
            this.bhp.questionMarkHelpEnabled = false;
            return;
         }
         var _loc2_:SceneState = this.config.fsm.current as SceneState;
         if(!_loc2_)
         {
            return;
         }
         if(BattleFsmConfig.guiHudEnabled)
         {
            if(!this.bhc || this.bhc.escape)
            {
               _loc3_ = this.fsm.board as BattleBoard;
               _loc4_ = !!_loc3_ ? _loc3_.selectedTile : null;
               if(this.handleEscape_deploy(param1))
               {
                  return;
               }
               if(this.handleEscape_local(param1))
               {
                  return;
               }
               if(this.fsm.interact)
               {
                  if(!param1 || this.fsm.turn && this.fsm.interact != this.fsm.turn.entity)
                  {
                     this.fsm.interact = null;
                     return;
                  }
               }
            }
         }
         if(param1)
         {
            this.config.pageManager.showOptions();
         }
      }
      
      private function moveModeHotKey(param1:CmdExec) : void
      {
         if(!this.turn || this.turn.committed || !this.turn.entity.playerControlled || this.config.accountInfo.tutorial || !BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(!this.bhc.keyboard || !this.bhc.selfPopup || !this.bhc.selfPopupMove)
         {
            return;
         }
         this.popupEnemyHelper.setupPopup(null);
         this.popupSelfHelper.setupPopup(null);
         this.turn.attackMode = false;
         this.turn.ability = null;
         this.bhp.selfPopupLastClicked = false;
         this.bhp.selfMoveSelect();
      }
      
      private function cmdFuncStarsPlus(param1:CmdExec) : void
      {
         this.bhp.selfAbilityStarsMod(1);
      }
      
      private function cmdFuncStarsMinus(param1:CmdExec) : void
      {
         this.bhp.selfAbilityStarsMod(-1);
      }
      
      private function abilityModeHotKey(param1:CmdExec) : void
      {
         var _loc8_:IAbilityDefLevel = null;
         var _loc9_:BattleAbilityDef = null;
         var _loc10_:PopupAbilityValidity = null;
         var _loc11_:int = 0;
         if(!this.turn || this.turn.committed || !this.turn.entity.playerControlled || this.config.accountInfo.tutorial || !BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(!this.bhc.keyboard || !this.bhc.selfPopup || !this.bhc.selfPopupAttack)
         {
            return;
         }
         if(this.turn._numAbilities > 0)
         {
            this.doCancelEscape(false);
            return;
         }
         this.popupEnemyHelper.setupPopup(null);
         this.popupSelfHelper.setupPopup(null);
         this.turn.attackMode = false;
         this.bhp.selfPopupLastClicked = false;
         this.fsm.setInteractNoEvent(this.turn.entity);
         this.bhp.selfAbilitySelect(null);
         var _loc2_:BattleAbility = this.turn.ability;
         var _loc3_:IAbilityDef = !!_loc2_ ? _loc2_.def : null;
         _loc3_ = !!_loc3_ ? _loc3_.root : null;
         this.valids.splice(0,this.valids.length);
         var _loc4_:int = -1;
         var _loc5_:IAbilityDefLevels = this.turn.entity.def.actives;
         var _loc6_:int = _loc5_.numAbilities;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = _loc5_.getAbilityDefLevel(_loc7_);
            if(_loc8_.level > 0)
            {
               _loc9_ = _loc8_.def as BattleAbilityDef;
               if(_loc9_.tag == BattleAbilityTag.SPECIAL)
               {
                  _loc10_ = PopupAbilityValidity.isAbilityInvalid(_loc9_,this.turn.entity,this.logger,null);
                  if(!_loc10_ || !_loc10_.valid)
                  {
                     this.logger.info("Skipping hotkey for " + _loc9_ + " not valid: " + _loc10_);
                  }
                  else
                  {
                     if(_loc3_ == _loc9_)
                     {
                        _loc4_ = this.valids.length;
                     }
                     this.valids.push(_loc9_);
                  }
               }
            }
            _loc7_++;
         }
         if(this.valids.length)
         {
            _loc11_ = (_loc4_ + 1) % this.valids.length;
            _loc9_ = this.valids[_loc11_];
            this.bhp.selfAbilitySelect(_loc9_.id);
         }
         else
         {
            this.bhp.selfAbilitySelect(null);
         }
         if(!this.turn.move.committed)
         {
            this.turn.move.reset(this.turn.move.first);
         }
      }
      
      private function attackModeHotKey(param1:CmdExec) : void
      {
         if(!this.turn || this.turn.committed || !this.turn.entity.playerControlled || this.config.accountInfo.tutorial || !BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(!this.bhc.keyboard || !this.bhc.selfPopup || !this.bhc.selfPopupAttack)
         {
            return;
         }
         if(this.turn._numAbilities > 0)
         {
            this.doCancelEscape(false);
            return;
         }
         this.popupEnemyHelper.setupPopup(null);
         this.popupSelfHelper.setupPopup(null);
         if(!this.turn.move.committed)
         {
            this.turn.move.reset(this.turn.move.first);
         }
         this.turn.ability = null;
         this.fsm.setInteractNoEvent(this.turn.entity);
         this.bhp.selfAttackSelect();
         this.bhp.selfPopupLastClicked = false;
      }
      
      private function toggleInfoFunc(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled || this.config.sceneControllerConfig.redeployRosterInFocus)
         {
            return;
         }
         this.bhp.toggleInfo();
      }
      
      private function toggleHelpFunc(param1:CmdExec) : void
      {
         if(!BattleFsmConfig.guiHudEnabled || this.config.sceneControllerConfig.redeployRosterInFocus)
         {
            return;
         }
         this.bhp.toggleQuestionMarkHelp();
      }
      
      public function update(param1:int) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         if(this.flicker)
         {
            this.flicker.update(param1);
         }
      }
      
      private function flickHandler(param1:StickFlicker, param2:int) : void
      {
         if(!BattleFsmConfig.guiHudEnabled)
         {
            return;
         }
         this.tiledir_nw = this.tiledir_ne = this.tiledir_sw = this.tiledir_se = false;
         this.alt_tiledir_nw = this.alt_tiledir_ne = this.alt_tiledir_sw = this.alt_tiledir_se = false;
         if(param2 <= -this.partition_3 || param2 >= this.partition_3)
         {
            this.tiledir_sw = this.tiledir_nw = true;
            if(param2 < 0)
            {
               this.alt_tiledir_nw = true;
            }
            else
            {
               this.alt_tiledir_sw = true;
            }
         }
         else if(param2 < -this.partition_2)
         {
            this.tiledir_nw = true;
            if(param2 < (-this.partition_2 + -this.partition_3) / 2)
            {
               this.alt_tiledir_sw = this.alt_tiledir_nw = true;
            }
            else
            {
               this.alt_tiledir_nw = this.alt_tiledir_ne = true;
            }
         }
         else if(param2 <= -this.partition_1)
         {
            this.tiledir_nw = this.tiledir_ne = true;
            if(param2 < (-this.partition_1 + -this.partition_2) / 2)
            {
               this.alt_tiledir_nw = true;
            }
            else
            {
               this.alt_tiledir_ne = true;
            }
         }
         else if(param2 < -this.partition_0)
         {
            this.tiledir_ne = true;
            if(param2 < (-this.partition_0 + -this.partition_1) / 2)
            {
               this.alt_tiledir_nw = this.alt_tiledir_ne = true;
            }
            else
            {
               this.alt_tiledir_se = this.alt_tiledir_ne = true;
            }
         }
         else if(param2 <= this.partition_0)
         {
            this.tiledir_ne = this.tiledir_se = true;
            if(param2 < (this.partition_0 + -this.partition_0) / 2)
            {
               this.alt_tiledir_ne = true;
            }
            else
            {
               this.alt_tiledir_se = true;
            }
         }
         else if(param2 < this.partition_1)
         {
            this.tiledir_se = true;
            if(param2 < (this.partition_0 + this.partition_1) / 2)
            {
               this.alt_tiledir_ne = this.alt_tiledir_se = true;
            }
            else
            {
               this.alt_tiledir_sw = this.alt_tiledir_se = true;
            }
         }
         else if(param2 <= this.partition_2)
         {
            this.tiledir_se = this.tiledir_sw = true;
            if(param2 < (this.partition_1 + this.partition_2) / 2)
            {
               this.alt_tiledir_se = true;
            }
            else
            {
               this.alt_tiledir_sw = true;
            }
         }
         else
         {
            this.tiledir_sw = true;
            if(param2 < (this.partition_2 + this.partition_3) / 2)
            {
               this.alt_tiledir_sw = this.alt_tiledir_se = true;
            }
            else
            {
               this.alt_tiledir_sw = this.alt_tiledir_nw = true;
            }
         }
         if(this.tiledir_nw || this.tiledir_ne || this.tiledir_sw || this.tiledir_se)
         {
            this.tickTileDir();
         }
      }
      
      public function handleInteractChange() : void
      {
         this.checkStickFlickerEnabled();
      }
      
      public function handleAbilityChange() : void
      {
         this.checkStickFlickerEnabled();
      }
      
      public function func_cmd_y(param1:CmdExec) : void
      {
         if(this.fsm.current is IBattleStateUserDeploying || this.fsm.current is BattleStateWaveRedeploy_Assemble)
         {
            this.cmdFuncReady(param1);
            return;
         }
         this.bhp.artifactHelper.useArtifact();
      }
      
      public function cmdFuncFacing(param1:CmdExec) : void
      {
         var _loc2_:BattleEntity = null;
         var _loc4_:TileRect = null;
         var _loc3_:BattleFacing = param1.cmd.config as BattleFacing;
         if(this.fsm.current is IBattleStateUserDeploying)
         {
            _loc2_ = this.fsm.interact as BattleEntity;
         }
         else if(this.fsm._turn)
         {
            if(!this.fsm._turn.committed)
            {
               _loc2_ = this.fsm._turn.entity as BattleEntity;
            }
         }
         if(_loc2_)
         {
            if(!_loc2_.mobility || !_loc2_.mobility.moving)
            {
               if(_loc2_.localLength == _loc2_.localWidth)
               {
                  _loc2_.facing = _loc3_;
               }
               else if(_loc3_.flip == _loc2_.facing)
               {
                  _loc4_ = _loc2_.rect.flip(null);
                  _loc2_.setPosFromTileRect(_loc4_);
               }
            }
         }
      }
   }
}
