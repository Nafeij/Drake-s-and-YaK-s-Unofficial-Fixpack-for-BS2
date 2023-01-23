package game.view
{
   import com.greensock.TweenMax;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.StableJson;
   import engine.saga.Saga;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.HappeningDefBag;
   import engine.saga.happening.HappeningDefVars;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.ServerSocketConnectEvent;
   import flash.net.ServerSocket;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import game.cfg.GameConfig;
   
   public class GameDevSocket implements IGameDevSocket
   {
       
      
      public var PORT:int = 8346;
      
      public var socket:ServerSocket;
      
      public var client:Socket;
      
      public var logger:ILogger;
      
      public var wrap:GameWrapper;
      
      public var config:GameConfig;
      
      public var incoming:Object;
      
      public var ready:Boolean;
      
      public var cleanedup:Boolean;
      
      private var hello:Boolean;
      
      private var bookmark:HappeningDef;
      
      public function GameDevSocket(param1:ILogger, param2:GameWrapper)
      {
         super();
         param1.i("SOCK","CTOR GameDevSocket");
         this.logger = param1;
         this.wrap = param2;
         this.config = param2.config;
         this.config.addEventListener(GameConfig.EVENT_SAGA_STARTED,this.sagaStartedHandler);
         this.attemptListen();
      }
      
      public function cleanup() : void
      {
         this.cleanedup = true;
         if(this.socket)
         {
            this.socket.close();
            this.socket = null;
         }
      }
      
      private function sagaStartedHandler(param1:Event) : void
      {
         this.checkReady();
      }
      
      private function attemptListen() : void
      {
         if(Boolean(this.socket) || this.cleanedup)
         {
            return;
         }
         try
         {
            this.socket = new ServerSocket();
            this.socket.bind(this.PORT);
            this.socket.addEventListener(ServerSocketConnectEvent.CONNECT,this.connectHandler);
            this.socket.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
            this.socket.listen(0);
            this.logger.i("SOCK","GameDevSocket listening on " + this.PORT);
         }
         catch(e:Error)
         {
            removeListeners();
            socket = null;
            TweenMax.delayedCall(1,attemptListen);
         }
      }
      
      private function removeListeners() : void
      {
         if(!this.socket)
         {
            return;
         }
         this.socket.removeEventListener(ServerSocketConnectEvent.CONNECT,this.connectHandler);
         this.socket.removeEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
      }
      
      private function connectHandler(param1:ServerSocketConnectEvent) : void
      {
         this.ready = false;
         this.hello = false;
         this.bookmark = null;
         this.client = param1.socket;
         this.logger.i("SOCK","GameDevSocket.connect " + this.PORT + " from " + this.client.remoteAddress + ":" + this.client.remotePort);
         this.client.addEventListener(ProgressEvent.SOCKET_DATA,this.clientSocketDataHandler);
      }
      
      private function checkReady() : void
      {
         if(!this.hello || this.ready)
         {
            return;
         }
         var _loc1_:Saga = this.config.saga;
         if(!_loc1_ || !_loc1_.started)
         {
            return;
         }
         this.ready = true;
         var _loc2_:AppInfo = this.config.context.appInfo;
         var _loc3_:Object = {
            "ready":true,
            "version":_loc2_.buildVersion,
            "exe":_loc2_.applicationDirectoryUrl_native
         };
         var _loc4_:String = StableJson.stringifyObject(_loc3_);
         this.client.writeUTFBytes(_loc4_);
         this.client.flush();
         this._executeBookmark();
      }
      
      private function clientSocketDataHandler(param1:ProgressEvent) : void
      {
         var buffer:ByteArray;
         var msg:String = null;
         var json:Object = null;
         var event:ProgressEvent = param1;
         if(!this.wrap || !this.wrap.config)
         {
            return;
         }
         buffer = new ByteArray();
         this.client.readBytes(buffer,0,this.client.bytesAvailable);
         try
         {
            buffer.position = 0;
            msg = buffer.readUTF();
            buffer.clear();
            if(!msg)
            {
               return;
            }
            json = JSON.parse(msg);
            if(!json || !json.ping)
            {
               this.logger.i("SOCK","GameDevSocket Received: " + msg);
            }
            this.parseIncomingMsg(json);
            this.wrap.config.context.appInfo.bringAppToFront();
         }
         catch(e:Error)
         {
            logger.e("SOCK","GameDevSocket Malformed message: [" + msg + "]\n" + e.getStackTrace());
         }
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this.logger.e("SOCK","Failed to open GameDevSocket on port " + this.PORT + ":\n" + param1);
         TweenMax.delayedCall(1,this.attemptListen);
      }
      
      private function parseIncomingMsg(param1:Object) : void
      {
         this.incoming = param1;
         this._processIncoming();
      }
      
      private function _processIncoming() : Boolean
      {
         if(this.cleanedup)
         {
            return false;
         }
         if(!this.incoming)
         {
            return true;
         }
         if(this._processIncomingHello())
         {
            return true;
         }
         if(this._processIncomingBookmark())
         {
            return true;
         }
         TweenMax.delayedCall(1,this._processIncoming);
         return false;
      }
      
      private function _processIncomingHello() : Boolean
      {
         if(!this.incoming)
         {
            return true;
         }
         var _loc1_:Object = this.incoming;
         var _loc2_:Boolean = Boolean(_loc1_.hello);
         if(_loc2_)
         {
            this.hello = true;
            this.checkReady();
            return true;
         }
         return false;
      }
      
      private function _processIncomingBookmark() : Boolean
      {
         if(!this.incoming)
         {
            return true;
         }
         var _loc1_:Object = this.incoming.bookmark;
         var _loc2_:Boolean = Boolean(this.incoming.reset);
         if(_loc1_)
         {
            this.bookmark = new HappeningDefVars(null).fromJson(_loc1_,this.logger,false);
            if(!this.ready)
            {
               this.logger.i("SOCK","Received bookmark prior to ready, saving for later...");
            }
            else
            {
               this._executeBookmark();
            }
            this.incoming = null;
            return true;
         }
         return false;
      }
      
      private function _executeBookmark() : void
      {
         if(!this.bookmark)
         {
            return;
         }
         var _loc1_:Saga = this.config.saga;
         if(!this.ready || !_loc1_)
         {
            return;
         }
         var _loc2_:String = this.bookmark.id;
         var _loc3_:HappeningDefBag = _loc1_.def.happenings;
         _loc3_.removeHappeningDefById(this.bookmark.id);
         _loc3_.addHappeningDef(this.bookmark);
         this.bookmark = null;
         this.wrap.config.saga.gotoBookmark(_loc2_,true);
      }
   }
}
