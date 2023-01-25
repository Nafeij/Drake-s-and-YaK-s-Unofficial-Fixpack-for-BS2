package com.stoicstudio.platform.gog
{
   import tbs.srv.data.LeaderboardData;
   
   public class GogLeaderboardGenerator
   {
       
      
      public function GogLeaderboardGenerator()
      {
         super();
      }
      
      public static function generateLeaderboards(param1:Object, param2:String, param3:String, param4:LeaderboardData, param5:LeaderboardData) : void
      {
         _populateLeaderboard(param1,param2,param3,param4,true);
         _populateLeaderboard(param1,param2,param3,param5,false);
         if(Boolean(param4.user_rank) && !param5.user_rank)
         {
            param5.user_rank = param4.user_rank;
            param5.user_value = param4.user_value;
         }
         else if(!param4.user_rank && Boolean(param5.user_rank))
         {
            param4.user_rank = param5.user_rank;
            param4.user_value = param5.user_value;
         }
      }
      
      private static function _populateLeaderboard(param1:Object, param2:String, param3:String, param4:LeaderboardData, param5:Boolean) : void
      {
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         param4.leaderboard_type = param1.name;
         param4.user_display_name = param3;
         param4.global = param5;
         var _loc6_:String = param5 ? "entries_global" : "entries_friends";
         var _loc7_:Array = param1[_loc6_];
         for each(_loc8_ in _loc7_)
         {
            _loc9_ = String(_loc8_.user);
            _loc10_ = int(_loc8_.rank);
            _loc11_ = int(_loc8_.score);
            _loc12_ = String(_loc8_.display_name);
            param4.addEntry(_loc12_,_loc11_,_loc9_);
            if(_loc9_ == param2)
            {
               param4.user_rank = _loc8_.rank;
               param4.user_value = _loc8_.score;
            }
         }
      }
   }
}
