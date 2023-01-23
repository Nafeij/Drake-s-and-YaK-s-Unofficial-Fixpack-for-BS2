package engine.core.logging.targets
{
   import engine.core.logging.ILogTarget;
   import engine.core.logging.ILogger;
   
   public class TraceLogTarget implements ILogTarget
   {
       
      
      public function TraceLogTarget()
      {
         super();
      }
      
      public function debug(param1:ILogger, param2:int, param3:String) : void
      {
         this._trace("[DEBUG] ",param1.name,param1.frameNumber,param2,param3);
      }
      
      public function info(param1:ILogger, param2:int, param3:String) : void
      {
         this._trace("[INFO]  ",param1.name,param1.frameNumber,param2,param3);
      }
      
      public function error(param1:ILogger, param2:int, param3:String) : void
      {
         this._trace("[ERROR] ",param1.name,param1.frameNumber,param2,param3);
      }
      
      public function critical(param1:ILogger, param2:int, param3:String) : void
      {
         this._trace("[CRIT]  ",param1.name,param1.frameNumber,param2,param3);
      }
      
      private function _trace(param1:String, param2:String, param3:int, param4:int, param5:String) : void
      {
         var _loc6_:String = !!param2 ? "(" + param2 + ") " : "";
      }
      
      public function getLogFilePath() : String
      {
         return null;
      }
   }
}
