package engine.battle.fsm.txn
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import engine.tile.TileLocationVars;
   import flash.errors.IllegalOperationError;
   
   public class BattleTxnDeploySend extends BattleTxn_Base
   {
      
      public static const PATH:String = "services/battle/deploy";
       
      
      public var party:IBattleParty;
      
      public function BattleTxnDeploySend(param1:String, param2:int, param3:IBattleParty, param4:Credentials, param5:Function, param6:BattleFsm, param7:ILogger)
      {
         var _loc10_:IBattleEntity = null;
         this.party = param3;
         this.checkParty(param3);
         var _loc8_:Object = {
            "battle_id":param1,
            "tiles":[]
         };
         var _loc9_:int = 0;
         while(_loc9_ < param3.numMembers)
         {
            _loc10_ = param3.getMember(_loc9_);
            _loc8_.tiles.push(TileLocationVars.save(_loc10_.tile.location));
            _loc9_++;
         }
         super(PATH + param4.urlCred,HttpRequestMethod.POST,_loc8_,param5,param6,param7);
      }
      
      private function checkParty(param1:IBattleParty) : void
      {
         var _loc3_:IBattleEntity = null;
         if(!param1.deployed)
         {
            throw new ArgumentError("Trying to pull a fast one, eh?");
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.numMembers)
         {
            _loc3_ = param1.getMember(_loc2_);
            if(!_loc3_.tile)
            {
               throw new IllegalOperationError("Claimed to be deployed, but null tile");
            }
            _loc2_++;
         }
      }
   }
}
