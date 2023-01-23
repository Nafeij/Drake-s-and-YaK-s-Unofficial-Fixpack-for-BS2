package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import tbs.srv.data.LeaderboardsData;
   
   public class LeaderboardsTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/game/leaderboards";
       
      
      public var boards_data:LeaderboardsData;
      
      public function LeaderboardsTxn(param1:Credentials, param2:Function, param3:ILogger, param4:int, param5:Array)
      {
         var _loc6_:Object = {
            "tourney_id":param4,
            "board_ids":param5
         };
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc6_,param2,param3);
         this.resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
         if(success && Boolean(jsonObject))
         {
            this.boards_data = new LeaderboardsData();
            this.boards_data.parseJson(jsonObject,logger);
         }
      }
   }
}
