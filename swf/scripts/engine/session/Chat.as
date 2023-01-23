package engine.session
{
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   import tbs.srv.data.FriendsData;
   
   public class Chat extends EventDispatcher
   {
      
      public static const GLOBAL_ROOM:String = "global";
      
      public static const FRIEND_NOTIFICATION_ROOM:String = "friend_notification";
      
      public static const LOBBY_ROOM_PREFIX:String = "lobby";
      
      private static const SENT_POLL_MS:int = 500;
       
      
      public var session:Session;
      
      public var rooms:Vector.<String>;
      
      private var logger:ILogger;
      
      private var send:ChatSendTxn;
      
      private var sent:int;
      
      private var friends:FriendsData;
      
      public var globalMsgs:Array;
      
      public function Chat(param1:Session, param2:FriendsData, param3:ILogger)
      {
         this.rooms = new Vector.<String>();
         this.globalMsgs = new Array();
         super();
         this.session = param1;
         this.logger = param3;
         this.friends = param2;
      }
      
      public function enterRoom(param1:String) : void
      {
         this.rooms.push(param1);
      }
      
      public function exitRoom(param1:String) : void
      {
         var _loc2_:int = this.rooms.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.rooms.splice(_loc2_,1);
         }
      }
      
      public function sendMessage(param1:String, param2:String) : void
      {
         ++this.sent;
         this.session.communicator.setPollTimeRequirement(this,SENT_POLL_MS);
         this.send = new ChatSendTxn(param1,param2,this.session.credentials,this.chatSendHandler,this.logger);
         this.send.send(this.session.communicator);
      }
      
      public function handleChatMsg(param1:ChatMsg) : void
      {
         this.logger.i("CHAT","Chat received: " + param1);
         this.addGlobalMsg(param1);
         dispatchEvent(new ChatEvent(param1));
         --this.sent;
         if(this.sent <= 0)
         {
            this.session.communicator.removePollTimeRequirement(this);
         }
         if(param1.user != this.session.credentials.userId)
         {
            this.friends.setOnline(param1.user,true);
         }
      }
      
      private function addGlobalMsg(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.room == GLOBAL_ROOM)
         {
            this.globalMsgs.push(param1);
            _loc2_ = 100;
            if(this.globalMsgs.length > _loc2_)
            {
               this.globalMsgs.splice(0,this.globalMsgs.length - _loc2_);
            }
         }
      }
      
      public function handleChatRoomMsg(param1:ChatRoomMsg) : void
      {
         this.logger.i("CHAT","ChatRoomMsg received: " + param1);
         this.addGlobalMsg(param1);
         dispatchEvent(new ChatRoomEvent(param1));
      }
      
      private function chatSendHandler(param1:ChatSendTxn) : void
      {
         this.send = null;
         if(!param1.success)
         {
            this.logger.i("CHAT","Chat Send failed, resending...");
            param1.resend(this.session.communicator,1000);
         }
      }
   }
}
