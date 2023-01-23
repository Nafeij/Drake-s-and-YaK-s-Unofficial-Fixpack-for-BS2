package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaDlcVariableDataVars extends SagaDlcVariableData
   {
      
      public static const schema:Object = {
         "name":"SagaDlcEntryVariableDataVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "value":{"type":"number"}
         }
      };
       
      
      public function SagaDlcVariableDataVars()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaDlcVariableData
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.varname = param1.name;
         this.varvalue = param1.value;
         return this;
      }
   }
}
