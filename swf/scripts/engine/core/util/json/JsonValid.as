package engine.core.util.json
{
   import engine.core.logging.ILogger;
   
   public class JsonValid
   {
      
      public static var logger:ILogger;
       
      
      public function JsonValid()
      {
         super();
      }
      
      public static function parse(param1:String, param2:Function = null) : Object
      {
         var jv:JsonValidator = null;
         var s:String = param1;
         var reviver:Function = param2;
         try
         {
            return JSON.parse(s,reviver);
         }
         catch(e:Error)
         {
            logger.error("Unable to parse JSON:\n" + e.getStackTrace());
            jv = new JsonValidator(logger);
            jv.validate(s);
            throw e;
         }
      }
   }
}
