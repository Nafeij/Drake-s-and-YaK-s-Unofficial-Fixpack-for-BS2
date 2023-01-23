package engine.battle.fsm.txn
{
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMoveVars;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class BattleTxnMoveSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/move";
       
      
      public function BattleTxnMoveSend(param1:String, param2:int, param3:IBattleMove, param4:int, param5:Credentials, param6:Function, param7:BattleFsm, param8:ILogger)
      {
         var _loc9_:Object = BattleMoveVars.save(param3);
         _loc9_.turn = param2;
         _loc9_.battle_id = param7.battleId;
         _loc9_.ordinal = param4;
         super(PATH + param5.urlCred,HttpRequestMethod.POST,_loc9_,param6,param7,param8);
         param8.debug("BattleTxnMoveSend " + JSON.stringify(_loc9_));
         if(param7.turn.entity != param3.entity)
         {
            throw new ArgumentError("BattleTxnMoveSend really invalid move entity");
         }
         if(param7.turn.entity.tile != param3.first)
         {
            throw new ArgumentError("BattleTxnMoveSend really invalid move tile " + param3.first + " should be " + param3.entity.tile);
         }
         resendOnFail = true;
      }
   }
}
