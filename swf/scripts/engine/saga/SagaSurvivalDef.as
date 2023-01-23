package engine.saga
{
   import engine.core.analytic.Ga;
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class SagaSurvivalDef
   {
       
      
      private var scoreDatas:Vector.<SagaSurvivalDef_ScoreData>;
      
      public var scoreDatasByName:Dictionary;
      
      public var leaderboards:SagaSurvivalDef_Leaderboards;
      
      private var _score_prev:int;
      
      private var _callback:Function;
      
      private var _uploaders:Vector.<LeaderboardAccumulator>;
      
      private var _finished:Boolean;
      
      public function SagaSurvivalDef(param1:ILogger)
      {
         this.scoreDatas = new Vector.<SagaSurvivalDef_ScoreData>();
         this.scoreDatasByName = new Dictionary();
         this._uploaders = new Vector.<LeaderboardAccumulator>();
         super();
         this.addScoreData(new SagaSurvivalDef_ScoreData("kills",false,0,400,1));
         this.addScoreData(new SagaSurvivalDef_ScoreData("deaths",true,0,40,1));
         this.addScoreData(new SagaSurvivalDef_ScoreData("time",true,0,200,1));
         this.addScoreData(new SagaSurvivalDef_ScoreData("reloads",true,0,12,10));
         this.addScoreData(new SagaSurvivalDef_ScoreData("recruits",false,0,40,1));
         this.addScoreData(new SagaSurvivalDef_ScoreData("damage_done",false,0,5000,0.1));
         this.addScoreData(new SagaSurvivalDef_ScoreData("damage_taken",true,0,3000,0.1));
         this.leaderboards = new SagaSurvivalDef_Leaderboards().initData(param1);
      }
      
      public function getMaxDisplayScore(param1:String) : int
      {
         var _loc2_:SagaSurvivalDef_ScoreData = this.scoreDatasByName[param1];
         if(_loc2_)
         {
            return _loc2_.maxDisplayScore;
         }
         return 0;
      }
      
      private function addScoreData(param1:SagaSurvivalDef_ScoreData) : void
      {
         this.scoreDatas.push(param1);
         this.scoreDatasByName[param1.name] = param1;
      }
      
      public function computeScores(param1:Saga, param2:Function) : void
      {
         var _loc8_:SagaSurvivalDef_ScoreData = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:* = param1.survivalProgress >= param1.survivalTotal;
         param1.setVar("survival_win_victory",_loc3_);
         param1.setVar("survival_win_reloads_num",param1.survivalReloadCount);
         var _loc4_:String = "survival_gameover";
         var _loc5_:String = "scores_" + param1.survivalProgress;
         var _loc6_:String = "stats_" + param1.survivalProgress;
         var _loc7_:int = 0;
         for each(_loc8_ in this.scoreDatas)
         {
            _loc10_ = _loc8_.computeScore(param1);
            _loc7_ += _loc10_;
            _loc11_ = param1.getVarInt("survival_win_" + _loc8_.name + "_num");
            Ga.normal(_loc4_,_loc6_,_loc8_.name,_loc11_);
            Ga.normal(_loc4_,_loc5_,_loc8_.name,_loc10_);
         }
         Ga.normal(_loc4_,_loc5_,"total",_loc7_);
         param1.setVar("survival_win_score",_loc7_);
         this._callback = param2;
         _loc9_ = this.leaderboards.getCategoryForDifficulty(param1.difficulty);
         if(!param1.isAchievementsSuppressed && SagaLeaderboards.isSupported && this.leaderboards.hasCategory(_loc9_))
         {
            this.uploadScore(param1,_loc9_,"survival_win_score",true);
            this.uploadScore(param1,_loc9_,"survival_win_kills_num",true);
            if(_loc3_)
            {
               this.uploadScore(param1,_loc9_,"survival_win_victory",true);
            }
            this.uploadScore(param1,_loc9_,"survival_win_score",false);
            if(_loc3_)
            {
               this.uploadScore(param1,_loc9_,"survival_win_time_num",false);
               this.uploadScore(param1,_loc9_,"survival_win_deaths_num",false);
            }
            this.uploadScore(param1,_loc9_,"survival_win_kills_num",false);
            this.startUploading();
         }
         else
         {
            this.checkFinished();
         }
      }
      
      private function startUploading() : void
      {
         var _loc1_:LeaderboardAccumulator = null;
         if(this._uploaders.length)
         {
            _loc1_ = this._uploaders[0];
            _loc1_.performUpload(this.totalAccumulationHandler);
         }
         this.checkFinished();
      }
      
      private function uploadScore(param1:Saga, param2:int, param3:String, param4:Boolean) : void
      {
         var _loc8_:LeaderboardAccumulator = null;
         var _loc5_:SagaSurvivalDef_Leaderboard = this.leaderboards.getLeaderboardByVarname(param2,param3,param4);
         if(!_loc5_)
         {
            param1.logger.info("SagaSurvivalDef.uploadScore No such board for cat " + param2 + " varname [" + param3 + "] accum " + param4);
            return;
         }
         var _loc6_:* = param3 + "_rank_";
         var _loc7_:int = param1.getVarInt(param3);
         _loc8_ = new LeaderboardAccumulator(param1,_loc5_,_loc7_);
         this._uploaders.push(_loc8_);
      }
      
      private function checkFinished() : void
      {
         if(this._uploaders.length <= 0)
         {
            this.finishUploadingScore();
         }
      }
      
      public function getScoreData(param1:String) : SagaSurvivalDef_ScoreData
      {
         return this.scoreDatasByName[param1];
      }
      
      private function totalAccumulationHandler(param1:String, param2:int, param3:int, param4:int, param5:int) : void
      {
         this._uploaders.shift();
         this.startUploading();
      }
      
      public function finishUploadingScore() : void
      {
         if(this._finished)
         {
            return;
         }
         this._finished = true;
         var _loc1_:Function = this._callback;
         this._callback = null;
         if(_loc1_ != null)
         {
            _loc1_();
         }
      }
   }
}
