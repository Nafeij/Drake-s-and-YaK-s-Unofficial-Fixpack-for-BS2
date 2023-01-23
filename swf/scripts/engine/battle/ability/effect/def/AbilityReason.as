package engine.battle.ability.effect.def
{
   import engine.battle.ability.model.BattleAbilityValidation;
   
   public class AbilityReason
   {
       
      
      public var msg:String;
      
      public var valid:BattleAbilityValidation;
      
      public function AbilityReason()
      {
         super();
      }
      
      public static function setMessage(param1:AbilityReason, param2:String) : void
      {
         if(param1)
         {
            param1.valid = null;
            param1.msg = param2;
         }
      }
      
      public static function setValid(param1:AbilityReason, param2:BattleAbilityValidation) : void
      {
         if(param1)
         {
            param1.msg = null;
            param1.valid = !!param2 ? param2 : BattleAbilityValidation.NULL;
         }
      }
      
      public static function setBoth(param1:AbilityReason, param2:BattleAbilityValidation, param3:String) : void
      {
         if(param1)
         {
            setValid(param1,param2);
            param1.msg = param3;
         }
      }
      
      public function clear() : void
      {
         this.msg = null;
         this.valid = null;
      }
      
      public function toString() : String
      {
         if(Boolean(this.valid) && Boolean(this.msg))
         {
            return this.valid.name + ": " + this.msg;
         }
         if(this.valid)
         {
            return this.valid.name;
         }
         if(this.msg)
         {
            return this.msg;
         }
         return "";
      }
   }
}
