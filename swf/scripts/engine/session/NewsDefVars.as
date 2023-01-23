package engine.session
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class NewsDefVars extends NewsDef
   {
      
      public static const schema:Object = {
         "name":"NewsEntryDefVars",
         "type":"object",
         "properties":{"entries":{
            "type":"array",
            "items":NewsEntryDefVars.schema
         }}
      };
       
      
      public function NewsDefVars()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : NewsDefVars
      {
         var _loc3_:Object = null;
         var _loc4_:NewsEntryDefVars = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.entries)
         {
            _loc4_ = new NewsEntryDefVars().fromJson(_loc3_,param2);
            entries.push(_loc4_);
         }
         sortEntries();
         return this;
      }
   }
}
