package game.gui.battle
{
   import engine.sound.ISoundDriver;
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public interface IGuiBattleHud
   {
       
      
      function init(param1:IGuiContext, param2:IGuiPopupListener, param3:IGuiBattleHudListener, param4:ISoundDriver, param5:Boolean) : void;
      
      function setSize(param1:Number, param2:Number) : void;
      
      function get deployTimer() : IGuiDeploymentTimer;
      
      function getWaveRedeployTop() : IGuiWaveRedeploymentTop;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function get initiative() : IGuiInitiative;
      
      function set initiative(param1:IGuiInitiative) : void;
      
      function showDeploy(param1:Boolean, param2:Boolean) : void;
      
      function showWaveRedeploy(param1:Boolean) : void;
      
      function showInitiativeHud(param1:Boolean) : void;
      
      function set deployPercent(param1:Number) : void;
      
      function refreshDeploymentTimer() : void;
   }
}
