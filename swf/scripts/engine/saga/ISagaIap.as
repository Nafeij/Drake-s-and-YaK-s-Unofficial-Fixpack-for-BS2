package engine.saga
{
   import flash.events.IEventDispatcher;
   
   public interface ISagaIap extends IEventDispatcher
   {
       
      
      function setSaga(param1:Saga) : void;
      
      function purchaseProduct(param1:String) : void;
      
      function requestProductInfo(param1:SagaDlcEntry) : void;
      
      function restorePurchase(param1:String) : void;
      
      function get skipIngamePitch() : Boolean;
   }
}
