package engine.saga.happening
{
   import engine.saga.SagaTriggerDef;
   import engine.saga.SagaTriggerType;
   import flash.events.IEventDispatcher;
   
   public interface IHappeningDefProvider extends IEventDispatcher
   {
       
      
      function getHappeningDef(param1:String) : HappeningDef;
      
      function get numHappenings() : int;
      
      function getHappeningDefByIndex(param1:int) : HappeningDef;
      
      function getTriggersByType(param1:SagaTriggerType, param2:Vector.<SagaTriggerDef>, param3:String) : Vector.<SagaTriggerDef>;
      
      function get providerName() : String;
      
      function get owner() : *;
      
      function get linkString() : String;
   }
}
