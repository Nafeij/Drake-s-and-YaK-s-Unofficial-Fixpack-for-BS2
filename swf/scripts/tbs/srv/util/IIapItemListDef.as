package tbs.srv.util
{
   public interface IIapItemListDef
   {
       
      
      function getItem(param1:String) : InAppPurchaseItemDef;
      
      function get mkt() : IapMkt;
      
      function getPrice(param1:int, param2:String, param3:Boolean) : int;
      
      function findItemsByUnlock(param1:String) : Vector.<InAppPurchaseItemDef>;
   }
}
