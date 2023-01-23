package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.entity.def.PartyDefVars;
   import engine.session.Credentials;
   import game.cfg.GameConfig;
   
   public class VersusStartMatchTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/vs/start";
       
      
      public function VersusStartMatchTxn(param1:Credentials, param2:int, param3:String, param4:int, param5:int, param6:int, param7:VsType, param8:Function, param9:GameConfig)
      {
         var _loc10_:Object = {};
         _loc10_.party = PartyDefVars.save(param9.legend.party).ids;
         _loc10_.timer = param5;
         if(param9.runMode.autologin)
         {
            _loc10_.priority = 100;
         }
         if(param2 != 0)
         {
            _loc10_.forcematch = param2;
         }
         if(param3)
         {
            _loc10_.scene = param3;
         }
         _loc10_.vs_type = param7.name;
         _loc10_.match_handle = param4;
         _loc10_.tourney_id = param6;
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc10_,param8,param9.logger);
         resendOnFail = true;
         resendOnFailDelayMs = 1000;
      }
   }
}
