package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.StatePhase;
   import engine.session.Chat;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundLibraryResource;
   import engine.sound.view.ISound;
   import engine.sound.view.SoundController;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.cfg.ILobby;
   import game.gui.GamePage;
   import game.session.actions.VsType;
   import game.session.states.GameStateDataEnum;
   import game.session.states.VersusCancelState;
   import game.session.states.VersusFindMatchState;
   import game.session.states.VersusMatchedState;
   
   public class VersusPage extends GamePage implements IGuiVersusListener
   {
       
      
      private var guiVersus:IGuiVersus;
      
      private var chatHelper:GlobalChatHelper;
      
      private var cmd_versus_escape:Cmd;
      
      private var slr:SoundLibraryResource;
      
      private var soundController:SoundController;
      
      private var sound:ISound;
      
      public function VersusPage(param1:GameConfig)
      {
         this.cmd_versus_escape = new Cmd("versus_escape",this.cmdEscapeFunc);
         super(param1);
         this.chatHelper = new GlobalChatHelper(this,param1,Chat.GLOBAL_ROOM);
         this.chatHelper.align = "topcenter";
         this.updateChatAlignment();
         param1.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_versus_escape,KeyBindGroup.TOWN);
         param1.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_versus_escape,KeyBindGroup.TOWN);
         param1.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         this.chatHelper.cleanup();
         config.keybinder.unbind(this.cmd_versus_escape);
         config.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         if(this.guiVersus)
         {
            this.guiVersus.cleanup();
         }
      }
      
      protected function fsmCurrentHandler(param1:Event) : void
      {
         var _loc3_:ILobby = null;
         var _loc4_:VersusMatchedState = null;
         var _loc5_:VersusFindMatchState = null;
         if(!config.fsm.current)
         {
            return;
         }
         var _loc2_:int = config.fsm.current.data.getValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID);
         if(_loc2_ != 0)
         {
            _loc3_ = !!config.factions ? config.factions.lobbyManager.getLobby(_loc2_) : null;
            this.chatHelper.chatroom = !!_loc3_ ? _loc3_.chatRoomId : null;
         }
         else
         {
            this.chatHelper.chatroom = Chat.GLOBAL_ROOM;
         }
         this.updateMusic();
         this.guiVersus = fullScreenMc as IGuiVersus;
         if(this.guiVersus)
         {
            _loc4_ = config.fsm.current as VersusMatchedState;
            if(_loc4_)
            {
               this.guiVersus.setOpponent(_loc4_.opponentParty,_loc4_.opponentName,_loc4_.battleCreateData.friendly);
               this.chatHelper.showWhenUnfocused = false;
               return;
            }
            _loc5_ = config.fsm.current as VersusFindMatchState;
            this.chatHelper.showWhenUnfocused = true;
            if(_loc5_)
            {
               this.guiVersus.reset();
            }
         }
      }
      
      override protected function handleStart() : void
      {
         this.slr = config.resman.getResource("common/sound/versus_sound.json.z",SoundLibraryResource) as SoundLibraryResource;
         if(!this.slr)
         {
         }
      }
      
      override protected function handleDelayStart() : void
      {
         this.chatHelper.bringToFront();
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this.updateChatAlignment();
      }
      
      private function updateChatAlignment() : void
      {
         if(this.guiVersus)
         {
            this.chatHelper.alignTopGlobal = this.guiVersus.chatAlignmentGlobalY;
         }
         else
         {
            this.chatHelper.alignTopGlobal = 0;
         }
         this.chatHelper.resize();
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.guiVersus)
         {
            this.guiVersus = fullScreenMc as IGuiVersus;
            this.guiVersus.init(config.gameGuiContext,config.options.overrideVersusCountdownSecs,this);
            this.updateChatAlignment();
         }
         if(!this.slr.ok)
         {
            logger.error("VersusPage: Unable to load sound library");
            return;
         }
         if(!this.soundController)
         {
            this.soundController = new SoundController("ScenePage",config.soundSystem.driver,this.soundControllerCallback,config.logger);
            this.soundController.library = this.slr.library;
         }
         this.updateMusic();
      }
      
      private function soundControllerCallback(param1:SoundController) : void
      {
         this.updateMusic();
      }
      
      private function updateMusic() : void
      {
         if(!this.slr.ok)
         {
            return;
         }
         if(!this.soundController || !this.soundController.complete)
         {
            logger.info("VersusPage: Waiting on Sound Library");
            return;
         }
         var _loc1_:int = config.fsm.current.data.getValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID);
         if(_loc1_)
         {
            return;
         }
         var _loc2_:ISoundDef = this.slr.library.getSoundDef("music");
         if(config.fsm.currentClass == VersusFindMatchState)
         {
            if(!config.soundSystem.music || config.soundSystem.music.def != _loc2_ || !config.soundSystem.music.playing)
            {
               logger.info("VersusPage: starting music");
               config.soundSystem.music = this.soundController.getSound(_loc2_.soundName,null);
               this.sound = config.soundSystem.music;
            }
         }
         else if(config.soundSystem.music == this.sound && Boolean(this.sound))
         {
            logger.info("VersusPage: stopping music");
            config.soundSystem.music = null;
         }
      }
      
      public function guiVersusExit() : void
      {
         if(this.sound)
         {
            if(this.sound == config.soundSystem.music)
            {
               config.soundSystem.music = null;
            }
            this.sound = null;
         }
         config.fsm.transitionTo(VersusCancelState,config.fsm.current.data);
      }
      
      public function guiVersusLaunch() : void
      {
         var _loc1_:VersusMatchedState = config.fsm.current as VersusMatchedState;
         if(_loc1_)
         {
            _loc1_.phase = StatePhase.COMPLETED;
         }
         else
         {
            config.fsm.current.phase = StatePhase.FAILED;
         }
      }
      
      public function cmdEscapeFunc(param1:CmdExec) : void
      {
         var _loc2_:VersusMatchedState = null;
         if(!config.pageManager.escapeFromMarket())
         {
            _loc2_ = config.fsm.current as VersusMatchedState;
            if(_loc2_)
            {
               return;
            }
            this.guiVersusExit();
         }
      }
      
      public function get guiVsType() : VsType
      {
         return config.fsm.current.data.getValue(GameStateDataEnum.VERSUS_TYPE);
      }
   }
}
