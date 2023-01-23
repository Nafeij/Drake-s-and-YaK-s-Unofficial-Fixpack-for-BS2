package engine.saga
{
   public interface ISagaPresenceManager
   {
       
      
      function update(param1:int) : void;
      
      function setBaseState(param1:String) : void;
      
      function pushNewState(param1:String) : SagaPresenceState;
   }
}
