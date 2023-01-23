package game.cfg
{
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.EntityDefVars;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPurchasableUnit;
   import tbs.srv.data.PurchasableUnitData;
   
   public class PurchasableUnit implements IPurchasableUnit
   {
      
      public static const schema:Object = {
         "name":"PurchasableUnit",
         "type":"object",
         "properties":{
            "cost":{"type":"number"},
            "limit":{"type":"number"},
            "def":{"type":EntityDefVars.schema}
         }
      };
       
      
      private var _def:IEntityDef;
      
      private var _limit:int;
      
      private var _cost:int;
      
      private var _comment:String = "";
      
      public function PurchasableUnit()
      {
         super();
      }
      
      public function set cost(param1:int) : void
      {
         this._cost = param1;
      }
      
      public function set limit(param1:int) : void
      {
         this._limit = param1;
      }
      
      public function set def(param1:IEntityDef) : void
      {
         this._def = param1;
      }
      
      public function get comment() : String
      {
         return this._comment;
      }
      
      public function parseData(param1:PurchasableUnitData, param2:GameConfig) : void
      {
         this._def = new EntityDefVars(param2.context.locale).fromJson(param1.def,param2.logger,param2.abilityFactory,param2.classes,param2,true,param2.itemDefs,param2.statCosts);
         this._limit = param1.limit;
         this._cost = param1.cost;
         if(param1.comment)
         {
            this._comment = param2.context.locale.translate(LocaleCategory.ENTITY,param1.comment);
         }
      }
      
      public function get def() : IEntityDef
      {
         return this._def;
      }
      
      public function get limit() : int
      {
         return this._limit;
      }
      
      public function get cost() : int
      {
         return this._cost;
      }
   }
}
