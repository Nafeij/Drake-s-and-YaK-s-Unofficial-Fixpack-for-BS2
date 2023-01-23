package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.fsm.State;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.http.HttpAction;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BaseBattleState extends State
   {
       
      
      private var startTime:int;
      
      private var txns:Vector.<HttpAction>;
      
      private var errorTimer:Timer;
      
      public var timeoutMs:int;
      
      private var pollRequirementMs:int;
      
      public var showDeploymentId:String;
      
      public var showRespawnDeploymentId:String;
      
      protected var _triggerMMAAchievementOnFinish:Boolean = false;
      
      private var _timeoutElapsedMs:int;
      
      public function BaseBattleState(param1:StateData, param2:BattleFsm, param3:ILogger, param4:int = 0, param5:int = 0)
      {
         this.txns = new Vector.<HttpAction>();
         super(param1,param2,param3);
         this.timeoutMs = param4;
         this.pollRequirementMs = param5;
         this._triggerMMAAchievementOnFinish = false;
      }
      
      public function fastForward() : void
      {
      }
      
      override protected function handleCleanup() : void
      {
         var _loc1_:HttpAction = null;
         super.handleCleanup();
         if(this.pollRequirementMs > 0)
         {
            if(this.battleFsm.isOnline)
            {
               this.battleFsm.session.communicator.removePollTimeRequirement(this);
            }
         }
         for each(_loc1_ in this.txns)
         {
            _loc1_.abort();
         }
         this.txns = null;
         if(this.errorTimer)
         {
            this.errorTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.errorTimerCompleteHandler);
            this.errorTimer.stop();
            this.errorTimer = null;
         }
      }
      
      protected function advanceTimer(param1:int) : void
      {
         var _loc2_:Saga = Saga.instance;
         if(_loc2_)
         {
            if(_loc2_.paused)
            {
               return;
            }
            if(_loc2_.isShowingTutorialTooltips)
            {
               return;
            }
         }
         if(this.timeoutMs)
         {
            this._timeoutElapsedMs += param1;
            if(this._timeoutElapsedMs >= this.timeoutMs)
            {
               this.handleTimeout();
            }
         }
      }
      
      protected function addTxn(param1:HttpAction) : void
      {
         this.txns.push(param1);
      }
      
      protected function handleTimeout() : void
      {
         this.battleFsm.addErrorMsg("Timed out " + this + " after " + this._timeoutElapsedMs);
         phase = StatePhase.FAILED;
      }
      
      override protected function handleEnteredState() : void
      {
         if(this.pollRequirementMs > 0)
         {
            if(this.battleFsm.isOnline)
            {
               this.battleFsm.session.communicator.setPollTimeRequirement(this,this.pollRequirementMs);
            }
         }
      }
      
      public function get battleFsm() : BattleFsm
      {
         return fsm as BattleFsm;
      }
      
      public function forceTimeout() : void
      {
         if(this.timeoutMs)
         {
            this.handleTimeout();
         }
      }
      
      public function get timeoutElapsedMs() : int
      {
         return this._timeoutElapsedMs;
      }
      
      public function get timeoutPercent() : Number
      {
         if(this.timeoutMs)
         {
            return this.timeoutElapsedMs / this.timeoutMs;
         }
         return 0;
      }
      
      public function get timeoutRemainingMs() : int
      {
         if(this.timeoutMs)
         {
            return this.timeoutMs - this.timeoutElapsedMs;
         }
         return 0;
      }
      
      public function timeoutAllDelayedTxns() : void
      {
         var _loc1_:HttpAction = null;
         for each(_loc1_ in this.txns)
         {
            if(!_loc1_.sent)
            {
               _loc1_.forceTimerTimeout();
            }
         }
      }
      
      private function errorTimerCompleteHandler(param1:TimerEvent) : void
      {
         logger.info("Could not recover from network errors.");
         this.battleFsm.addErrorMsg("Unable to communicate with Server.");
         phase = StatePhase.FAILED;
      }
      
      public function mockErrorTimeout() : void
      {
         if(Boolean(this.errorTimer) && this.errorTimer.running)
         {
            this.errorTimer.stop();
            this.errorTimerCompleteHandler(null);
         }
      }
   }
}
