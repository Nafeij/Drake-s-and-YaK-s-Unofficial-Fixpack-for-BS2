package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class SystemMsg extends ReliableMsg
   {
       
      
      public var msg:String;
      
      public function SystemMsg()
      {
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.msg = param1.msg;
      }
   }
}
