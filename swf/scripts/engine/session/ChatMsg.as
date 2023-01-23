package engine.session
{
   public class ChatMsg
   {
       
      
      public var user:int;
      
      public var username:String;
      
      public var room:String;
      
      public var msg:String;
      
      public function ChatMsg()
      {
         super();
      }
      
      public static function parse(param1:Object) : ChatMsg
      {
         var _loc2_:ChatMsg = new ChatMsg();
         _loc2_.username = param1.username;
         _loc2_.room = param1.room;
         _loc2_.user = param1.user;
         _loc2_.msg = param1.msg;
         return _loc2_;
      }
      
      public function toString() : String
      {
         return this.username + "/" + this.room + "/" + this.msg;
      }
   }
}
