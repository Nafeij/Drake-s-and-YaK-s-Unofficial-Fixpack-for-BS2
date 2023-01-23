package engine.saga
{
   import flash.events.EventDispatcher;
   import tbs.srv.data.LeaderboardData;
   
   public class SagaSurvival
   {
      
      public static var ENABLED:Boolean;
      
      public static var ENABLED_LEADERBOARDS:Boolean = true;
      
      public static var categories:Array = ["easy","norm","hard"];
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var def:SagaSurvivalDef;
      
      public var record:SagaSurvivalRecord;
      
      public var leaderboards_global:Vector.<Vector.<LeaderboardData>>;
      
      public var leaderboards_friends:Vector.<Vector.<LeaderboardData>>;
      
      public function SagaSurvival(param1:SagaSurvivalDef)
      {
         this.record = new SagaSurvivalRecord();
         this.leaderboards_global = new Vector.<Vector.<LeaderboardData>>();
         this.leaderboards_friends = new Vector.<Vector.<LeaderboardData>>();
         super();
         this.def = param1;
         this._initLeaderboard();
         SagaLeaderboards.dispatcher.addEventListener(SagaLeaderboardsEvent.FETCHED,this.leaderboardFetchedHandler);
         SagaLeaderboards.dispatcher.addEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.leaderboardFetchErrorHandler);
      }
      
      private static function _initOneLeaderboard(param1:Vector.<LeaderboardData>, param2:Vector.<String>) : void
      {
         var _loc3_:String = null;
         for each(_loc3_ in param2)
         {
            param1.push(null);
         }
      }
      
      public function cleanup() : void
      {
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCHED,this.leaderboardFetchedHandler);
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.leaderboardFetchErrorHandler);
      }
      
      private function leaderboardFetchErrorHandler(param1:SagaLeaderboardsEvent) : void
      {
         dispatcher.dispatchEvent(new SagaLeaderboardsEvent(SagaLeaderboardsEvent.FETCH_ERROR,param1.lbname));
      }
      
      private function leaderboardFetchedHandler(param1:SagaLeaderboardsEvent) : void
      {
         var _loc2_:String = param1.lbname;
         var _loc3_:LeaderboardData = SagaLeaderboards.getLeaderboard_friends(_loc2_);
         var _loc4_:LeaderboardData = SagaLeaderboards.getLeaderboard_global(_loc2_);
         var _loc5_:int = this.def.leaderboards.getCategoryByLeaderboard(_loc2_);
         var _loc6_:int = this.def.leaderboards.getIndexByCategory(_loc5_,_loc2_);
         this.leaderboards_global[_loc5_][_loc6_] = _loc4_;
         this.leaderboards_friends[_loc5_][_loc6_] = _loc3_;
         var _loc7_:int = this.def.leaderboards.getDifficultyForCategory(_loc5_);
         dispatcher.dispatchEvent(new SagaSurvivalEvent(SagaSurvivalEvent.CHANGED,_loc3_,_loc5_));
         dispatcher.dispatchEvent(new SagaSurvivalEvent(SagaSurvivalEvent.CHANGED,_loc4_,_loc5_));
      }
      
      private function _initLeaderboard() : void
      {
         var _loc1_:String = null;
         var _loc2_:Vector.<String> = null;
         var _loc3_:Vector.<LeaderboardData> = null;
         for each(_loc2_ in this.def.leaderboards._leaderboardName_byCategory)
         {
            _loc3_ = new Vector.<LeaderboardData>();
            this.leaderboards_global.push(_loc3_);
            _initOneLeaderboard(_loc3_,_loc2_);
            _loc3_ = new Vector.<LeaderboardData>();
            this.leaderboards_friends.push(_loc3_);
            _initOneLeaderboard(_loc3_,_loc2_);
         }
      }
      
      public function requestAllSurvivalLeaderboards() : void
      {
         var _loc1_:SagaSurvivalDef_Leaderboard = null;
         for each(_loc1_ in this.def.leaderboards._allLeaderboards)
         {
            SagaLeaderboards.fetchLeaderboard(_loc1_.name);
         }
      }
   }
}
