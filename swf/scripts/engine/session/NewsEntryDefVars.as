package engine.session
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class NewsEntryDefVars extends NewsEntryDef
   {
      
      public static const schema:Object = {
         "name":"NewsEntryDefVars",
         "type":"object",
         "properties":{
            "date":{"type":"string"},
            "content":{
               "type":"array",
               "items":"string"
            }
         }
      };
       
      
      public function NewsEntryDefVars()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : NewsEntryDefVars
      {
         var _loc4_:String = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         var _loc3_:Number = Date.parse(param1.date);
         this.date = new Date(_loc3_);
         this.content = "";
         for each(_loc4_ in param1.content)
         {
            this.content += _loc4_ + "\n";
         }
         return this;
      }
   }
}
