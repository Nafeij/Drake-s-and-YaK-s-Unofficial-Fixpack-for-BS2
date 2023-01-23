package game.gui
{
   import engine.battle.board.model.IBattleScenario;
   
   public interface IGuiOptionsBattleObjectives
   {
       
      
      function init(param1:IGuiContext, param2:IGuiOptionsBattleObjectivesListener) : void;
      
      function showScenario(param1:IBattleScenario) : void;
      
      function closeOptionsBattleObjectives() : Boolean;
      
      function cleanup() : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
   }
}
