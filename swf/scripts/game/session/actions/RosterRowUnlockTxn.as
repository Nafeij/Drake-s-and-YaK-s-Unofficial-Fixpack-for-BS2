package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import game.cfg.AccountInfoDef;
   
   public class RosterRowUnlockTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unlock";
       
      
      private var ai:AccountInfoDef;
      
      public function RosterRowUnlockTxn(param1:Credentials, param2:Function, param3:ILogger, param4:AccountInfoDef)
      {
         this.ai = param4;
         super(PATH + param1.urlCred,HttpRequestMethod.POST,body,param2,param3);
         resendOnFail = true;
         resendOnFailDelayMs = 1000;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
         if(success)
         {
            ++this.ai.legend.rosterRowCount;
         }
      }
   }
}
