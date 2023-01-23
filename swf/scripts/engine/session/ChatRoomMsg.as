package engine.session
{
   import engine.core.logging.ILogger;
   
   public class ChatRoomMsg
   {
       
      
      public var display_name:String;
      
      public var room:String;
      
      public var entered:Boolean;
      
      public var exited:Boolean;
      
      public function ChatRoomMsg()
      {
         super();
      }
      
      public function toString() : String
      {
         return "ChatRoomMsg [" + this.display_name + " " + this.room + " " + (this.entered ? "entered" : (this.exited ? "exited" : "???")) + "]";
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.display_name = param1.display_name;
         this.room = param1.room;
         this.entered = param1.entered;
         this.exited = param1.exited;
      }
   }
}
