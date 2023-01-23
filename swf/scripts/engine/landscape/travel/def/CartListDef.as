package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class CartListDef
   {
      
      public static const schema:Object = {
         "name":"CartListDef",
         "type":"object",
         "properties":{"carts":{
            "type":"array",
            "items":CartDef.schema
         }}
      };
       
      
      private var logger:ILogger;
      
      private var _cartDefsById:Dictionary;
      
      private var _enabledCartDefs:Vector.<CartDef>;
      
      public function CartListDef(param1:ILogger)
      {
         super();
         this.logger = param1;
         this._cartDefsById = new Dictionary();
         this._enabledCartDefs = new Vector.<CartDef>();
      }
      
      public function fromJson(param1:Object) : CartListDef
      {
         var _loc2_:Object = null;
         var _loc3_:CartDef = null;
         EngineJsonDef.validateThrow(param1,schema,this.logger);
         for each(_loc2_ in param1.carts)
         {
            _loc3_ = new CartDef().fromJson(_loc2_,this.logger);
            this.addCartDef(_loc3_);
         }
         return this;
      }
      
      public function addCartDef(param1:CartDef) : void
      {
         if(!param1)
         {
            throw new ArgumentError("CartDef.addCartDef null entity");
         }
         if(!param1.disabled)
         {
            this._enabledCartDefs.push(param1);
         }
         this._cartDefsById[param1.id] = param1;
      }
      
      public function getCartDefById(param1:String) : CartDef
      {
         var _loc2_:CartDef = null;
         if(Boolean(param1) && param1 != "")
         {
            _loc2_ = this._cartDefsById[param1];
         }
         return _loc2_;
      }
      
      public function getCartDefAt(param1:int) : CartDef
      {
         if(!this._enabledCartDefs || param1 >= this._enabledCartDefs.length)
         {
            return null;
         }
         return this._enabledCartDefs[param1];
      }
      
      public function getCartIndex(param1:CartDef) : int
      {
         var _loc2_:int = 0;
         var _loc3_:CartDef = null;
         for each(_loc3_ in this._enabledCartDefs)
         {
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getCartCount() : int
      {
         return this._enabledCartDefs.length;
      }
      
      public function logCarts(param1:ILogger) : void
      {
         var _loc2_:CartDef = null;
         param1.info("All Carts:");
         for each(_loc2_ in this._cartDefsById)
         {
            param1.info("\t" + _loc2_.id);
         }
      }
   }
}
