package engine.session
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   
   public class TxnGet extends HttpJsonAction
   {
      
      public static const PATH:String = "services/game";
       
      
      public function TxnGet(param1:Credentials, param2:Function, param3:ILogger)
      {
         super(PATH + param1.urlCred,HttpRequestMethod.GET,null,param2,param3);
      }
   }
}
