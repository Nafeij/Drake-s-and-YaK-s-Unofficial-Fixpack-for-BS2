package engine.stat.model
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class Stats
   {
      
      public static const userChangedStatTypes:Array = [StatType.STRENGTH,StatType.ARMOR,StatType.WILLPOWER,StatType.EXERTION,StatType.ARMOR_BREAK];
      
      private static var _userChangedStatDict:Dictionary;
       
      
      public var _statsByType:Dictionary;
      
      private var _stats:Vector.<Stat>;
      
      private var _provider:IStatsProvider;
      
      private var locked:Boolean = true;
      
      public function Stats(param1:IStatsProvider, param2:Boolean)
      {
         this._statsByType = new Dictionary();
         this._stats = new Vector.<Stat>();
         super();
         this._provider = param1;
         this.locked = param2;
      }
      
      public static function isUserChangedStat(param1:StatType) : Boolean
      {
         var _loc2_:StatType = null;
         if(!_userChangedStatDict)
         {
            _userChangedStatDict = new Dictionary();
            for each(_loc2_ in userChangedStatTypes)
            {
               _userChangedStatDict[_loc2_] = true;
            }
         }
         return _userChangedStatDict[param1];
      }
      
      public static function getResistanceType(param1:StatType) : StatType
      {
         if(param1 == StatType.STRENGTH)
         {
            return StatType.RESIST_STRENGTH;
         }
         if(param1 == StatType.ARMOR)
         {
            return StatType.RESIST_ARMOR;
         }
         if(param1 == StatType.WILLPOWER)
         {
            return StatType.RESIST_WILLPOWER;
         }
         return null;
      }
      
      public function toDebugString() : String
      {
         var _loc2_:Stat = null;
         var _loc1_:String = "";
         for each(_loc2_ in this._stats)
         {
            _loc1_ += StringUtil.padRight(_loc2_.type.name," ",12);
            _loc1_ += "=" + StringUtil.padLeft(_loc2_.value.toString()," ",2) + " / " + StringUtil.padLeft(_loc2_.base.toString()," ",2);
            _loc1_ += " mod=" + StringUtil.numberWithSign(_loc2_.modDelta,0) + " orig=" + _loc2_.original + "\n";
         }
         return _loc1_;
      }
      
      public function synchronizeFrom(param1:Stats) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Stat = null;
         var _loc4_:Stat = null;
         var _loc5_:int = 0;
         var _loc6_:Stat = null;
         this._provider = param1._provider;
         this.locked = param1.locked;
         _loc2_ = 0;
         while(_loc2_ < param1._stats.length)
         {
            _loc3_ = param1._stats[_loc2_];
            if(_loc2_ >= this._stats.length)
            {
               this.internalAddStat(_loc3_.clone());
            }
            else
            {
               _loc4_ = this._stats[_loc2_];
               if(_loc4_.type == _loc3_.type)
               {
                  _loc4_.synchronizeFrom(_loc3_);
               }
               else
               {
                  _loc4_ = this._statsByType[_loc3_.type];
                  if(_loc4_)
                  {
                     _loc4_.synchronizeFrom(_loc3_);
                     _loc5_ = this._stats.indexOf(_loc4_);
                     this._stats.splice(_loc5_,1);
                     this._stats.splice(_loc2_,0,_loc4_);
                  }
                  else
                  {
                     _loc4_ = _loc3_.clone();
                     this._stats.splice(_loc2_,0,_loc4_);
                     this._statsByType[_loc4_.type] = _loc4_;
                     _loc4_.provider = this.provider;
                  }
               }
            }
            _loc2_++;
         }
         while(this._stats.length > param1._stats.length)
         {
            _loc6_ = this._stats[param1._stats.length];
            this.removeStat(_loc6_.type);
         }
      }
      
      public function testEquals(param1:Stats, param2:ILogger) : Boolean
      {
         var _loc4_:Stat = null;
         var _loc5_:Stat = null;
         if(this._stats.length > param1._stats.length)
         {
            param2.info("Stats length mismatched");
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._stats.length)
         {
            _loc4_ = this._stats[_loc3_];
            _loc5_ = param1._stats[_loc3_];
            if(!_loc4_.testEquals(_loc5_,param2))
            {
               param2.info("Stat " + _loc4_ + " != " + _loc5_);
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function get rank() : int
      {
         return this.getValue(StatType.RANK);
      }
      
      public function set rank(param1:int) : void
      {
         this.setBase(StatType.RANK,param1);
      }
      
      public function get titleRank() : int
      {
         return this.getValue(StatType.TITLE_RANK);
      }
      
      public function set titleRank(param1:int) : void
      {
         this.setBase(StatType.TITLE_RANK,param1);
      }
      
      public function clone(param1:IStatsProvider) : Stats
      {
         var _loc3_:* = null;
         var _loc2_:Stats = new Stats(param1,this.locked);
         for(_loc3_ in this._stats)
         {
            _loc2_.internalAddStat(this._stats[_loc3_].clone());
         }
         return _loc2_;
      }
      
      public function get provider() : IStatsProvider
      {
         return this._provider;
      }
      
      public function removeStat(param1:StatType) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Stat = this._statsByType[param1];
         if(_loc2_)
         {
            _loc3_ = this._stats.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               this._stats.splice(_loc3_,1);
            }
         }
         delete this._statsByType[param1];
      }
      
      public function getStat(param1:StatType, param2:Boolean = true) : Stat
      {
         var _loc3_:Stat = this._statsByType[param1];
         if(!_loc3_ && param2)
         {
            throw new ArgumentError("No such stat: " + param1 + " on " + this._provider);
         }
         return _loc3_;
      }
      
      public function getBase(param1:StatType, param2:int = 0) : int
      {
         var _loc3_:Stat = this.getStat(param1,false);
         if(_loc3_)
         {
            return _loc3_.base;
         }
         return param2;
      }
      
      public function getValue(param1:StatType, param2:int = 0) : int
      {
         var _loc3_:Stat = this.getStat(param1,false);
         if(_loc3_)
         {
            return _loc3_.value;
         }
         return param2;
      }
      
      public function GetMaxAbilityLevel(param1:StatType) : int
      {
         return this.getValue(param1);
      }
      
      public function GetTotalUpgrades(param1:StatRanges) : int
      {
         var _loc3_:StatType = null;
         var _loc4_:StatRange = null;
         var _loc5_:Stat = null;
         var _loc2_:int = 0;
         for each(_loc3_ in userChangedStatTypes)
         {
            _loc4_ = param1.getStatRange(_loc3_);
            _loc5_ = this.getStat(_loc3_,false);
            if(Boolean(_loc5_) && Boolean(_loc4_))
            {
               _loc2_ += this.getValue(_loc3_) - _loc4_.min;
            }
         }
         return _loc2_;
      }
      
      public function get totalPower() : int
      {
         return this.getValue(StatType.RANK) - 1;
      }
      
      private function getSinglePower(param1:StatType, param2:StatRanges) : int
      {
         return this.getValue(param1) - param2.getStatRange(param1).min;
      }
      
      public function setBase(param1:StatType, param2:int) : void
      {
         this.addStat(param1,param2);
      }
      
      public function changeBase(param1:StatType, param2:int, param3:int) : void
      {
         var _loc4_:int = this.getBase(param1,0);
         var _loc5_:int = Math.max(param3,_loc4_ + param2);
         this.setBase(param1,_loc5_);
      }
      
      public function getStatByIndex(param1:int) : Stat
      {
         return this._stats[param1];
      }
      
      public function get numStats() : int
      {
         return this._stats.length;
      }
      
      public function hasStat(param1:StatType) : Boolean
      {
         return this._statsByType[param1] != null;
      }
      
      public function addStat(param1:StatType, param2:int) : Stat
      {
         if(!param1)
         {
            throw new ArgumentError("null stat type");
         }
         var _loc3_:Stat = this.getStat(param1,false);
         if(_loc3_)
         {
            _loc3_.base = param2;
         }
         else
         {
            _loc3_ = new Stat(param1,param2,this.locked);
            this.internalAddStat(_loc3_);
         }
         return _loc3_;
      }
      
      private function internalAddStat(param1:Stat) : void
      {
         if(this.hasStat(param1.type))
         {
            throw new ArgumentError("already hasStat");
         }
         this._stats.push(param1);
         this._statsByType[param1.type] = param1;
         param1.provider = this.provider;
      }
      
      public function getResistanceValue(param1:StatType) : int
      {
         var _loc2_:StatType = getResistanceType(param1);
         if(_loc2_)
         {
            return this.getValue(_loc2_,0);
         }
         return 0;
      }
      
      public function get exertionMoveBonusMax() : int
      {
         var _loc1_:int = this.getValue(StatType.EXERTION);
         var _loc2_:int = this.getValue(StatType.WILLPOWER_MOVE,1);
         return _loc1_ * _loc2_;
      }
      
      public function get exertionMoveBonusCur() : int
      {
         var _loc1_:int = this.getValue(StatType.EXERTION);
         var _loc2_:int = this.getValue(StatType.WILLPOWER);
         var _loc3_:int = Math.min(_loc1_,_loc2_);
         var _loc4_:int = this.getValue(StatType.WILLPOWER_MOVE,1);
         return _loc3_ * _loc4_;
      }
      
      public function getExertionRequiredForMove(param1:int) : int
      {
         var _loc2_:int = this.getValue(StatType.WILLPOWER_MOVE,1);
         var _loc3_:int = this.getValue(StatType.MOVEMENT);
         var _loc4_:int = param1 - _loc3_;
         if(_loc4_)
         {
            return 1 + (_loc4_ - 1) / _loc2_;
         }
         return 0;
      }
      
      public function getPercentOfOriginal(param1:StatType) : Number
      {
         var _loc2_:Stat = this.getStat(param1,false);
         if(Boolean(_loc2_) && Boolean(_loc2_.original))
         {
            return _loc2_.value / _loc2_.original;
         }
         return 1;
      }
   }
}
