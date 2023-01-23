package engine.battle.fsm.txn
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import tbs.srv.battle.data.client.BattleExitData;
   
   public class BattleTxnExitSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/exit";
       
      
      public function BattleTxnExitSend(param1:String, param2:Credentials, param3:Function, param4:BattleFsm, param5:ILogger)
      {
         var _loc6_:BattleExitData = new BattleExitData();
         _loc6_.battle_id = param4.battleId;
         super(PATH + param2.urlCred,HttpRequestMethod.POST,_loc6_,param3,param4,param5);
         resendOnFail = true;
      }
   }
}
