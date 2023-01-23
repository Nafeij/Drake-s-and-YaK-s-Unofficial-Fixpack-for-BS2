package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.State;
   import engine.scene.model.SceneLoader;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.actions.VsType;
   import game.session.states.FriendLobbyState;
   import game.session.states.GameStateDataEnum;
   import game.session.states.ProvingGroundsState;
   import game.session.states.TownLoadState;
   import game.session.states.TownState;
   import game.session.states.VersusFindMatchState;
   
   public class GreatHallPage extends GamePage implements IGuiGreatHallListener
   {
       
      
      private var ig:IGuiGreatHall;
      
      private var cmd_great_hall_escape:Cmd;
      
      public function GreatHallPage(param1:GameConfig)
      {
         this.cmd_great_hall_escape = new Cmd("great_hall_escape",this.cmdEscapeFunc);
         super(param1);
      }
      
      override protected function handleStart() : void
      {
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_great_hall_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_great_hall_escape,KeyBindGroup.TOWN);
      }
      
      override protected function handleLoaded() : void
      {
         if(fullScreenMc)
         {
            if(!this.ig)
            {
               this.ig = fullScreenMc as IGuiGreatHall;
               this.ig.init(config.gameGuiContext,this);
            }
         }
      }
      
      public function guiGreatHallExit() : void
      {
         var _loc1_:State = config.fsm.current;
         var _loc2_:SceneLoader = _loc1_.data.getValue(GameStateDataEnum.SCENE_LOADER);
         if(Boolean(_loc2_) && Boolean(_loc2_.scene))
         {
            config.fsm.transitionTo(TownState,_loc1_.data);
         }
         else
         {
            config.fsm.transitionTo(TownLoadState,_loc1_.data);
         }
      }
      
      public function guiGreatHallSkirmish() : void
      {
      }
      
      public function guiGreatHallFriend() : void
      {
         if(!config.fsm.credentials.offline)
         {
            config.fsm.transitionTo(FriendLobbyState,config.fsm.current.data);
         }
      }
      
      override public function cleanup() : void
      {
         config.keybinder.unbind(this.cmd_great_hall_escape);
         if(this.ig)
         {
            this.ig.cleanup();
            this.ig = null;
         }
      }
      
      public function guiGreathallVersus(param1:VsType, param2:int) : void
      {
         var _loc3_:int = 0;
         if(!config.fsm.credentials.offline)
         {
            _loc3_ = VersusFindMatchState.computeTimer(param2,config.globalPrefs);
            config.fsm.current.data.setValue(GameStateDataEnum.BATTLE_TIMER_SECS,_loc3_);
            config.fsm.current.data.setValue(GameStateDataEnum.FORCE_OPPONENT_ID,config.options.versusForceOpponentId);
            config.fsm.current.data.setValue(GameStateDataEnum.SCENE_URL,config.options.versusForceScene);
            config.fsm.current.data.setValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID,0);
            config.fsm.current.data.setValue(GameStateDataEnum.VERSUS_TYPE,param1);
            config.fsm.current.data.setValue(GameStateDataEnum.VERSUS_TOURNEY_ID,param2);
            config.fsm.transitionTo(VersusFindMatchState,config.fsm.current.data);
         }
      }
      
      public function guiGreatHallNarrative() : void
      {
      }
      
      public function guiGoToProvingGrounds() : void
      {
         var _loc1_:State = config.fsm.current;
         config.fsm.transitionTo(ProvingGroundsState,_loc1_.data);
      }
      
      public function cmdEscapeFunc(param1:CmdExec) : void
      {
         if(!config.pageManager.escapeFromMarket())
         {
            this.guiGreatHallExit();
         }
      }
   }
}
