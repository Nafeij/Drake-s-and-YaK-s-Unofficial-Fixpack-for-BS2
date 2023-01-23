package engine.def
{
   import engine.core.logging.ILogger;
   import engine.math.Box;
   
   public class BoxVars
   {
      
      public static const schema:Object = {
         "name":"BoxVars",
         "type":"object",
         "properties":{
            "width":{"type":"number"},
            "length":{"type":"number"},
            "height":{"type":"number"}
         }
      };
       
      
      public function BoxVars()
      {
         super();
      }
      
      public static function parse(param1:Object, param2:ILogger) : Box
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         return new Box(param1.width,param1.length,param1.height);
      }
      
      public static function save(param1:Box) : Object
      {
         return {
            "width":param1.width,
            "length":param1.length,
            "height":param1.height
         };
      }
   }
}
