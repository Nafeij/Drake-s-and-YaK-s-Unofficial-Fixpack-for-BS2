package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class LobbyTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/lobby/";
       
      
      public function LobbyTxn(param1:Credentials, param2:ILogger, param3:String, param4:int)
      {
         super(PATH + param3 + param1.urlCred,HttpRequestMethod.POST,param4.toString(),null,param2);
         this.resendOnFail = true;
      }
   }
}
