package engine.saga
{
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   
   public class SagaPresenceState extends EventDispatcher
   {
       
      
      public var prev:SagaPresenceState;
      
      public var next:SagaPresenceState;
      
      private var _state:String;
      
      private var logger:ILogger;
      
      public function SagaPresenceState(param1:String, param2:ILogger)
      {
         super();
         this._state = param1;
         this.logger = param2;
         param2.info("Adding presence state: " + param1);
      }
      
      public function remove() : void
      {
         this.logger.info("Event Dispatch: Removing presence state: " + this._state);
         this.prev.next = this.next;
         if(this.next)
         {
            this.next.prev = this.prev;
         }
         dispatchEvent(new SagaPresenceStateEvent());
      }
      
      public function set state(param1:String) : void
      {
         this.logger.info("Event Dispatch: Setting presence state: " + param1);
         this._state = param1;
         dispatchEvent(new SagaPresenceStateEvent());
      }
      
      public function get state() : String
      {
         return this._state;
      }
   }
}
