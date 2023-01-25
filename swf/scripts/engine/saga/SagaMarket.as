package engine.saga
{
   import engine.entity.def.ItemDef;
   import engine.saga.vars.VariableType;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SagaMarket extends EventDispatcher
   {
      
      public static const EVENT_SHOWING:String = "SagaMarket.EVENT_SHOWING";
       
      
      private var items:Vector.<ItemDef>;
      
      private var saga:Saga;
      
      private var _showing:Boolean;
      
      public function SagaMarket(param1:Saga)
      {
         this.items = new Vector.<ItemDef>();
         super();
         this.saga = param1;
      }
      
      public function get showing() : Boolean
      {
         return this._showing;
      }
      
      public function set showing(param1:Boolean) : void
      {
         if(this._showing == param1)
         {
            return;
         }
         this._showing = param1;
         dispatchEvent(new Event(EVENT_SHOWING));
      }
      
      public function cleanup() : void
      {
         this.items = null;
         this.saga = null;
      }
      
      public function get numItemDefs() : int
      {
         return !!this.items ? int(this.items.length) : 0;
      }
      
      public function getItemDef(param1:int) : ItemDef
      {
         return this.items[param1];
      }
      
      public function removeItemDef(param1:ItemDef) : Boolean
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ < 0)
         {
            return false;
         }
         this.items.splice(_loc2_,1);
         return true;
      }
      
      public function addItemDefById(param1:String) : ItemDef
      {
         var _loc2_:ItemDef = this.saga.def.itemDefs.getItemDef(param1);
         if(_loc2_)
         {
            this.items.push(_loc2_);
         }
         return _loc2_;
      }
      
      public function refresh() : void
      {
         var _loc5_:int = 0;
         var _loc6_:ItemDef = null;
         this.items = this.saga.generateRandomItemList(0,0);
         if(!this.items)
         {
            return;
         }
         var _loc1_:int = this.saga.getVarInt(SagaVar.VAR_MARKET_ITEMS_MIN);
         var _loc2_:int = this.saga.getVarInt(SagaVar.VAR_MARKET_ITEMS_MAX);
         var _loc3_:int = 0;
         if(_loc1_ == _loc2_)
         {
            _loc3_ = _loc1_;
         }
         else
         {
            _loc3_ = this.saga.rng.nextMinMax(_loc1_,_loc2_);
         }
         _loc3_ = Math.min(this.items.length,_loc3_);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this.saga.rng.nextMax(this.items.length - 1);
            _loc6_ = this.items[_loc5_];
            this.items[_loc5_] = this.items[_loc4_];
            this.items[_loc4_] = _loc6_;
            _loc4_++;
         }
         if(this.items.length > _loc3_)
         {
            this.items.splice(_loc3_,this.items.length - _loc3_);
         }
      }
      
      public function get availableSupplies() : int
      {
         return this.saga.getVar(SagaVar.VAR_MARKET_AVAILABLE_SUPPLIES,VariableType.INTEGER).asInteger;
      }
      
      public function set availableSupplies(param1:int) : void
      {
         this.saga.setVar(SagaVar.VAR_MARKET_AVAILABLE_SUPPLIES,param1);
      }
      
      public function get suppliesPerRenown() : int
      {
         return this.saga.getVar(SagaVar.VAR_MARKET_SUPPLIES_PER_RENOWN,VariableType.INTEGER).asInteger;
      }
   }
}
