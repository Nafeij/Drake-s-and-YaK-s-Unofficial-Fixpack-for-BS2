package game.gui.page
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleScenario;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleRewardData;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.locale.LocaleCategory;
   import engine.saga.WarOutcome;
   import engine.saga.WarOutcomeType;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiContext;
   import game.gui.battle.IGuiMatchPageListener;
   import game.gui.battle.IGuiMatchResolution;
   import game.session.states.SceneState;
   
   public class WarResolutionPage extends GamePage implements IGuiMatchPageListener
   {
      
      public static var mcClazz:Class;
       
      
      public var closedCallback:Function;
      
      private var guiResult:IGuiMatchResolution;
      
      private var sceneState:SceneState;
      
      private var fin:BattleFinishedData;
      
      private var outcome:WarOutcome;
      
      private var cmd_match_resolution_continue:Cmd;
      
      public function WarResolutionPage(param1:GameConfig, param2:BattleFinishedData, param3:WarOutcome, param4:Function)
      {
         this.cmd_match_resolution_continue = new Cmd("match_resolution_continue",this.cmdContinueFunc);
         super(param1);
         fitConstraints.maxHeight = fitConstraints.minHeight = 703;
         this.closedCallback = param4;
         this.fin = param2;
         this.outcome = param3;
      }
      
      override protected function handleStart() : void
      {
         setFullPageMovieClipClass(mcClazz);
      }
      
      private function cmdContinueFunc(param1:CmdExec) : void
      {
         this.quitGameButtonClickHandler(null);
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.guiResult)
         {
            fullScreenMc.x = 0;
            fullScreenMc.y = fullScreenMc.parent.height / 2;
            this.guiResult = fullScreenMc as IGuiMatchResolution;
            PlatformStarling.setPanning(false,logger,"WarResolutionPage.handleLoaded");
         }
      }
      
      override protected function handleDelayStart() : void
      {
         var _loc2_:BattleRewardData = null;
         var _loc3_:Vector.<String> = null;
         var _loc4_:Vector.<String> = null;
         var _loc5_:IGuiContext = null;
         var _loc6_:IBattleBoard = null;
         var _loc7_:IBattleScenario = null;
         this.sceneState = config.fsm.current as SceneState;
         if(!this.sceneState)
         {
            logger.info("No scene state for WarResolutionPage");
            return;
         }
         var _loc1_:* = this.outcome.type == WarOutcomeType.VICTORY;
         if(this.guiResult)
         {
            _loc2_ = !!this.fin ? this.fin.getReward(0) : null;
            _loc3_ = this.outcome.unitsReadyToPromote;
            _loc4_ = this.outcome.unitsInjured;
            _loc5_ = config.gameGuiContext;
            _loc6_ = this.sceneState.scene.focusedBoard;
            _loc7_ = !!_loc6_ ? _loc6_.scenario : null;
            this.guiResult.init(this,_loc7_,this.outcome,_loc2_,_loc3_,_loc4_,_loc1_,_loc5_,true);
            config.context.locale.translateDisplayObjects(LocaleCategory.GUI,fullScreenMc,logger);
            PlatformStarling.setPanning(false,logger,"WarResolutionPage.handleDelayStart");
         }
         if(_loc1_)
         {
            config.soundSystem.controller.playSound("ui_victory",null);
         }
         else
         {
            config.soundSystem.controller.playSound("ui_defeat",null);
         }
         if(config.saga)
         {
            config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_match_resolution_continue,"match_resolution");
            config.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_match_resolution_continue,"match_resolution");
            config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_match_resolution_continue,"match_resolution");
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_match_resolution_continue);
            GpDevBinder.instance.bind(null,GpControlButton.A,1,this.cmdContinueFunc,[null]);
         }
      }
      
      override public function cleanup() : void
      {
         GpDevBinder.instance.unbind(this.cmdContinueFunc);
         GpBinder.gpbinder.unbind(this.cmd_match_resolution_continue);
         if(config.keybinder)
         {
            config.keybinder.unbind(this.cmd_match_resolution_continue);
         }
         this.cmd_match_resolution_continue.cleanup();
         this.cmd_match_resolution_continue = null;
         if(this.sceneState)
         {
            this.sceneState = null;
         }
         if(this.guiResult)
         {
            this.guiResult.cleanup();
            this.guiResult = null;
         }
         this.closedCallback = null;
      }
      
      public function quitGameButtonClickHandler(param1:Object) : void
      {
         logger.info("WarResolutionPage.quitGameButtonClickHandler [" + param1 + "] closedCallback [" + this.closedCallback + "]");
         var _loc2_:Function = this.closedCallback;
         if(_loc2_ != null)
         {
            this.closedCallback = null;
            _loc2_(this);
         }
      }
      
      public function newGameButtonClickHandler(param1:Object) : void
      {
         if(this.closedCallback != null)
         {
            this.closedCallback(this);
         }
      }
   }
}
