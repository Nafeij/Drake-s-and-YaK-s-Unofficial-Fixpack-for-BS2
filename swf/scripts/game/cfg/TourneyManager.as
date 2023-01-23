package game.cfg
{
   import engine.core.logging.ILogger;
   import engine.session.Alert;
   import engine.session.AlertOrientationType;
   import engine.session.AlertStyleType;
   import engine.tourney.TourneyDef;
   import flash.events.Event;
   import game.session.actions.TourneyJoinTxn;
   import tbs.srv.util.Tourney;
   import tbs.srv.util.TourneyProgressData;
   import tbs.srv.util.TourneyWinnerData;
   
   public class TourneyManager
   {
      
      public static const PREF_ALERT_TOURNEY_START_:String = "PREF_ALERT_TOURNEY_START_";
      
      public static const PREF_ALERT_TOURNEY_END_:String = "PREF_ALERT_TOURNEY_END_";
      
      public static const PREF_ALERT_TOURNEY_WIN_:String = "PREF_ALERT_TOURNEY_WIN_";
       
      
      public var tourney:Tourney;
      
      public var tourneyWinner:TourneyWinnerData;
      
      public var tourneyProgress:TourneyProgressData;
      
      private var gameConfig:GameConfig;
      
      private var _clock_skew:Number = 0;
      
      public function TourneyManager(param1:GameConfig)
      {
         this.tourney = new Tourney();
         this.tourneyWinner = new TourneyWinnerData();
         this.tourneyProgress = new TourneyProgressData();
         super();
         this.gameConfig = param1;
         this.gameConfig.addEventListener(GameConfig.EVENT_ACCOUNT_INFO,this.accountInfoHandler);
      }
      
      public function cleanup() : void
      {
         this.gameConfig.removeEventListener(GameConfig.EVENT_ACCOUNT_INFO,this.accountInfoHandler);
      }
      
      private function accountInfoHandler(param1:Event) : void
      {
         this.clock_skew = this.gameConfig.accountInfo.server_delta_time;
      }
      
      public function get clock_skew() : Number
      {
         return this._clock_skew;
      }
      
      public function set clock_skew(param1:Number) : void
      {
         this._clock_skew = param1;
         if(this.tourney)
         {
            this.tourney.clock_skew = param1;
         }
      }
      
      public function get logger() : ILogger
      {
         return this.gameConfig.logger;
      }
      
      private function alertTourney() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(Boolean(this.tourney.tourney_id) && this.tourney.started)
         {
            _loc1_ = PREF_ALERT_TOURNEY_START_ + this.tourney.tourney_id;
            _loc2_ = this.gameConfig.globalPrefs.getPref(_loc1_);
            if(!_loc2_)
            {
               _loc3_ = this.gameConfig.gameGuiContext.translate("tournament_started_title");
               _loc4_ = this.gameConfig.gameGuiContext.translate("tournament_started_msg");
               this.gameConfig.alerts.addAlert(Alert.create(0,_loc3_,_loc4_,null,null,AlertOrientationType.LEFT,AlertStyleType.TOURNEY,null));
               this.gameConfig.globalPrefs.setPref(_loc1_,true);
            }
         }
      }
      
      private function alertTourneyEnded() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(this.tourneyWinner.tourney_id)
         {
            _loc1_ = PREF_ALERT_TOURNEY_END_ + this.tourneyWinner.tourney_id;
            _loc2_ = this.gameConfig.globalPrefs.getPref(_loc1_);
            if(!_loc2_)
            {
               if(!this.tourneyWinner.isAWinner(this.gameConfig.fsm.credentials.userId))
               {
                  _loc3_ = this.tourneyWinner.winnerName;
                  if(!_loc3_)
                  {
                     _loc3_ = "Apathy";
                  }
                  _loc4_ = this.gameConfig.gameGuiContext.translate("tournament_ended_msg");
                  this.gameConfig.alerts.addAlert(Alert.create(0,_loc3_,_loc4_,null,null,AlertOrientationType.LEFT,AlertStyleType.TOURNEY,null));
               }
               this.gameConfig.globalPrefs.setPref(_loc1_,true);
            }
         }
      }
      
      private function alertTourneyWinners() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:TourneyDef = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:* = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         if(this.tourneyWinner.tourney_id)
         {
            _loc1_ = PREF_ALERT_TOURNEY_WIN_ + this.tourneyWinner.tourney_id;
            _loc2_ = this.gameConfig.globalPrefs.getPref(_loc1_);
            if(!_loc2_)
            {
               _loc3_ = this.tourneyWinner.def;
               _loc4_ = 0;
               while(_loc4_ < this.tourneyWinner.ranked_ids.length)
               {
                  _loc5_ = this.tourneyWinner.ranked_ids[_loc4_];
                  if(_loc5_ == this.gameConfig.fsm.credentials.userId)
                  {
                     _loc6_ = this.tourneyWinner.winnerName;
                     _loc7_ = _loc3_.rewards[_loc4_];
                     _loc8_ = "<font color=\'#FFE595\'>+" + _loc7_.toString() + " " + this.gameConfig.gameGuiContext.translate("renown") + "</font>";
                     _loc9_ = _loc4_ + 1;
                     _loc10_ = this.gameConfig.gameGuiContext.translate("tournament_winner_" + _loc9_ + "_title");
                     _loc11_ = this.gameConfig.gameGuiContext.translate("tournament_winner_" + _loc9_ + "_msg_") + _loc8_;
                     this.gameConfig.alerts.addAlert(Alert.create(0,_loc10_,_loc11_,null,null,AlertOrientationType.LEFT,AlertStyleType.TOURNEY,null));
                     break;
                  }
                  _loc4_++;
               }
               this.gameConfig.globalPrefs.setPref(_loc1_,true);
            }
         }
      }
      
      public function joinTourney(param1:int, param2:Function) : void
      {
         var tourney_id:int = param1;
         var callback:Function = param2;
         var txn:TourneyJoinTxn = new TourneyJoinTxn(this.gameConfig.fsm.credentials,function(param1:TourneyJoinTxn):void
         {
            if(param1.success)
            {
               tourneyProgress.parseJson(param1.jsonObject,logger);
               if(callback != null)
               {
                  callback();
               }
            }
         },this.logger,tourney_id);
         txn.send(this.gameConfig.fsm.communicator);
      }
      
      public function handleOneMsg(param1:Object) : Boolean
      {
         var _loc2_:String = param1["class"];
         switch(_loc2_)
         {
            case "tbs.srv.util.Tourney":
               this.tourney.parseJson(param1,this.logger);
               this.logger.info("TourneyManager.handleOneMsg " + this.tourney);
               this.alertTourney();
               return true;
            case "tbs.srv.util.TourneyProgressData":
               this.tourneyProgress.parseJson(param1,this.logger);
               this.logger.info("TourneyManager.handleOneMsg " + this.tourneyProgress);
               return true;
            case "tbs.srv.util.TourneyWinnerData":
               this.tourneyWinner.parseJson(param1,this.logger);
               this.logger.info("TourneyManager.handleOneMsg " + this.tourneyWinner);
               this.alertTourneyEnded();
               this.alertTourneyWinners();
               return true;
            default:
               return false;
         }
      }
   }
}
