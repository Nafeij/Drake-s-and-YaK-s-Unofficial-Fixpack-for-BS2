package game.gui.battle
{
   import engine.battle.board.model.IBattleScenario;
   import engine.battle.fsm.BattleRewardData;
   import engine.saga.WarOutcome;
   import game.gui.IGuiContext;
   
   public interface IGuiMatchResolution
   {
       
      
      function init(param1:IGuiMatchPageListener, param2:IBattleScenario, param3:WarOutcome, param4:BattleRewardData, param5:Vector.<String>, param6:Vector.<String>, param7:Boolean, param8:IGuiContext, param9:Boolean) : void;
      
      function cleanup() : void;
   }
}
