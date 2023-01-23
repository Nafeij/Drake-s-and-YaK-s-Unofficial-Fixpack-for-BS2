package engine.core.http
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public class HttpRequest
   {
      
      public static const INTERNAL_TIMEOUT_STATUS:int = 999;
       
      
      private var m_callback:Function;
      
      private var logger:ILogger;
      
      private var m_errorCount:uint;
      
      private var m_loader:URLLoader;
      
      private var m_compressed:Boolean;
      
      public var probe:Boolean;
      
      private var url:String;
      
      private var timer:Timer;
      
      public var status:int;
      
      public var method:HttpRequestMethod;
      
      private var complete:Boolean;
      
      public function HttpRequest(param1:String, param2:HttpRequestMethod, param3:Object, param4:Function, param5:ILogger, param6:Class = null, param7:Boolean = false)
      {
         this.timer = new Timer(5000,1);
         super();
         if(!param5)
         {
            throw new ArgumentError("logs?");
         }
         this.method = param2;
         this.url = param1;
         this.logger = param5;
         this.m_callback = param4;
         var _loc8_:URLRequest = new URLRequest(param1);
         _loc8_.method = param2.name;
         _loc8_.data = param3;
         if(param3)
         {
            if(param3 is ByteArray)
            {
               _loc8_.contentType = "application/octet-stream";
            }
            else if(param3 is URLVariables)
            {
               _loc8_.contentType = "application/x-www-form-urlencoded";
            }
            else if(param3 is String)
            {
               _loc8_.contentType = "text/plain";
            }
            else
            {
               _loc8_.data = JSON.stringify(param3);
               _loc8_.contentType = "application/json";
            }
         }
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         if(null != param6)
         {
            this.m_loader = new param6() as URLLoader;
         }
         else
         {
            this.m_loader = new URLLoader();
         }
         this.m_compressed = param7;
         if(this.m_compressed)
         {
            this.m_loader.dataFormat = URLLoaderDataFormat.BINARY;
         }
         this.performLoad(_loc8_);
      }
      
      public function toString() : String
      {
         return this.method.name + " " + this.url;
      }
      
      protected function timerCompleteHandler(param1:TimerEvent) : void
      {
         this.status = INTERNAL_TIMEOUT_STATUS;
         this.makeComplete(null,false);
      }
      
      private function performLoad(param1:URLRequest) : void
      {
         var ul:URLRequest = param1;
         this.m_loader.addEventListener(ProgressEvent.PROGRESS,this.onUrlLoadProgress);
         this.m_loader.addEventListener(Event.COMPLETE,this.onUrlLoadComplete);
         this.m_loader.addEventListener(Event.OPEN,this.onUrlLoadOpen);
         this.m_loader.addEventListener(IOErrorEvent.IO_ERROR,this.onUrlIoError);
         this.m_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.onUrlHttpStatus);
         if(HTTPStatusEvent.HTTP_RESPONSE_STATUS)
         {
            this.m_loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,this.onUrlHttpStatus);
         }
         else
         {
            this.m_loader.addEventListener("httpResponseStatus",this.onUrlHttpStatus);
         }
         try
         {
            this.m_loader.load(ul);
         }
         catch(error:Error)
         {
            logger.error("HttpRequest fail: " + error.getStackTrace());
            makeComplete(null,false);
         }
      }
      
      protected function onUrlLoadProgress(param1:ProgressEvent) : void
      {
      }
      
      protected function onUrlHttpStatus(param1:HTTPStatusEvent) : void
      {
         this.status = param1.status;
         if(this.status < 200 || this.status >= 300)
         {
            this.logger.debug("HttpRequest.onUrlHttpStatus " + this + ": " + param1);
            ++this.m_errorCount;
         }
      }
      
      protected function onUrlIoError(param1:IOErrorEvent) : void
      {
         ++this.m_errorCount;
         this.logger.info("HttpRequest.onUrlIoError " + param1.toString());
         this.makeComplete(null,false);
      }
      
      protected function onUrlLoadOpen(param1:Event) : void
      {
      }
      
      protected function onUrlLoadComplete(param1:Event) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:URLLoader = param1.target as URLLoader;
         if(this.m_compressed)
         {
            if(_loc2_.data is ByteArray)
            {
               _loc3_ = _loc2_.data;
               _loc3_.uncompress();
            }
         }
         this.makeComplete(_loc2_.data,true);
      }
      
      public function get loader() : URLLoader
      {
         return this.m_loader;
      }
      
      private function makeComplete(param1:*, param2:Boolean) : void
      {
         this.timer.stop();
         if(!this.complete)
         {
            if(!param2)
            {
               ++this.m_errorCount;
            }
            this.complete = true;
            if(this.m_callback != null)
            {
               this.m_callback(param1,this.m_errorCount == 0,this.status);
            }
         }
      }
   }
}
