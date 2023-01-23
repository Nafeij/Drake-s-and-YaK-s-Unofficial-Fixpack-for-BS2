package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class GameLocationTxn extends HttpJsonAction
   {
       
      
      public function GameLocationTxn(param1:Credentials, param2:String, param3:ILogger)
      {
         super("services/game/location" + param1.urlCred,HttpRequestMethod.POST,param2,null,param3);
         resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
