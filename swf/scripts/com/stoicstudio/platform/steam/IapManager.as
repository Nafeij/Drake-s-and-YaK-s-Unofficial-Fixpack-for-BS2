package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import air.steamworks.ane.SteamworksCallbackEvent;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.entity.def.Legend;
   import engine.session.IIapManager;
   import engine.session.Iap;
   import engine.session.IapManagerEvent;
   import engine.session.Session;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import tbs.srv.util.IIapItemListDef;
   import tbs.srv.util.IapFinalizeTxn;
   import tbs.srv.util.IapInfoTxn;
   import tbs.srv.util.IapInitTxn;
   import tbs.srv.util.InAppPurchaseItemDef;
   import tbs.srv.util.InAppPurchaseItemListDef;
   import tbs.srv.util.PurchaseCounts;
   
   public class IapManager extends EventDispatcher implements IIapManager
   {
      
      public static var steam:SteamworksAne;
       
      
      private var locale:Locale;
      
      private var _itemList:InAppPurchaseItemListDef;
      
      private var session:Session;
      
      private var language:String;
      
      private var logger:ILogger;
      
      private var iaps:Dictionary;
      
      public var _debugImmediateFinalize:Boolean;
      
      public var _purchases:PurchaseCounts;
      
      private var _legend:Legend;
      
      public var _sandbox:Boolean;
      
      private var stashedAuthorizations:Dictionary;
      
      public function IapManager(param1:InAppPurchaseItemListDef, param2:PurchaseCounts, param3:Legend, param4:Session, param5:String, param6:Locale, param7:ILogger)
      {
         this.iaps = new Dictionary();
         this.stashedAuthorizations = new Dictionary();
         super();
         this.locale = param6;
         this._itemList = param1;
         this.session = param4;
         this.logger = param7;
         this.language = param5;
         this._purchases = param2;
         this._legend = param3;
         steam.addEventListener(SteamworksCallbackEvent.TYPE,this.steamworksCallbackHandler);
      }
      
      public function purchase(param1:String) : Iap
      {
         var _loc4_:Iap = null;
         var _loc2_:InAppPurchaseItemDef = this._itemList.getItem(param1);
         if(!_loc2_)
         {
            this.logger.error("IapManager.purchase invalid item id: " + param1);
            return null;
         }
         if(!steam.SteamUtils_IsOverlayEnabled())
         {
            this.logger.info("IapManager.purchase steam overlay is disabled");
            if(this._debugImmediateFinalize)
            {
            }
         }
         var _loc3_:String = _loc2_.name;
         _loc4_ = new Iap(this,this.logger);
         _loc4_.item = _loc2_;
         this.iaps[_loc4_] = _loc4_;
         this.logger.info("IapManager.purchase " + _loc4_);
         _loc4_.addEventListener(Iap.EVENT_POST_INIT,this.iapPostInitHandler);
         dispatchEvent(new IapManagerEvent(IapManagerEvent.STARTED,_loc4_));
         var _loc5_:IapInitTxn = new IapInitTxn(this.session.credentials,this.purchaseInitTxnHandler,this.logger,_loc4_,this.language);
         _loc5_.send(this.session.communicator);
         return _loc4_;
      }
      
      private function iapPostInitHandler(param1:Event) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc2_:Iap = param1.target as Iap;
         if(this.iaps[_loc2_])
         {
            if(_loc2_.orderid in this.stashedAuthorizations)
            {
               _loc3_ = Boolean(this.stashedAuthorizations[_loc2_.orderid]);
               _loc4_ = "IapManager.iapPostInitHandler unstashing auth " + _loc3_ + " for " + _loc2_;
               this.logger.info(_loc4_);
               this.sendInfo(_loc4_);
               delete this.stashedAuthorizations[_loc2_.orderid];
               this.handleAuthorization(_loc2_,_loc3_);
            }
         }
      }
      
      private function purchaseInitTxnHandler(param1:IapInitTxn) : void
      {
         this.logger.info("IapManager.purchaseInitTxnHandler " + param1.iap);
         if(!(param1.iap in this.iaps))
         {
            return;
         }
         if(param1.iap.error)
         {
            param1.iap.removeEventListener(Iap.EVENT_POST_INIT,this.iapPostInitHandler);
            delete this.iaps[param1.iap];
            return;
         }
         if(this._debugImmediateFinalize)
         {
            this.finalizeTransaction(param1.iap);
         }
      }
      
      private function getIapByOrderId(param1:int) : Iap
      {
         var _loc2_:Iap = null;
         for each(_loc2_ in this.iaps)
         {
            if(_loc2_.orderid == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function steamworksCallbackHandler(param1:SteamworksCallbackEvent) : void
      {
         var _loc2_:int = 0;
         var _loc5_:String = null;
         this.logger.info("IapManager.steamworksCallbackHandler callback=" + param1.callback);
         if(param1.callback.callback_type != "MicroTxnAuthorizationResponse_t")
         {
            return;
         }
         _loc2_ = parseInt(param1.callback.m_ulOrderID);
         this.logger.info("IapManager.steamworksCallbackHandler m_ulOrderID=" + _loc2_);
         var _loc3_:Boolean = Boolean(param1.callback.m_bAuthorized);
         var _loc4_:Iap = this.getIapByOrderId(_loc2_);
         if(!_loc4_)
         {
            _loc5_ = "steamworksCallbackHandler No such order: " + _loc2_;
            this.logger.info(_loc5_);
            this.stashedAuthorizations[_loc2_] = _loc3_;
            this.sendInfo(_loc5_);
            return;
         }
         this.handleAuthorization(_loc4_,_loc3_);
      }
      
      public function sendInfo(param1:String) : void
      {
         var _loc2_:IapInfoTxn = new IapInfoTxn(this.session.credentials,null,this.logger,param1);
         _loc2_.send(this.session.communicator);
      }
      
      private function handleAuthorization(param1:Iap, param2:Boolean) : void
      {
         var _loc3_:String = "IapManager.handleAuthorization iap=" + param1 + " auth=" + param2;
         this.logger.info(_loc3_);
         this.sendInfo(_loc3_);
         if(!param2)
         {
            this.logger.info("handleAuthorization unauthorized " + param1);
            param1.setUnauthorized();
            return;
         }
         this.finalizeTransaction(param1);
      }
      
      private function finalizeTransaction(param1:Iap) : void
      {
         this.logger.info("IapManager.finalizeTransaction " + param1);
         var _loc2_:IapFinalizeTxn = new IapFinalizeTxn(this.session.credentials,this.purchaseFinalizeTxnHandler,this.logger,param1);
         _loc2_.send(this.session.communicator);
      }
      
      private function purchaseFinalizeTxnHandler(param1:IapFinalizeTxn) : void
      {
         this.logger.info("IapManager.purchaseFinalizeTxnHandler " + param1.iap);
         param1.iap.removeEventListener(Iap.EVENT_POST_INIT,this.iapPostInitHandler);
         delete this.iaps[param1.iap];
         if(param1.responseCode == 200)
         {
            if(param1.iap.item.roster_rows > 0)
            {
               this._legend.rosterRowCount += param1.iap.item.roster_rows;
            }
            this._purchases.incrementPurchaseCount(param1.iap.item.id);
         }
      }
      
      public function get itemList() : IIapItemListDef
      {
         return this._itemList;
      }
      
      public function translate(param1:String) : String
      {
         return this.locale.translate(LocaleCategory.IAP,param1);
      }
      
      public function set purchases(param1:PurchaseCounts) : void
      {
         this._purchases = param1;
      }
      
      public function get purchases() : PurchaseCounts
      {
         return this._purchases;
      }
      
      public function get sandbox() : Boolean
      {
         return this._sandbox;
      }
      
      public function set sandbox(param1:Boolean) : void
      {
         this._sandbox = param1;
      }
      
      public function set debugImmediateFinalize(param1:Boolean) : void
      {
         this._debugImmediateFinalize = param1;
      }
      
      public function get debugImmediateFinalize() : Boolean
      {
         return this._debugImmediateFinalize;
      }
      
      public function set gameData(param1:Object) : void
      {
         this._legend = param1 as Legend;
      }
      
      public function get gameData() : Object
      {
         return this._legend;
      }
   }
}
