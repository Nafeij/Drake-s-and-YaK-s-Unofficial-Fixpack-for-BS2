package lib.engine.logging.targets.air
{
   import engine.core.logging.ILogTarget;
   import engine.core.logging.ILogTargetCleanupable;
   import engine.core.logging.ILogger;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   
   public class FileLogTarget implements ILogTarget, ILogTargetCleanupable
   {
       
      
      private var fs:FileStream;
      
      private var file:File;
      
      public function FileLogTarget(param1:File, param2:ILogger)
      {
         var file:File = param1;
         var logger:ILogger = param2;
         super();
         this.file = file;
         this.fs = new FileStream();
         try
         {
            this.fs.open(file,FileMode.APPEND);
         }
         catch(e:Error)
         {
            fs = null;
            logger.error("unable to open file: " + e.getStackTrace());
         }
      }
      
      public function cleanup() : void
      {
         if(this.fs)
         {
            this.fs.close();
            this.fs = null;
         }
      }
      
      private function _trace(param1:String, param2:String, param3:int, param4:int, param5:String) : void
      {
         var _loc6_:String = null;
         if(this.fs)
         {
            _loc6_ = !!param2 ? "(" + param2 + ") " : "";
            this.fs.writeUTFBytes(param1.concat(_loc6_,param3," ",param4," ",param5,"\n"));
         }
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
         this.flush();
      }
      
      public function flush() : void
      {
         if(this.fs)
         {
            try
            {
               this.fs.close();
            }
            catch(err:Error)
            {
            }
            try
            {
               this.fs.open(this.file,FileMode.APPEND);
            }
            catch(err:Error)
            {
               fs = null;
            }
         }
      }
      
      public function critical(param1:ILogger, param2:int, param3:String) : void
      {
         var logger:ILogger = param1;
         var time:int = param2;
         var str:String = param3;
         if(this.fs)
         {
            try
            {
               this.fs.writeUTFBytes("\n[CRIT] ==============================\n[CRIT] (" + logger.name + ") " + logger.frameNumber + " " + time + " " + str + "\n" + "[CRIT] ==============================\n\n");
               this.fs.close();
            }
            catch(err:Error)
            {
            }
            try
            {
               this.fs.open(this.file,FileMode.APPEND);
            }
            catch(err:Error)
            {
               fs = null;
            }
         }
      }
      
      public function getLogFilePath() : String
      {
         return !!this.file ? String(this.file.nativePath) : null;
      }
   }
}
