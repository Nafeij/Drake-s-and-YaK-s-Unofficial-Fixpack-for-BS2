package tbs.srv.util
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class PurchaseCounts extends EventDispatcher
   {
       
      
      public var purchases:Vector.<PurchaseCountData>;
      
      private var purchasesById:Dictionary;
      
      public function PurchaseCounts()
      {
         this.purchases = new Vector.<PurchaseCountData>();
         this.purchasesById = new Dictionary();
         super();
      }
      
      public function getPurchaseCountData(param1:String) : PurchaseCountData
      {
         return this.purchasesById[param1];
      }
      
      public function getPurchaseCount(param1:String) : int
      {
         var _loc2_:PurchaseCountData = this.purchasesById[param1];
         return !!_loc2_ ? _loc2_.purchase_count : 0;
      }
      
      public function addPurchase(param1:PurchaseCountData) : void
      {
         this.purchases.push(param1);
         this.purchasesById[param1.item_id] = param1;
      }
      
      public function incrementPurchaseCount(param1:String) : void
      {
         var _loc2_:PurchaseCountData = this.getPurchaseCountData(param1);
         if(_loc2_)
         {
            ++_loc2_.purchase_count;
         }
         else
         {
            _loc2_ = new PurchaseCountData();
            _loc2_.item_id = param1;
            _loc2_.purchase_count = 1;
            this.addPurchase(_loc2_);
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function decrementPurchase(param1:String) : void
      {
         var _loc2_:PurchaseCountData = this.getPurchaseCountData(param1);
         if(_loc2_)
         {
            _loc2_.purchase_count = Math.max(0,_loc2_.purchase_count - 1);
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
   }
}
