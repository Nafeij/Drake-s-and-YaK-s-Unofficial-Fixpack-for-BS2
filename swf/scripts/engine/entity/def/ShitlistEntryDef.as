package engine.entity.def
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class ShitlistEntryDef
   {
      
      public static const schema:Object = {
         "name":"ShitlistEntryDef",
         "properties":{
            "weight":{"type":"number"},
            "target":{"type":AbilityExecutionEntityConditions.schema}
         }
      };
       
      
      public var target:AbilityExecutionEntityConditions;
      
      public var weight:int;
      
      public function ShitlistEntryDef()
      {
         this.target = new AbilityExecutionEntityConditions();
         super();
      }
      
      public static function vctor() : Vector.<ShitlistEntryDef>
      {
         return new Vector.<ShitlistEntryDef>();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ShitlistEntryDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.target = this.target.fromJson(param1.target,param2);
         this.weight = param1.weight;
         return this;
      }
      
      public function toJson(param1:Boolean = false) : Object
      {
         return {
            "weight":this.weight,
            "target":this.target.save(param1)
         };
      }
   }
}
