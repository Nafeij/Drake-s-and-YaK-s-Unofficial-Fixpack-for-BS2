package engine.session
{
   import flash.events.IEventDispatcher;
   import tbs.srv.util.IIapItemListDef;
   import tbs.srv.util.PurchaseCounts;
   
   public interface IIapManager extends IEventDispatcher
   {
       
      
      function purchase(param1:String) : Iap;
      
      function get itemList() : IIapItemListDef;
      
      function translate(param1:String) : String;
      
      function sendInfo(param1:String) : void;
      
      function set purchases(param1:PurchaseCounts) : void;
      
      function get purchases() : PurchaseCounts;
      
      function set sandbox(param1:Boolean) : void;
      
      function get sandbox() : Boolean;
      
      function set debugImmediateFinalize(param1:Boolean) : void;
      
      function get debugImmediateFinalize() : Boolean;
      
      function set gameData(param1:Object) : void;
      
      function get gameData() : Object;
   }
}
