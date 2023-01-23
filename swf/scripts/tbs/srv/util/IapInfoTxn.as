package tbs.srv.util
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class IapInfoTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/iap/info";
       
      
      public function IapInfoTxn(param1:Credentials, param2:Function, param3:ILogger, param4:String)
      {
         super(PATH + param1.urlCred,HttpRequestMethod.POST,param4,param2,param3);
         resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
