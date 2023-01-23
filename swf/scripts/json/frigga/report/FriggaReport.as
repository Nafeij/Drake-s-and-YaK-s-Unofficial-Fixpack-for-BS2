package json.frigga.report
{
   public class FriggaReport
   {
       
      
      private var messages:Vector.<FriggaMessage>;
      
      public function FriggaReport(param1:Vector.<FriggaMessage>)
      {
         this.messages = new Vector.<FriggaMessage>();
         super();
         this.messages = param1;
      }
      
      public static function getWriter() : FriggaWriter
      {
         return new FriggaWriter();
      }
      
      public function isValid() : Boolean
      {
         return this.getMessages().length == 0;
      }
      
      public function getMessages() : Vector.<FriggaMessage>
      {
         return this.messages;
      }
      
      public function getMessagesAsString() : String
      {
         var _loc2_:FriggaMessage = null;
         if(this.messages.length == 0)
         {
            return "";
         }
         var _loc1_:String = "Errors (message | property | actualValue): \n";
         for each(_loc2_ in this.messages)
         {
            _loc1_ += _loc2_.message + (_loc2_.property != null ? " | " + _loc2_.property : "") + (_loc2_.actual != "" ? " | " + _loc2_.actual : "") + "\n";
         }
         return _loc1_;
      }
   }
}
