package game.gui.battle
{
   import game.gui.IGuiContext;
   
   public interface IGuiDeploymentTimer
   {
       
      
      function init(param1:IGuiContext, param2:IGuiBattleHudListener) : void;
      
      function showDeploy(param1:Boolean, param2:Boolean) : void;
      
      function deployTimerPercent(param1:Number) : void;
      
      function handleLocaleChange() : void;
   }
}
