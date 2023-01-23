package engine.saga
{
   import com.greensock.TweenMax;
   import tbs.srv.data.LeaderboardData;
   
   public class LeaderboardAccumulator
   {
       
      
      public var lb:SagaSurvivalDef_Leaderboard;
      
      public var value:int;
      
      private var _callback:Function;
      
      public var rank_prev:int;
      
      public var rank_next:int;
      
      public var score_prev:int;
      
      public var score_next:int;
      
      private var saga:Saga;
      
      private var _finished:Boolean;
      
      public function LeaderboardAccumulator(param1:Saga, param2:SagaSurvivalDef_Leaderboard, param3:int)
      {
         super();
         this.lb = param2;
         this.value = param3;
         this.saga = param1;
      }
      
      public function performUpload(param1:Function) : void
      {
         this._callback = param1;
         if(!this.lb)
         {
            this.finishAccumulation();
            return;
         }
         var _loc2_:LeaderboardData = SagaLeaderboards.getLeaderboard_global(this.lb.name);
         if(_loc2_)
         {
            this.score_prev = _loc2_.user_value;
            this.rank_prev = _loc2_.user_rank;
         }
         var _loc3_:Number = 10;
         TweenMax.delayedCall(_loc3_,this.timeoutFailureHandler);
         if(!this.lb.accum || Boolean(_loc2_))
         {
            this._performActualUpload();
            return;
         }
         SagaLeaderboards.dispatcher.addEventListener(SagaLeaderboardsEvent.FETCHED,this.fetchedPrevHandler);
         SagaLeaderboards.dispatcher.addEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.fetchErrorPrevHandler);
         SagaLeaderboards.fetchLeaderboard(this.lb.name);
      }
      
      private function timeoutFailureHandler() : void
      {
         if(Boolean(this.saga) && Boolean(this.saga.logger))
         {
            this.saga.logger.error("LeaderboardAccumulator.timeoutFailureHandler " + this.lb);
         }
         this.finishAccumulation();
      }
      
      private function fetchErrorPrevHandler(param1:SagaLeaderboardsEvent) : void
      {
         if(param1.lbname != this.lb.name)
         {
            return;
         }
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.fetchErrorPrevHandler);
         if(this._finished)
         {
            return;
         }
         this.saga.logger.error("LeaderboardAccumulator.fetchErrorPrevHandler " + param1);
         this.finishAccumulation();
      }
      
      private function fetchedPrevHandler(param1:SagaLeaderboardsEvent) : void
      {
         if(param1.lbname != this.lb.name)
         {
            return;
         }
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.fetchErrorPrevHandler);
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCHED,this.fetchedPrevHandler);
         if(this._finished)
         {
            return;
         }
         var _loc2_:LeaderboardData = SagaLeaderboards.getLeaderboard_global(this.lb.name);
         this.score_prev = _loc2_.user_value;
         this._performActualUpload();
      }
      
      private function _performActualUpload() : void
      {
         if(this._finished)
         {
            return;
         }
         var _loc1_:Saga = Saga.instance;
         SagaLeaderboards.dispatcher.addEventListener(SagaLeaderboardScoreUploadedEvent.UPLOADED,this.uploadedHandler);
         if(this.lb.accum)
         {
            if(!this.value)
            {
               _loc1_.logger.info("LeaderboardUploader nothing to accumulate for [" + this.lb.name + "]");
               this.rank_next = this.rank_prev;
               this.finishAccumulation();
               return;
            }
            this.score_next = this.score_prev + this.value;
            _loc1_.logger.info("LeaderboardUploader accumulating [" + this.lb.name + "] new total score of " + this.score_next);
         }
         else
         {
            this.score_next = this.value;
            _loc1_.logger.info("LeaderboardUploader uploading [" + this.lb.name + "] new best score of " + this.score_next);
         }
         SagaLeaderboards.uploadLeaderboardScore(this.lb.name,this.score_next,false);
      }
      
      private function uploadedHandler(param1:SagaLeaderboardScoreUploadedEvent) : void
      {
         if(param1.lbname != this.lb.name)
         {
            return;
         }
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardScoreUploadedEvent.UPLOADED,this.uploadedHandler);
         var _loc2_:Saga = Saga.instance;
         if(this._finished)
         {
            return;
         }
         this.rank_prev = param1.rank_prev;
         this.rank_next = param1.rank_next;
         this.finishAccumulation();
      }
      
      public function finishAccumulation() : void
      {
         if(this._finished)
         {
            return;
         }
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.fetchErrorPrevHandler);
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCHED,this.fetchedPrevHandler);
         SagaLeaderboards.dispatcher.removeEventListener(SagaLeaderboardScoreUploadedEvent.UPLOADED,this.uploadedHandler);
         this._finished = true;
         TweenMax.killDelayedCallsTo(this.timeoutFailureHandler);
         this.setVnRanks(this.rank_prev,this.rank_next);
         var _loc1_:Function = this._callback;
         this._callback = null;
         if(_loc1_ != null)
         {
            _loc1_(this.lb.name,this.rank_prev,this.rank_next,this.score_prev,this.score_next);
         }
      }
      
      private function setVnRanks(param1:int, param2:int) : void
      {
         this.saga.setVar(this.lb.name + "_rank_prev",param1);
         this.saga.setVar(this.lb.name + "_rank_next",param1);
      }
   }
}
