package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class ArrangePartyTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/party/arrange";
       
      
      public function ArrangePartyTxn(param1:Credentials, param2:Function, param3:ILogger, param4:Vector.<String>, param5:int)
      {
         var _loc7_:String = null;
         var _loc6_:Object = {"party":[]};
         for each(_loc7_ in param4)
         {
            _loc6_.party.push(_loc7_);
         }
         if(param5)
         {
            _loc6_.lobby = param5;
         }
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc6_,param2,param3);
         resendOnFail = true;
         resendOnFailDelayMs = 1000;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
