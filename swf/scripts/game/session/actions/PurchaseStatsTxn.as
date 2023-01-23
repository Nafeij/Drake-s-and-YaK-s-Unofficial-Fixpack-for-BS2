package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class PurchaseStatsTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unit/stats/purchase";
       
      
      public function PurchaseStatsTxn(param1:Credentials, param2:Function, param3:ILogger, param4:String, param5:Array, param6:Array)
      {
         var _loc7_:Object = {
            "unit_id":param4,
            "stats":param5,
            "deltas":param6
         };
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc7_,param2,param3);
         resendOnFail = true;
         resendOnFailDelayMs = 1000;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
