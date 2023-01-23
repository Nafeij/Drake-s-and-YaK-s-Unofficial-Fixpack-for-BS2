package game.gui.battle
{
   public interface IGuiPopupListener
   {
       
      
      function guiEnemyPopupSelect(param1:String, param2:int) : void;
      
      function guiEnemyPopupExecute(param1:String, param2:int) : void;
      
      function selfAttackSelect() : void;
      
      function selfMoveSelect() : void;
      
      function selfEndTurnSelect() : void;
      
      function selfAbilitySelect(param1:String) : void;
   }
}
