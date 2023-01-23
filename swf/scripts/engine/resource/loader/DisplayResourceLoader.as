package engine.resource.loader
{
   import engine.core.logging.ILogger;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class DisplayResourceLoader extends IResourceLoader implements IResourceLoaderListener
   {
       
      
      private var _logger:ILogger;
      
      public var loader:Loader;
      
      public var urlResourceLoader:URLResourceLoader;
      
      public function DisplayResourceLoader(param1:String, param2:IResourceLoaderListener, param3:ILogger)
      {
         var url:String = param1;
         var listener:IResourceLoaderListener = param2;
         var logger:ILogger = param3;
         this.loader = new Loader();
         super(url,listener,logger);
         this._logger = logger;
         try
         {
            this.urlResourceLoader = new URLResourceLoader(url,this,logger,true);
         }
         catch(error:Error)
         {
            logger.error("DisplayResourceLoader proxy failed " + url + ": " + error);
            emitCompleteCallback(false);
         }
      }
      
      public function resourceLoaderCompleteHandler(param1:IResourceLoader) : void
      {
         this.urlResourceLoaderCompleteHandler(param1 as URLResourceLoader);
      }
      
      private function urlResourceLoaderCompleteHandler(param1:URLResourceLoader) : void
      {
         var bytes:ByteArray = null;
         var appDomain:ApplicationDomain = null;
         var secDomain:SecurityDomain = null;
         var ldrContext:LoaderContext = null;
         var s:int = 0;
         var e:int = 0;
         var d:int = 0;
         var rhs:URLResourceLoader = param1;
         processingTime = rhs.processingTime;
         loadTime = rhs.loadTime;
         startTime = getTimer();
         if(error || !rhs || rhs.error)
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("DisplayResourceLoader proxy failed: " + url);
            }
            emitCompleteCallback(false);
            return;
         }
         try
         {
            bytes = this.urlResourceLoader.data as ByteArray;
            if(bytes.length <= 0)
            {
               logger.error("DisplayResourceLoader proxy ZERO BYTES " + url);
               emitCompleteCallback(false);
               return;
            }
            appDomain = null;
            secDomain = null;
            ldrContext = new LoaderContext(false,appDomain,secDomain);
            ldrContext.allowCodeImport = true;
            this.loader.contentLoaderInfo.addEventListener(Event.INIT,this.onLoadInit);
            this.loader.contentLoaderInfo.addEventListener(Event.OPEN,this.onLoadOpen);
            this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
            this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadFailed);
            this.loader.contentLoaderInfo.addEventListener(Event.UNLOAD,this.loaderInfoUnloadHandler);
            this.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.loaderInfoHttpStatusHandler);
            this.loader.contentLoaderInfo.addEventListener(Event.DEACTIVATE,this.loaderInfoDeactivateHandler);
            s = getTimer();
            this.loader.loadBytes(bytes,ldrContext);
            e = getTimer();
            d = e - s;
            if(this.urlResourceLoader)
            {
               this.urlResourceLoader.unload();
               this.urlResourceLoader = null;
            }
         }
         catch(error:Error)
         {
            logger.error("DisplayResourceLoader proxy unpack failed " + url + ": " + error + "\n" + error.getStackTrace());
            emitCompleteCallback(false);
         }
      }
      
      protected function loaderInfoDeactivateHandler(param1:Event) : void
      {
      }
      
      protected function loaderInfoHttpStatusHandler(param1:HTTPStatusEvent) : void
      {
      }
      
      protected function loaderInfoProgressHandler(param1:ProgressEvent) : void
      {
      }
      
      protected function loaderInfoUnloadHandler(param1:Event) : void
      {
      }
      
      private function onLoadInit(param1:Event) : void
      {
      }
      
      private function onLoadOpen(param1:Event) : void
      {
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         if(Boolean(this.loader) && Boolean(this.loader.contentLoaderInfo))
         {
            numBytes = this.loader.contentLoaderInfo.bytesTotal;
         }
         this.unlisten();
         processingTime += getTimer() - startTime;
         emitCompleteCallback(true);
      }
      
      private function onLoadFailed(param1:IOErrorEvent) : void
      {
         logger.error("DisplayResourceLoader onLoadFailed proxy loadBytes " + url + " " + param1.text);
         this.unlisten();
         emitCompleteCallback(false);
      }
      
      private function unlisten() : void
      {
         if(Boolean(this.loader) && Boolean(this.loader.contentLoaderInfo))
         {
            this.loader.contentLoaderInfo.removeEventListener(Event.INIT,this.onLoadInit);
            this.loader.contentLoaderInfo.removeEventListener(Event.OPEN,this.onLoadOpen);
            this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadComplete);
            this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadFailed);
            this.loader.contentLoaderInfo.removeEventListener(Event.UNLOAD,this.loaderInfoUnloadHandler);
            this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.loaderInfoProgressHandler);
            this.loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.loaderInfoHttpStatusHandler);
            this.loader.contentLoaderInfo.removeEventListener(Event.DEACTIVATE,this.loaderInfoDeactivateHandler);
         }
      }
      
      override public function unload() : void
      {
         this.unlisten();
         if(this.loader)
         {
            this.loader.unloadAndStop();
            this.loader = null;
         }
         if(this.urlResourceLoader)
         {
            this.urlResourceLoader.unload();
            this.urlResourceLoader = null;
         }
      }
      
      public function get content() : DisplayObject
      {
         return this.loader.content;
      }
      
      override public function get data() : *
      {
         return this.content;
      }
   }
}
