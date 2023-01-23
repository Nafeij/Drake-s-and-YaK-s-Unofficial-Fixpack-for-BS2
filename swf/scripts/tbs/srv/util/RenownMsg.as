package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class RenownMsg extends ReliableMsg
   {
       
      
      public var user:int;
      
      public var total:int;
      
      public function RenownMsg()
      {
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.user = param1.user;
         this.total = param1.total;
      }
   }
}
