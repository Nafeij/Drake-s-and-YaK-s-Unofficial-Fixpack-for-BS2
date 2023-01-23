package engine.battle.fsm.txn
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class BattleTxnSurrenderSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/surrender";
       
      
      public function BattleTxnSurrenderSend(param1:String, param2:Credentials, param3:Function, param4:BattleFsm, param5:ILogger)
      {
         var _loc6_:Object = {
            "battle_id":param1,
            "turn":(!!param4 ? param4.turns.length - 1 : 0)
         };
         super(PATH + param2.urlCred,HttpRequestMethod.POST,_loc6_,param3,param4,param5);
         resendOnFail = true;
      }
   }
}
