package engine.battle.ability.effect.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class BooleanValueReqs
   {
      
      public static const schema:Object = {
         "name":"BooleanValueReqs",
         "properties":{"value":{"type":"boolean"}}
      };
      
      public static const empty:BooleanValueReqs = new BooleanValueReqs();
      
      public static const emptyJsonEverything:Object = empty.save(true);
       
      
      public var value:Boolean;
      
      public function BooleanValueReqs()
      {
         super();
      }
      
      public static function check(param1:BooleanValueReqs, param2:Boolean) : Boolean
      {
         if(!param1)
         {
            return true;
         }
         return param1.value == param2;
      }
      
      public static function ctorFromJson(param1:Object, param2:ILogger) : BooleanValueReqs
      {
         if(param1)
         {
            return new BooleanValueReqs().fromJson(param1,param2);
         }
         return null;
      }
      
      public function get isEmpty() : Boolean
      {
         return !this.value;
      }
      
      public function toString() : String
      {
         return this.value.toString();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BooleanValueReqs
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.value = param1.value;
         return this;
      }
      
      public function save(param1:Boolean = false) : Object
      {
         return {"value":this.value};
      }
   }
}
