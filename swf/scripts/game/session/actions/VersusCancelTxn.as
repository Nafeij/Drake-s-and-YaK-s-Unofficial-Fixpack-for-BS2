package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.session.Credentials;
   import game.cfg.GameConfig;
   
   public class VersusCancelTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/vs/cancel";
       
      
      public function VersusCancelTxn(param1:Credentials, param2:int, param3:Function, param4:GameConfig)
      {
         super(PATH + param1.urlCred,HttpRequestMethod.POST,{"match_handle":param2},param3,param4.logger);
      }
   }
}
