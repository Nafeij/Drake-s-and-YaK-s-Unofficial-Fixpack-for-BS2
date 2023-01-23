package game.gui.page
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleRewardData;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.sim.IBattleParty;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.locale.LocaleCategory;
   import engine.saga.Saga;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiContext;
   import game.gui.battle.IGuiMatchPageListener;
   import game.gui.battle.IGuiMatchResolution;
   import game.session.states.GameStateDataEnum;
   import game.session.states.SceneState;
   
   public class MatchResolutionPage extends GamePage implements IGuiMatchPageListener
   {
      
      public static var mcClazz:Class;
       
      
      public var closedCallback:Function;
      
      public var board:BattleBoard;
      
      private var guiResult:IGuiMatchResolution;
      
      private var sceneState:SceneState;
      
      public var showStats:Boolean;
      
      private var cmd_match_resolution_continue:Cmd;
      
      private var cmd_match_resolution_reload:Cmd;
      
      public function MatchResolutionPage(param1:GameConfig, param2:BattleBoard, param3:Function, param4:Boolean)
      {
         this.cmd_match_resolution_continue = new Cmd("match_resolution_continue",this.cmdContinueFunc);
         this.cmd_match_resolution_reload = new Cmd("match_resolution_reload",this.cmdReloadFunc);
         super(param1);
         this.name = "match_resolution_page";
         this.showStats = param4;
         fitConstraints.maxHeight = fitConstraints.minHeight = 703;
         this.closedCallback = param3;
         this.board = param2;
      }
      
      private function cmdContinueFunc(param1:CmdExec) : void
      {
         this.quitGameButtonClickHandler(null);
      }
      
      private function cmdReloadFunc(param1:CmdExec) : void
      {
         var _loc2_:Saga = config.saga;
         if(Boolean(_loc2_) && _loc2_.isSurvival)
         {
            _loc2_.survivalReload();
         }
      }
      
      override protected function handleStart() : void
      {
         setFullPageMovieClipClass(mcClazz);
      }
      
      override protected function handleLoaded() : void
      {
         logger.info("MatchResolutionPage.handleLoaded fullScreenMc=" + fullScreenMc + " guiResult=" + this.guiResult);
         if(Boolean(fullScreenMc) && !this.guiResult)
         {
            fullScreenMc.x = 0;
            fullScreenMc.y = fullScreenMc.parent.height / 2;
            this.guiResult = fullScreenMc as IGuiMatchResolution;
            PlatformStarling.setPanning(false,logger,"MatchResolutionPage.handleLoaded");
         }
      }
      
      override protected function handleDelayStart() : void
      {
         var _loc5_:BattleRewardData = null;
         var _loc6_:Vector.<String> = null;
         var _loc7_:Vector.<String> = null;
         var _loc8_:IGuiContext = null;
         this.sceneState = config.fsm.current as SceneState;
         logger.info("MatchResolutionPage.handleDelayStart guiResult=" + this.guiResult);
         var _loc1_:BattleFinishedData = this.board.fsm.current.data.getValue(BattleStateDataEnum.FINISHED);
         var _loc2_:String = this.board.fsm.current.data.getValue(BattleStateDataEnum.VICTORIOUS_TEAM);
         var _loc3_:IBattleParty = this.board.getPartyById(this.board.fsm.session.credentials.userId.toString());
         var _loc4_:* = _loc3_.team == _loc2_;
         if(this.guiResult)
         {
            _loc5_ = _loc1_.getReward(this.board.fsm.localBattleOrder);
            _loc6_ = this.board.fsm.unitsReadyToPromote;
            _loc7_ = this.board.fsm.unitsInjured;
            _loc8_ = config.gameGuiContext;
            this.guiResult.init(this,this.board.scenario,null,_loc5_,_loc6_,_loc7_,_loc4_,_loc8_,this.showStats);
            config.context.locale.translateDisplayObjects(LocaleCategory.GUI,fullScreenMc,logger);
            PlatformStarling.setPanning(false,logger,"MatchResolutionPage.handleDelayStart");
         }
         if(config.saga)
         {
            config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_match_resolution_continue,"match_resolution");
            config.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_match_resolution_continue,"match_resolution");
            config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_match_resolution_continue,"match_resolution");
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_match_resolution_continue);
            GpBinder.gpbinder.bindPress(GpControlButton.X,this.cmd_match_resolution_reload);
            GpDevBinder.instance.bind(null,GpControlButton.A,1,this.cmdContinueFunc,[null]);
         }
      }
      
      override public function cleanup() : void
      {
         if(cleanedup)
         {
            return;
         }
         GpDevBinder.instance.unbind(this.cmdContinueFunc);
         GpBinder.gpbinder.unbind(this.cmd_match_resolution_continue);
         GpBinder.gpbinder.unbind(this.cmd_match_resolution_reload);
         config.keybinder.unbind(this.cmd_match_resolution_continue);
         if(this.guiResult)
         {
            this.guiResult.cleanup();
         }
         else
         {
            logger.info("MatchResolutionPage.cleanup with null guiResult");
         }
         this.cmd_match_resolution_continue.cleanup();
         this.cmd_match_resolution_continue = null;
         this.cmd_match_resolution_reload.cleanup();
         this.cmd_match_resolution_reload = null;
         this.sceneState = null;
         this.guiResult = null;
         this.board = null;
         this.closedCallback = null;
         super.cleanup();
      }
      
      public function quitGameButtonClickHandler(param1:Object) : void
      {
         if(this.closedCallback != null)
         {
            config.fsm.current.data.setValue(GameStateDataEnum.REMATCH,false);
            this.closedCallback(this);
         }
      }
      
      public function newGameButtonClickHandler(param1:Object) : void
      {
         if(this.closedCallback != null)
         {
            config.fsm.current.data.setValue(GameStateDataEnum.REMATCH,true);
            this.closedCallback(this);
         }
      }
   }
}
