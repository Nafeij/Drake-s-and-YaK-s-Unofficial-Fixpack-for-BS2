package game.gui.battle
{
   import engine.battle.board.model.IBattleEntity;
   import flash.geom.Point;
   
   public interface IGuiInitiativeListener
   {
       
      
      function guiInitiativeEndTurn() : void;
      
      function guiInitiativeInteract(param1:IBattleEntity) : Boolean;
      
      function guiInitiativeTooltipOverride(param1:Array, param2:Point) : void;
      
      function guiInitiativeCancelTooltipOverride(param1:Array) : void;
   }
}
