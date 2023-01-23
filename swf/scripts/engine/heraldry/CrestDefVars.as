package engine.heraldry
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class CrestDefVars extends CrestDef
   {
      
      public static const schema:Object = {
         "name":"CrestDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "id":{"type":"string"},
            "tags":{"type":"string"},
            "prereq":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function CrestDefVars()
      {
         super();
      }
      
      public static function toJson(param1:CrestDef, param2:HeraldrySystem) : Object
      {
         var _loc3_:Object = {
            "name":param1.name,
            "id":param1.id,
            "tags":param2.makeTagsArray(param1.tags).join(",")
         };
         if(param1.prereq)
         {
            _loc3_.prereq = param1.prereq;
         }
         return _loc3_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : CrestDefVars
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.name = param1.name;
         this.id = param1.id;
         this.prereq = param1.prerewq;
         if(param1.tags)
         {
            this.tagsArray = param1.tags.split(/[,\s]/);
         }
         else
         {
            this.tagsArray = [];
         }
         return this;
      }
   }
}
