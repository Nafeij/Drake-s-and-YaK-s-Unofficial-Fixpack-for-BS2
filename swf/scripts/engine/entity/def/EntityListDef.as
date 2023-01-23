package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class EntityListDef extends EventDispatcher implements IEntityListDef
   {
       
      
      public var entityDefs:Vector.<IEntityDef>;
      
      private var entityDefsById:Dictionary;
      
      protected var _classes:EntityClassDefList;
      
      public var _locale:Locale;
      
      public var url:String;
      
      private var _numCombatants:int;
      
      private var _trackCombatants:Boolean = true;
      
      private var _logger:ILogger;
      
      public function EntityListDef(param1:Locale, param2:EntityClassDefList, param3:ILogger)
      {
         this.entityDefs = new Vector.<IEntityDef>();
         this.entityDefsById = new Dictionary();
         super();
         this._locale = param1;
         this._classes = param2;
         this._logger = param3;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function set trackCombatants(param1:Boolean) : void
      {
         this._trackCombatants = param1;
      }
      
      public function cleanup() : void
      {
         this.entityDefs = null;
         this.entityDefsById = null;
         this._classes = null;
         this._locale = null;
      }
      
      public function get trackCombatants() : Boolean
      {
         return this._trackCombatants;
      }
      
      public function get locale() : Locale
      {
         return this._locale;
      }
      
      public function get classes() : EntityClassDefList
      {
         return this._classes;
      }
      
      public function addEntityDef(param1:IEntityDef) : void
      {
         if(!param1)
         {
            throw new ArgumentError("EntityListDef.addEntityDef null entity");
         }
         if(!this._trackCombatants || !param1.combatant || this.entityDefs.length == 0)
         {
            this.entityDefs.push(param1);
         }
         else
         {
            this.entityDefs.splice(this._numCombatants,0,param1);
         }
         if(param1.combatant)
         {
            ++this._numCombatants;
         }
         this.entityDefsById[param1.id] = param1;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function getEntityDefById(param1:String) : IEntityDef
      {
         return this.entityDefsById[param1];
      }
      
      public function get numEntityDefs() : int
      {
         return this.entityDefs.length;
      }
      
      public function getEntityDef(param1:int) : IEntityDef
      {
         return this.entityDefs[param1];
      }
      
      public function removeEntityDef(param1:IEntityDef) : void
      {
         if(!this.getEntityDefById(param1.id))
         {
            return;
         }
         if(param1.combatant)
         {
            --this._numCombatants;
         }
         this.entityDefs.splice(this.entityDefs.indexOf(param1),1);
         delete this.entityDefsById[param1.id];
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function clear() : void
      {
         this._numCombatants = 0;
         this.entityDefs.splice(0,this.entityDefs.length);
         this.entityDefsById = new Dictionary();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function sortEntities() : void
      {
         this.entityDefs = this.entityDefs.sort(this.sortComparator);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function sortById() : void
      {
         this._trackCombatants = false;
         this._numCombatants = 0;
         this.entityDefs = this.entityDefs.sort(this.sortIdComparator);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function sortIdComparator(param1:IEntityDef, param2:IEntityDef) : int
      {
         if(param1.id < param2.id)
         {
            return -1;
         }
         if(param1.id > param2.id)
         {
            return 1;
         }
         return 0;
      }
      
      private function sortComparator(param1:IEntityDef, param2:IEntityDef) : int
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         if(param1.combatant && !param2.combatant)
         {
            return -1;
         }
         if(!param1.combatant && param2.combatant)
         {
            return 1;
         }
         if(!param1.combatant && !param2.combatant)
         {
            return 0;
         }
         if(Boolean(Saga.instance) && Boolean(Saga.instance.def.survival))
         {
            _loc7_ = int(param1.stats.getValue(StatType.INJURY));
            _loc8_ = int(param2.stats.getValue(StatType.INJURY));
            if(!_loc7_ && Boolean(_loc8_))
            {
               return -1;
            }
            if(Boolean(_loc7_) && !_loc8_)
            {
               return 1;
            }
            _loc9_ = param1.isSurvivalRecruited;
            _loc10_ = param2.isSurvivalRecruited;
            if(_loc9_ && !_loc10_)
            {
               return -1;
            }
            if(!_loc9_ && _loc10_)
            {
               return 1;
            }
         }
         if(param1.entityClass.partyTag != param1.entityClass.partyTag)
         {
            return param1.entityClass.partyTag.localeCompare(param1.entityClass.partyTag);
         }
         var _loc3_:String = !!param1.entityClass.parentEntityClass ? param1.entityClass.parentEntityClass.name : param1.entityClass.name;
         var _loc4_:String = !!param2.entityClass.parentEntityClass ? param2.entityClass.parentEntityClass.name : param2.entityClass.name;
         if(_loc3_ != _loc4_)
         {
            return _loc3_.localeCompare(_loc4_);
         }
         if(param1.entityClass != param2.entityClass)
         {
            return param1.entityClass.name.localeCompare(param2.entityClass.name);
         }
         var _loc5_:int = int(param1.stats.getValue(StatType.RANK));
         var _loc6_:int = int(param2.stats.getValue(StatType.RANK));
         if(_loc5_ != _loc6_)
         {
            return _loc5_ - _loc6_;
         }
         return param1.name.localeCompare(param2.name);
      }
      
      public function copyFrom(param1:IEntityListDef) : void
      {
         this.clear();
         var _loc2_:int = 0;
         while(_loc2_ < param1.numEntityDefs)
         {
            this.addEntityDef(param1.getEntityDef(_loc2_));
            _loc2_++;
         }
      }
      
      public function setEntityId(param1:EntityDef, param2:String) : void
      {
         if(this.entityDefsById[param2])
         {
            return;
         }
         delete this.entityDefsById[param1.id];
         param1.id = param2;
         this.entityDefsById[param1.id] = param1;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function promoteEntityOrder(param1:EntityDef) : void
      {
         this._trackCombatants = false;
         var _loc2_:int = this.entityDefs.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.entityDefs.splice(_loc2_,1);
            this.entityDefs.splice(_loc2_ - 1,0,param1);
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function demoteEntityOrder(param1:EntityDef) : void
      {
         this._trackCombatants = false;
         var _loc2_:int = this.entityDefs.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.entityDefs.length - 1)
         {
            this.entityDefs.splice(_loc2_,1);
            this.entityDefs.splice(_loc2_ + 1,0,param1);
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function createNewEntityDef() : EntityDef
      {
         var _loc2_:String = null;
         var _loc3_:EntityDef = null;
         this._trackCombatants = false;
         var _loc1_:int = 0;
         while(_loc1_ < 100)
         {
            _loc2_ = "New Entity " + _loc1_;
            if(!this.getEntityDefById(_loc2_))
            {
               _loc3_ = new EntityDef(this.locale);
               _loc3_.id = _loc2_;
               this.addEntityDef(_loc3_);
               return _loc3_;
            }
            _loc1_++;
         }
         return null;
      }
      
      public function get numCombatants() : int
      {
         if(this._trackCombatants)
         {
            return this._numCombatants;
         }
         return this.numEntityDefs;
      }
      
      public function get numInjuredCombatants() : int
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         for each(_loc2_ in this.entityDefs)
         {
            if(_loc2_.combatant)
            {
               if(_loc2_.stats.getBase(StatType.INJURY))
               {
                  _loc1_++;
               }
            }
         }
         return _loc1_;
      }
      
      public function get numSurvivalAvailable() : int
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         for each(_loc2_ in this.entityDefs)
         {
            if(_loc2_.combatant)
            {
               if(!_loc2_.isSurvivalDead && _loc2_.isSurvivalRecruited)
               {
                  _loc1_++;
               }
            }
         }
         return _loc1_;
      }
      
      public function get hasInjuredCombatants() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         for each(_loc2_ in this.entityDefs)
         {
            if(_loc2_.combatant)
            {
               if(_loc2_.stats.getBase(StatType.INJURY))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get hasUpgradeableCombatants() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         for each(_loc2_ in this.entityDefs)
         {
            if(_loc2_.combatant)
            {
               if(_loc2_.isPromotable || _loc2_.isUpgradeable)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function changeLocale(param1:Locale) : void
      {
         var _loc2_:IEntityDef = null;
         var _loc3_:EntityDef = null;
         this._locale = param1;
         for each(_loc2_ in this.entityDefs)
         {
            _loc3_ = _loc2_ as EntityDef;
            _loc3_.changeLocale(param1);
         }
      }
      
      public function countCombatantAtRank(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:IEntityDef = null;
         for each(_loc3_ in this.entityDefs)
         {
            if(_loc3_.combatant)
            {
               if(Boolean(_loc3_.stats) && _loc3_.stats.rank == param1)
               {
                  _loc2_++;
               }
            }
         }
         return _loc2_;
      }
      
      public function getCombatantIndex(param1:IEntityDef) : int
      {
         var _loc2_:int = 0;
         var _loc3_:IEntityDef = null;
         for each(_loc3_ in this.entityDefs)
         {
            if(_loc3_.combatant)
            {
               if(_loc3_ == param1)
               {
                  return _loc2_;
               }
               _loc2_++;
            }
         }
         return -1;
      }
      
      public function getCombatantAt(param1:int) : IEntityDef
      {
         var _loc2_:int = 0;
         var _loc3_:IEntityDef = null;
         for each(_loc3_ in this.entityDefs)
         {
            if(_loc3_.combatant)
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
      
      public function get combatantRankMin() : int
      {
         var _loc3_:IEntityDef = null;
         var _loc1_:Saga = Saga.instance;
         var _loc2_:int = 10000;
         for each(_loc3_ in this.entityDefs)
         {
            if(_loc3_.combatant)
            {
               if(Boolean(_loc1_) && _loc1_.isSurvival)
               {
                  if(!_loc3_.isSurvivalRecruited || _loc3_.isSurvivalDead)
                  {
                     continue;
                  }
               }
               _loc2_ = Math.min(_loc2_,_loc3_.stats.rank);
            }
         }
         return _loc2_;
      }
      
      public function get combatantRankMax() : int
      {
         var _loc3_:IEntityDef = null;
         var _loc1_:Saga = Saga.instance;
         var _loc2_:int = 0;
         for each(_loc3_ in this.entityDefs)
         {
            if(_loc3_.combatant)
            {
               if(Boolean(_loc1_) && _loc1_.isSurvival)
               {
                  if(!_loc3_.isSurvivalRecruited || _loc3_.isSurvivalDead)
                  {
                     continue;
                  }
               }
               _loc2_ = Math.max(_loc2_,_loc3_.stats.rank);
            }
         }
         return _loc2_;
      }
      
      public function getEntityStatValue(param1:String, param2:StatType) : int
      {
         var _loc3_:IEntityDef = this.getEntityDefById(param1);
         return !!_loc3_ ? int(_loc3_.stats.getValue(param2)) : 0;
      }
      
      public function getDebugString() : String
      {
         var _loc3_:IEntityDef = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < this.entityDefs.length)
         {
            _loc3_ = this.entityDefs[_loc2_];
            _loc1_ += _loc2_.toString() + "   " + _loc3_.getSummaryLine() + "\n";
            _loc2_++;
         }
         return _loc1_;
      }
   }
}
