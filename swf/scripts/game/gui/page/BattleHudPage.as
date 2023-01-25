package game.gui.page
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.ability.IAbilityDef;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.op.model.Op_TargetAoe;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.controller.BattleBoardTargetHelper;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.BattleTurnEvent;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.BattleTurnOrderEvent;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.fsm.state.BattleStateFinished;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Assemble;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Prepare;
   import engine.battle.fsm.state.BattleStateWaveRespawn;
   import engine.battle.fsm.state.BattleStateWaveRespawn_Complete;
   import engine.battle.fsm.state.BattleStateWaveRespawn_ResetCamera;
   import engine.battle.fsm.state.IBattleStateWaveRedeploy_Prepare;
   import engine.battle.sim.BattleParty;
   import engine.battle.sim.BattlePartyEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.fsm.FsmEvent;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.Camera;
   import engine.core.util.ArrayUtil;
   import engine.gui.BattleHudConfig;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.action.Action;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.scene.SceneControllerConfig;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import engine.scene.view.SceneViewSprite;
   import engine.sound.view.ISound;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.HornHelper;
   import game.gui.IArtifactHelper;
   import game.gui.IGuiChat;
   import game.gui.InfoBarHelper;
   import game.gui.ValkaSpearHelper;
   import game.gui.WaveTurnCounterHelper;
   import game.gui.battle.IGuiAbilityPopupListener;
   import game.gui.battle.IGuiBattleHudListener;
   import game.gui.battle.IGuiInitiativeListener;
   import game.gui.battle.IGuiMovePopupListener;
   import game.gui.battle.IGuiOptionsListener;
   import game.gui.battle.IGuiPopupListener;
   import game.gui.battle.IGuiPropPopupListener;
   import game.session.states.SceneState;
   import game.view.TutorialTooltip;
   
   public class BattleHudPage extends GamePage implements IGuiPopupListener, IGuiInitiativeListener, IGuiOptionsListener, IGuiBattleHudListener, IGuiMovePopupListener, IGuiPropPopupListener, IGuiAbilityPopupListener
   {
      
      private static const PREF_NUM_MULTI_TARGET_ATTACK_TUTS_DISPLAYED:String = "PREF_NUM_MULTI_TARGET_ATTACK_TUTS_DISPLAYED";
      
      private static const PREF_NUM_MULTI_TARGET_ABILITY_TUTS_DISPLAYED:String = "PREF_NUM_MULTI_TARGET_ABILITY_TUTS_DISPLAYED";
      
      private static const NUM_TIMES_TO_DISPLAY_MULTI_TARGET_TUT:int = 3;
      
      public static var multiTargetTutorialBlocked:Boolean = true;
       
      
      internal var _board:BattleBoard;
      
      private var _view:BattleBoardView;
      
      private var _fsm:BattleFsm;
      
      private var _chat:IGuiChat;
      
      private var timerChecker:Timer;
      
      private var _tt:TutorialTooltip;
      
      private var _ttMultiTargetAttackNeedsDisplay:Boolean;
      
      private var camera:Camera;
      
      private var parties:Vector.<BattleParty>;
      
      private var partyMembers:Vector.<IBattleEntity>;
      
      private var infoBarHelper:InfoBarHelper;
      
      public var artifactHelper:IArtifactHelper;
      
      private var waveTurnCounterHelper:WaveTurnCounterHelper;
      
      public var popupEnemyHelper:PopupEnemyHelper;
      
      public var popupSelfHelper:PopupSelfHelper;
      
      public var popupPropHelper:PopupPropHelper;
      
      internal var _turn:BattleTurn;
      
      private var _abilityCommitted:Boolean;
      
      public var bhpLoadHelper:BattleHudPageLoadHelper;
      
      public var bhpPopupLoadHelper:BattleHudPagePopupLoadHelper;
      
      public var bhpAbilityPopup:BattleHudPageAbilityPopup;
      
      public var bhpRedeployHelper:BattleHudPageRedeployHelper;
      
      public var bhpLoadingOverlayHelper:BattleHudPageLoadingOverlayHelper;
      
      private var _sceneView:SceneViewSprite;
      
      public var selfPopupLastClicked:Boolean = false;
      
      private var interactFromInitiative:Boolean = false;
      
      private var input:BattleHudPageInput;
      
      public var scene:Scene;
      
      private var gpOverlay:BattleHudGpOverlay;
      
      public var battleHandler:ScenePageBattleHandler;
      
      private var saga:Saga;
      
      private var tooltips:BattleHudPage_Tooltips;
      
      private var _cleanedup:Boolean;
      
      private var deployTimeoutSoundPlayed:Boolean;
      
      private const END_TURN_SOUND_TIME_MS:int = 10500;
      
      private var turnPlayedTimeout:BattleTurn;
      
      private var end_turn_timer_sound:ISound;
      
      private var _lastCameraViewChangeCounter:int = -1;
      
      private var _turnMove:IBattleMove;
      
      private var _overrideTooltipStrs:Array;
      
      private var _overrideTooltipPoint_g:Point;
      
      private var _selectedTriggersChanged:Boolean;
      
      private var _hoverTileChanged:Boolean;
      
      public var _order:BattleTurnOrder;
      
      private var _questionMarkHelpEnabled:Boolean;
      
      public function BattleHudPage(param1:GameConfig, param2:ScenePageBattleHandler, param3:BattleBoard, param4:BattleBoardView, param5:SceneViewSprite, param6:ShellCmdManager)
      {
         this.timerChecker = new Timer(100,0);
         this.parties = new Vector.<BattleParty>();
         this.partyMembers = new Vector.<IBattleEntity>();
         super(param1);
         this.saga = param1.saga;
         this.visible = false;
         this.battleHandler = param2;
         this._board = param3;
         this.bhpLoadHelper = new BattleHudPageLoadHelper(this,param1);
         this.bhpPopupLoadHelper = new BattleHudPagePopupLoadHelper(this,param1);
         this.bhpAbilityPopup = new BattleHudPageAbilityPopup(this,param1);
         this.bhpRedeployHelper = new BattleHudPageRedeployHelper(this,param1);
         this.bhpLoadingOverlayHelper = new BattleHudPageLoadingOverlayHelper(this,param1);
         this.view = param4;
         this._sceneView = param5;
         this.infoBarHelper = new InfoBarHelper(this);
         this.scene = param5.scene;
         mouseEnabled = false;
         mouseChildren = true;
         this.input = new BattleHudPageInput(this);
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         var _loc7_:int = this.saga.getVarInt(SagaVar.VAR_TRAVEL_HUD_APPEARANCE);
         if(_loc7_ == 1 || _loc7_ == 3)
         {
            this.artifactHelper = new ValkaSpearHelper(this,this.input.hornGpBmp);
         }
         else
         {
            this.artifactHelper = new HornHelper(this,this.input.hornGpBmp);
         }
         this.tooltips = new BattleHudPage_Tooltips(this);
         this.initBoard(param3);
         if(param3)
         {
            param3.artifactMaxUseCount = this.artifactHelper.getMaxUse();
         }
         this.waveTurnCounterHelper = new WaveTurnCounterHelper(param3.waves,this);
         this.timerChecker.addEventListener(TimerEvent.TIMER,this.timerHandler);
         this.timerChecker.start();
         this.checkPopupHelper();
         this.resizeHandler();
         param6.add("hud",this.shellCmdFuncHud);
         this.updateInfoOnEvent(null);
         param1.keybinder.disableBindsFromGroup(KeyBindGroup.COMBAT);
         param1.battleHudConfig.addEventListener(BattleHudConfig.EVENT_CHANGED,this.battleHudConfigHandler);
         this.saga.addEventListener(SagaEvent.EVENT_PAUSE,this.sagaPauseHandler);
         this.scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.gpOverlay = new BattleHudGpOverlay(this);
         addChild(this.gpOverlay);
         this.sceneReadyHandler(null);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         this.battleGuiEnableHandler(null);
      }
      
      public static function calculateRemainingTurnMaxStars(param1:BattleTurn) : int
      {
         if(!param1 || !param1.entity || !param1.move)
         {
            return 0;
         }
         var _loc2_:int = int(param1.entity.stats.getValue(StatType.EXERTION));
         var _loc3_:int = int(param1.entity.stats.getValue(StatType.WILLPOWER));
         return int(Math.min(_loc2_,_loc3_));
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            if(this.tooltips)
            {
               this.tooltips.checkForTutorialTooltips();
            }
         }
      }
      
      private function battleGuiEnableHandler(param1:Event) : void
      {
         this.checkVisible();
      }
      
      public function checkVisible() : void
      {
         if(BattleFsmConfig.guiHudShouldRender)
         {
            if(Boolean(this.scene) && this.scene.ready)
            {
               if(this.board && this.board.sim && Boolean(this.board.sim.fsm))
               {
                  if(this.board.sim.fsm.currentClass != BattleStateFinished)
                  {
                     this.visible = true;
                     return;
                  }
               }
            }
         }
         this.visible = false;
      }
      
      private function sceneReadyHandler(param1:SceneEvent) : void
      {
         if(this.scene.ready)
         {
            this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
            this.checkVisible();
            config.keybinder.enableBindsFromGroup(KeyBindGroup.COMBAT);
         }
      }
      
      public function shellCmdFuncHud(param1:CmdExec) : void
      {
         this.input.cmdFuncToggleHud(null);
      }
      
      override public function cleanup() : void
      {
         if(this._cleanedup)
         {
            return;
         }
         this.saga.removeEventListener(SagaEvent.EVENT_PAUSE,this.sagaPauseHandler);
         this.tooltips.cleanup();
         this.tooltips = null;
         removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         config.battleHudConfig.removeEventListener(BattleHudConfig.EVENT_CHANGED,this.battleHudConfigHandler);
         removeChild(this.gpOverlay);
         this.gpOverlay.cleanup();
         this.gpOverlay = null;
         if(this.scene)
         {
            this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
            this.scene = null;
         }
         shell.removeShell("hud");
         this.input.cleanup();
         this.input = null;
         this._cleanedup = true;
         removeAllChildren();
         if(this.popupEnemyHelper)
         {
            this.popupEnemyHelper.cleanup();
            this.popupEnemyHelper = null;
         }
         if(this.popupSelfHelper)
         {
            this.popupSelfHelper.cleanup();
            this.popupSelfHelper = null;
         }
         if(this.popupPropHelper)
         {
            this.popupPropHelper.cleanup();
            this.popupPropHelper = null;
         }
         if(this.waveTurnCounterHelper)
         {
            this.waveTurnCounterHelper.cleanup();
            this.waveTurnCounterHelper = null;
         }
         this.board = null;
         this.timerChecker.removeEventListener(TimerEvent.TIMER,this.timerHandler);
         this.timerChecker.stop();
         this.timerChecker = null;
         this.battleHandler = null;
         this.bhpLoadHelper.cleanup();
         this.bhpLoadHelper = null;
         this.bhpPopupLoadHelper.cleanup();
         this.bhpPopupLoadHelper = null;
         this.bhpAbilityPopup.cleanup();
         this.bhpAbilityPopup = null;
         this.bhpRedeployHelper.cleanup();
         this.bhpRedeployHelper = null;
         this.bhpLoadingOverlayHelper.cleanup();
         this.bhpLoadingOverlayHelper = null;
         this.turn = null;
         this.view = null;
         this._sceneView = null;
         this.infoBarHelper.cleanup();
         this.infoBarHelper = null;
         this.artifactHelper.cleanup();
         this.artifactHelper = null;
         this.board = null;
         this.battleHandler = null;
         this.partyMembers = null;
         this.parties = null;
         this.fsm = null;
         super.cleanup();
      }
      
      public function set battleChat(param1:IGuiChat) : void
      {
         this._chat = param1;
         dispatchEvent(new BattleHudPageEvent(BattleHudPageEvent.CHAT_ENABLED));
      }
      
      public function guiHornUse() : void
      {
         this.artifactHelper.useArtifact();
      }
      
      public function get view() : BattleBoardView
      {
         return this._view;
      }
      
      public function set view(param1:BattleBoardView) : void
      {
         this._view = param1;
         if(!this._cleanedup)
         {
            this.checkPopupHelper();
         }
      }
      
      private function checkDeploymentInitiative() : void
      {
         var _loc1_:IBattleParty = null;
         var _loc2_:Vector.<IBattleEntity> = null;
         var _loc3_:int = 0;
         if(this.fsm && this.board && this.fsm.current is IBattleStateUserDeploying)
         {
            _loc1_ = this.board.getPartyById(this.fsm.session.credentials.userId.toString());
            _loc2_ = _loc1_.getAllMembers(null);
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].spawnedCaster != null)
               {
                  _loc2_.splice(_loc3_,1);
               }
               else
               {
                  _loc3_++;
               }
            }
            this.bhpLoadHelper.setInitiativeEntities(_loc2_,true,null);
         }
      }
      
      public function guiBattleHudDeployReady() : Boolean
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:int = 0;
         var _loc5_:BattleStateWaveRedeploy_Assemble = null;
         var _loc6_:ActionDef = null;
         var _loc7_:Action = null;
         var _loc1_:Boolean = false;
         var _loc2_:BattleStateDeploy = this._fsm.current as BattleStateDeploy;
         if(_loc2_)
         {
            _loc2_.autoDeployLocal();
            _loc1_ = true;
         }
         else if(this._fsm.current is BattleStateWaveRedeploy_Assemble)
         {
            _loc4_ = 0;
            while(_loc4_ < this.parties.length)
            {
               if(this.parties[_loc4_].isPlayer)
               {
                  _loc3_ = this.parties[_loc4_];
                  break;
               }
               _loc4_++;
            }
            if(Boolean(_loc3_) && _loc3_.numAlive > 0)
            {
               _loc5_ = this._fsm.current as BattleStateWaveRedeploy_Assemble;
               _loc5_.redeployComplete();
               _loc1_ = true;
            }
            else
            {
               _loc6_ = new ActionDef(null);
               _loc6_.type = ActionType.TUTORIAL_POPUP;
               _loc6_.msg = this.board.scene.context.locale.translateGui("tip_battle_wave_ready_empty_party");
               _loc6_.param = "button=true";
               _loc6_.location = "CENTER:CENTER";
               _loc6_.instant = true;
               _loc7_ = this.board.getSaga().executeActionDef(_loc6_,null,null);
            }
         }
         return _loc1_;
      }
      
      public function guiBattleHudWaveFlee() : Boolean
      {
         var _loc1_:IBattleStateWaveRedeploy_Prepare = this._fsm.current as IBattleStateWaveRedeploy_Prepare;
         if(_loc1_)
         {
            _loc1_.chooseToFlee();
            return true;
         }
         return false;
      }
      
      public function guiBattleHudWaveFight() : Boolean
      {
         var _loc1_:IBattleStateWaveRedeploy_Prepare = this._fsm.current as IBattleStateWaveRedeploy_Prepare;
         if(_loc1_)
         {
            _loc1_.chooseToFight();
            return true;
         }
         return false;
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         if(!this._fsm)
         {
            return;
         }
         if(Boolean(this.saga) && this.saga.paused)
         {
            return;
         }
         var _loc2_:BattleStateDeploy = this._fsm.current as BattleStateDeploy;
         if(_loc2_)
         {
            if(this.bhpLoadHelper.guihud)
            {
               if(!this.deployTimeoutSoundPlayed)
               {
                  if(!_loc2_.isLocalDeployed && _loc2_.timeoutMs > 0 && _loc2_.timeoutRemainingMs < this.END_TURN_SOUND_TIME_MS)
                  {
                     this.deployTimeoutSoundPlayed = true;
                     this.end_turn_timer_sound = config.soundSystem.controller.playSound("ui_end_turn_timer",null);
                  }
               }
               if(_loc2_.timeoutPercent)
               {
                  this.bhpLoadHelper.guihud.deployPercent = _loc2_.timeoutPercent;
               }
            }
            return;
         }
         var _loc3_:BattleStateTurnBase = this._fsm.current as BattleStateTurnBase;
         if(_loc3_)
         {
            if(this.bhpLoadHelper.initiative)
            {
               this.bhpLoadHelper.initiative.turnCommitted = !this.turn || this.turn.committed || this.turn.complete;
               if(Boolean(this.turn) && this.turnPlayedTimeout != this.turn)
               {
                  if(!this.turn.committed && _loc3_.timeoutMs > 0 && _loc3_.timeoutRemainingMs < this.END_TURN_SOUND_TIME_MS)
                  {
                     this.turnPlayedTimeout = this.turn;
                     this.end_turn_timer_sound = config.soundSystem.controller.playSound("ui_end_turn_timer",null);
                     if(this.turn.entity.isPlayer)
                     {
                        this.bhpLoadHelper.initiative.displayLowOnTime(width,height);
                     }
                  }
               }
               this.bhpLoadHelper.initiative.timerPercent = _loc3_.timeoutPercent;
               return;
            }
         }
      }
      
      private function sagaPauseHandler(param1:Event) : void
      {
         if(this.saga.paused)
         {
            this.deployTimeoutSoundPlayed = false;
            this.turnPlayedTimeout = null;
            if(this.end_turn_timer_sound)
            {
               this.end_turn_timer_sound.stop(true);
               this.end_turn_timer_sound = null;
            }
         }
      }
      
      private function currentHandler(param1:FsmEvent) : void
      {
         if(this.end_turn_timer_sound != null)
         {
            this.end_turn_timer_sound.stop(true);
            this.end_turn_timer_sound = null;
         }
         this.updateInfoOnEvent(null);
      }
      
      override protected function resizeHandler() : void
      {
         this._lastCameraViewChangeCounter = -1;
         if(this.popupSelfHelper != null)
         {
            this.popupSelfHelper.positionPopup();
         }
         if(this.popupEnemyHelper != null)
         {
            this.popupEnemyHelper.positionPopup();
         }
         if(this.popupPropHelper)
         {
            this.popupPropHelper.positionPopup();
         }
         this.bhpLoadHelper.resizeHandler(width,height);
         this.bhpPopupLoadHelper.resizeHandler(width,height);
         this.bhpAbilityPopup.resizeHandler(width,height);
         this.bhpRedeployHelper.resizeHandler(width,height);
         this.bhpLoadingOverlayHelper.resizeHandler(width,height);
         this.artifactHelper.resizeHandler();
         this.updateBattleHelp();
      }
      
      private function turnCommittedHandler(param1:BattleFsmEvent) : void
      {
         if(this.turn)
         {
            if(this.bhpLoadHelper.initiative)
            {
               this.bhpLoadHelper.initiative.turnCommitted = this.turn.committed;
            }
            this.popupEnemyHelper.setupPopup(null);
            this.popupPropHelper.setupPopup(null);
            this.selfPopupLastClicked = false;
            this.bhpAbilityPopup.handleTurnCommitted();
            if(!this.turn.committed)
            {
               this.abilityCommitted = false;
            }
         }
      }
      
      public function get turnMove() : IBattleMove
      {
         return this._turnMove;
      }
      
      public function set turnMove(param1:IBattleMove) : void
      {
         if(this._turnMove == param1)
         {
            return;
         }
         if(this._turnMove)
         {
            this._turnMove.removeEventListener(BattleMoveEvent.WAYPOINT,this.moveWayPointHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.SUPPRESS_COMMIT,this.moveWayPointHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.EXECUTING,this.updateInfoOnEvent);
            this._turnMove.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.MOVE_CHANGED,this.updateInfoOnEvent);
         }
         this._turnMove = param1;
         if(this._turnMove)
         {
            this._turnMove.addEventListener(BattleMoveEvent.WAYPOINT,this.moveWayPointHandler);
            this._turnMove.addEventListener(BattleMoveEvent.SUPPRESS_COMMIT,this.moveWayPointHandler);
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTING,this.updateInfoOnEvent);
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this._turnMove.addEventListener(BattleMoveEvent.MOVE_CHANGED,this.updateInfoOnEvent);
         }
      }
      
      public function get turn() : BattleTurn
      {
         return this._turn;
      }
      
      public function set turn(param1:BattleTurn) : void
      {
         if(this._turn == param1)
         {
            return;
         }
         if(this._turn)
         {
            this._turn.removeEventListener(BattleTurnEvent.ABILITY_TARGET,this.abilityTargetChanged);
         }
         this._turn = param1;
         this.turnMove = !!this._turn ? this._turn.move : null;
         if(this._turn)
         {
            this._turn.addEventListener(BattleTurnEvent.ABILITY_TARGET,this.abilityTargetChanged);
         }
         if(this._cleanedup)
         {
            return;
         }
         this.turnInteractHandler(null);
         this.moveWayPointHandler(null);
         this.abilityTargetChanged(null);
      }
      
      private function turnInteractHandler(param1:BattleFsmEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:IBattleMove = null;
         if(this._fsm)
         {
            this._board.showInfoBanner(this._fsm.interact);
            if(this._fsm.current is IBattleStateUserDeploying)
            {
               this.bhpRedeployHelper.interactHandler(param1);
            }
         }
         if(this._tt)
         {
            logger.info("Removing the multi target selection tooltip");
            this._tt.layer.removeTooltip(this._tt);
            this._tt = null;
         }
         if(this._ttMultiTargetAttackNeedsDisplay)
         {
            this._ttMultiTargetAttackNeedsDisplay = false;
            this.createMultiTargetTutorial("tut_battle_switch_target_gp","tut_battle_switch_target_gp");
         }
         if(Boolean(this._turn) && this._turn.committed)
         {
            logger.info("BattleHudPage.turnInteractHandler ignoring due to _turn.committed");
            return;
         }
         if(this.bhpLoadHelper && this.bhpLoadHelper.initiative && Boolean(this._fsm))
         {
            if(this._fsm.current is IBattleStateUserDeploying)
            {
               this.bhpLoadHelper.initiative.clearEndButton();
            }
            this.bhpLoadHelper.initiative.interact(this._fsm.interact,this.interactFromInitiative,this._turn != null && this._fsm.interact != this._turn.entity);
            this.interactFromInitiative = false;
            if(this._turn && this._turn.entity && Boolean(this._turn.entity.playerControlled))
            {
               if(this._turn.attackMode)
               {
                  if(!this._turn._inRange[this.turn.turnInteract])
                  {
                     this._turn.attackMode = false;
                  }
               }
               if(this.selfPopupLastClicked && this.turn.turnInteract == null)
               {
                  this.fsm.interact = this.turn.entity;
               }
               this.selfPopupLastClicked = false;
            }
            else
            {
               this.selfPopupLastClicked = false;
            }
            this.popupEnemyHelper.setupPopup(this._abilityCommitted ? null : this._turn);
            this.popupSelfHelper.setupPopup(this._abilityCommitted ? null : this._turn);
            this.popupPropHelper.setupPopup(this._abilityCommitted ? null : this._turn);
            if(!this._abilityCommitted && this._turn && this._turn.entity && Boolean(this._turn.entity.playerControlled))
            {
               _loc3_ = int(this.turn.entity.stats.getValue(StatType.WILLPOWER));
               this.popupSelfHelper.updateWillpower(_loc3_);
            }
            this.infoBarHelper.updateInfo();
            this.updateBattleHelp();
            if(this._fsm.interact == null)
            {
               _loc4_ = !!this._turn ? this._turn.move : null;
               if(Boolean(_loc4_) && !_loc4_.committed)
               {
                  if(PlatformInput.lastInputGp)
                  {
                     this.board.selectedTile = _loc4_.first;
                     this.view.centerOnEntity(this.turn.entity);
                  }
               }
            }
            this.input.handleInteractChange();
            return;
         }
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
         this.abilityCommitted = false;
         this.updateInfoOnEvent(null);
         this.bhpLoadHelper.initiative.turnCommitted = false;
         if(this._fsm)
         {
            this.bhpLoadHelper.setInitiativeEntities(this._fsm.order.aliveOrder,false,this._fsm.interact);
         }
         else
         {
            this.bhpLoadHelper.setInitiativeEntities(null,false,this._fsm.interact);
         }
         this.tooltips.onNextTurn();
      }
      
      public function guiInitiativeEndTurn() : void
      {
         var _loc1_:* = false;
         var _loc2_:IBattleAbilityDef = null;
         if(!this.board)
         {
            throw new IllegalOperationError("Should not get here");
         }
         if(this._turn.committed)
         {
            logger.info("BattleHudPage.guiInitiativeEndTurn ignoring due to _turn.committed");
            return;
         }
         if(Boolean(this._turn) && Boolean(this.turn.entity))
         {
            if(!this._turn.entity.playerControlled)
            {
               logger.info("BattleHudPage.guiInitiativeEndTurn ignoring due to NOT PLAYER CONTROLLED");
               return;
            }
            _loc1_ = this.turn.numAbilities == 0;
            if(!this._turn.move.committed && !this._turn.committed && _loc1_)
            {
               _loc2_ = this._turn.entity.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_rest");
               this._turn.ability = new BattleAbility(this._turn.entity,_loc2_,this._turn.entity.board.abilityManager);
            }
            else
            {
               this._turn.ability = null;
            }
            this._turn.committed = true;
         }
      }
      
      public function guiInitiativeInteract(param1:IBattleEntity) : Boolean
      {
         var _loc2_:SceneControllerConfig = SceneControllerConfig.instance;
         if(_loc2_)
         {
            if(_loc2_.restrictInput)
            {
               if(!_loc2_.allowEntities || _loc2_.allowEntities.indexOf(param1) < 0)
               {
                  return false;
               }
            }
         }
         this.interactFromInitiative = true;
         this.fsm.interact = null;
         this.interactFromInitiative = true;
         this.fsm.interact = param1;
         return true;
      }
      
      private function refreshInitiativeHandler(param1:BattleTurnOrderEvent) : void
      {
         this.bhpLoadHelper.setInitiativeEntities(this._fsm.order.aliveOrder,false,this._fsm.interact);
      }
      
      public function cancelOverrideTooltip(param1:Array) : void
      {
         if(param1 == this._overrideTooltipStrs || !param1)
         {
            this.overrideTooltip(null,null);
         }
      }
      
      public function overrideTooltip(param1:Array, param2:Point) : void
      {
         if(param2 == this._overrideTooltipPoint_g && ArrayUtil.isEqual(this._overrideTooltipStrs,param1))
         {
            return;
         }
         this._overrideTooltipPoint_g = param2;
         this._overrideTooltipStrs = param1;
         if(!this._overrideTooltipStrs || !this._overrideTooltipStrs.length)
         {
            this.bhpLoadHelper._guiBattleTooltip.setTooltipStrings(null);
            this.hoverTileHandler(null);
            return;
         }
         this.bhpLoadHelper._guiBattleTooltip.setTooltipStrings(param1);
         this._positionTooltip(param2);
      }
      
      private function selectedTriggersHandler(param1:BattleBoardEvent) : void
      {
         if(!this._board)
         {
            return;
         }
         this._selectedTriggersChanged = true;
      }
      
      private function hoverTileHandler(param1:BattleBoardEvent) : void
      {
         if(!this._board)
         {
            return;
         }
         this._hoverTileChanged = true;
      }
      
      private function _handleHoverTileChanged() : void
      {
         var _loc1_:Array = null;
         var _loc3_:Vector.<IBattleBoardTrigger> = null;
         var _loc4_:IBattleBoardTrigger = null;
         this._hoverTileChanged = false;
         this._selectedTriggersChanged = false;
         this.bhpAbilityPopup.handleHoverTile();
         if(Boolean(this._overrideTooltipStrs) && Boolean(this._overrideTooltipStrs.length))
         {
            return;
         }
         if(this._board._triggers)
         {
            _loc3_ = this._board._triggers._selectedTriggers;
            if(Boolean(_loc3_) && Boolean(_loc3_.length))
            {
               for each(_loc4_ in _loc3_)
               {
                  _loc1_ = this._renderTriggerTooltip(_loc4_,_loc1_);
               }
            }
         }
         var _loc2_:IBattleEntity = this._board.hoverEntity;
         if(_loc2_ && !_loc2_.mobile && Boolean(_loc2_.attackable))
         {
            _loc1_ = this._addStringToArray(_loc1_,_loc2_.name + ": " + _loc2_.def.description);
         }
         this.bhpLoadHelper._guiBattleTooltip.setTooltipStrings(_loc1_);
         this.positionTooltip();
      }
      
      private function _addStringToArray(param1:Array, param2:String) : Array
      {
         if(param2)
         {
            param1 = !!param1 ? param1 : [];
            param1.push(param2);
         }
         return param1;
      }
      
      private function _renderTriggerTooltip(param1:IBattleBoardTrigger, param2:Array) : Array
      {
         var _loc3_:String = null;
         var _loc4_:Vector.<IAbilityDef> = null;
         var _loc5_:IAbilityDef = null;
         if(!param1.def.visible || !param1.enabled || param1.def.incorporeal && !this._board.fsm.activeEntity.incorporeal)
         {
            return param2;
         }
         if(param1.def.stringId)
         {
            _loc3_ = config.context.locale.translateEncodedToken(param1.def.stringId,false);
            param2 = this._addStringToArray(param2,_loc3_);
         }
         else
         {
            _loc4_ = param1.getDisplayAbilities();
            for each(_loc5_ in _loc4_)
            {
               if(_loc5_.name)
               {
                  _loc3_ = _loc5_.name;
               }
               else
               {
                  _loc3_ = _loc5_.id;
               }
               _loc3_ += ": " + _loc5_.descriptionBrief;
               param2 = this._addStringToArray(param2,_loc3_);
            }
         }
         return param2;
      }
      
      private function positionTooltip() : void
      {
         var _loc2_:Tile = null;
         var _loc3_:BattleBoardView = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Point = null;
         var _loc1_:MovieClip = this.bhpLoadHelper._guiBattleTooltip.movieClip;
         if(_loc1_.visible)
         {
            _loc2_ = this._board.hoverTile;
            if(_loc2_)
            {
               _loc3_ = BattleBoardView.instance;
               _loc4_ = _loc3_.units;
               _loc5_ = _loc2_.x + 1;
               _loc6_ = _loc2_.y + 1;
               _loc7_ = _loc3_.getScreenPointGlobal(_loc5_ * _loc4_,_loc6_ * _loc4_);
               this._positionTooltip(_loc7_);
            }
         }
      }
      
      private function _positionTooltip(param1:Point) : void
      {
         var _loc3_:Point = null;
         var _loc2_:MovieClip = this.bhpLoadHelper._guiBattleTooltip.movieClip;
         if(_loc2_.visible)
         {
            _loc3_ = globalToLocal(param1);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
         }
      }
      
      private function cameraViewChangedHandler(param1:Event) : void
      {
      }
      
      private function boardEntitHudIndicatorVisibleHandler(param1:BattleEntityEvent) : void
      {
         if(Boolean(this._turn) && this._turn.entity == param1.entity)
         {
            this.popupSelfHelper.setupPopup(this._turn);
         }
      }
      
      private function boardEntityUsingHandler(param1:BattleBoardEvent) : void
      {
         this.popupPropHelper.setupPopup(null);
      }
      
      private function boardSetupHandler(param1:BattleBoardEvent) : void
      {
         if(this.bhpLoadHelper.guihud)
         {
            this.bhpLoadHelper.guihud.showDeploy(false,true);
            if(Boolean(this._board) && Boolean(this._board.waves))
            {
               this.bhpLoadHelper.guihud.showWaveRedeploy(false);
            }
         }
         if(this.bhpLoadHelper.battleGo)
         {
            addChild(this.bhpLoadHelper.battleGo.mc);
            this.bhpLoadHelper.battleGo.mc.x = width / 2;
            this.bhpLoadHelper.battleGo.mc.y = height / 2;
            this.bhpLoadHelper.battleGo.playOnce();
         }
      }
      
      public function get board() : BattleBoard
      {
         return this._board;
      }
      
      public function set board(param1:BattleBoard) : void
      {
         if(this._board == param1)
         {
            return;
         }
         this.initBoard(param1);
      }
      
      private function initBoard(param1:BattleBoard) : void
      {
         var _loc2_:IBattleParty = null;
         var _loc3_:int = 0;
         var _loc4_:IBattleEntity = null;
         if(this._board)
         {
            this._board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            this._board.removeEventListener(BattleBoardEvent.HOVER_TILE,this.hoverTileHandler);
            this._board.removeEventListener(BattleBoardEvent.SELECTED_TRIGGERS,this.selectedTriggersHandler);
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_USING_START,this.boardEntityUsingHandler);
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_USING_END,this.boardEntityUsingHandler);
            this._board.removeEventListener(BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE,this.boardEntitHudIndicatorVisibleHandler);
            for each(_loc2_ in this.parties)
            {
               _loc2_.removeEventListener(BattlePartyEvent.DEPLOYED,this.updateInfoOnEvent);
            }
            for each(_loc4_ in this.partyMembers)
            {
               _loc4_.removeEventListener(BattleEntityEvent.DEPLOYMENT_READY,this.updateInfoOnEvent);
            }
         }
         this._board = param1;
         this.fsm = !!this._board ? this._board.sim.fsm : null;
         this.camera = !!this.board ? this.board._scene._camera : null;
         this.parties.splice(0,this.parties.length);
         this.partyMembers.splice(0,this.parties.length);
         this.artifactHelper.board = param1;
         if(this._board)
         {
            this._board.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            this._board.addEventListener(BattleBoardEvent.HOVER_TILE,this.hoverTileHandler);
            this._board.addEventListener(BattleBoardEvent.SELECTED_TRIGGERS,this.selectedTriggersHandler);
            this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_USING_START,this.boardEntityUsingHandler);
            this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_USING_END,this.boardEntityUsingHandler);
            this._board.addEventListener(BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE,this.boardEntitHudIndicatorVisibleHandler);
            for each(_loc2_ in this.board.parties)
            {
               if(_loc2_.type == BattlePartyType.LOCAL)
               {
                  this.parties.push(_loc2_);
                  _loc2_.addEventListener(BattlePartyEvent.DEPLOYED,this.updateInfoOnEvent);
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.numMembers)
                  {
                     _loc4_ = _loc2_.getMember(_loc3_);
                     this.partyMembers.push(_loc4_);
                     _loc4_.addEventListener(BattleEntityEvent.DEPLOYMENT_READY,this.updateInfoOnEvent);
                     _loc3_++;
                  }
               }
            }
            this.tooltips.startTooltips();
         }
         this.bhpLoadHelper.handleBoardChange();
         this.updateInfoOnEvent(null);
         dispatchEvent(new BattleHudPageEvent(BattleHudPageEvent.BOARDCHANGE));
      }
      
      public function get order() : BattleTurnOrder
      {
         return this._order;
      }
      
      public function set order(param1:BattleTurnOrder) : void
      {
         if(this._order == param1)
         {
            return;
         }
         if(this._order)
         {
            this._order.removeEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
            this._order.removeEventListener(BattleTurnOrderEvent.REFRESH_INITIATIVE,this.refreshInitiativeHandler);
            this._order.removeEventListener(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_VFX,this.playForgeAheadVfx);
            this._order.removeEventListener(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_PILLAGE_VFX,this.playForgeAheadPillageVfx);
            this._order.removeEventListener(BattleTurnOrderEvent.PLAY_INSULT_VFX,this.playInsultVfx);
         }
         this._order = param1;
         if(this._order)
         {
            this._order.addEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
            this._order.addEventListener(BattleTurnOrderEvent.REFRESH_INITIATIVE,this.refreshInitiativeHandler);
            this._order.addEventListener(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_VFX,this.playForgeAheadVfx);
            this._order.addEventListener(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_PILLAGE_VFX,this.playForgeAheadPillageVfx);
            this._order.addEventListener(BattleTurnOrderEvent.PLAY_INSULT_VFX,this.playInsultVfx);
         }
      }
      
      public function get fsm() : BattleFsm
      {
         return this._fsm;
      }
      
      public function set fsm(param1:BattleFsm) : void
      {
         if(this._fsm == param1)
         {
            return;
         }
         if(this._fsm)
         {
            this._fsm.removeEventListener(BattleFsmEvent.INTERACT,this.turnInteractHandler);
            this._fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
            this._fsm.removeEventListener(FsmEvent.CURRENT,this.currentHandler);
            this._fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.turnCommittedHandler);
            this._fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
            this._fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.turnAbilityTargetHandler);
            this._fsm.removeEventListener(BattleFsmEvent.WAVE_RESPITE,this.playRespite);
            this._fsm.removeEventListener(BattleFsmEvent.WAVE_ENEMY_REINFORCEMENTS,this.playEnemyReinforcements);
         }
         this._fsm = param1;
         this.order = !!this._fsm ? this.fsm.order as BattleTurnOrder : null;
         if(this._fsm)
         {
            this._fsm.addEventListener(BattleFsmEvent.INTERACT,this.turnInteractHandler);
            this._fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
            this._fsm.addEventListener(FsmEvent.CURRENT,this.currentHandler);
            this._fsm.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.turnCommittedHandler);
            this._fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
            this._fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.turnAbilityTargetHandler);
            this._fsm.addEventListener(BattleFsmEvent.WAVE_RESPITE,this.playRespite);
            this._fsm.addEventListener(BattleFsmEvent.WAVE_ENEMY_REINFORCEMENTS,this.playEnemyReinforcements);
            if(this._fsm.turn)
            {
               this.turnHandler(null);
            }
         }
         if(this.popupPropHelper)
         {
            this.popupPropHelper.fsm = this._fsm;
         }
      }
      
      private function pillageHandler(param1:BattleTurnOrderEvent) : void
      {
         this.bhpLoadHelper.playPillageOnce(this);
         this.bhpLoadHelper.playPillage2Once(this);
         config.gameGuiContext.playSound("ui_pillage");
      }
      
      private function forgeAheadVfxOk(param1:IBattleEntity) : Boolean
      {
         if(Boolean(param1) && Boolean(param1.def))
         {
            if(param1.def.entityClass)
            {
               if(param1.def.entityClass.race == "dredge")
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      private function playForgeAheadVfx(param1:BattleTurnOrderEvent) : void
      {
         if(this.forgeAheadVfxOk(param1.ent))
         {
            this.bhpLoadHelper.playForgeAheadOnce(this);
         }
      }
      
      private function playInsultVfx(param1:BattleTurnOrderEvent) : void
      {
         this.bhpLoadHelper.playInsultOnce(this,param1.ent);
      }
      
      private function playForgeAheadPillageVfx(param1:BattleTurnOrderEvent) : void
      {
         this.bhpLoadHelper.playForgeAheadPillageOnce(this);
      }
      
      private function playRespite(param1:Event) : void
      {
         this.bhpLoadHelper.playRespiteOnce(this);
      }
      
      private function playReinforcements() : void
      {
         this.bhpLoadHelper.playReinforcementsOnce(this);
      }
      
      private function playEnemyReinforcements(param1:Event) : void
      {
         this.bhpLoadHelper.playEnemyReinforcementsOnce(this);
      }
      
      public function selfAttackSelect() : void
      {
         var _loc1_:IBattleEntity = null;
         config.gameGuiContext.playSound("ui_attack_button");
         this.turn.attackMode = true;
         this._fsm.dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ATTACK));
         this.selfPopupLastClicked = true;
         if(PlatformInput.lastInputGp)
         {
            _loc1_ = this.input.getInteractIndex_attack(1);
            if(_loc1_)
            {
               this.fsm.interact = _loc1_;
            }
         }
      }
      
      public function selfEndTurnSelect() : void
      {
         this.guiInitiativeEndTurn();
      }
      
      public function checkPopupHelper() : void
      {
         if(!this._view)
         {
            return;
         }
         if(!this._view || !this._view.board || !this._view.board.sim)
         {
            return;
         }
         var _loc1_:BattleHudConfig = config.battleHudConfig;
         if(!this.popupEnemyHelper && Boolean(this.bhpPopupLoadHelper.guiEnemyPopup))
         {
            this.popupEnemyHelper = new PopupEnemyHelper(this.bhpPopupLoadHelper.guiEnemyPopup,this._view,_loc1_);
         }
         if(!this.popupSelfHelper && Boolean(this.bhpPopupLoadHelper.guiSelfPopup))
         {
            this.popupSelfHelper = new PopupSelfHelper(this.bhpPopupLoadHelper.guiSelfPopup,this._view,_loc1_);
         }
         if(!this.popupPropHelper && Boolean(this.bhpPopupLoadHelper.guiPropPopup))
         {
            this.popupPropHelper = new PopupPropHelper(this.bhpPopupLoadHelper.guiPropPopup,this._view,_loc1_);
            this.popupPropHelper.fsm = this._fsm;
         }
      }
      
      public function guiEnemyPopupExecute(param1:String, param2:int) : void
      {
         if(this._turn.committed)
         {
            logger.info("BattleHudPage.enemyPopupExeute ignoring due to _turn.committed");
            return;
         }
         var _loc3_:IAbilityDef = this._turn.entity.def.attacks.getAbilityDefById(param1);
         var _loc4_:BattleAbilityDef = _loc3_.getAbilityDefForLevel(param2 + 1) as BattleAbilityDef;
         this._turn.ability = new BattleAbility(this._turn.entity,_loc4_,this.board.abilityManager);
         this._turn.ability.targetSet.setTarget(this._turn.turnInteract);
         this.executeTurnAbility(0);
      }
      
      public function guiEnemyPopupSelect(param1:String, param2:int) : void
      {
         if(!this.board)
         {
            throw new IllegalOperationError("Should not get here");
         }
         if(Boolean(this._turn.ability) && (this._turn.ability.executed || this._turn.ability.executing))
         {
            return;
         }
         if(this.abilityCommitted)
         {
            return;
         }
         this.popupEnemyHelper.selectAbility(this._turn,param1,param2);
      }
      
      private function turnAbilityTargetHandler(param1:BattleFsmEvent) : void
      {
         if(!this._turn || this._turn.committed)
         {
            return;
         }
         var _loc2_:IBattleAbility = this._turn._ability;
         if(!_loc2_ || _loc2_.executing)
         {
            return;
         }
         if(this.turn.entity.playerControlled)
         {
            if(_loc2_.targetSet.tiles.length > 0)
            {
               config.gameGuiContext.playSound("ui_skystriker_mark");
            }
         }
         this.positionAbilityPopup();
      }
      
      public function doConfirmClickGuiAbilityPopup() : void
      {
         this.bhpAbilityPopup.doConfirmClick();
      }
      
      public function guiAbilityPopupExecute(param1:int) : void
      {
         config.gameGuiContext.playSound("ui_ability_button");
         this.executeTurnAbility(param1);
         this.bhpAbilityPopup.hide();
         this.infoBarHelper.hideAbilityInfo();
      }
      
      public function guiAbilityPopupChanged(param1:int) : void
      {
         var _loc4_:BattleEntity = null;
         var _loc5_:IBattleEntity = null;
         var _loc6_:Tile = null;
         var _loc7_:int = 0;
         var _loc2_:BattleAbilityDef = this._turn.ability.def.getAbilityDefForLevel(Math.max(param1,1)) as BattleAbilityDef;
         var _loc3_:BattleAbility = new BattleAbility(this._turn.entity,_loc2_,this.board.abilityManager);
         _loc3_.targetSet.supressEvents = true;
         if(_loc3_.def.targetRule == BattleAbilityTargetRule.ADJACENT_BATTLEENTITY)
         {
            _loc4_ = this._turn.ability.targetSet.targets[0] as BattleEntity;
            this.updateTargets(_loc3_,_loc4_);
         }
         else
         {
            if(_loc3_.def.targetRule == BattleAbilityTargetRule.FORWARD_ARC)
            {
               BattleBoardTargetHelper.forwardArc_setupAbility(_loc3_,this._turn._ability.targetSet.baseTile);
               return;
            }
            for each(_loc5_ in this._turn.ability.targetSet.targets)
            {
               _loc3_.targetSet.addTarget(_loc5_);
            }
            if(this._turn.ability.targetSet.tiles.length <= _loc3_.def.targetCount)
            {
               for each(_loc6_ in this._turn.ability.targetSet.tiles)
               {
                  _loc3_.targetSet.addTile(_loc6_);
               }
            }
            else
            {
               _loc7_ = 0;
               while(_loc7_ < this._turn.ability.targetSet.tiles.length && _loc7_ < _loc3_.def.targetCount)
               {
                  _loc3_.targetSet.addTile(this._turn.ability.targetSet.tiles[_loc7_]);
                  _loc7_++;
               }
            }
         }
         _loc3_.setAssociatedTargets(this._turn.ability.getAssociatedTargets());
         _loc3_.targetSet.supressEvents = false;
         this._fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         this._turn.ability = _loc3_;
         this._fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         if(this.infoBarHelper)
         {
            this.infoBarHelper.showAbilityInfo();
         }
      }
      
      public function positionAbilityPopup() : void
      {
         if(this.bhpAbilityPopup)
         {
            this.bhpAbilityPopup.positionAbilityPopup();
         }
      }
      
      private function abilityTargetChanged(param1:BattleTurnEvent) : void
      {
         if(this._cleanedup)
         {
            return;
         }
         this.positionAbilityPopup();
      }
      
      private function turnAbilityHandler(param1:BattleFsmEvent) : void
      {
         if(Boolean(this.turn) && !this.turn.ability)
         {
            if(this.turn.entity.playerControlled)
            {
               config.gameGuiContext.playSound("ui_ability_cancel");
            }
         }
         this.positionAbilityPopup();
         this.updateInfoOnEvent(param1);
         if(this.input)
         {
            this.input.handleAbilityChange();
         }
         if(this.infoBarHelper)
         {
            if(this.turn.ability && this.turn.ability && this.turn.ability.def.tag == BattleAbilityTag.SPECIAL && this.turn.entity && Boolean(this.turn.entity.playerControlled))
            {
               this.infoBarHelper.showAbilityInfo();
            }
            else
            {
               this.infoBarHelper.updateInfo();
            }
         }
      }
      
      private function executeTurnAbility(param1:int) : void
      {
         var _loc2_:BattleAbilityDef = null;
         var _loc3_:BattleAbility = null;
         var _loc4_:BattleEntity = null;
         var _loc5_:BattleStateTurnBase = null;
         var _loc6_:BattleAbility = null;
         if(!this._turn.ability)
         {
            return;
         }
         if(!this._turn.ability.checkCosts(true))
         {
            logger.info("Ability costs cannot be paid, aborting exec");
            this._turn.ability = null;
            return;
         }
         if(!this._turn.move.committed)
         {
            if(this._turn.move.numSteps > 1)
            {
               this._turn.move.reset(null);
            }
         }
         if(param1 > 0)
         {
            _loc2_ = this._turn.ability.def.getAbilityDefForLevel(param1) as BattleAbilityDef;
            _loc3_ = new BattleAbility(this._turn.entity,_loc2_,this.board.abilityManager);
            _loc3_.targetSet.supressEvents = true;
            if(_loc3_.def.targetRule == BattleAbilityTargetRule.ADJACENT_BATTLEENTITY)
            {
               _loc4_ = this._turn.ability.targetSet.targets[0] as BattleEntity;
               this.updateTargets(_loc3_,_loc4_);
            }
            else
            {
               _loc3_.targetSet = this._turn.ability.targetSet.clone(_loc3_);
            }
            _loc3_.targetSet.supressEvents = false;
            this._turn.ability = _loc3_;
         }
         if(_loc2_ && _loc2_.artifactChargeCost > 0 && this.fsm.current is BattleStateTurnBase)
         {
            _loc5_ = this.fsm.current as BattleStateTurnBase;
            _loc6_ = this._turn.ability;
            this._turn.ability = null;
            _loc5_.performAction(_loc6_);
            return;
         }
         this.abilityCommitted = true;
         if(!this._turn.move.committed)
         {
            this._turn.move.setCommitted("BattleHudPage.executeTurnAbility " + this._turn.ability);
         }
         this._turn.committed = true;
      }
      
      public function selfAbilityStarsMod(param1:int) : void
      {
         this.bhpAbilityPopup.starsMod(param1);
      }
      
      public function selfAbilitySelect(param1:String) : void
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:IBattleMove = null;
         var _loc5_:BattleAbilityDef = null;
         var _loc6_:BattleAbilityDef = null;
         var _loc7_:BattleAbilityDef = null;
         if(this._turn.ability)
         {
            if(this._turn.ability.executed || this._turn.ability.executing)
            {
               return;
            }
         }
         config.gameGuiContext.playSound("ui_ability_button");
         var _loc2_:IBattleEntity = this._turn.entity;
         if(param1)
         {
            _loc3_ = this._fsm.interact;
            _loc4_ = this._turn.move;
            _loc5_ = _loc2_.lowestValidAbilityDef(param1,_loc3_,null,_loc4_) as BattleAbilityDef;
            _loc6_ = _loc2_.highestAvailableAbilityDef(param1) as BattleAbilityDef;
            _loc7_ = _loc6_;
            if(_loc5_)
            {
               _loc7_ = _loc5_;
            }
            if(Boolean(_loc7_) && _loc7_.level > 0)
            {
               if(PlatformInput.lastInputGp)
               {
                  this.board.selectedTile = _loc2_.tile;
               }
               else
               {
                  this._board.selectedTile = null;
               }
               this._turn.ability = new BattleAbility(_loc2_,_loc7_,this.board.abilityManager);
               if(_loc5_)
               {
                  this._turn.ability.lowestLevelAllowed = _loc5_.level;
               }
               if(_loc7_.targetRule == BattleAbilityTargetRule.SELF)
               {
                  this._turn._ability.targetSet.setTarget(_loc2_);
               }
               else if(_loc7_.targetRule == BattleAbilityTargetRule.SELF_AOE_1)
               {
                  this.handleTargets_SelfAoe1(true,true,true);
               }
               else if(_loc7_.targetRule == BattleAbilityTargetRule.SELF_AOE_ENEMY_1)
               {
                  this.handleTargets_SelfAoe1(false,true,false);
               }
               this._turn.notifyTargetsUpdated();
            }
         }
         this.selfPopupLastClicked = true;
         this.bhpLoadHelper.initiative.interact(this._fsm.interact,false,false);
         this.infoBarHelper.showAbilityInfo();
         if(Boolean(_loc7_) && _loc7_.targetRule != BattleAbilityTargetRule.SELF)
         {
            if(this.turn.numInRange > 1)
            {
               this.createMultiTargetTutorial("tut_battle_switch_target_gp",PREF_NUM_MULTI_TARGET_ABILITY_TUTS_DISPLAYED);
            }
         }
      }
      
      private function handleTargets_SelfAoe1(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:BattleAbility = this._turn._ability;
         var _loc5_:Dictionary = new Dictionary();
         var _loc6_:IBattleEntity = this._turn.entity;
         _loc5_ = Op_TargetAoe.computeAoeTargets(_loc6_,_loc5_,1,1,param1,param2,param3);
         _loc4_.setAssociatedTargets(_loc5_);
         _loc4_.targetSet.setTarget(_loc6_);
      }
      
      private function createMultiTargetTutorial(param1:String, param2:String) : void
      {
         var _loc3_:int = 0;
         if(!multiTargetTutorialBlocked)
         {
            _loc3_ = config.globalPrefs.getPref(param2);
            if(_loc3_ < NUM_TIMES_TO_DISPLAY_MULTI_TARGET_TUT)
            {
               logger.info("Displaying multitarget tut with key: " + param2 + " numTimesDisplayed: " + _loc3_ + " limit: " + NUM_TIMES_TO_DISPLAY_MULTI_TARGET_TUT);
               this._tt = config.tutorialLayer.createTooltip(null,TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,param1),false,false,0,null);
               _loc3_++;
               config.globalPrefs.setPref(param2,_loc3_);
            }
            else
            {
               logger.info("Exceeded display limit for multitarget tut with key: " + param2 + " numTimesDisplayed: " + _loc3_ + " limit: " + NUM_TIMES_TO_DISPLAY_MULTI_TARGET_TUT);
            }
         }
      }
      
      public function get abilityCommitted() : Boolean
      {
         return this._abilityCommitted;
      }
      
      public function set abilityCommitted(param1:Boolean) : void
      {
         this._abilityCommitted = param1;
         this.popupEnemyHelper.enabled = !this._abilityCommitted;
         this.popupSelfHelper.enabled = !this._abilityCommitted;
         this.popupPropHelper.enabled = !this._abilityCommitted;
         this.bhpAbilityPopup.hide();
      }
      
      private function positionWayPointHandler() : void
      {
         if(!this.turn || !this.turn.move || !this.turn.move.wayPointTile)
         {
            return;
         }
         if(!this.bhpLoadHelper || !this.bhpPopupLoadHelper.guiMovePopup || !this.bhpPopupLoadHelper.guiMovePopup.movieClip.visible)
         {
            return;
         }
         var _loc1_:Number = this.turn.entity.diameter / 2;
         var _loc2_:Number = this.turn.move.wayPointTile.x + _loc1_;
         var _loc3_:Number = this.turn.move.wayPointTile.y + _loc1_;
         var _loc4_:Number = _loc2_ * this.view.units;
         var _loc5_:Number = _loc3_ * this.view.units;
         var _loc6_:Point = this.view.getScreenPointGlobal(_loc4_,_loc5_);
         var _loc7_:Point = this.bhpPopupLoadHelper.guiMovePopup.movieClip.parent.globalToLocal(_loc6_);
         this.bhpPopupLoadHelper.guiMovePopup.moveTo(_loc7_.x,_loc7_.y);
      }
      
      private function moveWayPointHandler(param1:BattleMoveEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(!this.board || !this.board.boardSetup)
         {
            return;
         }
         if(this.gpOverlay)
         {
            this.gpOverlay.dirty();
         }
         var _loc2_:IBattleMove = !!this.turn ? this.turn.move : null;
         if(_loc2_)
         {
            if(!_loc2_.suppressCommit && !_loc2_.committed && _loc2_.wayPointTile && _loc2_.wayPointTile != _loc2_.first && !_loc2_.waypointBlocked)
            {
               if(!config.sceneControllerConfig.restrictInput || config.sceneControllerConfig.allowMoveTile == _loc2_.wayPointTile)
               {
                  _loc3_ = _loc2_.wayPointSteps - 1;
                  _loc4_ = int(this.turn.entity.stats.getValue(StatType.MOVEMENT));
                  _loc5_ = Math.max(0,_loc3_ - _loc4_);
                  _loc6_ = int(this.turn.entity.stats.getValue(StatType.WILLPOWER_MOVE,1));
                  _loc7_ = 0;
                  if(_loc5_ > 0)
                  {
                     _loc7_ = 1 + (_loc5_ - 1) / _loc6_;
                  }
                  this.bhpPopupLoadHelper.guiMovePopup.show(_loc7_);
                  this.positionWayPointHandler();
                  return;
               }
            }
         }
         this.bhpPopupLoadHelper.guiMovePopup.hide();
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         var _loc2_:int = 0;
         this.popupEnemyHelper.setupPopup(this.abilityCommitted ? null : this.turn);
         this.popupSelfHelper.setupPopup(this.abilityCommitted ? null : this.turn);
         this.popupSelfHelper.setupPopup(this.abilityCommitted ? null : this.turn);
         if(!this.abilityCommitted)
         {
            _loc2_ = int(this.turn.entity.stats.getValue(StatType.WILLPOWER));
            this.popupSelfHelper.updateWillpower(_loc2_);
         }
         this.updateInfoOnEvent(param1);
      }
      
      public function selfMoveSelect() : void
      {
         config.gameGuiContext.playSound("ui_movement_button");
         this.fsm.interact = null;
      }
      
      public function guiMovePopupExecute() : void
      {
         var _loc1_:IBattleMove = !!this._turn ? this._turn.move : null;
         var _loc2_:IBattleEntity = !!this._turn ? this._turn.entity : null;
         if(Boolean(_loc1_) && !_loc1_.committed)
         {
            if(_loc2_ && _loc2_.alive && Boolean(_loc2_.playerControlled))
            {
               config.gameGuiContext.playSound("ui_movement_button");
               this.turn.move.trimStepsToWaypoint(true);
               this.turn.move.setCommitted("BattleHudPage.guiMovePopupExecute");
            }
         }
         this.bhpPopupLoadHelper.guiMovePopup.hide();
      }
      
      public function guiMovePopupOver() : void
      {
         if(!this.turn.move.committed)
         {
            this.turn.move.trimStepsToWaypoint(true);
         }
      }
      
      private function updateInfoOnEvent(param1:Event) : void
      {
         if(this.fsm)
         {
            if(this.bhpLoadHelper.guihud)
            {
               switch(this.fsm.currentClass)
               {
                  case BattleStateDeploy:
                     this.bhpLoadHelper.guihud.showDeploy(true,true);
                     break;
                  case BattleStateWaveRedeploy_Prepare:
                     this.bhpLoadHelper.guihud.showWaveRedeploy(true);
                     this.bhpLoadHelper.guihud.showInitiativeHud(false);
                     this.artifactHelper.showArtifact(false);
                     this.bhpLoadHelper.suppressInitiativeForWaveRedeploy(true);
                     this.waveTurnCounterHelper.waveTurnCounter.visible = false;
                     this.bhpRedeployHelper.showRedeploymentGui();
                     this.bhpLoadHelper.guihud.refreshDeploymentTimer();
                     break;
                  case BattleStateWaveRedeploy_Assemble:
                     if(!param1)
                     {
                        this.playReinforcements();
                     }
                     this.bhpLoadHelper.guihud.showWaveRedeploy(false);
                     if(BattleFsmConfig.guiWaveDeployEnabled)
                     {
                        this.showWaveDeploy();
                     }
                     else
                     {
                        BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_WAVE_DEPLOY_ENABLE,this.onWaveTutorialComplete);
                     }
                     break;
                  case BattleStateWaveRespawn:
                     this.bhpRedeployHelper.hideRedeploymentGui();
                     this.bhpLoadingOverlayHelper.showLoadingOverlay();
                     break;
                  case BattleStateWaveRespawn_ResetCamera:
                     this.bhpLoadingOverlayHelper.hideLoadingOverlay();
                     break;
                  case BattleStateWaveRespawn_Complete:
                     this.bhpLoadHelper.suppressInitiativeForWaveRedeploy(false);
               }
            }
            this.checkDeploymentInitiative();
         }
         this.infoBarHelper.updateInfo();
         this.moveWayPointHandler(null);
         if(this.bhpLoadHelper.initiative)
         {
            this.bhpLoadHelper.initiative.clearEndButton();
         }
      }
      
      private function onWaveTutorialComplete(param1:Event) : void
      {
         this.showWaveDeploy();
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_WAVE_DEPLOY_ENABLE,this.onWaveTutorialComplete);
      }
      
      private function showWaveDeploy() : void
      {
         this.bhpLoadHelper.guihud.showDeploy(true,false);
         this.bhpRedeployHelper.activateRedeploymentGui();
      }
      
      public function toggleQuestionMarkHelp() : void
      {
         this.questionMarkHelpEnabled = !this.questionMarkHelpEnabled;
         if(this.battleHandler.page)
         {
            this.battleHandler.page.handleMenuButton();
         }
      }
      
      public function set questionMarkHelpEnabled(param1:Boolean) : void
      {
         if(param1)
         {
            config.globalPrefs.setPref(GameConfig.PREF_BATTLE_FIRST_TIME,false);
         }
         this._questionMarkHelpEnabled = param1;
         this.updateBattleHelp();
      }
      
      public function get questionMarkHelpEnabled() : Boolean
      {
         return this._questionMarkHelpEnabled;
      }
      
      public function updateBattleHelp() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:SceneState = null;
         var _loc3_:Boolean = false;
         if(this.bhpLoadHelper.battleHelp)
         {
            if(this._questionMarkHelpEnabled)
            {
               if(!this.bhpLoadHelper.battleHelp.movieClip.parent)
               {
                  this.addChild(this.bhpLoadHelper.battleHelp.movieClip);
               }
               _loc1_ = this.bhpLoadHelper.optionButton as DisplayObject;
               _loc2_ = config.fsm.current as SceneState;
               _loc3_ = Boolean(_loc2_) && _loc2_.bannerButtonEnabled;
               this.bhpLoadHelper.battleHelp.updateHelp(this.artifactHelper.artifact,this.bhpLoadHelper.initiative,this._chat,_loc1_,this.width,this.height,_loc3_);
            }
            else if(this.bhpLoadHelper.battleHelp.movieClip.parent)
            {
               this.removeChild(this.bhpLoadHelper.battleHelp.movieClip);
            }
         }
      }
      
      public function guiOptionsSetChat(param1:Boolean) : void
      {
         dispatchEvent(new BattleHudPageEvent(BattleHudPageEvent.CHAT_ENABLED));
      }
      
      public function guiOptionsToggleFullcreen() : void
      {
         config.context.appInfo.toggleFullscreen();
      }
      
      public function guiOptionsQuitGame() : void
      {
         config.context.appInfo.exitGame("options");
      }
      
      public function guiOptionsSetMusic(param1:Boolean) : void
      {
         config.soundSystem.mixer.musicEnabled = param1;
      }
      
      public function guiOptionsSetSfx(param1:Boolean) : void
      {
         config.soundSystem.mixer.sfxEnabled = param1;
      }
      
      public function guiOptionsSurrenderMatch() : void
      {
         this._fsm.surrender();
      }
      
      private function updateTargets(param1:BattleAbility, param2:BattleEntity) : void
      {
         var _loc10_:IBattleEntity = null;
         var _loc3_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc4_:IBattleEntity = param1.caster;
         var _loc5_:BattleAbilityTargetRule = param1.def.targetRule;
         var _loc6_:IBattleMove = this.turn.move;
         var _loc7_:TileRect = _loc6_.interrupted ? _loc4_.rect : _loc6_.lastTileRect;
         if(_loc5_ == BattleAbilityTargetRule.FORWARD_ARC)
         {
            throw new IllegalOperationError("updateTargets not for FORWARD_ARC");
         }
         BattleBoardTargetHelper.selectAdjacent(_loc4_,_loc7_,_loc5_,_loc3_);
         var _loc8_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         this.sortClockwise(_loc4_,param2,_loc3_,_loc8_);
         var _loc9_:int = 0;
         while(_loc9_ < param1.def.targetCount && _loc9_ < _loc8_.length)
         {
            _loc10_ = _loc8_[_loc9_];
            param1.targetSet.addTarget(_loc10_);
            _loc9_++;
         }
      }
      
      private function sortClockwise(param1:IBattleEntity, param2:IBattleEntity, param3:Vector.<IBattleEntity>, param4:Vector.<IBattleEntity>) : void
      {
         var _loc7_:BattleEntity = null;
         var _loc8_:Object = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Object = null;
         if(param3.length == 0)
         {
            return;
         }
         var _loc5_:Number = Math.atan2(param2.centerX - param1.centerX,param2.centerY - param1.centerY);
         var _loc6_:Array = [];
         for each(_loc7_ in param3)
         {
            _loc9_ = _loc7_.centerX - param1.centerX;
            _loc10_ = _loc7_.centerY - param1.centerY;
            _loc11_ = Math.atan2(_loc9_,_loc10_);
            _loc11_ -= _loc5_;
            _loc11_ = -_loc11_;
            _loc11_ = MathUtil.radians2Pi(_loc11_);
            _loc12_ = {
               "angle":_loc11_,
               "entity":_loc7_
            };
            _loc6_.push(_loc12_);
         }
         _loc6_.sortOn(["angle"]);
         param4.splice(0,param4.length);
         for each(_loc8_ in _loc6_)
         {
            param4.push(_loc8_.entity);
         }
      }
      
      public function updateInput(param1:int) : void
      {
         if(this.input)
         {
            this.input.update(param1);
         }
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this._hoverTileChanged || this._selectedTriggersChanged)
         {
            this._handleHoverTileChanged();
         }
         if(this.gpOverlay)
         {
            this.gpOverlay.update();
         }
         if(this.bhpLoadingOverlayHelper)
         {
            this.bhpLoadingOverlayHelper.update(param1);
         }
         var _loc2_:int = int(this.camera.viewChangeCounter);
         if(_loc2_ > this._lastCameraViewChangeCounter)
         {
            this._lastCameraViewChangeCounter = _loc2_;
            if(this.popupSelfHelper != null)
            {
               this.popupSelfHelper.positionPopup();
            }
            if(this.popupEnemyHelper != null)
            {
               this.popupEnemyHelper.positionPopup();
            }
            if(this.popupPropHelper != null)
            {
               this.popupPropHelper.positionPopup();
            }
            this.positionWayPointHandler();
            this.positionAbilityPopup();
            this.positionTooltip();
         }
         if(this.popupSelfHelper)
         {
            this.popupSelfHelper.update(param1);
         }
         if(this.popupEnemyHelper)
         {
            this.popupEnemyHelper.update(param1);
         }
         this.bhpAbilityPopup.updatePopup(param1);
         if(this.tooltips)
         {
            this.tooltips.update(param1);
         }
         if(this.bhpPopupLoadHelper)
         {
            this.bhpPopupLoadHelper.update(param1);
         }
         if(this.bhpLoadHelper)
         {
            this.bhpLoadHelper.update(param1);
         }
         if(this.popupPropHelper)
         {
            this.popupPropHelper.update(param1);
         }
      }
      
      public function handleLocaleChange() : void
      {
         if(this.bhpLoadHelper)
         {
            this.bhpLoadHelper.handleLocaleChange();
         }
         if(this.infoBarHelper)
         {
            this.infoBarHelper.handleLocaleChange();
         }
      }
      
      public function toggleInfo() : void
      {
         this._sceneView.showHelp = !this._sceneView.showHelp;
         if(this.battleHandler.page)
         {
            this.battleHandler.page.handleDpadUpButton();
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         if(Boolean(this.popupSelfHelper) && this.popupSelfHelper.handleGpButton(param1))
         {
            return true;
         }
         if(Boolean(this.popupEnemyHelper) && this.popupEnemyHelper.handleGpButton(param1))
         {
            return true;
         }
         if(Boolean(this.popupPropHelper) && this.popupPropHelper.handleGpButton(param1))
         {
            return true;
         }
         if(this.bhpAbilityPopup.handleGpButton(param1))
         {
            return true;
         }
         return false;
      }
      
      private function battleHudConfigHandler(param1:Event) : void
      {
         this._lastCameraViewChangeCounter = -1;
      }
      
      override public function handleOptionsButton() : void
      {
         if(this.bhpLoadHelper)
         {
            this.bhpLoadHelper.handleOptionsButton();
         }
      }
      
      override public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this.bhpLoadHelper)
         {
            this.bhpLoadHelper.handleOptionsShowing(param1);
         }
      }
      
      public function mouseMoveHandler(param1:MouseEvent) : void
      {
         this._board.hoverTile = null;
         this._board.hoverEntity = null;
      }
      
      public function guiInitiativeTooltipOverride(param1:Array, param2:Point) : void
      {
         this.overrideTooltip(param1,param2);
      }
      
      public function guiInitiativeCancelTooltipOverride(param1:Array) : void
      {
         this.cancelOverrideTooltip(param1);
      }
      
      public function guiPropPopupUsed() : void
      {
         logger.info("BHP guiPropPopupUsed");
         if(!this._turn)
         {
            return;
         }
         if(this._turn.committed)
         {
            return;
         }
         var _loc1_:IBattleEntity = !!this._turn ? this._turn.turnInteract : null;
         if(!_loc1_)
         {
            return;
         }
         if(!_loc1_.usable)
         {
            this.bhpPopupLoadHelper.guiPropPopup.hide();
            return;
         }
         if(this._board.isUsingEntity)
         {
            logger.info("BHP already using");
            return;
         }
         _loc1_.handleUsed(this._turn.entity);
      }
   }
}
