package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.session.Chat;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.IGuiStrandOptions;
   import game.gui.IGuiStrandOptionsListener;
   
   public class TownPage extends ScenePage implements IGuiStrandOptionsListener
   {
       
      
      private var chatHelper:GlobalChatHelper;
      
      private var guidepost:String;
      
      private var guidepostClick:String;
      
      private var guidepostPrefKey:String;
      
      private var _options:IGuiStrandOptions;
      
      private var cmd_town_escape:Cmd;
      
      public function TownPage(param1:GameConfig)
      {
         this.cmd_town_escape = new Cmd("town_escape",this.cmdEscapeFunc);
         super(param1);
         enableBanner = true;
      }
      
      private function checkTownChatEnabled() : void
      {
         if(Boolean(sceneState) && sceneState.chatEnabled)
         {
            if(!this.chatHelper)
            {
               this.chatHelper = new GlobalChatHelper(this,config,Chat.GLOBAL_ROOM);
            }
         }
         else if(this.chatHelper)
         {
            this.chatHelper.cleanup();
            this.chatHelper = null;
         }
      }
      
      override protected function chatEnabledHandler(param1:Event) : void
      {
         super.chatEnabledHandler(param1);
         this.checkTownChatEnabled();
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         config.keybinder.unbind(this.cmd_town_escape);
         if(this.chatHelper)
         {
            this.chatHelper.cleanup();
            this.chatHelper = null;
         }
      }
      
      override protected function handleStart() : void
      {
         super.handleStart();
         sceneState.bannerButtonEnabled = true;
         this.checkTownChatEnabled();
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_town_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_town_escape,KeyBindGroup.TOWN);
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(this.chatHelper)
         {
            this.chatHelper.resize();
         }
         if(this._options)
         {
            this._options.setSize(width,height);
         }
      }
      
      override protected function handleDelayStart() : void
      {
         super.handleDelayStart();
         if(this.chatHelper)
         {
            this.chatHelper.bringToFront();
         }
         if(this._options)
         {
            this.addChild(this._options.movieClip);
         }
         bringContainerToFront();
      }
      
      override protected function handleLandscapeClick(param1:String) : Boolean
      {
         return sceneState.handleLandscapeClick(param1);
      }
      
      private function optionsLoadedHandler(param1:ResourceLoadedEvent) : void
      {
      }
      
      public function guiOptionsSetMusic(param1:Boolean) : void
      {
         config.soundSystem.mixer.musicEnabled = param1;
      }
      
      public function guiOptionsSetSfx(param1:Boolean) : void
      {
         config.soundSystem.mixer.sfxEnabled = param1;
      }
      
      public function guiOptionsToggleFullcreen() : void
      {
         config.context.appInfo.toggleFullscreen();
      }
      
      public function guiOptionsNews() : void
      {
         config.showNews();
      }
      
      public function guiOptionsQuitGame() : void
      {
         config.context.appInfo.exitGame("options");
      }
      
      public function cmdEscapeFunc(param1:CmdExec) : void
      {
         if(!config.pageManager.escapeFromMarket())
         {
            if(this._options)
            {
               this._options.toggleOptions();
            }
         }
      }
   }
}
