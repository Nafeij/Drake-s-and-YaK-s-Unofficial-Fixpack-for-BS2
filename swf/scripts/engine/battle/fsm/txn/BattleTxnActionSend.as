package engine.battle.fsm.txn
{
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import tbs.srv.battle.data.client.BattleActionData;
   
   public class BattleTxnActionSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/action";
       
      
      public function BattleTxnActionSend(param1:String, param2:int, param3:IBattleAbility, param4:int, param5:Boolean, param6:Credentials, param7:Function, param8:BattleFsm, param9:ILogger)
      {
         var _loc10_:BattleActionData = new BattleActionData();
         _loc10_.setupBattleActionData(0,param8.turn.number,param8.battleId,param3,param4,param5);
         param9.debug("BattleTxnActionSend " + _loc10_);
         super(PATH + param6.urlCred,HttpRequestMethod.POST,_loc10_,param7,param8,param9);
         resendOnFail = true;
      }
   }
}
