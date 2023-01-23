package engine.saga
{
   import engine.core.util.AppInfo;
   import flash.events.EventDispatcher;
   
   public class NullSagaPresenceManager extends EventDispatcher implements ISagaPresenceManager
   {
       
      
      private const ResolveThrottleTime:int = 15000;
      
      protected var _baseState:SagaPresenceState;
      
      protected var _appInfo:AppInfo;
      
      protected var _lastState:String;
      
      private var _pendingStateChange:String = "";
      
      private var _timeSinceLastResolve:int = 0;
      
      public function NullSagaPresenceManager(param1:AppInfo)
      {
         super();
         this._appInfo = param1;
         this._lastState = SagaPresenceManager.StateNone;
         this._baseState = new SagaPresenceState(SagaPresenceManager.StateNone,this._appInfo.logger);
         this._baseState.addEventListener(SagaPresenceStateEvent.STATE_CHANGE,this.handleStateChange);
      }
      
      public function setBaseState(param1:String) : void
      {
         this._appInfo.logger.info("Setting base saga state: " + param1);
         this._baseState.state = param1;
      }
      
      public function pushNewState(param1:String) : SagaPresenceState
      {
         var _loc2_:SagaPresenceState = new SagaPresenceState(param1,this._appInfo.logger);
         _loc2_.addEventListener(SagaPresenceStateEvent.STATE_CHANGE,this.handleStateChange);
         var _loc3_:SagaPresenceState = this.fetchTail();
         _loc3_.next = _loc2_;
         _loc2_.prev = _loc3_;
         this.handleStateChange(null);
         return _loc2_;
      }
      
      private function fetchTail() : SagaPresenceState
      {
         var _loc1_:SagaPresenceState = this._baseState;
         while(_loc1_.next != null)
         {
            _loc1_ = _loc1_.next;
         }
         return _loc1_;
      }
      
      public function handleStateChange(param1:SagaPresenceStateEvent) : void
      {
         this._appInfo.logger.info("Handling saga presence state change");
         var _loc2_:SagaPresenceState = this.fetchTail();
         if(this._lastState != _loc2_.state)
         {
            this._pendingStateChange = _loc2_.state;
         }
         this._lastState = _loc2_.state;
      }
      
      public function update(param1:int) : void
      {
         this._timeSinceLastResolve += param1;
         if(this._pendingStateChange != "" && this._timeSinceLastResolve > this.ResolveThrottleTime)
         {
            this._appInfo.logger.info("Resolving the saga presence state to [" + this._pendingStateChange + "]");
            this.resolveStateChange(this._pendingStateChange);
            this._pendingStateChange = "";
            this._timeSinceLastResolve = 0;
         }
      }
      
      protected function resolveStateChange(param1:String) : void
      {
      }
   }
}
