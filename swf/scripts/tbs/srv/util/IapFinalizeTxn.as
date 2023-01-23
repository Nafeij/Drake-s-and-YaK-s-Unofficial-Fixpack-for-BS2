package tbs.srv.util
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import engine.session.Iap;
   
   public class IapFinalizeTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/iap/finalize";
       
      
      public var iap:Iap;
      
      public function IapFinalizeTxn(param1:Credentials, param2:Function, param3:ILogger, param4:Iap)
      {
         var _loc5_:Object = {"orderid":param4.orderid};
         this.iap = param4;
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc5_,param2,param3);
         resendOnFail = false;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
         if(responseCode == 200)
         {
            this.iap.setComplete();
         }
         else
         {
            this.iap.setError(response);
         }
      }
   }
}
