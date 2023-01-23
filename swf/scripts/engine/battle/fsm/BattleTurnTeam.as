package engine.battle.fsm
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   
   public class BattleTurnTeam
   {
       
      
      public var turnParties:Vector.<BattleTurnParty>;
      
      public var currents:Vector.<IBattleEntity>;
      
      public var team:String;
      
      public var logger:ILogger;
      
      public function BattleTurnTeam(param1:String, param2:ILogger)
      {
         this.turnParties = new Vector.<BattleTurnParty>();
         this.currents = new Vector.<IBattleEntity>();
         super();
         this.team = param1;
         this.logger = param2;
      }
      
      public function updateFromActiveEntity(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnParty = null;
         if(!param1)
         {
            return;
         }
         for each(_loc2_ in this.turnParties)
         {
            if(_loc2_.party == param1.party)
            {
               _loc2_.updateFromActiveEntity(param1);
               break;
            }
         }
      }
      
      public function toString() : String
      {
         return this.team;
      }
      
      public function addParty(param1:IBattleParty) : void
      {
         var _loc2_:BattleTurnParty = null;
         if(param1.team != this.team)
         {
            throw new ArgumentError("Invalid team for party " + param1);
         }
         for each(_loc2_ in this.turnParties)
         {
            if(_loc2_.party == param1)
            {
               throw new ArgumentError("Already added party " + param1);
            }
         }
         _loc2_ = new BattleTurnParty(param1,this.logger);
         this.turnParties.push(_loc2_);
      }
      
      public function removeParty(param1:IBattleParty) : void
      {
         var _loc3_:BattleTurnParty = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.turnParties.length)
         {
            _loc3_ = this.turnParties[_loc2_];
            if(_loc3_.party == param1)
            {
               this.turnParties.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         this.removePartyFromCurrents(param1);
      }
      
      private function removePartyFromCurrents(param1:IBattleParty) : void
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1.numMembers)
         {
            _loc3_ = param1.getMember(_loc2_);
            _loc4_ = this.currents.indexOf(_loc3_);
            if(_loc4_ >= 0)
            {
               this.currents.splice(_loc4_,1);
            }
            _loc2_++;
         }
      }
      
      public function next() : Vector.<IBattleEntity>
      {
         var _loc1_:BattleTurnParty = null;
         var _loc2_:IBattleEntity = null;
         this.currents.splice(0,this.currents.length);
         for each(_loc1_ in this.turnParties)
         {
            _loc2_ = _loc1_.next();
            if(_loc2_)
            {
               this.currents.push(_loc2_);
            }
         }
         return this.currents;
      }
      
      public function getAllTeamMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:BattleTurnParty = null;
         if(!param1)
         {
            param1 = new Vector.<IBattleEntity>();
         }
         for each(_loc2_ in this.turnParties)
         {
            _loc2_.party.getAllMembers(param1);
         }
         return param1;
      }
      
      public function getAliveMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:BattleTurnParty = null;
         for each(_loc2_ in this.turnParties)
         {
            param1 = _loc2_.getAliveMembers(param1);
         }
         return param1;
      }
      
      public function pruneDeadEntities() : int
      {
         var _loc2_:BattleTurnParty = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.turnParties)
         {
            _loc1_ += _loc2_.pruneDeadEntities();
         }
         return _loc1_;
      }
      
      protected function battleTurnPartyForEntity(param1:IBattleEntity) : BattleTurnParty
      {
         var _loc2_:BattleTurnParty = null;
         var _loc3_:IBattleEntity = null;
         for each(_loc2_ in this.turnParties)
         {
            for each(_loc3_ in _loc2_.members)
            {
               if(param1 == _loc3_)
               {
                  return _loc2_;
               }
            }
         }
         throw new IllegalOperationError("Could not find BattleTurnParty for IBattleEntity");
      }
      
      public function bumpToNext(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnParty = this.battleTurnPartyForEntity(param1);
         if(_loc2_ != null)
         {
            _loc2_.bumpToNext(param1);
         }
      }
      
      public function moveToLast(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnParty = this.battleTurnPartyForEntity(param1);
         if(_loc2_ != null)
         {
            _loc2_.moveToLast(param1);
         }
      }
      
      public function moveToBefore(param1:IBattleEntity, param2:IBattleEntity) : void
      {
         var _loc3_:BattleTurnParty = this.battleTurnPartyForEntity(param1);
         if(_loc3_ != null)
         {
            _loc3_.moveToBefore(param1,param2);
         }
      }
      
      public function addEntity(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnParty = null;
         this.currents.splice(0,0,param1);
         for each(_loc2_ in this.turnParties)
         {
            if(_loc2_.party == param1.party)
            {
               _loc2_.addEntity(param1);
            }
         }
      }
      
      public function removeEntity(param1:IBattleEntity) : void
      {
         var _loc3_:BattleTurnParty = null;
         var _loc2_:int = this.currents.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.currents.splice(_loc2_,1);
         }
         for each(_loc3_ in this.turnParties)
         {
            if(_loc3_.party == param1.party)
            {
               _loc3_.removeEntity(param1);
            }
         }
      }
   }
}
