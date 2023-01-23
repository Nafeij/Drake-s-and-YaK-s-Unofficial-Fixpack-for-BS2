package engine.core.logging.targets
{
   import engine.core.logging.ILogger;
   
   public interface IDebugLogTarget
   {
       
      
      function debugLogTarget_debug(param1:ILogger, param2:String) : void;
      
      function debugLogTarget_info(param1:ILogger, param2:String) : void;
      
      function debugLogTarget_error(param1:ILogger, param2:String) : void;
   }
}
