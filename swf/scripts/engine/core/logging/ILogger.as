package engine.core.logging
{
   public interface ILogger
   {
       
      
      function get name() : String;
      
      function d(param1:String, param2:String, ... rest) : void;
      
      function i(param1:String, param2:String, ... rest) : void;
      
      function e(param1:String, param2:String, ... rest) : void;
      
      function c(param1:String, param2:String, ... rest) : void;
      
      function debug(param1:String, ... rest) : void;
      
      function info(param1:String, ... rest) : void;
      
      function error(param1:String, ... rest) : void;
      
      function critical(param1:String, ... rest) : void;
      
      function addTarget(param1:ILogTarget) : ILogger;
      
      function removeTarget(param1:ILogTarget) : ILogger;
      
      function get isDebugEnabled() : Boolean;
      
      function set isDebugEnabled(param1:Boolean) : void;
      
      function get frameNumber() : int;
      
      function set frameNumber(param1:int) : void;
      
      function cleanup() : void;
      
      function get isLogging() : Boolean;
      
      function set logLevel(param1:String) : void;
      
      function get logLevel() : String;
      
      function get numErrors() : int;
      
      function getLogFilePaths() : Array;
   }
}
