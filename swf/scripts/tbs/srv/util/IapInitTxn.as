package tbs.srv.util
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import engine.session.Iap;
   
   public class IapInitTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/iap/init";
       
      
      public var iap:Iap;
      
      public function IapInitTxn(param1:Credentials, param2:Function, param3:ILogger, param4:Iap, param5:String)
      {
         var _loc6_:Object = {
            "overlay":true,
            "language":param5,
            "items":[{
               "id":param4.item.id,
               "qty":1,
               "description":param4.item.name
            }]
         };
         this.iap = param4;
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc6_,param2,param3);
         resendOnFail = false;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
         if(responseCode == 200)
         {
            logger.info("IapInitTxn OK responseCode " + responseCode + " json=" + JSON.stringify(jsonObject));
            this.iap.setInit(jsonObject.orderid,jsonObject.transid);
            this.iap.handlePostInit();
         }
         else
         {
            logger.error("IapInitTxn FAIL responseCode " + responseCode);
            this.iap.setError(response);
         }
      }
   }
}
