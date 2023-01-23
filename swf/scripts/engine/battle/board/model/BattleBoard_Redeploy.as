package engine.battle.board.model
{
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.saga.ISaga;
   import flash.errors.IllegalOperationError;
   
   public class BattleBoard_Redeploy
   {
      
      public static const MAX_PARTY:int = 6;
       
      
      public var board:IBattleBoard;
      
      public var saga:ISaga;
      
      public var roster:IEntityListDef;
      
      public var enabled:Boolean;
      
      private var _battleEntityPool:Vector.<IBattleEntity>;
      
      public function BattleBoard_Redeploy(param1:IBattleBoard)
      {
         this._battleEntityPool = new Vector.<IBattleEntity>();
         super();
         this.board = param1;
         this.saga = param1.getSaga();
         this.roster = this.saga.roster;
      }
      
      public function insertPartyMember(param1:String, param2:int) : void
      {
         var _loc6_:IBattleEntity = null;
         if(!this.enabled)
         {
            throw new IllegalOperationError("Redeployment not enabled");
         }
         var _loc3_:IBattleParty = this.board.getPartyById("0");
         var _loc4_:IBattleEntity = _loc3_.getMemberByDefId(param1);
         if(_loc4_)
         {
            _loc3_.movePartyMember(_loc4_,param2);
            return;
         }
         var _loc5_:int = 0;
         for each(_loc6_ in _loc3_.getAllMembers(null))
         {
            if(_loc6_.alive)
            {
               if(_loc6_.spawnedCaster == null)
               {
                  _loc5_++;
               }
            }
         }
         if(_loc5_ >= MAX_PARTY)
         {
            this.removePartyMemberAt(param2);
         }
         this.addPartyMember(param1,param2);
      }
      
      public function swapPartyMembers(param1:String, param2:String) : void
      {
         if(!this.enabled)
         {
            throw new IllegalOperationError("Redeployment not enabled");
         }
         var _loc3_:IBattleParty = this.board.getPartyById("0");
         var _loc4_:IBattleEntity = _loc3_.getMemberByDefId(param2);
         var _loc5_:IBattleEntity = _loc3_.getMemberByDefId(param1);
         if(!_loc4_ || !_loc5_)
         {
            throw new IllegalOperationError("swapPartyMembers attempted with one or more non-party member entities");
         }
         var _loc6_:int = _loc3_.getMemberIndex(_loc5_);
         var _loc7_:int = _loc3_.getMemberIndex(_loc4_);
         if(_loc6_ > _loc7_)
         {
            _loc3_.movePartyMember(_loc5_,_loc7_);
            _loc3_.movePartyMember(_loc4_,_loc6_);
         }
         else
         {
            _loc3_.movePartyMember(_loc4_,_loc6_);
            _loc3_.movePartyMember(_loc5_,_loc7_);
         }
      }
      
      public function getBattleEntity(param1:IEntityDef) : IBattleEntity
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._battleEntityPool.length)
         {
            if(param1.id == this._battleEntityPool[_loc2_].def.id)
            {
               return this._battleEntityPool[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function addPartyMember(param1:String, param2:int) : void
      {
         if(!this.enabled)
         {
            throw new IllegalOperationError("Redeployment not enabled");
         }
         var _loc3_:IEntityDef = this.roster.getEntityDefById(param1);
         if(!_loc3_)
         {
            throw new ArgumentError("Bad entity does not exist in roster: [" + param1 + "]");
         }
         var _loc4_:IBattleEntity = null;
         var _loc5_:int = 0;
         while(_loc5_ < this._battleEntityPool.length)
         {
            if(this._battleEntityPool[_loc5_].def == _loc3_)
            {
               _loc4_ = this._battleEntityPool[_loc5_];
               this._battleEntityPool.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
         if(!_loc4_)
         {
            _loc4_ = this.board.addPlayerPartyMember(_loc3_,0,null,null,true);
         }
         else
         {
            this.board.addPlayerPartyMemberBattleEntity(_loc4_,0);
         }
         this.board.autoDeployPartyById(_loc4_.party.id);
         var _loc6_:IBattleFsm = this.board.fsm;
         _loc6_.order.addEntity(_loc4_);
         if(param2 >= 0 && param2 < MAX_PARTY)
         {
            _loc4_.party.movePartyMember(_loc4_,param2);
         }
      }
      
      public function removePartyMemberById(param1:String) : void
      {
         if(!this.enabled)
         {
            throw new IllegalOperationError("Redeployment not enabled");
         }
         var _loc2_:IBattleParty = this.board.getPartyById("0");
         var _loc3_:IBattleEntity = _loc2_.getMemberByIdOrDefId(param1);
         if(!_loc3_)
         {
            return;
         }
         this.removePartyMember(_loc3_);
      }
      
      private function removePartyMemberAt(param1:int) : void
      {
         if(!this.enabled)
         {
            throw new IllegalOperationError("Redeployment not enabled");
         }
         var _loc2_:IBattleParty = this.board.getPartyById("0");
         var _loc3_:IBattleEntity = _loc2_.getAliveMember(param1);
         if(!_loc3_)
         {
            throw new ArgumentError("Invalid slotnum " + param1 + " for " + _loc2_);
         }
         this.removePartyMember(_loc3_);
      }
      
      private function removePartyMember(param1:IBattleEntity) : void
      {
         var _loc3_:IBattleEntity = null;
         if(!param1)
         {
            throw new ArgumentError("null entity for removal from");
         }
         var _loc2_:IBattleFsm = this.board.fsm;
         _loc2_.order.removeEntity(param1);
         _loc2_.interact = _loc2_.order.activeEntity;
         this.board.removeEntity(param1);
         for each(_loc3_ in this._battleEntityPool)
         {
            if(_loc3_ == param1)
            {
               return;
            }
         }
         this._battleEntityPool.push(param1);
      }
   }
}
