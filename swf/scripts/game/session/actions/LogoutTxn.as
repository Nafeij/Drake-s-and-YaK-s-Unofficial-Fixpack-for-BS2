package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class LogoutTxn extends HttpJsonAction
   {
       
      
      public function LogoutTxn(param1:Credentials, param2:Function, param3:ILogger)
      {
         param3.info("LogoutTxn " + param1.urlCred);
         var _loc4_:Object = {
            "steam_id":param1.steamId,
            "steam_ticket":param1.steamAuthTicket
         };
         super("services/auth/logout" + param1.urlCred,HttpRequestMethod.POST,_loc4_,param2,param3);
      }
   }
}
