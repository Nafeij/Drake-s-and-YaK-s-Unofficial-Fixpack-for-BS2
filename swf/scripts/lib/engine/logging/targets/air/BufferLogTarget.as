package lib.engine.logging.targets.air
{
   import engine.core.logging.ILogTarget;
   import engine.core.logging.ILogTargetCleanupable;
   import engine.core.logging.ILogger;
   
   public class BufferLogTarget implements ILogTarget, ILogTargetCleanupable
   {
       
      
      private var buffer:Array;
      
      public function BufferLogTarget()
      {
         this.buffer = [];
         super();
      }
      
      public function cleanup() : void
      {
         this.buffer = null;
      }
      
      public function unbuffer(param1:ILogTarget) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.buffer)
         {
            switch(_loc2_.type)
            {
               case "debug":
                  param1.debug(_loc2_.logger,_loc2_.time,_loc2_.str);
                  break;
               case "info":
                  param1.info(_loc2_.logger,_loc2_.time,_loc2_.str);
                  break;
               case "error":
                  param1.error(_loc2_.logger,_loc2_.time,_loc2_.str);
                  break;
            }
         }
      }
      
      private function storeBuffer(param1:String, param2:ILogger, param3:int, param4:String) : void
      {
         this.buffer.push({
            "type":param1,
            "logger":param2,
            "time":param3,
            "str":"BUFFERED: " + param4
         });
      }
      
      public function debug(param1:ILogger, param2:int, param3:String) : void
      {
         this.storeBuffer("debug",param1,param2,param3);
      }
      
      public function info(param1:ILogger, param2:int, param3:String) : void
      {
         this.storeBuffer("info",param1,param2,param3);
      }
      
      public function error(param1:ILogger, param2:int, param3:String) : void
      {
         this.storeBuffer("error",param1,param2,param3);
      }
      
      public function critical(param1:ILogger, param2:int, param3:String) : void
      {
         this.storeBuffer("critical",param1,param2,param3);
      }
      
      public function getLogFilePath() : String
      {
         return null;
      }
   }
}
