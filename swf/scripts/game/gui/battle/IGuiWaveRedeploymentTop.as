package game.gui.battle
{
   import engine.sound.ISoundDriver;
   import game.gui.IGuiContext;
   
   public interface IGuiWaveRedeploymentTop
   {
       
      
      function init(param1:IGuiContext, param2:IGuiBattleHudListener, param3:ISoundDriver) : void;
      
      function showRedeploymentTop(param1:Boolean) : void;
      
      function handleLocaleChange() : void;
   }
}
