package engine.ability.def
{
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class AbilityDefLevels implements IAbilityDefLevels
   {
       
      
      protected var abilities:Vector.<IAbilityDefLevel>;
      
      private var indexes:Dictionary;
      
      protected var _suppressions:Vector.<String>;
      
      protected var _suppressionsById:Dictionary;
      
      protected var _name:String;
      
      public function AbilityDefLevels(param1:String)
      {
         this.abilities = new Vector.<IAbilityDefLevel>();
         this.indexes = new Dictionary();
         super();
         this._name = param1;
      }
      
      public static function save(param1:IAbilityDefLevels) : Array
      {
         var _loc4_:IAbilityDefLevel = null;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1.numAbilities)
         {
            _loc4_ = param1.getAbilityDefLevel(_loc3_);
            _loc2_.push(AbilityDefLevel.save(_loc4_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      protected function handleDirtyAbilities() : void
      {
      }
      
      public function clone(param1:ILogger) : IAbilityDefLevels
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function setAbilityDefLevel(param1:IAbilityDef, param2:int, param3:int, param4:ILogger) : IAbilityDefLevel
      {
         param2 = Math.min(param1.maxLevel,param2);
         var _loc5_:int = this.getAbilityIndex(param1.id);
         var _loc6_:IAbilityDefLevel = new AbilityDefLevel(param1,param2,param3);
         if(_loc5_ >= 0)
         {
            this.abilities[_loc5_] = _loc6_;
            this.handleDirtyAbilities();
         }
         else
         {
            this.addAbilityDefLevel(_loc6_,param4);
         }
         return _loc6_;
      }
      
      public function addAbilityDefLevel(param1:IAbilityDefLevel, param2:ILogger) : IAbilityDefLevel
      {
         if(!this.getAbilityDefLevelById(param1.id))
         {
            this.abilities.push(param1);
            this.indexes[param1.id] = this.abilities.length - 1;
         }
         this.handleDirtyAbilities();
         return param1;
      }
      
      public function get numAbilities() : int
      {
         return this.abilities.length;
      }
      
      public function getAbilityDef(param1:int) : IAbilityDef
      {
         return this.abilities[param1].def;
      }
      
      public function getAbilityDefLevel(param1:int) : IAbilityDefLevel
      {
         return this.abilities[param1];
      }
      
      public function getAbilityIndex(param1:String) : int
      {
         if(param1 in this.indexes)
         {
            return this.indexes[param1];
         }
         return -1;
      }
      
      public function getAbilityLevel(param1:int) : int
      {
         return this.abilities[param1].level;
      }
      
      public function hasAbility(param1:String) : Boolean
      {
         return param1 in this.indexes;
      }
      
      public function getAbilityDefById(param1:String) : IAbilityDef
      {
         var _loc2_:IAbilityDefLevel = this.getAbilityDefLevelById(param1);
         return !!_loc2_ ? _loc2_.def : null;
      }
      
      public function getAbilityDefLevelById(param1:String) : IAbilityDefLevel
      {
         var _loc2_:int = this.getAbilityIndex(param1);
         if(_loc2_ >= 0)
         {
            return this.getAbilityDefLevel(_loc2_);
         }
         return null;
      }
      
      public function addSuppression(param1:String) : void
      {
         if(this.isSuppressed(param1))
         {
            return;
         }
         if(!this._suppressionsById)
         {
            this._suppressionsById = new Dictionary();
            this._suppressions = new Vector.<String>();
         }
         this._suppressions.push(param1);
         this._suppressionsById[param1] = param1;
         if(this.hasAbility(param1))
         {
            this.removeAbility(param1);
         }
      }
      
      public function removeAbility(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IAbilityDefLevel = null;
         var _loc2_:int = this.getAbilityIndex(param1);
         if(_loc2_ >= 0)
         {
            delete this.indexes[param1];
            this.abilities.splice(_loc2_,1);
            _loc3_ = _loc2_;
            while(_loc3_ < this.abilities.length)
            {
               _loc4_ = this.abilities[_loc3_];
               this.indexes[_loc4_.id] = _loc3_;
               _loc3_++;
            }
         }
         this.handleDirtyAbilities();
      }
      
      public function isSuppressed(param1:String) : Boolean
      {
         return Boolean(this._suppressionsById) && Boolean(this._suppressionsById[param1]);
      }
      
      public function getDebugString() : String
      {
         var _loc3_:IAbilityDefLevel = null;
         var _loc1_:* = "";
         var _loc2_:int = 0;
         while(_loc2_ < this.numAbilities)
         {
            _loc3_ = this.getAbilityDefLevel(_loc2_);
            if(_loc1_)
            {
               _loc1_ += ", ";
            }
            _loc1_ += "1:" + _loc3_;
            _loc2_++;
         }
         return _loc1_;
      }
   }
}
