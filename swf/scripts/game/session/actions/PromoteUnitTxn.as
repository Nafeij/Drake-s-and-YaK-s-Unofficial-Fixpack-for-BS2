package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class PromoteUnitTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unit/promote";
       
      
      public function PromoteUnitTxn(param1:Credentials, param2:Function, param3:ILogger, param4:String, param5:String, param6:String)
      {
         var _loc7_:Object = {
            "unit_id":param4,
            "class_id":param5,
            "name":param6
         };
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc7_,param2,param3);
         resendOnFail = true;
      }
   }
}
