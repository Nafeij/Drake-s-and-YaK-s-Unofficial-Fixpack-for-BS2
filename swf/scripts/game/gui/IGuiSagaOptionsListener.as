package game.gui
{
   import flash.events.Event;
   
   public interface IGuiSagaOptionsListener
   {
       
      
      function guiOptionsSetMusic(param1:Boolean) : void;
      
      function guiOptionsSetSfx(param1:Boolean) : void;
      
      function guiOptionsToggleFullcreen() : void;
      
      function guiOptionsQuitGame() : void;
      
      function guiOptionsNews() : void;
      
      function guiOptionsDifficulty() : void;
      
      function guiOptionsCredits() : void;
      
      function guiOptionsResume() : void;
      
      function guiOptionsHideLayers() : void;
      
      function guiOptionsSaveLoad() : void;
      
      function guiOptionsLang() : void;
      
      function guiOptionsAudio() : void;
      
      function guiOptionsGp() : void;
      
      function guiOptionsTrainingExit() : void;
      
      function guiOptionsTutorialExit() : void;
      
      function guiOptionsSurvivalReload() : void;
      
      function guiOptionsBattleObjectives() : void;
      
      function guiOptionsGooglePlaySignOut() : void;
      
      function guiOptionsGooglePlaySignIn() : void;
      
      function guiOptionsGaOptState() : void;
      
      function guiOptionsGpRefreshBindingHandler(param1:Event) : void;
   }
}
