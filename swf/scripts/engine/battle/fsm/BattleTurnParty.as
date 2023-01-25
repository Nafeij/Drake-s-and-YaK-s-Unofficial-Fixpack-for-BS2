package engine.battle.fsm
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   
   public class BattleTurnParty
   {
       
      
      public var party:IBattleParty;
      
      public var members:Vector.<IBattleEntity>;
      
      public var current:IBattleEntity;
      
      public var _nextIndex:int = 0;
      
      public var logger:ILogger;
      
      public function BattleTurnParty(param1:IBattleParty, param2:ILogger)
      {
         var _loc4_:IBattleEntity = null;
         this.members = new Vector.<IBattleEntity>();
         super();
         this.party = param1;
         this.logger = param2;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numMembers)
         {
            _loc4_ = param1.getMember(_loc3_);
            if(_loc4_.alive && Boolean(_loc4_.enabled) && Boolean(_loc4_.active))
            {
               this.members.push(_loc4_);
            }
            _loc3_++;
         }
      }
      
      public function toString() : String
      {
         return this.party.toString();
      }
      
      public function addEntity(param1:IBattleEntity) : void
      {
         if(this.members.indexOf(param1) >= 0)
         {
            param1.logger.info("BattleTurnParty.addEntity " + param1 + " already present in " + this);
            return;
         }
         if(this._nextIndex < this.members.length)
         {
            this.members.splice(this._nextIndex,0,param1);
         }
         else
         {
            this.members.splice(0,0,param1);
         }
      }
      
      public function removeEntity(param1:IBattleEntity) : void
      {
         var _loc2_:int = this.members.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.members.splice(_loc2_,1);
         }
         if(this.current == param1)
         {
            if(this._nextIndex > 0)
            {
               --this._nextIndex;
            }
            this.current = null;
         }
      }
      
      public function updateFromActiveEntity(param1:IBattleEntity) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:int = this.members.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.current = param1;
            this._nextIndex = (_loc2_ + 1) % this.members.length;
         }
      }
      
      public function next() : IBattleEntity
      {
         if(this._nextIndex < this.members.length)
         {
            this.current = this.members[this._nextIndex];
         }
         else
         {
            this.current = null;
         }
         this._nextIndex = ++this._nextIndex % this.members.length;
         return this.current;
      }
      
      public function pruneDeadEntities() : int
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = int(this.members.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this.members[_loc2_];
            if(!_loc3_ || !_loc3_.alive || !_loc3_.enabled || !_loc3_.active || _loc3_.cleanedup)
            {
               this.logger.info("BattleTurnParty.pruneDeadEntities " + _loc3_ + " from " + this);
               if(_loc2_ < this._nextIndex)
               {
                  --this._nextIndex;
               }
               _loc4_ = _loc2_;
               while(_loc4_ < this.members.length - _loc1_ - 1)
               {
                  this.members[_loc4_] = this.members[_loc4_ + 1];
                  _loc4_++;
               }
               if(_loc3_ == this.current)
               {
                  this.current = null;
               }
               _loc1_++;
            }
            _loc2_--;
         }
         if(_loc1_)
         {
            this.members.splice(this.members.length - _loc1_,_loc1_);
         }
         if(this.members.length == 0 || this._nextIndex >= this.members.length)
         {
            this._nextIndex = 0;
         }
         return _loc1_;
      }
      
      public function getAliveMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:IBattleEntity = null;
         for each(_loc2_ in this.members)
         {
            if(param1 == null)
            {
               param1 = new Vector.<IBattleEntity>();
            }
            if(_loc2_.alive && Boolean(_loc2_.enabled) && Boolean(_loc2_.active))
            {
               param1.push(_loc2_);
            }
         }
         return param1;
      }
      
      public function getFutureCurrent(param1:int) : IBattleEntity
      {
         if(param1 < 0)
         {
            throw new ArgumentError("bad offset");
         }
         if(this.members.length <= 0)
         {
            return null;
         }
         var _loc2_:int = 0;
         if(param1 == 0 && this.members.length > 1)
         {
            if(Boolean(this.current) && this.current.alive)
            {
               return this.current;
            }
            this.current = this.current;
         }
         _loc2_ = this._nextIndex + param1 - 1;
         if(_loc2_ < 0)
         {
            _loc2_ += this.members.length;
         }
         _loc2_ %= this.members.length;
         return this.members[_loc2_];
      }
      
      protected function debug_spewMembers() : void
      {
         this.current.logger.debug("############################");
         this.current.logger.debug("_nextIndex = " + this._nextIndex);
         var _loc1_:int = 0;
         while(_loc1_ < this.members.length)
         {
            this.current.logger.debug("[" + _loc1_ + "] id=" + this.members[_loc1_].id);
            _loc1_++;
         }
      }
      
      public function bumpToNext(param1:IBattleEntity) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = this.members.indexOf(param1);
         if(_loc2_ != -1 && this._nextIndex < this.members.length)
         {
            this.members.splice(_loc2_,1);
            _loc3_ = this.members.indexOf(this.current);
            this._nextIndex = (_loc3_ + 1) % (this.members.length + 1);
            if(this._nextIndex < this.members.length)
            {
               this.members.splice(this._nextIndex,0,param1);
            }
            else
            {
               this.members.push(param1);
            }
         }
      }
      
      public function moveToLast(param1:IBattleEntity) : void
      {
         var _loc2_:IBattleEntity = this.members[this._nextIndex];
         if(_loc2_ == param1)
         {
            this._nextIndex = (this._nextIndex + 1) % this.members.length;
            return;
         }
         this.moveToBefore(param1,_loc2_);
         _loc2_ = this.members[this._nextIndex];
         if(_loc2_ == param1)
         {
            this._nextIndex = (this._nextIndex + 1) % this.members.length;
         }
      }
      
      public function moveToBefore(param1:IBattleEntity, param2:IBattleEntity) : void
      {
         if(param1 == param2)
         {
            return;
         }
         var _loc3_:int = this.members.indexOf(param1);
         var _loc4_:int = this.members.indexOf(param2);
         if(_loc3_ == _loc4_ - 1)
         {
            return;
         }
         this.members.splice(_loc3_,1);
         if(_loc4_ > _loc3_)
         {
            _loc4_--;
         }
         this.members.splice(_loc4_,0,param1);
      }
   }
}
