package tbs.srv.util
{
   import engine.ability.def.AbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.EntityDefVars;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ItemListDef;
   import flash.utils.Dictionary;
   
   public class InAppPurchaseItemListDef implements IIapItemListDef
   {
       
      
      private var items:Dictionary;
      
      private var currencies:Dictionary;
      
      private var _mkt:IapMkt;
      
      private var units:Dictionary;
      
      private var logger:ILogger;
      
      public function InAppPurchaseItemListDef(param1:Object, param2:Locale, param3:ILogger, param4:AbilityDefFactory, param5:EntityClassDefList, param6:ItemListDef)
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:InAppPurchaseItemDef = null;
         var _loc11_:InAppPurchaseCurrencyDef = null;
         var _loc12_:IEntityDef = null;
         this.items = new Dictionary();
         this.currencies = new Dictionary();
         this.units = new Dictionary();
         super();
         this.logger = param3;
         for each(_loc7_ in param1.items)
         {
            _loc10_ = new InAppPurchaseItemDef(_loc7_,param2);
            this.items[_loc10_.id] = _loc10_;
         }
         for each(_loc8_ in param1.currencies)
         {
            _loc11_ = new InAppPurchaseCurrencyDef(_loc8_);
            this.currencies[_loc11_.id] = _loc11_;
         }
         for each(_loc9_ in param1.units)
         {
            _loc12_ = new EntityDefVars(param2).fromJson(_loc9_,param3,param4,param5,null,true,param6,null);
            this.units[_loc12_.id] = _loc12_;
         }
         this._mkt = new IapMkt(param1.marketplace,param2);
      }
      
      public function get mkt() : IapMkt
      {
         return this._mkt;
      }
      
      public function getUnit(param1:String) : IEntityDef
      {
         return this.units[param1];
      }
      
      public function getItem(param1:String) : InAppPurchaseItemDef
      {
         return this.items[param1];
      }
      
      public function getPrice(param1:int, param2:String, param3:Boolean) : int
      {
         if(param2 == "USD")
         {
            return param1;
         }
         var _loc4_:InAppPurchaseCurrencyDef = this.currencies[param2];
         if(!_loc4_)
         {
            this.logger.error("Unsupported currency: " + param2);
            return -1;
         }
         return param1 / _loc4_.conversion;
      }
      
      public function getItemPrice(param1:InAppPurchaseItemDef, param2:String, param3:Boolean) : int
      {
         return this.getPrice(param1.usd_cents,param2,param3);
      }
      
      public function findItemsByUnlock(param1:String) : Vector.<InAppPurchaseItemDef>
      {
         var _loc3_:InAppPurchaseItemDef = null;
         var _loc2_:Vector.<InAppPurchaseItemDef> = new Vector.<InAppPurchaseItemDef>();
         for each(_loc3_ in this.items)
         {
            if(_loc3_.unlocks.indexOf(param1) >= 0)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
   }
}
