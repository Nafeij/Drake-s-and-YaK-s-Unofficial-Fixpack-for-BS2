package engine.battle.fsm.txn
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class BattleTxnTurnInitSend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/sync";
       
      
      public var entityId:String;
      
      public var team:String;
      
      public var turnNumber:int;
      
      public var divergence:Boolean;
      
      public var hashStr:String;
      
      public function BattleTxnTurnInitSend(param1:String, param2:int, param3:String, param4:int, param5:IBattleEntity, param6:Credentials, param7:Function, param8:BattleFsm, param9:ILogger)
      {
         this.turnNumber = param2;
         var _loc10_:Object = null;
         if(param5)
         {
            this.entityId = param5.id;
            this.team = param5.team;
         }
         _loc10_ = {};
         _loc10_.battle_id = param8.battleId;
         _loc10_.entity = this.entityId;
         _loc10_.team = this.team;
         _loc10_.turn = param2;
         _loc10_.entities = [];
         _loc10_.randomSampleCount = param5.board.abilityManager.rng.sampleCount;
         _loc10_.hash = param4;
         super(PATH + param6.urlCred,HttpRequestMethod.POST,_loc10_,param7,param8,param9);
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         super.handleJsonResponseProcessing();
         if(success)
         {
            if(jsonObject)
            {
               this.divergence = jsonObject.divergence;
            }
         }
      }
   }
}
