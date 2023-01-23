package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class BattleStateError extends BaseBattleState
   {
       
      
      public var message:String = "";
      
      public function BattleStateError(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:String = null;
         super.handleEnteredState();
         for each(_loc1_ in battleFsm.errors)
         {
            logger.error("BattleStateError: " + _loc1_);
            this.message += _loc1_ + "\n";
         }
         battleFsm.exitBattle();
      }
   }
}
