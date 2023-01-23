package engine.entity.def
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class TitleListDefVars extends TitleListDef
   {
      
      public static const schema:Object = {
         "name":"TitleListDefVars",
         "type":"object",
         "properties":{"titles":{
            "type":"array",
            "items":TitleDefVars.schema
         }}
      };
       
      
      public function TitleListDefVars(param1:Locale, param2:ILogger)
      {
         super(param1,param2);
      }
      
      public static function save(param1:TitleListDef) : Object
      {
         var _loc3_:TitleDef = null;
         var _loc4_:Object = null;
         var _loc2_:Object = {"titles":[]};
         for each(_loc3_ in param1.getTitleDict())
         {
            _loc4_ = TitleDefVars.save(_loc3_);
            _loc2_.items.push(_loc4_);
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:BattleAbilityDefFactory, param3:ILogger) : TitleListDef
      {
         var _loc4_:Object = null;
         var _loc5_:TitleDef = null;
         EngineJsonDef.validateThrow(param1,schema,param3);
         for each(_loc4_ in param1.titles)
         {
            _loc5_ = new TitleDefVars(locale).fromJson(_loc4_,param2,param3);
            addTitleDef(_loc5_);
         }
         return this;
      }
   }
}
