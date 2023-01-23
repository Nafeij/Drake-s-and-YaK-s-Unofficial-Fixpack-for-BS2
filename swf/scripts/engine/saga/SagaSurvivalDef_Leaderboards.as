package engine.saga
{
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class SagaSurvivalDef_Leaderboards
   {
      
      public static var categories:Array = ["norm","hard"];
      
      public static var leaderboards_json:Object = {"categories":[[],[{
         "name":"_lb_srv_score_tot_norm",
         "accum":true,
         "varname":"survival_win_score"
      },{
         "name":"_lb_srv_score_best_norm",
         "accum":false,
         "varname":"survival_win_score"
      },{
         "name":"_lb_srv_survivals_norm",
         "accum":true,
         "varname":"survival_win_victory"
      },{
         "name":"_lb_srv_time_least_norm",
         "accum":false,
         "varname":"survival_win_time_num"
      },{
         "name":"_lb_srv_deaths_fewest_norm",
         "accum":false,
         "varname":"survival_win_deaths_num"
      },{
         "name":"_lb_srv_kills_most_norm",
         "accum":false,
         "varname":"survival_win_kills_num"
      },{
         "name":"_lb_srv_kills_tot_norm",
         "accum":true,
         "varname":"survival_win_kills_num"
      }],[{
         "name":"_lb_srv_score_tot_hard",
         "accum":true,
         "varname":"survival_win_score"
      },{
         "name":"_lb_srv_score_best_hard",
         "accum":false,
         "varname":"survival_win_score"
      },{
         "name":"_lb_srv_survivals_hard",
         "accum":true,
         "varname":"survival_win_victory"
      },{
         "name":"_lb_srv_time_least_hard",
         "accum":false,
         "varname":"survival_win_time_num"
      },{
         "name":"_lb_srv_deaths_fewest_hard",
         "accum":false,
         "varname":"survival_win_deaths_num"
      },{
         "name":"_lb_srv_kills_most_hard",
         "accum":false,
         "varname":"survival_win_kills_num"
      },{
         "name":"_lb_srv_kills_tot_hard",
         "accum":true,
         "varname":"survival_win_kills_num"
      }]]};
       
      
      public var _leaderboard_byCategory:Vector.<Vector.<SagaSurvivalDef_Leaderboard>>;
      
      public var _leaderboard_byCategoryByName:Vector.<Dictionary>;
      
      public var _leaderboardName_byCategory:Vector.<Vector.<String>>;
      
      public var _allLeaderboards:Vector.<SagaSurvivalDef_Leaderboard>;
      
      public var _category_byLeaderboardName:Dictionary;
      
      public var _leaderboardIndex_byCategoryByName:Vector.<Dictionary>;
      
      public function SagaSurvivalDef_Leaderboards()
      {
         this._leaderboard_byCategory = new Vector.<Vector.<SagaSurvivalDef_Leaderboard>>();
         this._leaderboard_byCategoryByName = new Vector.<Dictionary>();
         this._leaderboardName_byCategory = new Vector.<Vector.<String>>();
         this._allLeaderboards = new Vector.<SagaSurvivalDef_Leaderboard>();
         this._category_byLeaderboardName = new Dictionary();
         this._leaderboardIndex_byCategoryByName = new Vector.<Dictionary>();
         super();
      }
      
      public function initData(param1:ILogger) : SagaSurvivalDef_Leaderboards
      {
         return this.fromJson(leaderboards_json,param1);
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaSurvivalDef_Leaderboards
      {
         var _loc4_:int = 0;
         var _loc5_:Vector.<SagaSurvivalDef_Leaderboard> = null;
         var _loc6_:Dictionary = null;
         var _loc7_:Vector.<String> = null;
         var _loc8_:Dictionary = null;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc13_:SagaSurvivalDef_Leaderboard = null;
         var _loc14_:* = undefined;
         var _loc3_:Array = param1.categories;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = new Vector.<SagaSurvivalDef_Leaderboard>();
            _loc6_ = new Dictionary();
            _loc7_ = new Vector.<String>();
            _loc8_ = new Dictionary();
            _loc9_ = _loc4_;
            this._leaderboard_byCategory.push(_loc5_);
            this._leaderboard_byCategoryByName.push(_loc6_);
            this._leaderboardName_byCategory.push(_loc7_);
            this._leaderboardIndex_byCategoryByName.push(_loc8_);
            _loc10_ = _loc3_[_loc4_];
            _loc11_ = 0;
            while(_loc11_ < _loc10_.length)
            {
               _loc12_ = _loc10_[_loc11_];
               _loc13_ = new SagaSurvivalDef_Leaderboard().fromJson(_loc12_);
               _loc5_.push(_loc13_);
               _loc6_[_loc13_.name] = _loc13_;
               _loc7_.push(_loc13_.name);
               this._allLeaderboards.push(_loc13_);
               _loc14_ = this._category_byLeaderboardName[_loc13_.name];
               if(_loc14_ != undefined && _loc14_ != _loc4_)
               {
                  param2.error("already has category for [" + _loc13_ + "]");
               }
               this._category_byLeaderboardName[_loc13_.name] = _loc4_;
               _loc8_[_loc13_.name] = _loc11_;
               _loc11_++;
            }
            _loc4_++;
         }
         return this;
      }
      
      public function hasCategory(param1:int) : Boolean
      {
         var _loc2_:Vector.<SagaSurvivalDef_Leaderboard> = this._leaderboard_byCategory[param1];
         return Boolean(_loc2_) && Boolean(_loc2_.length);
      }
      
      public function getCategoryForDifficulty(param1:int) : int
      {
         return param1 - 1;
      }
      
      public function getDifficultyForCategory(param1:int) : int
      {
         return param1 + 1;
      }
      
      public function getLeaderboardNamesForDifficulty(param1:int) : Vector.<String>
      {
         var _loc2_:int = this.getCategoryForDifficulty(param1);
         return this.getLeaderboardNamesForCategory(_loc2_);
      }
      
      public function getLeaderboardsForDifficulty(param1:int) : Vector.<SagaSurvivalDef_Leaderboard>
      {
         var _loc2_:int = this.getCategoryForDifficulty(param1);
         return this.getLeaderboardsForCategory(_loc2_);
      }
      
      public function getLeaderboardByNameForDifficulty(param1:int, param2:String) : SagaSurvivalDef_Leaderboard
      {
         var _loc3_:int = this.getCategoryForDifficulty(param1);
         return this.getLeaderboardByNameForCategory(_loc3_,param2);
      }
      
      public function getLeaderboardNamesForCategory(param1:int) : Vector.<String>
      {
         return this._leaderboardName_byCategory[param1];
      }
      
      public function getLeaderboardsForCategory(param1:int) : Vector.<SagaSurvivalDef_Leaderboard>
      {
         if(param1 < 0 || param1 >= this._leaderboard_byCategory.length)
         {
            throw new ArgumentError("bogus leaderboard category " + param1);
         }
         return this._leaderboard_byCategory[param1];
      }
      
      public function getLeaderboardByNameForCategory(param1:int, param2:String) : SagaSurvivalDef_Leaderboard
      {
         var _loc3_:Dictionary = this._leaderboard_byCategoryByName[param1];
         return _loc3_[param2];
      }
      
      public function getLeaderboardByVarname(param1:int, param2:String, param3:Boolean) : SagaSurvivalDef_Leaderboard
      {
         var _loc5_:SagaSurvivalDef_Leaderboard = null;
         var _loc4_:Vector.<SagaSurvivalDef_Leaderboard> = this.getLeaderboardsForCategory(param1);
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.accum == param3)
            {
               if(_loc5_.varname == param2)
               {
                  return _loc5_;
               }
            }
         }
         return null;
      }
      
      public function getCategoryByLeaderboard(param1:String) : int
      {
         return this._category_byLeaderboardName[param1];
      }
      
      public function getDifficultyByLeaderboard(param1:String) : int
      {
         var _loc2_:int = this.getCategoryByLeaderboard(param1);
         return this.getDifficultyForCategory(_loc2_);
      }
      
      public function getIndexByDifficulty(param1:int, param2:String) : int
      {
         var _loc3_:int = this.getCategoryForDifficulty(param1);
         return this.getIndexByCategory(_loc3_,param2);
      }
      
      public function getIndexByCategory(param1:int, param2:String) : int
      {
         return this._leaderboardIndex_byCategoryByName[param1][param2];
      }
   }
}
