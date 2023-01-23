package engine.battle.fsm.txn
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import tbs.srv.battle.data.client.BattleKilledData;
   
   public class BattleTxnKillSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/killed";
       
      
      public function BattleTxnKillSend(param1:BattleFsm, param2:int, param3:IBattleEntity, param4:IBattleEntity, param5:ILogger)
      {
         var _loc6_:BattleKilledData = new BattleKilledData();
         _loc6_.turn = param2;
         _loc6_.entity = param3.def.id;
         _loc6_.killedparty = int(param3.party.id);
         if(param4)
         {
            _loc6_.killerparty = int(param4.party.id);
            _loc6_.killer = param4.def.id;
         }
         else
         {
            _loc6_.killerparty = 0;
            _loc6_.killer = null;
         }
         _loc6_.battle_id = param1.battleId;
         param5.info("BattleTxnKillSend " + _loc6_.battle_id + ", killed=" + _loc6_.killedparty + "/" + _loc6_.entity + " by " + _loc6_.killerparty + "/" + _loc6_.killer);
         super(PATH + param1.session.credentials.urlCred,HttpRequestMethod.POST,_loc6_,null,param1,param1.logger);
         resendOnFail = true;
      }
   }
}
