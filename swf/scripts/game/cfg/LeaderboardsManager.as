package game.cfg
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   import game.session.actions.LeaderboardsTxn;
   import tbs.srv.data.LeaderboardData;
   import tbs.srv.data.LeaderboardsData;
   
   public class LeaderboardsManager extends EventDispatcher
   {
      
      public static const THROTTLE_MS:int = 5000;
      
      private static const lbids_global:Array = ["ELO","WINS","WINLOSS","TOTAL","BEST_WIN_STREAK","WIN_STREAK"];
      
      private static const lbids_tourney_current:Array = ["ELO","WINS","WINLOSS","TOTAL","BEST_WIN_STREAK","WIN_STREAK"];
      
      private static const lbids_tourney_history:Array = ["WINS"];
       
      
      private var config:GameConfig;
      
      private var _data:LeaderboardsData;
      
      private var _requestTime:int;
      
      public var last_tourney_id:int = -1;
      
      public var last_tourney_parent_id:int = -1;
      
      public function LeaderboardsManager(param1:GameConfig)
      {
         super();
         this.config = param1;
         this.refresh();
      }
      
      public function cleanup() : void
      {
      }
      
      public function get data() : LeaderboardsData
      {
         this.refresh();
         return this._data;
      }
      
      public function refresh() : void
      {
         var _loc1_:TourneyManager = !!this.config.factions ? this.config.factions.tourneys : null;
         var _loc2_:int = !!_loc1_ ? (_loc1_.tourney.started ? _loc1_.tourney.tourney_id : _loc1_.tourneyWinner.tourney_id) : 0;
         var _loc3_:int = getTimer() - this._requestTime;
         if(this._requestTime <= 0 || _loc3_ > THROTTLE_MS)
         {
            if(this.config.fsm)
            {
               if(this.config.fsm.communicator.connected)
               {
                  this._requestTime = getTimer();
                  new LeaderboardsTxn(this.config.fsm.session.credentials,this.txnHandler,this.config.logger,0,lbids_global).send(this.config.fsm.communicator);
                  if(_loc2_)
                  {
                     new LeaderboardsTxn(this.config.fsm.session.credentials,this.txnHandler,this.config.logger,_loc2_,lbids_tourney_current).send(this.config.fsm.communicator);
                  }
                  if(Boolean(_loc1_) && Boolean(_loc1_.tourney.parent_id))
                  {
                     new LeaderboardsTxn(this.config.fsm.session.credentials,this.txnHandler,this.config.logger,_loc1_.tourney.parent_id,lbids_tourney_history).send(this.config.fsm.communicator);
                  }
               }
            }
         }
      }
      
      private function txnHandler(param1:LeaderboardsTxn) : void
      {
         var _loc2_:LeaderboardData = null;
         if(param1.boards_data)
         {
            if(!this._data)
            {
               this._data = param1.boards_data;
            }
            else
            {
               for each(_loc2_ in param1.boards_data.allBoards)
               {
                  this._data.replaceBoard(_loc2_);
               }
            }
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
   }
}
