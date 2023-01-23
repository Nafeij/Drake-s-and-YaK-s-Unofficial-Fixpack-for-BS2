package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class RenameUnitTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unit/rename";
       
      
      public function RenameUnitTxn(param1:Credentials, param2:Function, param3:ILogger, param4:String, param5:String)
      {
         var _loc6_:Object = {
            "unit_id":param4,
            "name":param5
         };
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc6_,param2,param3);
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
      }
   }
}
