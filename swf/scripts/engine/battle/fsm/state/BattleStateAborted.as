package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class BattleStateAborted extends BaseBattleState
   {
       
      
      public function BattleStateAborted(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
   }
}
