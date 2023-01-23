package game.gui.battle
{
   import engine.ability.def.AbilityDef;
   import engine.battle.board.model.IBattleEntity;
   import game.gui.IGuiContext;
   
   public interface IGuiSelfPopup extends IGuiPopup
   {
       
      
      function init(param1:IGuiContext, param2:IGuiPopupListener) : void;
      
      function setValues(param1:Vector.<AbilityDef>, param2:Boolean, param3:Boolean, param4:Boolean) : void;
      
      function updateWillpower(param1:int) : void;
      
      function hotEndTurn(param1:IBattleEntity) : void;
      
      function cleanup() : void;
      
      function getDebugString() : String;
      
      function update(param1:int) : void;
   }
}
