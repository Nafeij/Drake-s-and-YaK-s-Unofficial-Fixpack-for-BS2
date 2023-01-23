package com.google.analytics.core
{
   import com.google.analytics.debug.DebugConfiguration;
   import com.google.analytics.debug.VisualDebugMode;
   import com.google.analytics.utils.Environment;
   import com.google.analytics.utils.Protocols;
   import com.google.analytics.utils.Variables;
   import com.google.analytics.v4.Configuration;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class GIFRequest
   {
      
      private static const MAX_REQUEST_LENGTH:Number = 2048;
       
      
      private var _config:Configuration;
      
      private var _debug:DebugConfiguration;
      
      private var _buffer:Buffer;
      
      private var _info:Environment;
      
      private var _utmac:String;
      
      private var _lastRequest:URLRequest;
      
      private var _count:int;
      
      private var _alertcount:int;
      
      private var _requests:Array;
      
      public function GIFRequest(param1:Configuration, param2:DebugConfiguration, param3:Buffer, param4:Environment)
      {
         super();
         this._config = param1;
         this._debug = param2;
         this._buffer = param3;
         this._info = param4;
         this._count = 0;
         this._alertcount = 0;
         this._requests = [];
      }
      
      public function get utmac() : String
      {
         return this._utmac;
      }
      
      public function get utmwv() : String
      {
         return this._config.version;
      }
      
      public function get utmn() : String
      {
         return Utils.generate32bitRandom() as String;
      }
      
      public function get utmhn() : String
      {
         return this._info.domainName;
      }
      
      public function get utmsp() : String
      {
         return this._config.sampleRate * 100 as String;
      }
      
      public function get utmcc() : String
      {
         var _loc1_:Array = [];
         if(this._buffer.hasUTMA())
         {
            _loc1_.push(this._buffer.utma.toURLString() + ";");
         }
         if(this._buffer.hasUTMZ())
         {
            _loc1_.push(this._buffer.utmz.toURLString() + ";");
         }
         if(this._buffer.hasUTMV())
         {
            _loc1_.push(this._buffer.utmv.toURLString() + ";");
         }
         return _loc1_.join("+");
      }
      
      public function updateToken() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = new Date().getTime();
         _loc2_ = (_loc1_ - this._buffer.utmb.lastTime) * (this._config.tokenRate / 1000);
         if(this._debug.verbose)
         {
            this._debug.info("tokenDelta: " + _loc2_,VisualDebugMode.geek);
         }
         if(_loc2_ >= 1)
         {
            this._buffer.utmb.token = Math.min(Math.floor(this._buffer.utmb.token + _loc2_),this._config.bucketCapacity);
            this._buffer.utmb.lastTime = _loc1_;
            if(this._debug.verbose)
            {
               this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.geek);
            }
         }
      }
      
      private function _debugSend(param1:URLRequest) : void
      {
         var _loc3_:String = null;
         var _loc2_:* = "";
         switch(this._debug.mode)
         {
            case VisualDebugMode.geek:
               _loc2_ = "Gif Request #" + this._alertcount + ":\n" + param1.url;
               break;
            case VisualDebugMode.advanced:
               _loc3_ = param1.url;
               if(_loc3_.indexOf("?") > -1)
               {
                  _loc3_ = _loc3_.split("?")[0];
               }
               _loc3_ = this._shortenURL(_loc3_);
               _loc2_ = "Send Gif Request #" + this._alertcount + ":\n" + _loc3_ + " ?";
               break;
            case VisualDebugMode.basic:
            default:
               _loc2_ = "Send " + this._config.serverMode.toString() + " Gif Request #" + this._alertcount + " ?";
         }
         this._debug.alertGifRequest(_loc2_,param1,this);
         ++this._alertcount;
      }
      
      private function _shortenURL(param1:String) : String
      {
         var _loc2_:Array = null;
         if(param1.length > 60)
         {
            _loc2_ = param1.split("/");
            while(param1.length > 60)
            {
               _loc2_.shift();
               param1 = "../" + _loc2_.join("/");
            }
         }
         return param1;
      }
      
      public function onSecurityError(param1:SecurityErrorEvent) : void
      {
         if(this._debug.GIFRequests)
         {
            this._debug.failure(param1.text);
         }
      }
      
      public function onIOError(param1:IOErrorEvent) : void
      {
         var _loc2_:String = this._lastRequest.url;
         var _loc3_:String = String(this._requests.length - 1);
         var _loc4_:* = "Gif Request #" + _loc3_ + " failed";
         if(this._debug.GIFRequests)
         {
            if(!this._debug.verbose)
            {
               if(_loc2_.indexOf("?") > -1)
               {
                  _loc2_ = _loc2_.split("?")[0];
               }
               _loc2_ = this._shortenURL(_loc2_);
            }
            if(int(this._debug.mode) > int(VisualDebugMode.basic))
            {
               _loc4_ += " \"" + _loc2_ + "\" does not exists or is unreachable";
            }
            this._debug.failure(_loc4_);
         }
         else
         {
            this._debug.warning(_loc4_);
         }
         this._removeListeners(param1.target);
      }
      
      public function onComplete(param1:Event) : void
      {
         var _loc2_:String = param1.target.loader.name;
         this._requests[_loc2_].complete();
         var _loc3_:* = "Gif Request #" + _loc2_ + " sent";
         var _loc4_:String = this._requests[_loc2_].request.url;
         if(this._debug.GIFRequests)
         {
            if(!this._debug.verbose)
            {
               if(_loc4_.indexOf("?") > -1)
               {
                  _loc4_ = _loc4_.split("?")[0];
               }
               _loc4_ = this._shortenURL(_loc4_);
            }
            if(int(this._debug.mode) > int(VisualDebugMode.basic))
            {
               _loc3_ += " to \"" + _loc4_ + "\"";
            }
            this._debug.success(_loc3_);
         }
         else
         {
            this._debug.info(_loc3_);
         }
         this._removeListeners(param1.target);
      }
      
      private function _removeListeners(param1:Object) : void
      {
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
         param1.removeEventListener(Event.COMPLETE,this.onComplete);
      }
      
      public function sendRequest(param1:URLRequest) : void
      {
         var loader:Loader;
         var context:LoaderContext;
         var request:URLRequest = param1;
         if(request.url.length > MAX_REQUEST_LENGTH)
         {
            this._debug.failure("No request sent. URI length too long.");
            return;
         }
         loader = new Loader();
         loader.name = String(this._count++);
         context = new LoaderContext(false);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         this._lastRequest = request;
         this._requests[loader.name] = new RequestObject(request);
         try
         {
            loader.load(request,context);
         }
         catch(e:Error)
         {
            _debug.failure("\"Loader.load()\" could not instanciate Gif Request");
         }
      }
      
      public function send(param1:String, param2:Variables = null, param3:Boolean = false, param4:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc6_:URLRequest = null;
         var _loc7_:URLRequest = null;
         this._utmac = param1;
         if(!param2)
         {
            param2 = new Variables();
         }
         param2.URIencode = false;
         param2.pre = ["utmwv","utmn","utmhn","utmt","utme","utmcs","utmsr","utmsc","utmul","utmje","utmfl","utmdt","utmhid","utmr","utmp"];
         param2.post = ["utmcc"];
         if(this._debug.verbose)
         {
            this._debug.info("tracking: " + this._buffer.utmb.trackCount + "/" + this._config.trackingLimitPerSession,VisualDebugMode.geek);
         }
         if(this._buffer.utmb.trackCount < this._config.trackingLimitPerSession || param3)
         {
            if(param4)
            {
               this.updateToken();
            }
            if(param3 || !param4 || this._buffer.utmb.token >= 1)
            {
               if(!param3 && param4)
               {
                  --this._buffer.utmb.token;
               }
               this._buffer.utmb.trackCount += 1;
               if(this._debug.verbose)
               {
                  this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.geek);
               }
               param2.utmwv = this.utmwv;
               param2.utmn = Utils.generate32bitRandom();
               if(this._info.domainName != "")
               {
                  param2.utmhn = this._info.domainName;
               }
               if(this._config.sampleRate < 1)
               {
                  param2.utmsp = this._config.sampleRate * 100;
               }
               if(this._config.serverMode == ServerOperationMode.local || this._config.serverMode == ServerOperationMode.both)
               {
                  _loc5_ = this._info.locationSWFPath;
                  if(_loc5_.lastIndexOf("/") > 0)
                  {
                     _loc5_ = _loc5_.substring(0,_loc5_.lastIndexOf("/"));
                  }
                  _loc6_ = new URLRequest();
                  if(this._config.localGIFpath.indexOf("http") == 0)
                  {
                     _loc6_.url = this._config.localGIFpath;
                  }
                  else
                  {
                     _loc6_.url = _loc5_ + this._config.localGIFpath;
                  }
                  _loc6_.url += "?" + param2.toString();
                  if(this._debug.active && this._debug.GIFRequests)
                  {
                     this._debugSend(_loc6_);
                  }
                  else
                  {
                     this.sendRequest(_loc6_);
                  }
               }
               if(this._config.serverMode == ServerOperationMode.remote || this._config.serverMode == ServerOperationMode.both)
               {
                  _loc7_ = new URLRequest();
                  if(this._info.protocol == Protocols.HTTPS)
                  {
                     _loc7_.url = this._config.secureRemoteGIFpath;
                  }
                  else if(this._info.protocol == Protocols.HTTP)
                  {
                     _loc7_.url = this._config.remoteGIFpath;
                  }
                  else
                  {
                     _loc7_.url = this._config.remoteGIFpath;
                  }
                  param2.utmac = this.utmac;
                  param2.utmcc = encodeURIComponent(this.utmcc);
                  _loc7_.url += "?" + param2.toString();
                  if(this._debug.active && this._debug.GIFRequests)
                  {
                     this._debugSend(_loc7_);
                  }
                  else
                  {
                     this.sendRequest(_loc7_);
                  }
               }
            }
         }
      }
   }
}
