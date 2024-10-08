package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class RetireRosterUnitTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unit/retire";
       
      
      public function RetireRosterUnitTxn(param1:Credentials, param2:Function, param3:ILogger, param4:String)
      {
         var _loc5_:Object = {"unit_id":param4};
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc5_,param2,param3);
         resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
