package game.cfg
{
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.Legend;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import tbs.srv.util.CurrencyData;
   import tbs.srv.util.PurchaseCounts;
   import tbs.srv.util.UnlockData;
   
   public class AccountInfoDef extends EventDispatcher
   {
      
      public static const UNLOCKS:String = "AccountInfoDef.UNLOCKS";
      
      public static const CURRENCY:String = "AccountInfoDef.CURRENCY";
       
      
      public const crownChitIconUrl:String = "common/battle/banner/chit/crown_jade_backer.png";
      
      public const crownIconUrl:String = "common/battle/banner/crown/crown_base.png";
      
      private var classes:EntityClassDefList;
      
      private var gameConfig:GameConfig;
      
      public var logger:ILogger;
      
      public var daily_login_streak:int;
      
      public var daily_login_bonus:int;
      
      private var unlocks:Vector.<UnlockData>;
      
      private var unlocksById:Dictionary;
      
      public var legend:Legend;
      
      public var tutorial:Boolean;
      
      public var purchases:PurchaseCounts;
      
      public var currency:String = "USD";
      
      public var iap_sandbox:Boolean;
      
      public var server_delta_time:Number = 0;
      
      public var completed_tutorial:Boolean;
      
      public var login_count:int = 0;
      
      public function AccountInfoDef(param1:GameConfig)
      {
         this.unlocks = new Vector.<UnlockData>();
         this.unlocksById = new Dictionary();
         this.purchases = new PurchaseCounts();
         super();
         this.logger = param1.logger;
         this.classes = param1.classes;
         this.gameConfig = param1;
         this.legend = new Legend(9,this.logger,param1.context.locale,param1.classes,param1.statCosts,param1.abilityFactory,param1.itemDefs);
      }
      
      public function handleUnlock(param1:UnlockData) : void
      {
         this.setUnlock(param1);
         dispatchEvent(new Event(UNLOCKS));
      }
      
      protected function setUnlock(param1:UnlockData) : void
      {
         var _loc3_:UnlockData = null;
         this.unlocksById[param1.unlock_id] = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.unlocks.length)
         {
            _loc3_ = this.unlocks[_loc2_];
            if(_loc3_.unlock_id == param1.unlock_id)
            {
               this.unlocks[_loc2_] = param1;
               return;
            }
            _loc2_++;
         }
         this.unlocks.push(param1);
      }
      
      public function getUnlockById(param1:String) : UnlockData
      {
         return this.unlocksById[param1];
      }
      
      public function hasUnlock(param1:String) : Boolean
      {
         var _loc2_:UnlockData = null;
         if(param1)
         {
            _loc2_ = this.getUnlockById(param1);
            if(!_loc2_)
            {
               return false;
            }
            if(_loc2_.unlock_duration <= 0)
            {
               return true;
            }
            return _loc2_.unlock_time + _loc2_.unlock_duration > new Date().time + this.server_delta_time;
         }
         return true;
      }
      
      public function handleCurrencyData(param1:CurrencyData) : void
      {
         if(this.currency != param1.currency)
         {
            this.currency = param1.currency;
            dispatchEvent(new Event(CURRENCY));
         }
      }
   }
}
