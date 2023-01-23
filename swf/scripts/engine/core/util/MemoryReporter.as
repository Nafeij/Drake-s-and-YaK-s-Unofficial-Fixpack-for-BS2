package engine.core.util
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceCollector;
   import engine.resource.ResourceManager;
   import flash.system.System;
   
   public class MemoryReporter
   {
      
      private static var last_resman_ordinal:int = 0;
      
      public static var DISABLE_TIMED_CHECKING:Boolean;
       
      
      private var logger:ILogger;
      
      private var last_memory_mb:int = 0;
      
      public var currentMb:int = 0;
      
      private var sample_period_ms:int = 2000;
      
      private var sample_elapsed:int;
      
      public var bloat_report_size_mb:int = 1000;
      
      public function MemoryReporter(param1:ILogger)
      {
         this.sample_elapsed = this.sample_period_ms;
         super();
         this.logger = param1;
      }
      
      public static function notifyModified() : void
      {
         last_resman_ordinal = 0;
      }
      
      public function checkMemory(param1:int, param2:int) : void
      {
         this.sample_elapsed += param1;
         if(DISABLE_TIMED_CHECKING || this.sample_elapsed < this.sample_period_ms)
         {
            if(last_resman_ordinal == param2)
            {
               return;
            }
         }
         last_resman_ordinal = param2;
         this.sample_elapsed = 0;
         this.currentMb = System.privateMemory / (1024 * 1024);
         var _loc3_:int = 50;
         if(this.currentMb > 900)
         {
            _loc3_ = 10;
         }
         else if(this.currentMb > 800)
         {
            _loc3_ = 20;
         }
         else if(this.currentMb > 700)
         {
            _loc3_ = 30;
         }
         if(Math.abs(this.last_memory_mb - this.currentMb) >= _loc3_)
         {
            this.logger.info("MEMORY SIZE: " + this.currentMb + " MB");
            this.last_memory_mb = this.currentMb;
            if(this.last_memory_mb >= this.bloat_report_size_mb)
            {
               if(!ResourceManager.BIGMEM && !ResourceCollector.ENABLED)
               {
                  this.logger.error("MEMORY BLOAT " + this.currentMb + " MB");
                  this.bloat_report_size_mb += 50;
               }
            }
         }
      }
   }
}
