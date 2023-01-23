package engine.entity.def
{
   import engine.ability.def.AbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.StableJson;
   import engine.def.EngineJsonDef;
   import engine.entity.UnitStatCosts;
   import engine.saga.vars.IBattleEntityProvider;
   
   public class EntityListDefVars extends EntityListDef
   {
      
      public static const schema:Object = {
         "name":"EntityListDefVars",
         "type":"object",
         "properties":{"defs":{
            "type":"array",
            "items":EntityDefVars.schema
         }}
      };
       
      
      public function EntityListDefVars(param1:Locale, param2:ILogger)
      {
         super(param1,null,param2);
      }
      
      public static function save(param1:EntityListDef, param2:ILogger) : Object
      {
         var _loc5_:EntityDef = null;
         var _loc3_:Object = {"defs":[]};
         var _loc4_:int = 0;
         while(_loc4_ < param1.numEntityDefs)
         {
            _loc5_ = param1.getEntityDef(_loc4_) as EntityDef;
            _loc3_.defs.push(EntityDefVars.save(_loc5_,param2));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:AbilityDefFactory, param4:EntityClassDefList, param5:IBattleEntityProvider, param6:Boolean, param7:ItemListDef, param8:UnitStatCosts = null) : EntityListDefVars
      {
         var errors:int;
         var cdv:Object = null;
         var ed:EntityDef = null;
         var ss:String = null;
         var vars:Object = param1;
         var logger:ILogger = param2;
         var abilityDefFactory:AbilityDefFactory = param3;
         var classes:EntityClassDefList = param4;
         var bbp:IBattleEntityProvider = param5;
         var warnStats:Boolean = param6;
         var itemDefs:ItemListDef = param7;
         var statCosts:UnitStatCosts = param8;
         EngineJsonDef.validateThrow(vars,schema,logger);
         this._classes = classes;
         errors = 0;
         for each(cdv in vars.defs)
         {
            try
            {
               ed = new EntityDefVars(locale).fromJson(cdv,logger,abilityDefFactory,classes,bbp,warnStats,itemDefs,statCosts);
               if(getEntityDefById(ed.id))
               {
                  logger.error("Entity list [" + url + "] has duplicate entries for [" + ed.id + "]");
                  errors++;
               }
               else
               {
                  addEntityDef(ed);
               }
            }
            catch(e:Error)
            {
               ss = "";
               try
               {
                  ss = StableJson.stringify(cdv,null,"  ");
               }
               catch(e2:Error)
               {
                  logger.error("Error creating error message!");
               }
               errors++;
               logger.error("EntityListDefVars Failed to load entity def: " + e.getStackTrace() + "\n" + ss);
            }
         }
         if(errors)
         {
            throw new ArgumentError("Failed to load entity list.  Errors: " + errors);
         }
         return this;
      }
   }
}
