package game.gui
{
   public interface IGuiSagaOptionsShareListener
   {
       
      
      function guiSagaOptionsShare_Stats() : void;
      
      function guiSagaOptionsShare_RateApp() : void;
      
      function guiSagaOptionsShare_ShareApp() : void;
      
      function guiSagaOptionsShare_Soundtrack() : void;
      
      function get guiSagaOptionsShare_CanShowStats() : Boolean;
      
      function get guiSagaOptionsShare_CanRateApp() : Boolean;
      
      function get guiSagaOptionsShare_CanShareApp() : Boolean;
      
      function get guiSagaOptionsShare_CanSoundtrack() : Boolean;
   }
}
