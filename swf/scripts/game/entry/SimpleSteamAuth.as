package game.entry
{
   import com.adobe.crypto.MD5;
   import engine.core.logging.ILogger;
   import engine.session.IAuthentication;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   
   public class SimpleSteamAuth
   {
       
      
      private var auth:IAuthentication;
      
      private var callback:Function;
      
      private var handle:int;
      
      private var ready:Boolean;
      
      private var logger:ILogger;
      
      private var m_loader:URLLoader;
      
      public var ok:Boolean;
      
      public var ticket:String;
      
      public var user:String;
      
      public var hash:String;
      
      public function SimpleSteamAuth(param1:IAuthentication, param2:ILogger, param3:Function)
      {
         super();
         this.auth = param1;
         this.callback = param3;
         this.logger = param2;
         this.ticket = param1.requestAuthSessionTicket(null);
         this.user = param1.getUserID();
         this.hash = MD5.hash(this.user + "/" + this.ticket);
      }
      
      public function start() : void
      {
         var _loc1_:String = "https://tbs2-authenticator.herokuapp.com/?ticket=" + this.ticket + "&userid=" + this.user;
         var _loc2_:URLRequest = new URLRequest(_loc1_);
         _loc2_.method = URLRequestMethod.GET;
         this.m_loader = new URLLoader();
         this.m_loader.addEventListener(Event.COMPLETE,this.onUrlLoadComplete);
         this.m_loader.addEventListener(IOErrorEvent.IO_ERROR,this.onUrlIoError);
         try
         {
            this.m_loader.load(_loc2_);
         }
         catch(error:Error)
         {
         }
      }
      
      protected function onUrlIoError(param1:IOErrorEvent) : void
      {
         this.logger.error("SimpleSteamAuth IO failed: " + param1);
         if(this.callback != null)
         {
            this.callback(null);
         }
      }
      
      protected function onUrlLoadComplete(param1:Event) : void
      {
         var _loc4_:String = null;
         var _loc2_:String = this.m_loader.data;
         if(!_loc2_)
         {
            this.logger.error("SimpleSteamAuth no response");
            this.callback(null);
            return;
         }
         var _loc3_:Array = _loc2_.split(" ");
         if(_loc3_[0] == "fail")
         {
            this.logger.error("SimpleSteamAuth response fail");
            this.callback(null);
         }
         else if(_loc3_[0] == "ok")
         {
            this.ok = true;
            _loc4_ = String(_loc3_[1]);
            if(_loc4_ != this.hash)
            {
               this.logger.error("SimpleSteamAuth response with invalid ticket");
               this.callback(null);
            }
            else
            {
               this.logger.info("SimpleSteamAuth response ok");
               this.callback(this.ticket);
            }
         }
         else
         {
            this.logger.error("SimpleSteamAuth response unknown [" + _loc2_ + "]");
            this.callback(null);
         }
      }
   }
}
