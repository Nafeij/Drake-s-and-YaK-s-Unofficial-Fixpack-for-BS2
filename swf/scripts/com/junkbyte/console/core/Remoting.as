package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleLevel;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   [Event(name="connect",type="flash.events.Event")]
   public class Remoting extends ConsoleCore
   {
       
      
      protected var _callbacks:Object;
      
      protected var _remoting:Boolean;
      
      protected var _local:LocalConnection;
      
      protected var _socket:Socket;
      
      protected var _sendBuffer:ByteArray;
      
      protected var _recBuffers:Object;
      
      protected var _senders:Dictionary;
      
      protected var _loggedIn:Boolean;
      
      protected var _selfId:String;
      
      protected var _lastRecieverId:String;
      
      public function Remoting(param1:Console)
      {
         var m:Console = param1;
         this._callbacks = new Object();
         this._sendBuffer = new ByteArray();
         this._recBuffers = new Object();
         this._senders = new Dictionary();
         super(m);
         this.registerCallback("login",function(param1:ByteArray):void
         {
            login(param1.readUTF());
         });
      }
      
      public function update() : void
      {
         var _loc1_:String = null;
         var _loc2_:ByteArray = null;
         var _loc3_:ByteArray = null;
         if(this._sendBuffer.length)
         {
            if(Boolean(this._socket) && this._socket.connected)
            {
               this._socket.writeBytes(this._sendBuffer);
               this._sendBuffer = new ByteArray();
            }
            else if(this._local)
            {
               this._sendBuffer.position = 0;
               if(this._sendBuffer.bytesAvailable < 38000)
               {
                  _loc2_ = this._sendBuffer;
                  this._sendBuffer = new ByteArray();
               }
               else
               {
                  _loc2_ = new ByteArray();
                  this._sendBuffer.readBytes(_loc2_,0,Math.min(38000,this._sendBuffer.bytesAvailable));
                  _loc3_ = new ByteArray();
                  this._sendBuffer.readBytes(_loc3_);
                  this._sendBuffer = _loc3_;
               }
               this._local.send(this.remoteLocalConnectionName,"synchronize",this._selfId,_loc2_);
            }
            else
            {
               this._sendBuffer = new ByteArray();
            }
         }
         for(_loc1_ in this._recBuffers)
         {
            this.processRecBuffer(_loc1_);
         }
      }
      
      protected function get selfLlocalConnectionName() : String
      {
         return config.remotingConnectionName + "Sender";
      }
      
      protected function get remoteLocalConnectionName() : String
      {
         return config.remotingConnectionName + "Receiver";
      }
      
      private function processRecBuffer(param1:String) : void
      {
         var buffer:ByteArray;
         var pointer:uint = 0;
         var cmdlen:uint = 0;
         var cmd:String = null;
         var arg:ByteArray = null;
         var callbackData:Object = null;
         var blen:uint = 0;
         var recbuffer:ByteArray = null;
         var id:String = param1;
         if(!this._senders[id])
         {
            this._senders[id] = true;
            if(this._lastRecieverId)
            {
               report("Switched to [" + id + "] as primary remote.",-2);
            }
            this._lastRecieverId = id;
         }
         buffer = this._recBuffers[id];
         try
         {
            pointer = uint(buffer.position = 0);
            while(buffer.bytesAvailable)
            {
               cmdlen = uint(buffer.readByte());
               if(buffer.bytesAvailable == 0)
               {
                  break;
               }
               cmd = buffer.readUTFBytes(cmdlen);
               arg = null;
               if(buffer.bytesAvailable == 0)
               {
                  break;
               }
               if(buffer.readBoolean())
               {
                  if(buffer.bytesAvailable == 0)
                  {
                     break;
                  }
                  blen = buffer.readUnsignedInt();
                  if(buffer.bytesAvailable < blen)
                  {
                     break;
                  }
                  arg = new ByteArray();
                  buffer.readBytes(arg,0,blen);
               }
               callbackData = this._callbacks[cmd];
               if(callbackData == null)
               {
                  report("Unknown remote commmand received [" + cmd + "].",ConsoleLevel.ERROR);
               }
               else if(!callbackData.latest || id == this._lastRecieverId)
               {
                  if(arg)
                  {
                     callbackData.fun(arg);
                  }
                  else
                  {
                     callbackData.fun();
                  }
               }
               pointer = buffer.position;
            }
            if(pointer < buffer.length)
            {
               recbuffer = new ByteArray();
               recbuffer.writeBytes(buffer,pointer);
               this._recBuffers[id] = buffer = recbuffer;
            }
            else
            {
               delete this._recBuffers[id];
            }
         }
         catch(err:Error)
         {
            report("Remoting sync error: " + err,9);
         }
      }
      
      private function synchronize(param1:String, param2:Object) : void
      {
         var _loc3_:ByteArray = param2 as ByteArray;
         if(_loc3_ == null)
         {
            report("Remoting sync error. Recieved non-ByteArray:" + param2,9);
            return;
         }
         var _loc4_:ByteArray = this._recBuffers[param1];
         if(_loc4_)
         {
            _loc4_.position = _loc4_.length;
            _loc4_.writeBytes(_loc3_);
         }
         else
         {
            this._recBuffers[param1] = _loc3_;
         }
      }
      
      public function send(param1:String, param2:ByteArray = null) : Boolean
      {
         if(!this._remoting)
         {
            return false;
         }
         this._sendBuffer.position = this._sendBuffer.length;
         this._sendBuffer.writeByte(param1.length);
         this._sendBuffer.writeUTFBytes(param1);
         if(param2)
         {
            this._sendBuffer.writeBoolean(true);
            this._sendBuffer.writeUnsignedInt(param2.length);
            this._sendBuffer.writeBytes(param2);
         }
         else
         {
            this._sendBuffer.writeBoolean(false);
         }
         return true;
      }
      
      public function get connected() : Boolean
      {
         return this._remoting && this._loggedIn;
      }
      
      public function get remoting() : Boolean
      {
         return this._remoting;
      }
      
      public function set remoting(param1:Boolean) : void
      {
         if(param1 == this._remoting)
         {
            return;
         }
         this._selfId = this.generateId();
         if(param1)
         {
            this.startRemoting();
         }
         else
         {
            this.close();
         }
         console.panels.updateMenu();
      }
      
      protected function startRemoting() : void
      {
         if(!this.startLocalConnection())
         {
            report("Could not create remoting client service.",10);
            return;
         }
         this._sendBuffer = new ByteArray();
         report("<b>Remoting started.</b> " + this.getInfo(),-1);
         this.send("started");
      }
      
      public function remotingSocket(param1:String, param2:int = 0) : void
      {
         if(Boolean(this._socket) && this._socket.connected)
         {
            this._socket.close();
            this._socket = null;
         }
         if(Boolean(param1) && Boolean(param2))
         {
            this.remoting = true;
            report("Connecting to socket " + param1 + ":" + param2);
            this._socket = new Socket();
            this._socket.addEventListener(Event.CLOSE,this.socketCloseHandler);
            this._socket.addEventListener(Event.CONNECT,this.socketConnectHandler);
            this._socket.addEventListener(IOErrorEvent.IO_ERROR,this.socketIOErrorHandler);
            this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.socketSecurityErrorHandler);
            this._socket.addEventListener(ProgressEvent.SOCKET_DATA,this.socketDataHandler);
            this._socket.connect(param1,param2);
         }
      }
      
      private function socketCloseHandler(param1:Event) : void
      {
         if(param1.currentTarget == this._socket)
         {
            this._socket = null;
         }
      }
      
      private function socketConnectHandler(param1:Event) : void
      {
         report("Remoting socket connected.",-1);
         this._sendBuffer = new ByteArray();
         if(this._loggedIn || this.checkLogin(""))
         {
            this.sendLoginSuccess();
         }
         else
         {
            this.send("loginRequest");
         }
      }
      
      private function socketIOErrorHandler(param1:Event) : void
      {
         report("Remoting socket error." + param1,9);
         this.remotingSocket(null);
      }
      
      private function socketSecurityErrorHandler(param1:Event) : void
      {
         report("Remoting security error." + param1,9);
         this.remotingSocket(null);
      }
      
      private function socketDataHandler(param1:Event) : void
      {
         this.handleSocket(param1.currentTarget as Socket);
      }
      
      public function handleSocket(param1:Socket) : void
      {
         if(!this._senders[param1])
         {
            this._senders[param1] = this.generateId();
            this._socket = param1;
         }
         var _loc2_:ByteArray = new ByteArray();
         param1.readBytes(_loc2_);
         this.synchronize(this._senders[param1],_loc2_);
      }
      
      protected function onLocalConnectionStatus(param1:StatusEvent) : void
      {
         if(param1.level == "error" && this._loggedIn && !(this._socket && this._socket.connected))
         {
            report("Remote connection lost.",ConsoleLevel.ERROR);
            this._loggedIn = false;
         }
      }
      
      protected function onRemoteAsyncError(param1:AsyncErrorEvent) : void
      {
         report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.",10);
         this.remoting = false;
      }
      
      protected function onRemotingSecurityError(param1:SecurityErrorEvent) : void
      {
         report("Remoting security error.",9);
         this.printHowToGlobalSetting();
      }
      
      protected function getInfo() : String
      {
         return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
      }
      
      protected function printHowToGlobalSetting() : void
      {
         report("Make sure your flash file is \'trusted\' in Global Security Settings.",-2);
         report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\'  &gt; add the location of the local flash (swf) file.",-2);
      }
      
      protected function generateId() : String
      {
         return new Date().time + "." + Math.floor(Math.random() * 100000);
      }
      
      protected function startLocalConnection() : Boolean
      {
         this.close();
         this._remoting = true;
         this._local = new LocalConnection();
         this._local.client = {"synchronize":this.synchronize};
         this._local.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRemotingSecurityError,false,0,true);
         this._local.addEventListener(StatusEvent.STATUS,this.onLocalConnectionStatus,false,0,true);
         this._local.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onRemoteAsyncError,false,0,true);
         try
         {
            this._local.connect(this.selfLlocalConnectionName);
         }
         catch(err:Error)
         {
            _remoting = false;
            _local = null;
            return false;
         }
         return true;
      }
      
      public function registerCallback(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._callbacks[param1] = {
            "fun":param2,
            "latest":param3
         };
      }
      
      private function sendLoginSuccess() : void
      {
         this._loggedIn = true;
         this.send("loginSuccess");
         dispatchEvent(new Event(Event.CONNECT));
      }
      
      public function login(param1:String = "") : void
      {
         if(this._loggedIn || this.checkLogin(param1))
         {
            this.sendLoginSuccess();
         }
         else
         {
            this.send("loginFail");
         }
      }
      
      private function checkLogin(param1:String) : Boolean
      {
         return config.remotingPassword === null && config.keystrokePassword == param1 || config.remotingPassword === "" || config.remotingPassword == param1;
      }
      
      public function close() : void
      {
         if(this._local)
         {
            try
            {
               this._local.close();
            }
            catch(error:Error)
            {
               report("Remote.close: " + error,10);
            }
         }
         this._remoting = false;
         this._sendBuffer = new ByteArray();
         this._local = null;
      }
   }
}
