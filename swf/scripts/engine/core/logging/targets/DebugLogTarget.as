package engine.core.logging.targets
{
   import engine.core.logging.ILogTarget;
   import engine.core.logging.ILogger;
   
   public class DebugLogTarget implements ILogTarget
   {
       
      
      private var dispatching:Boolean;
      
      public var listener:IDebugLogTarget;
      
      public var errorCallback:Function;
      
      public function DebugLogTarget()
      {
         super();
      }
      
      public function debug(param1:ILogger, param2:int, param3:String) : void
      {
         if(Boolean(this.listener) && !this.dispatching)
         {
            this.dispatching = true;
            this.listener.debugLogTarget_debug(param1,param3);
            this.dispatching = false;
         }
      }
      
      public function info(param1:ILogger, param2:int, param3:String) : void
      {
         if(Boolean(this.listener) && !this.dispatching)
         {
            this.dispatching = true;
            this.listener.debugLogTarget_info(param1,param3);
            this.dispatching = false;
         }
      }
      
      public function error(param1:ILogger, param2:int, param3:String) : void
      {
         if(Boolean(this.listener) && !this.dispatching)
         {
            this.dispatching = true;
            this.listener.debugLogTarget_error(param1,param3);
            if(this.errorCallback != null)
            {
               this.errorCallback();
            }
            this.dispatching = false;
         }
      }
      
      public function critical(param1:ILogger, param2:int, param3:String) : void
      {
         this.error(param1,param2,param3);
      }
      
      public function getLogFilePath() : String
      {
         return null;
      }
   }
}
