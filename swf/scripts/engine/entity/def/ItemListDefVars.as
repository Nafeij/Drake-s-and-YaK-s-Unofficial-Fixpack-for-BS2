package engine.entity.def
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class ItemListDefVars extends ItemListDef
   {
      
      public static const schema:Object = {
         "name":"ItemListDefVars",
         "type":"object",
         "properties":{"items":{
            "type":"array",
            "items":ItemDefVars.schema
         }}
      };
       
      
      public function ItemListDefVars(param1:Locale, param2:ILogger)
      {
         super(param1,param2);
      }
      
      public static function save(param1:ItemListDef) : Object
      {
         var _loc3_:ItemDef = null;
         var _loc4_:Object = null;
         var _loc2_:Object = {"items":[]};
         for each(_loc3_ in param1.items)
         {
            _loc4_ = ItemDefVars.save(_loc3_);
            _loc2_.items.push(_loc4_);
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:BattleAbilityDefFactory, param3:ILogger) : ItemListDef
      {
         var _loc4_:Object = null;
         var _loc5_:ItemDef = null;
         EngineJsonDef.validateThrow(param1,schema,param3);
         for each(_loc4_ in param1.items)
         {
            _loc5_ = new ItemDefVars(locale).fromJson(_loc4_,param2,param3);
            _loc5_.resolve(param2);
            addItemDef(_loc5_);
         }
         return this;
      }
   }
}
