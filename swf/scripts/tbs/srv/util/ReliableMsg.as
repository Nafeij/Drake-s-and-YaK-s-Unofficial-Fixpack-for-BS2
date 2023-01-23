package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class ReliableMsg
   {
       
      
      public var reliable_msg_id:int;
      
      public var reliable_msg_target:String;
      
      public var timestamp:Number;
      
      public function ReliableMsg()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.reliable_msg_id = param1.reliable_msg_id;
         this.reliable_msg_target = param1.reliable_msg_target;
         this.timestamp = param1.timestamp;
      }
   }
}
