package engine.core.logging
{
   public interface ILogTarget
   {
       
      
      function debug(param1:ILogger, param2:int, param3:String) : void;
      
      function info(param1:ILogger, param2:int, param3:String) : void;
      
      function error(param1:ILogger, param2:int, param3:String) : void;
      
      function critical(param1:ILogger, param2:int, param3:String) : void;
      
      function getLogFilePath() : String;
   }
}
