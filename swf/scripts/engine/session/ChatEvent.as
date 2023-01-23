package engine.session
{
   import flash.events.Event;
   
   public class ChatEvent extends Event
   {
      
      public static const TYPE:String = "GameChatEvent.TYPE";
       
      
      public var msg:ChatMsg;
      
      public function ChatEvent(param1:ChatMsg)
      {
         super(TYPE);
         this.msg = param1;
      }
   }
}
