package engine.resource.loader
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class URLResourceLoader extends IURLResourceLoader
   {
      
      public static var _consoleNativeHttpClientGetStub:Function;
      
      public static var MAX_RETRIES_HTTP:int = 0;
       
      
      private var m_loader:URLLoader;
      
      private var compressed:Boolean = false;
      
      private var lastPercentLog:int = -10;
      
      private var lastProgressDelta:int = 0;
      
      private var retries:int = 0;
      
      private var isHttp:Boolean;
      
      public function URLResourceLoader(param1:String, param2:IResourceLoaderListener, param3:ILogger, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false)
      {
         this.m_loader = new SagaURLLoader();
         super(param1,param2,param3);
         this.compressed = param5;
         this.unrequired = param6;
         this.isHttp = StringUtil.startsWith(param1,"http://") || StringUtil.startsWith(param1,"https://");
         if(param4)
         {
            this.m_loader.dataFormat = URLLoaderDataFormat.BINARY;
         }
         this.load();
      }
      
      private function load() : void
      {
         var urlr:URLRequest = null;
         try
         {
            startTime = getTimer();
            if(url.lastIndexOf(".z") == url.length - 2)
            {
               this.m_loader.dataFormat = URLLoaderDataFormat.BINARY;
               this.compressed = true;
            }
            urlr = new URLRequest(url);
            this.m_loader.addEventListener(Event.COMPLETE,this.onLoadComplete);
            this.m_loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadFailed);
            this.m_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
            this.m_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.onHTTPStatus);
            this.m_loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,this.onHTTPStatus);
            this.m_loader.load(urlr);
         }
         catch(error:Error)
         {
            logger.error("URLResourceLoader failed: " + error.toString());
            if(Capabilities.isDebugger)
            {
               throw error;
            }
            emitCompleteCallback(false);
         }
      }
      
      private function progressHandler(param1:ProgressEvent) : void
      {
         var _loc10_:* = false;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - startTime;
         var _loc4_:Number = _loc3_ / 1000;
         var _loc5_:Number = int(100 * _loc4_) / 100;
         var _loc6_:int = param1.bytesLoaded / 1024;
         var _loc7_:int = param1.bytesTotal / 1024;
         var _loc8_:Number = int(100 * param1.bytesTotal / 1024 / 1024 / _loc4_) / 100;
         var _loc9_:int = 100 * param1.bytesLoaded / param1.bytesTotal;
         if(_loc9_ > this.lastPercentLog + 50)
         {
            _loc10_ = true;
         }
         else if(_loc9_ > this.lastPercentLog + 10)
         {
            _loc11_ = 1000;
            _loc10_ = _loc3_ > this.lastProgressDelta + _loc11_;
         }
         if(_loc9_ == 100 && this.lastPercentLog < 0)
         {
            _loc10_ = false;
         }
         if(_loc10_)
         {
            this.lastProgressDelta = _loc3_;
            this.lastPercentLog = _loc9_;
            _loc12_ = _loc5_ * param1.bytesTotal / param1.bytesLoaded;
            _loc13_ = int(100 * (_loc12_ - _loc5_)) / 100;
         }
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var endTime:int;
         var deltaTime:int;
         var secf:Number;
         var sec:Number;
         var kbLoaded:int;
         var MBperS:Number;
         var event:Event = param1;
         var cur:int = getTimer();
         loadTime = cur - startTime;
         startTime = cur;
         endTime = getTimer();
         deltaTime = endTime - startTime;
         secf = deltaTime / 1000;
         sec = int(100 * secf) / 100;
         kbLoaded = this.m_loader.bytesLoaded / 1024;
         MBperS = int(100 * this.m_loader.bytesLoaded / 1024 / 1024 / secf) / 100;
         this.unlisten();
         if(this.m_loader.dataFormat == URLLoaderDataFormat.BINARY)
         {
            if(this.compressed)
            {
               try
               {
                  (this.m_loader.data as ByteArray).uncompress();
               }
               catch(err:Error)
               {
                  logger.error("Failed to uncompress data " + url + ": " + err);
                  emitCompleteCallback(false);
                  return;
               }
            }
            numBytes = (this.m_loader.data as ByteArray).length;
         }
         else if(this.m_loader.dataFormat == URLLoaderDataFormat.TEXT)
         {
            numBytes = (this.m_loader.data as String).length;
         }
         processingTime = getTimer() - startTime;
         emitCompleteCallback(true);
      }
      
      private function onLoadFailed(param1:IOErrorEvent) : void
      {
         var _loc2_:String = null;
         if(!this.isHttp || this.retries >= MAX_RETRIES_HTTP)
         {
            _loc2_ = "URLResourceLoader.onLoadFailed " + url + ": ErrorID " + param1.errorID + " - " + param1.toString();
            if(unrequired)
            {
               logger.info(_loc2_);
            }
            else
            {
               logger.error(_loc2_);
            }
            this.unlisten();
            emitCompleteCallback(false);
         }
         else
         {
            ++this.retries;
            this.load();
         }
      }
      
      private function onSecurityError(param1:SecurityErrorEvent) : void
      {
         logger.error("Security error " + url + ": " + param1);
      }
      
      private function onHTTPStatus(param1:HTTPStatusEvent) : void
      {
         if(param1.status != 200)
         {
         }
      }
      
      private function unlisten() : void
      {
         if(this.m_loader)
         {
            this.m_loader.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
            this.m_loader.removeEventListener(Event.COMPLETE,this.onLoadComplete);
            this.m_loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadFailed);
            this.m_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
            this.m_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.onHTTPStatus);
            this.m_loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,this.onHTTPStatus);
         }
      }
      
      override public function unload() : void
      {
         this.unlisten();
         if(this.m_loader)
         {
            this.m_loader.close();
            this.m_loader = null;
         }
      }
      
      override public function get data() : *
      {
         return !!this.m_loader ? this.m_loader.data : null;
      }
      
      override public function get dataFormat() : String
      {
         return !!this.m_loader ? this.m_loader.dataFormat : null;
      }
   }
}
