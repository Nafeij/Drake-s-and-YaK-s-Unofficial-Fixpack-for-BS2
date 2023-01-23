package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class TutorialCompletedTxn extends HttpJsonAction
   {
       
      
      public function TutorialCompletedTxn(param1:Credentials, param2:Function, param3:ILogger)
      {
         super("services/account/tutorial" + param1.urlCred,HttpRequestMethod.POST,null,param2,param3);
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
