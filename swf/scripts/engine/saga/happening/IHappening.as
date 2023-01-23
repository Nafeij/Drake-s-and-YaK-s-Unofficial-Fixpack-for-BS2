package engine.saga.happening
{
   import flash.events.IEventDispatcher;
   
   public interface IHappening extends IEventDispatcher
   {
       
      
      function execute() : void;
      
      function get isEnded() : Boolean;
      
      function get isTranscendent() : Boolean;
      
      function end(param1:Boolean) : void;
   }
}
