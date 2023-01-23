package engine.resource.loader
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   
   public class IResourceLoader
   {
       
      
      private var m_url:String;
      
      private var m_completeListener:IResourceLoaderListener;
      
      private var m_complete:Boolean;
      
      private var m_error:Boolean;
      
      private var m_logger:ILogger;
      
      public var numBytes:int;
      
      protected var startTime:int;
      
      public var loadTime:int;
      
      public var processingTime:int;
      
      public var unrequired:Boolean;
      
      public function IResourceLoader(param1:String, param2:IResourceLoaderListener, param3:ILogger)
      {
         super();
         if(!param3)
         {
            throw ArgumentError("gotta have a logger");
         }
         this.m_url = param1;
         this.m_completeListener = param2;
         this.m_logger = param3;
      }
      
      public function unload() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function get data() : *
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function get error() : Boolean
      {
         return this.m_error;
      }
      
      public function get complete() : Boolean
      {
         return this.m_complete;
      }
      
      protected function emitCompleteCallback(param1:Boolean) : void
      {
         var ok:Boolean = param1;
         this.m_error = !ok;
         this.m_complete = true;
         try
         {
            if(this.m_completeListener)
            {
               this.m_completeListener.resourceLoaderCompleteHandler(this);
            }
         }
         catch(e:Error)
         {
            logger.error("Failure emitting complete callback for " + m_url + ":\n" + e.getStackTrace());
         }
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
      
      public function get logger() : ILogger
      {
         return this.m_logger;
      }
   }
}
