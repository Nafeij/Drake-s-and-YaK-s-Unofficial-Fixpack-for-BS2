package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class LeaderboardsData
   {
       
      
      private var boards:Vector.<LeaderboardData>;
      
      public var max_entries:int;
      
      public function LeaderboardsData()
      {
         this.boards = new Vector.<LeaderboardData>();
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:LeaderboardData = null;
         this.max_entries = param1.max_entries;
         for each(_loc3_ in param1.boards)
         {
            _loc4_ = new LeaderboardData();
            _loc4_.parseJson(_loc3_,param2);
            this.boards.push(_loc4_);
         }
      }
      
      public function replaceBoard(param1:LeaderboardData) : void
      {
         var _loc3_:LeaderboardData = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.boards.length)
         {
            _loc3_ = this.boards[_loc2_];
            if(_loc3_.leaderboard_type == param1.leaderboard_type && _loc3_.tourney_id == param1.tourney_id)
            {
               this.boards[_loc2_] = param1;
               return;
            }
            _loc2_++;
         }
         this.boards.push(param1);
      }
      
      public function get allBoards() : Vector.<LeaderboardData>
      {
         return this.boards;
      }
      
      public function getBoardsForRankingGroup(param1:int, param2:Vector.<LeaderboardData>) : Vector.<LeaderboardData>
      {
         var _loc4_:LeaderboardData = null;
         if(param2 == null)
         {
            param2 = new Vector.<LeaderboardData>();
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.boards.length)
         {
            _loc4_ = this.boards[_loc3_];
            if(_loc4_.tourney_id == param1)
            {
               param2.push(_loc4_);
            }
            _loc3_++;
         }
         return param2;
      }
      
      public function findBoard(param1:int, param2:String) : LeaderboardData
      {
         var _loc4_:LeaderboardData = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.boards.length)
         {
            _loc4_ = this.boards[_loc3_];
            if(_loc4_.leaderboard_type == param2 && _loc4_.tourney_id == param1)
            {
               return _loc4_;
            }
            _loc3_++;
         }
         return null;
      }
   }
}
