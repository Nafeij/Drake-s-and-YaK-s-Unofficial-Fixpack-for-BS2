package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class ItemVars extends Item
   {
      
      public static const schema:Object = {
         "name":"ItemVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "defid":{"type":"string"}
         }
      };
       
      
      public function ItemVars()
      {
         super();
      }
      
      public static function save(param1:Item) : Object
      {
         return {
            "id":param1.id,
            "defid":param1.defid
         };
      }
      
      public function fromJson(param1:Object, param2:ILogger) : Item
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         id = param1.id;
         defid = param1.defid;
         return this;
      }
   }
}
