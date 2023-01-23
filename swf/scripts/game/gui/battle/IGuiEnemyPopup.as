package game.gui.battle
{
   import game.gui.IGuiContext;
   
   public interface IGuiEnemyPopup extends IGuiPopup
   {
       
      
      function init(param1:IGuiContext, param2:IGuiPopupListener) : void;
      
      function setupPopup(param1:Array, param2:Array, param3:int, param4:int, param5:int) : void;
      
      function setStrengthDamageText(param1:int, param2:int, param3:int) : void;
      
      function setArmorDamageText(param1:int, param2:int, param3:Boolean = false) : void;
      
      function updateWillpower(param1:int) : void;
      
      function cleanup() : void;
   }
}
