package engine.battle.sim
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.ArrayUtil;
   import engine.math.MathUtil;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.stat.model.Stats;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class BattleParty extends EventDispatcher implements IBattleParty
   {
       
      
      private var members:Vector.<IBattleEntity>;
      
      private var _team:String;
      
      private var _type:BattlePartyType;
      
      private var _board:IBattleBoard;
      
      private var _deployed:Boolean;
      
      private var iterator:int;
      
      private var _deployment:String;
      
      private var _isPlayer:Boolean;
      
      private var _isAlly:Boolean;
      
      private var _id:String;
      
      private var _surrendered:Boolean;
      
      private var _partyName:String;
      
      private var _aborted:Boolean;
      
      private var _artifactChargeCount:int;
      
      private var _timer:int;
      
      private var _bonusRenown:int;
      
      private var _trauma:Number = 0;
      
      private var _initialVitality:Number = 0;
      
      private var _vitality:Number = 0;
      
      public function BattleParty(param1:IBattleBoard, param2:String, param3:String, param4:String, param5:String, param6:BattlePartyType, param7:int, param8:Boolean = false)
      {
         this.members = new Vector.<IBattleEntity>();
         super();
         this._partyName = param2;
         this._id = param3;
         this._team = param4;
         this._deployment = param5;
         this._board = param1;
         this._type = param6;
         this._isPlayer = param6 == BattlePartyType.LOCAL;
         this._timer = param7;
         if(!this._isPlayer)
         {
            this._isAlly = this._isAlly;
         }
      }
      
      public function changeDeployment(param1:String) : void
      {
         this._deployment = param1;
      }
      
      public function get partyName() : String
      {
         return this._partyName;
      }
      
      override public function toString() : String
      {
         return this.team + ", type=" + this.type;
      }
      
      public function getAliveMember(param1:int) : IBattleEntity
      {
         var _loc3_:IBattleEntity = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.members)
         {
            if(_loc3_.alive)
            {
               if(_loc2_ == param1)
               {
                  return _loc3_;
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      public function getMemberById(param1:String) : IBattleEntity
      {
         var _loc2_:IBattleEntity = null;
         for each(_loc2_ in this.members)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getMemberByDefId(param1:String) : IBattleEntity
      {
         var _loc2_:IBattleEntity = null;
         for each(_loc2_ in this.members)
         {
            if(_loc2_.def.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getMemberByIdOrDefId(param1:String) : IBattleEntity
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:IBattleEntity = null;
         for each(_loc3_ in this.members)
         {
            if(_loc3_.id == param1)
            {
               return _loc3_;
            }
            if(!_loc2_)
            {
               if(_loc3_.def.id == param1)
               {
                  _loc2_ = _loc3_;
               }
            }
         }
         return _loc2_;
      }
      
      public function getNextDefIdFor(param1:String) : String
      {
         return null;
      }
      
      public function cleanup() : void
      {
         var _loc1_:IBattleEntity = null;
         for each(_loc1_ in this.members)
         {
            if(_loc1_.party == this)
            {
               _loc1_.party = null;
            }
            this._removeListeners(_loc1_);
         }
         this.members = null;
         this._board = null;
      }
      
      public function addMember(param1:IBattleEntity) : void
      {
         var _loc2_:Number = NaN;
         param1.party = this;
         this.members.push(param1);
         this._addListeners(param1);
         if(this._deployed || !param1.isPlayer)
         {
            _loc2_ = this._computeVitalityUnit(param1);
            if(_loc2_)
            {
               this._initialVitality += _loc2_;
               this.setVitality(this._vitality + _loc2_);
            }
         }
      }
      
      public function removeMember(param1:IBattleEntity) : void
      {
         param1.party = null;
         var _loc2_:int = this.members.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.members.splice(_loc2_,1);
         }
         this._removeListeners(param1);
      }
      
      private function _addListeners(param1:IBattleEntity) : void
      {
         var _loc2_:Stats = param1.stats;
         var _loc3_:Stat = _loc2_.getStat(StatType.STRENGTH);
         var _loc4_:Stat = _loc2_.getStat(StatType.ARMOR);
         if(_loc3_)
         {
            _loc3_.addEventListener(StatEvent.BASE_CHANGE,this.statChangeHandler);
         }
         if(_loc4_)
         {
            _loc4_.addEventListener(StatEvent.BASE_CHANGE,this.statChangeHandler);
         }
      }
      
      private function _removeListeners(param1:IBattleEntity) : void
      {
         var _loc2_:Stats = param1.stats;
         var _loc3_:Stat = _loc2_.getStat(StatType.STRENGTH);
         var _loc4_:Stat = _loc2_.getStat(StatType.ARMOR);
         if(_loc3_)
         {
            _loc3_.removeEventListener(StatEvent.BASE_CHANGE,this.statChangeHandler);
         }
         if(_loc4_)
         {
            _loc4_.removeEventListener(StatEvent.BASE_CHANGE,this.statChangeHandler);
         }
      }
      
      private function statChangeHandler(param1:Event) : void
      {
         var _loc2_:Number = this.computeVitality();
         this.setVitality(_loc2_);
      }
      
      public function randomizeOrder() : void
      {
         var _loc2_:int = 0;
         var _loc3_:IBattleEntity = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.members.length)
         {
            _loc2_ = this.board.scene.context.rng.nextMinMax(_loc1_,this.members.length - 1);
            _loc3_ = this.members[_loc2_];
            this.members[_loc2_] = this.members[_loc1_];
            this.members[_loc1_] = _loc3_;
            _loc1_++;
         }
      }
      
      public function resetIterator() : void
      {
         this.iterator = 0;
      }
      
      public function next() : IBattleEntity
      {
         if(this.iterator < this.members.length)
         {
            return this.members[this.iterator++];
         }
         return null;
      }
      
      public function set deployed(param1:Boolean) : void
      {
         var _loc3_:IBattleEntity = null;
         if(this._deployed == param1)
         {
            return;
         }
         if(param1)
         {
            for each(_loc3_ in this.members)
            {
               if(!_loc3_.deploymentReady)
               {
                  throw new IllegalOperationError("Cannot deploy -- " + _loc3_ + " is not ready");
               }
            }
         }
         var _loc2_:Number = this.computeVitality();
         this._initialVitality = _loc2_;
         this._vitality = _loc2_;
         this._trauma = 0;
         this._deployed = param1;
         dispatchEvent(new BattlePartyEvent(BattlePartyEvent.DEPLOYED));
      }
      
      public function undeployAll() : void
      {
         var _loc1_:IBattleEntity = null;
         for each(_loc1_ in this.members)
         {
            _loc1_.deploymentReady = false;
         }
      }
      
      public function recomputeVitality() : void
      {
         this._vitality = -1;
         this._initialVitality = this.computeVitality();
         this.setVitality(this._initialVitality);
      }
      
      private function setVitality(param1:Number) : void
      {
         var _loc2_:BattleBoard = this._board as BattleBoard;
         if(Boolean(_loc2_) && _loc2_.suppressPartyVitality)
         {
            return;
         }
         if(param1 != this._vitality)
         {
            this._vitality = param1;
            if(this._initialVitality)
            {
               this._trauma = (this._initialVitality - this._vitality) / this._initialVitality;
               this._trauma = Math.min(1,Math.max(0,this._trauma));
            }
            dispatchEvent(new BattlePartyEvent(BattlePartyEvent.TRAUMA));
            _loc2_.handleTraumaChanged(this);
         }
      }
      
      private function computeVitality() : Number
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in this.members)
         {
            _loc1_ += this._computeVitalityUnit(_loc2_);
         }
         return _loc1_;
      }
      
      private function _computeVitalityUnit(param1:IBattleEntity) : Number
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 && param1.alive && param1.includeVitality)
         {
            _loc2_ = int(param1.stats.getBase(StatType.STRENGTH));
            _loc3_ = int(param1.stats.getBase(StatType.ARMOR));
            return _loc2_ + _loc3_ * 0.5;
         }
         return 0;
      }
      
      public function get deployed() : Boolean
      {
         return this._deployed;
      }
      
      public function get numMembers() : int
      {
         return !!this.members ? int(this.members.length) : 0;
      }
      
      public function get numActive() : int
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.members)
         {
            if(Boolean(_loc2_.enabled) && Boolean(_loc2_.active))
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function getMember(param1:int) : IBattleEntity
      {
         return this.members[param1];
      }
      
      public function getMemberIndex(param1:IBattleEntity) : int
      {
         return this.members.indexOf(param1);
      }
      
      public function get board() : IBattleBoard
      {
         return this._board;
      }
      
      public function get team() : String
      {
         return this._team;
      }
      
      public function get type() : BattlePartyType
      {
         return this._type;
      }
      
      public function get deployment() : String
      {
         return this._deployment;
      }
      
      public function get isPlayer() : Boolean
      {
         return this._isPlayer;
      }
      
      public function get isEnemy() : Boolean
      {
         return !this._isPlayer && !this._isAlly;
      }
      
      public function get isAlly() : Boolean
      {
         return this._isAlly;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get surrendered() : Boolean
      {
         return this._surrendered;
      }
      
      public function set surrendered(param1:Boolean) : void
      {
         this._surrendered = param1;
      }
      
      public function getAllMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:IBattleEntity = null;
         if(!param1)
         {
            param1 = new Vector.<IBattleEntity>();
         }
         for each(_loc2_ in this.members)
         {
            if(_loc2_.alive)
            {
               param1.push(_loc2_);
            }
         }
         return param1;
      }
      
      public function getDeadMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:IBattleEntity = null;
         if(!param1)
         {
            param1 = new Vector.<IBattleEntity>();
         }
         for each(_loc2_ in this.members)
         {
            if(!_loc2_.alive)
            {
               param1.push(_loc2_);
            }
         }
         return param1;
      }
      
      public function get aborted() : Boolean
      {
         return this._aborted;
      }
      
      public function set aborted(param1:Boolean) : void
      {
         this._aborted = param1;
      }
      
      public function get artifactChargeCount() : int
      {
         return this._artifactChargeCount;
      }
      
      public function set artifactChargeCount(param1:int) : void
      {
         param1 = Math.max(0,Math.min(param1,this._board.artifactMaxUseCount));
         if(this._artifactChargeCount == param1)
         {
            return;
         }
         var _loc2_:int = this._artifactChargeCount;
         this._artifactChargeCount = param1;
         dispatchEvent(new BattlePartyHornEvent(BattlePartyHornEvent.HORN,_loc2_));
      }
      
      public function get timer() : int
      {
         return this._timer;
      }
      
      public function get vitality() : Number
      {
         return this._vitality;
      }
      
      public function get initialVitality() : Number
      {
         return this._initialVitality;
      }
      
      public function get trauma() : Number
      {
         return this._trauma;
      }
      
      public function get numAlive() : int
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.members)
         {
            if(Boolean(_loc2_.enabled) && Boolean(_loc2_.active) && _loc2_.alive)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get bonusRenown() : int
      {
         return this._bonusRenown;
      }
      
      public function set bonusRenown(param1:int) : void
      {
         this._bonusRenown = param1;
      }
      
      public function getMemberNearestCentroid(param1:Boolean) : IBattleEntity
      {
         var _loc4_:IBattleEntity = null;
         var _loc5_:IBattleEntity = null;
         var _loc6_:int = 0;
         var _loc2_:Point = this.getCentroid();
         var _loc3_:Number = Number.MAX_VALUE;
         for each(_loc5_ in this.members)
         {
            if(Boolean(_loc5_.enabled) && Boolean(_loc5_.active))
            {
               if(!(_loc5_.deploymentFinalized && !param1))
               {
                  _loc6_ = MathUtil.distanceSquared(_loc5_.x,_loc5_.y,_loc2_.x,_loc2_.y);
                  if(_loc6_ < _loc3_)
                  {
                     _loc3_ = _loc6_;
                     _loc4_ = _loc5_;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public function getCentroid() : Point
      {
         var _loc3_:IBattleEntity = null;
         var _loc1_:Point = new Point();
         var _loc2_:int = 0;
         for each(_loc3_ in this.members)
         {
            if(Boolean(_loc3_.enabled) && Boolean(_loc3_.active))
            {
               _loc1_.x += _loc3_.x;
               _loc1_.y += _loc3_.y;
               _loc2_++;
            }
         }
         if(_loc2_)
         {
            _loc1_.x /= _loc2_;
            _loc1_.y /= _loc2_;
         }
         return _loc1_;
      }
      
      public function getNumMembersNotDeploymentFinalized() : int
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.members)
         {
            if(Boolean(_loc2_.enabled) && Boolean(_loc2_.active) && !_loc2_.deploymentFinalized)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get rankMin() : int
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.members)
         {
            if(_loc2_.stats)
            {
               if(_loc1_ == 0)
               {
                  _loc1_ = int(_loc2_.stats.rank);
               }
               else
               {
                  _loc1_ = Math.min(_loc1_,_loc2_.stats.rank);
               }
            }
         }
         return _loc1_;
      }
      
      public function get rankMax() : int
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.members)
         {
            if(_loc2_.stats)
            {
               _loc1_ = Math.max(_loc1_,_loc2_.stats.rank);
            }
         }
         return _loc1_;
      }
      
      public function visit(param1:Function) : void
      {
         var _loc2_:IBattleEntity = null;
         for each(_loc2_ in this.members)
         {
            param1(_loc2_);
         }
      }
      
      public function getDebugString() : String
      {
         var _loc3_:IBattleEntity = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < this.members.length)
         {
            _loc3_ = this.members[_loc2_];
            _loc1_ += _loc2_.toString() + "   " + _loc3_.getSummaryLine() + "\n";
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function movePartyMember(param1:IBattleEntity, param2:int) : void
      {
         var _loc3_:int = this.members.indexOf(param1);
         if(_loc3_ < 0)
         {
            throw new ArgumentError("ent " + param1 + " is not in party " + this);
         }
         if(_loc3_ == param2)
         {
            return;
         }
         this.members.splice(_loc3_,1);
         if(param2 > this.members.length)
         {
            param2 = int(this.members.length);
         }
         ArrayUtil.insertAt(this.members,param2,param1);
      }
   }
}
