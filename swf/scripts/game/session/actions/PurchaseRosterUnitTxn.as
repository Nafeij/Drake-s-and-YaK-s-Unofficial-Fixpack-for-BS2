package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class PurchaseRosterUnitTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unit/hire";
       
      
      public function PurchaseRosterUnitTxn(param1:Credentials, param2:Function, param3:ILogger, param4:String, param5:String, param6:String)
      {
         var _loc7_:Object = {
            "purchasable_unit_id":param4,
            "new_unit_id":param5,
            "new_unit_name":param6
         };
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc7_,param2,param3);
         resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
