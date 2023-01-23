package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaDlcsVars extends SagaDlcs
   {
      
      public static const schema:Object = {
         "name":"SagaDlcsVars",
         "type":"object",
         "properties":{"entries":{
            "type":"array",
            "items":SagaDlcEntryVars.schema
         }}
      };
       
      
      public function SagaDlcsVars()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : SagaDlcs
      {
         var _loc4_:Object = null;
         var _loc5_:SagaDlcEntry = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc4_ in param1.entries)
         {
            _loc5_ = new SagaDlcEntryVars().fromJson(_loc4_,param2);
            entries.push(_loc5_);
         }
         if(param3)
         {
            reportDlcKeys(param2);
         }
         return this;
      }
   }
}
