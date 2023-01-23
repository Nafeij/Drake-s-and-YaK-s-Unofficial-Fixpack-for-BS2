package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import tbs.srv.data.LobbyOptionsData;
   
   public class LobbyInviteTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/lobby/invite";
       
      
      public function LobbyInviteTxn(param1:Credentials, param2:ILogger, param3:LobbyOptionsData)
      {
         super(PATH + param1.urlCred,HttpRequestMethod.POST,JSON.stringify(param3),null,param2);
         this.resendOnFail = true;
      }
   }
}
