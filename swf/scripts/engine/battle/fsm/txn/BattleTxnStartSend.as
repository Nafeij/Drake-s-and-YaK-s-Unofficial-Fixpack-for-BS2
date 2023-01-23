package engine.battle.fsm.txn
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class BattleTxnStartSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/ready";
       
      
      public function BattleTxnStartSend(param1:String, param2:Credentials, param3:Function, param4:BattleFsm, param5:ILogger)
      {
         super(PATH + param2.urlCred,HttpRequestMethod.POST,{"battle_id":param1},param3,param4,param5);
      }
   }
}
