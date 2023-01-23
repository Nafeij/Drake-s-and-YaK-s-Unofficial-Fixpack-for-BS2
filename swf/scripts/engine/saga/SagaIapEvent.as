package engine.saga
{
   import flash.events.Event;
   
   public final class SagaIapEvent extends Event
   {
      
      public static const PRODUCT_LIST:String = "SagaIap.ProductList";
      
      public static const PURCHASE_COMPLETE:String = "SagaIap.PurchaseComplete";
      
      public static const PURCHASE_FAILED:String = "SagaIap.PurchaseFailed";
      
      public static const PURCHASE_DEFERRED:String = "SagaIap.PurchaseDeferred";
      
      public static const RESTORE_SUCCESS:String = "SagaIap.RestoreSuccess";
      
      public static const RESTORE_FAILED:String = "SagaIap.RestoreFailed";
      
      public static const STORE_OPENED:String = "SagaIap.StoreOpened";
      
      public static const STORE_FAILED:String = "SagaIap.StoreFailed";
       
      
      public var product:SagaIapProduct;
      
      public var dlc:String;
      
      public function SagaIapEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
