package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.IDebugStringable;
   import engine.entity.def.IEntityListStatProvider;
   import engine.math.Rng;
   import engine.saga.SagaBucket;
   import engine.saga.SagaBucketEnt;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class BattleBoardBucketSpawner
   {
       
      
      public var logger:ILogger;
      
      public var owner:IDebugStringable;
      
      public var cast:IEntityListStatProvider;
      
      public var rng:Rng;
      
      public var counts:Dictionary;
      
      public var outstandingCountRequirements:Dictionary;
      
      public var sb:SagaBucket;
      
      public function BattleBoardBucketSpawner(param1:SagaBucket, param2:IEntityListStatProvider, param3:Rng, param4:IDebugStringable, param5:ILogger)
      {
         this.counts = new Dictionary();
         super();
         this.cast = param2;
         this.rng = param3;
         this.owner = param4;
         this.logger = param5;
         this.sb = param1;
         this.outstandingCountRequirements = ArrayUtil.combineDictionaries(param1.minRequirements,this.outstandingCountRequirements);
      }
      
      public function cleanup() : void
      {
         this.cast = null;
         this.rng = this.rng;
         this.owner = null;
         this.logger = null;
         this.counts = null;
         this.outstandingCountRequirements = null;
         this.sb = null;
      }
      
      public function toDebugString() : String
      {
         return this.owner.toDebugString();
      }
      
      public function get hasOutstandingCountRequirements() : Boolean
      {
         var _loc1_:int = 0;
         if(this.outstandingCountRequirements)
         {
            for each(_loc1_ in this.outstandingCountRequirements)
            {
               if(_loc1_ > 0)
               {
                  return true;
               }
            }
            this.outstandingCountRequirements = null;
         }
         return false;
      }
      
      private function filterSpawnerPossibilities(param1:int) : Vector.<SpawnPossibility>
      {
         var _loc3_:SagaBucketEnt = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:SpawnPossibility = null;
         var _loc2_:Vector.<SpawnPossibility> = new Vector.<SpawnPossibility>();
         var _loc4_:Number = 0;
         for each(_loc3_ in this.sb._ents)
         {
            _loc5_ = _loc3_.entityId;
            _loc6_ = int(this.counts[_loc5_]);
            if(_loc3_.max)
            {
               if(_loc6_ >= _loc3_.max)
               {
                  continue;
               }
            }
            _loc7_ = this.cast.getEntityStatValue(_loc5_,StatType.RANK);
            if(_loc7_ <= 0)
            {
               this.logger.error("BattleBoard " + this.toDebugString() + " Invalid bucket entity [" + _loc3_ + "] for bucket [" + this.sb.name + "]");
            }
            else
            {
               if(_loc7_ <= param1)
               {
                  _loc8_ = new SpawnPossibility(_loc3_,_loc7_);
                  _loc2_.push(_loc8_);
               }
               if(_loc3_.min)
               {
                  if(_loc6_ < _loc3_.min)
                  {
                     if(!_loc8_)
                     {
                        _loc8_ = new SpawnPossibility(_loc3_,_loc7_);
                     }
                     _loc2_.splice(0,_loc2_.length);
                     _loc2_.push(_loc8_);
                     return _loc2_;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function computeWeightSum(param1:Vector.<SpawnPossibility>) : Number
      {
         var _loc3_:SpawnPossibility = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in param1)
         {
            _loc2_ += _loc3_.weight;
         }
         return _loc2_;
      }
      
      public function findMinRankInBucket() : int
      {
         var _loc2_:SagaBucketEnt = null;
         var _loc3_:int = 0;
         var _loc1_:int = int.MAX_VALUE;
         for each(_loc2_ in this.sb._ents)
         {
            _loc3_ = this.cast.getEntityStatValue(_loc2_.entityId,StatType.RANK);
            if(_loc3_ < _loc1_)
            {
               _loc1_ = _loc3_;
            }
         }
         return _loc1_;
      }
      
      public function pickFromBucket(param1:int) : String
      {
         var _loc6_:SpawnPossibility = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc2_:Vector.<SpawnPossibility> = this.filterSpawnerPossibilities(param1);
         if(!_loc2_ || !_loc2_.length)
         {
            return null;
         }
         var _loc3_:Number = this.computeWeightSum(_loc2_);
         var _loc4_:Number = this.rng.nextNumber();
         _loc4_ *= _loc3_;
         var _loc5_:Number = 0;
         for each(_loc6_ in _loc2_)
         {
            _loc5_ += _loc6_.weight;
            if(_loc5_ >= _loc4_)
            {
               _loc7_ = _loc6_.sbe.entityId;
               _loc8_ = int(this.counts[_loc7_]);
               _loc8_++;
               this.counts[_loc7_] = _loc8_;
               this._checkOutstandingCount(_loc7_,_loc8_);
               return _loc7_;
            }
         }
         return null;
      }
      
      private function _checkOutstandingCount(param1:String, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = this.outstandingCountRequirements[param1];
         if(_loc3_ != undefined)
         {
            _loc4_ = _loc3_;
            _loc4_ -= param2;
            if(_loc4_ <= 0)
            {
               delete this.outstandingCountRequirements[param1];
            }
            else
            {
               this.outstandingCountRequirements[param1] = _loc4_;
            }
         }
      }
   }
}

import engine.saga.SagaBucketEnt;

class SpawnPossibility
{
    
   
   public var sbe:SagaBucketEnt;
   
   public var id:int;
   
   public var weight:Number = 0;
   
   public var rank:int;
   
   public function SpawnPossibility(param1:SagaBucketEnt, param2:int)
   {
      super();
      this.sbe = param1;
      this.id = this.id;
      this.weight = param1.weight;
      this.rank = param2;
      if(!this.weight)
      {
         this.weight = 1;
      }
   }
}
