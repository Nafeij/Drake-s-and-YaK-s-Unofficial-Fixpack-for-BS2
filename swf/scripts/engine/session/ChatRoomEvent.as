package engine.session
{
   import flash.events.Event;
   
   public class ChatRoomEvent extends Event
   {
      
      public static const TYPE:String = "ChatRoomEvent.TYPE";
       
      
      public var msg:ChatRoomMsg;
      
      public function ChatRoomEvent(param1:ChatRoomMsg)
      {
         super(TYPE);
         this.msg = param1;
      }
   }
}
