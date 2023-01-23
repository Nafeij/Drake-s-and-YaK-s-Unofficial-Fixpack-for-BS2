package engine.saga.action
{
   import engine.battle.fsm.BattleFinishedData;
   import engine.saga.WarOutcome;
   
   public interface IAction_War_Impl
   {
       
      
      function handleStarted() : void;
      
      function determineWarOutcome(param1:WarOutcome) : BattleFinishedData;
      
      function applyBattleResults(param1:WarOutcome, param2:BattleFinishedData) : void;
      
      function handleProcessWarPlan() : void;
      
      function setupWarRiskString() : void;
   }
}
