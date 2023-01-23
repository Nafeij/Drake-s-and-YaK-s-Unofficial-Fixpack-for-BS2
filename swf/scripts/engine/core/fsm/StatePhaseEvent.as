package engine.core.fsm
{
   import flash.events.Event;
   
   public class StatePhaseEvent extends Event
   {
      
      public static const EVENT_TYPE:String = "StateEvent";
       
      
      public var state:State;
      
      public var from:StatePhase;
      
      public var to:StatePhase;
      
      public function StatePhaseEvent(param1:State, param2:StatePhase, param3:Boolean = false, param4:Boolean = false)
      {
         super(EVENT_TYPE,param3,param4);
         this.state = param1;
         this.from = param2;
         this.to = param1.phase;
      }
   }
}
