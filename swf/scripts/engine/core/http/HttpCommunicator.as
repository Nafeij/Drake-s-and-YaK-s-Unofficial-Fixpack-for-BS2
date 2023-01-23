package engine.core.http
{
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class HttpCommunicator extends EventDispatcher
   {
      
      private static const DEFAULT_POLL_TIME:int = 3000;
       
      
      private var m_logger:ILogger;
      
      private var m_hostUrl:String;
      
      private var txnProcessedCallback:Function;
      
      private var txnPollCallback:Function;
      
      private var _pollTimeMs:int = 3000;
      
      private var _connected:Boolean;
      
      public var errorState:HttpErrorState;
      
      private var txnFetch:HttpJsonAction;
      
      private var polltimes:Dictionary;
      
      public function HttpCommunicator(param1:ILogger, param2:String, param3:Function, param4:Function)
      {
         this.polltimes = new Dictionary();
         super();
         this.m_logger = param1;
         this.m_hostUrl = param2;
         this.txnProcessedCallback = param3;
         this.txnPollCallback = param4;
         this.errorState = new HttpErrorState(param1);
         param1.info("HttpCommunicator hostUrl=" + param2);
      }
      
      public function request(param1:String, param2:HttpRequestMethod, param3:Object, param4:Function) : HttpRequest
      {
         var url:String = param1;
         var method:HttpRequestMethod = param2;
         var body:Object = param3;
         var responseCallback:Function = param4;
         if(!method)
         {
            throw new ArgumentError("fail method");
         }
         return new HttpRequest(this.m_hostUrl + url,method,body,function(param1:*, param2:Boolean, param3:int):void
         {
            if(param3 == 0 || param3 >= 401 && param3 != 500)
            {
               errorState.noticeError();
            }
            else
            {
               errorState.noticeOk();
            }
            responseCallback(param1,param2,param3);
         },this.m_logger);
      }
      
      final public function requestGet(param1:String, param2:Object, param3:Function) : HttpRequest
      {
         return this.request(this.m_hostUrl + param1,HttpRequestMethod.GET,param2,param3);
      }
      
      final public function requestPost(param1:String, param2:Object, param3:Function) : HttpRequest
      {
         return this.request(this.m_hostUrl + param1,HttpRequestMethod.POST,param2,param3);
      }
      
      public function get logger() : ILogger
      {
         return this.m_logger;
      }
      
      public function get hostUrl() : String
      {
         return this.m_hostUrl;
      }
      
      public function set hostUrl(param1:String) : void
      {
         this.m_hostUrl = param1;
      }
      
      public function onHttpTxnResponseProcessed(param1:HttpAction) : void
      {
         if(!this._connected && !param1.isMaintenance)
         {
            return;
         }
         if(this.txnProcessedCallback != null)
         {
            this.txnProcessedCallback(param1);
         }
         this.checkPoll();
         dispatchEvent(new HttpTxnResponseProcessedEvent(param1));
      }
      
      private function get pollTimeMs() : int
      {
         return this._pollTimeMs;
      }
      
      private function set pollTimeMs(param1:int) : void
      {
         if(this._pollTimeMs == param1)
         {
            return;
         }
         this._pollTimeMs = param1;
         this.checkPoll();
      }
      
      private function checkPoll() : void
      {
         if(Boolean(this.txnFetch) && !this.txnFetch.sent)
         {
            this.txnFetch.abort();
            this.txnFetch = null;
         }
         if(!this._connected || this._pollTimeMs <= 0)
         {
            return;
         }
         if(this.txnPollCallback != null)
         {
            this.txnFetch = this.txnPollCallback();
            if(this.txnFetch)
            {
               this.txnFetch.send(this,this.fetchHandler,this._pollTimeMs);
            }
         }
      }
      
      private function fetchHandler(param1:HttpJsonAction) : void
      {
         this.checkPoll();
      }
      
      public function get connected() : Boolean
      {
         return this._connected;
      }
      
      public function set connected(param1:Boolean) : void
      {
         if(this._connected == param1)
         {
            return;
         }
         this._connected = param1;
         this.checkPoll();
      }
      
      public function setPollTimeRequirement(param1:Object, param2:int) : void
      {
         this.polltimes[param1] = param2;
         this.resetPollTime();
      }
      
      public function removePollTimeRequirement(param1:Object) : void
      {
         delete this.polltimes[param1];
         this.resetPollTime();
      }
      
      private function resetPollTime() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = DEFAULT_POLL_TIME;
         for each(_loc2_ in this.polltimes)
         {
            if(_loc2_ > 0 && _loc2_ < _loc1_)
            {
               _loc1_ = _loc2_;
            }
         }
         this.pollTimeMs = _loc1_;
      }
   }
}
