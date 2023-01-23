package engine.core.fsm
{
   import engine.core.logging.ILogger;
   import flash.events.IEventDispatcher;
   
   public interface IFsm extends IEventDispatcher
   {
       
      
      function get currentClass() : Class;
      
      function update(param1:int) : void;
      
      function get current() : State;
      
      function getLogger() : ILogger;
   }
}
