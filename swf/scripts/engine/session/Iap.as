package engine.session
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import tbs.srv.util.InAppPurchaseItemDef;
   
   public class Iap extends EventDispatcher
   {
      
      public static const EVENT_POST_INIT:String = "Iap.EVENT_POST_INIT";
       
      
      public var item:InAppPurchaseItemDef;
      
      public var orderid:int;
      
      public var transid:int;
      
      public var error:Boolean;
      
      public var complete:Boolean;
      
      public var init:Boolean;
      
      public var unauthorized:Boolean;
      
      public var authorized:Boolean;
      
      public var errorMsg:String;
      
      public var logger:ILogger;
      
      private var man:IIapManager;
      
      public function Iap(param1:IIapManager, param2:ILogger)
      {
         super();
         this.logger = param2;
         this.man = param1;
      }
      
      override public function toString() : String
      {
         return "Iap[" + this.item.id + " " + this.orderid + " " + this.transid + "]";
      }
      
      public function setUnauthorized() : void
      {
         this.unauthorized = true;
         this.authorized = false;
         var _loc1_:String = "Iap.setUnauthorized " + this;
         this.logger.info(_loc1_);
         this.man.sendInfo(_loc1_);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function setAuthorized() : void
      {
         this.unauthorized = false;
         this.authorized = true;
         var _loc1_:String = "Iap.setAuthorized " + this;
         this.logger.info(_loc1_);
         this.man.sendInfo(_loc1_);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function setInit(param1:int, param2:int) : void
      {
         this.init = true;
         this.orderid = param1;
         this.transid = param2;
         var _loc3_:String = "Iap.setInit " + this;
         this.logger.info(_loc3_);
         this.man.sendInfo(_loc3_);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function handlePostInit() : void
      {
         var _loc1_:String = "Iap.handlePostInit " + this;
         this.logger.info(_loc1_);
         this.man.sendInfo(_loc1_);
         dispatchEvent(new Event(EVENT_POST_INIT));
      }
      
      public function setError(param1:String) : void
      {
         this.errorMsg = param1;
         this.error = true;
         var _loc2_:String = "Iap.setError " + this + ": " + param1;
         this.logger.error(_loc2_);
         this.man.sendInfo(_loc2_);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function setComplete() : void
      {
         this.complete = true;
         var _loc1_:String = "Iap.setComplete " + this;
         this.logger.info(_loc1_);
         this.man.sendInfo(_loc1_);
         dispatchEvent(new Event(Event.CHANGE));
      }
   }
}
