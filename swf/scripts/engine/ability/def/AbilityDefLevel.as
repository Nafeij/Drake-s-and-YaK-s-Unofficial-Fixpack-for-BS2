package engine.ability.def
{
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   
   public class AbilityDefLevel implements IAbilityDefLevel
   {
       
      
      public var _def:IAbilityDef;
      
      private var _level:int;
      
      private var _rankAcquired:int;
      
      private var _enabled:Boolean = true;
      
      public function AbilityDefLevel(param1:IAbilityDef, param2:int, param3:int)
      {
         super();
         this._def = param1;
         this._level = param2;
         this._rankAcquired = param3;
      }
      
      public static function save(param1:IAbilityDefLevel) : Object
      {
         return {
            "id":param1.id,
            "level":param1.level,
            "rankAcquired":param1.rankAcquired
         };
      }
      
      public function toString() : String
      {
         return this._def + "/" + this._level;
      }
      
      public function get id() : String
      {
         return this.def.id;
      }
      
      public function get def() : IAbilityDef
      {
         return this._def;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function set level(param1:int) : void
      {
         this._level = param1;
      }
      
      public function get rankAcquired() : int
      {
         return this._rankAcquired;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
      }
   }
}
