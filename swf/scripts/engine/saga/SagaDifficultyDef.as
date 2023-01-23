package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaDifficultyDef
   {
      
      public static const schema:Object = {
         "name":"SagaDifficultyDef",
         "type":"object",
         "properties":{
            "danger":{"type":"number"},
            "strength":{"type":"number"},
            "armor":{"type":"number"}
         }
      };
       
      
      public var danger:int;
      
      public var strength:int;
      
      public var armor:int;
      
      public function SagaDifficultyDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaDifficultyDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.danger = param1.danger;
         this.strength = param1.strength;
         this.armor = param1.armor;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "danger":this.danger,
            "strength":this.strength,
            "armor":this.armor
         };
      }
   }
}
