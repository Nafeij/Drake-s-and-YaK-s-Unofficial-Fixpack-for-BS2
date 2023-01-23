package engine.session
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Credentials extends EventDispatcher
   {
      
      public static const EVENT_COMMITTED:String = "Credentials.EVENT_COMMITTED";
      
      public static const EVENT_VALIDATION:String = "Credentials.EVENT_VALIDATION";
      
      public static const EVENT_SESSION:String = "Credentials.EVENT_SESSION";
       
      
      private var _vbb_name:String;
      
      private var _gameServerUrl:String;
      
      public var offline:Boolean;
      
      private var _valid:Boolean;
      
      private var _sessionKey:String;
      
      public var logger:ILogger;
      
      public var userId:int;
      
      public var password:String;
      
      public var steamId:String;
      
      public var steamAuthTicketHandle:int;
      
      public var steamAuthTicket:String;
      
      public var childNumber:int;
      
      public var displayName:String;
      
      public var protocolVersion:int;
      
      public function Credentials(param1:String, param2:int, param3:String, param4:int, param5:ILogger)
      {
         super();
         this.protocolVersion = param4;
         this._vbb_name = param1;
         this._gameServerUrl = param3;
         this.logger = param5;
         this.childNumber = param2;
      }
      
      public function commit() : void
      {
         this.validate();
         if(this.valid)
         {
            dispatchEvent(new Event(EVENT_COMMITTED));
         }
      }
      
      public function validate() : void
      {
         this.valid = this.checkValidity();
      }
      
      public function checkValidity() : Boolean
      {
         if(this._gameServerUrl)
         {
            if(Boolean(this._vbb_name) && Boolean(this.password))
            {
               return true;
            }
            if(Boolean(this.steamId) && Boolean(this.steamAuthTicket))
            {
               return true;
            }
            if(Boolean(this.sessionKey) && Boolean(this.userId))
            {
               return true;
            }
         }
         return false;
      }
      
      public function get valid() : Boolean
      {
         return this._valid;
      }
      
      public function set valid(param1:Boolean) : void
      {
         if(this._valid != param1)
         {
            this._valid = param1;
            dispatchEvent(new Event(EVENT_VALIDATION));
         }
      }
      
      public function get vbb_name() : String
      {
         return this._vbb_name;
      }
      
      public function set vbb_name(param1:String) : void
      {
         this._vbb_name = param1;
         this.validate();
      }
      
      public function get gameServerUrl() : String
      {
         return this._gameServerUrl;
      }
      
      public function set gameServerUrl(param1:String) : void
      {
         this._gameServerUrl = param1;
         this.validate();
      }
      
      public function get sessionKey() : String
      {
         return this._sessionKey;
      }
      
      public function set sessionKey(param1:String) : void
      {
         if(this._sessionKey == param1)
         {
            return;
         }
         this._sessionKey = param1;
         this.logger.i("CRED","Credentials.sessionKey " + this.userId + " " + this.vbb_name + " " + this.displayName + " " + this.sessionKey);
         this.validate();
         dispatchEvent(new Event(EVENT_SESSION));
      }
      
      public function get urlCred() : String
      {
         return "/" + this.sessionKey;
      }
   }
}
