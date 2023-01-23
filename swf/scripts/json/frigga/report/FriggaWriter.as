package json.frigga.report
{
   public class FriggaWriter
   {
       
      
      private var messages:Vector.<FriggaMessage>;
      
      public function FriggaWriter()
      {
         this.messages = new Vector.<FriggaMessage>();
         super();
      }
      
      public function writeMessage(param1:String, param2:String = "", param3:* = "") : FriggaWriter
      {
         if(param1 != null && param1 != "")
         {
            this.messages.push(new FriggaMessage(param1,param2,param3));
         }
         return this;
      }
      
      public function getOutput() : FriggaReport
      {
         return new FriggaReport(this.messages);
      }
   }
}
