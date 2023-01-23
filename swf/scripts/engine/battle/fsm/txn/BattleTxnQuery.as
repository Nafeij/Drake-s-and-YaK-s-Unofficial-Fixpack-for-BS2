package engine.battle.fsm.txn
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   
   public class BattleTxnQuery extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/query";
       
      
      public function BattleTxnQuery(param1:String, param2:int, param3:Function, param4:BattleFsm, param5:ILogger)
      {
         var _loc6_:Object = {
            "battle_id":param4.battleId,
            "turn":param2
         };
         super(PATH + param4.session.credentials.urlCred,HttpRequestMethod.POST,_loc6_,param3,param4,param5);
         resendOnFail = true;
      }
   }
}
