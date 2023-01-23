package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class SessionSteamOverlayTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/session/steam/overlay";
       
      
      public function SessionSteamOverlayTxn(param1:Credentials, param2:Function, param3:ILogger, param4:Boolean)
      {
         super(PATH + param1.urlCred + "/" + param4,HttpRequestMethod.POST,null,param2,param3);
         this.resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
