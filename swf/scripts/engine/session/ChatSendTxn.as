package engine.session
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   
   public class ChatSendTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/chat";
       
      
      public function ChatSendTxn(param1:String, param2:String, param3:Credentials, param4:Function, param5:ILogger)
      {
         super(PATH + "/" + param1 + param3.urlCred,HttpRequestMethod.POST,param2,param4,param5);
      }
   }
}
