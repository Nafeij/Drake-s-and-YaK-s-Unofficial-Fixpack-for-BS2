package engine.entity.def
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatModDef;
   import engine.stat.def.StatModDefVars;
   import flash.errors.IllegalOperationError;
   
   public class ItemDefVars extends ItemDef
   {
      
      public static const schema:Object = {
         "name":"ItemDefVars",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "optional":true
            },
            "icon":{
               "type":"string",
               "optional":true
            },
            "passive":{
               "type":"string",
               "optional":true
            },
            "rank":{
               "type":"number",
               "optional":true
            },
            "statmods":{
               "type":"array",
               "items":StatModDefVars.schema,
               "optional":true
            },
            "omitFromMarketplace":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function ItemDefVars(param1:Locale)
      {
         super(param1);
      }
      
      public static function save(param1:ItemDef) : Object
      {
         var _loc3_:StatModDef = null;
         var _loc4_:Object = null;
         var _loc2_:Object = {
            "id":(!!param1.id ? param1.id : ""),
            "icon":(!!param1.icon ? param1.icon : ""),
            "rank":param1.rank
         };
         if(param1.passive)
         {
            _loc2_.passive = param1.passive + "/" + param1.passiveRank;
         }
         if(Boolean(param1.statmods) && param1.statmods.length > 0)
         {
            _loc2_.statmods = [];
            for each(_loc3_ in param1.statmods)
            {
               _loc4_ = StatModDefVars.save(_loc3_);
               _loc2_.statmods.push(_loc4_);
            }
         }
         if(param1.omitFromMarketplace)
         {
            _loc2_.omitFromMarketplace = param1.omitFromMarketplace;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:BattleAbilityDefFactory, param3:ILogger, param4:Boolean = true) : ItemDef
      {
         EngineJsonDef.validateThrow(param1,schema,param3);
         if(param4)
         {
            if(param1.id == undefined)
            {
               throw new IllegalOperationError("id required for itemdef");
            }
            if(param1.icon == undefined)
            {
               throw new IllegalOperationError("icon required for itemdef");
            }
            if(param1.rank == undefined)
            {
               throw new IllegalOperationError("rank required for itemdef");
            }
         }
         _id = param1.id;
         _icon = param1.icon;
         _rank = param1.rank;
         if(EngineJsonDef._validate != null)
         {
            if(Boolean(_id) && _id != _id.toLowerCase())
            {
               throw new IllegalOperationError("invalid id [" + _id + "]");
            }
            if(Boolean(_icon) && _icon != _icon.toLowerCase())
            {
               throw new IllegalOperationError("invalid icon path [" + _icon + "]");
            }
         }
         this.parsePassive(param1.passive);
         this.parseStatmods(param1.statmods,param3);
         omitFromMarketplace = BooleanVars.parse(param1.omitFromMarketplace,omitFromMarketplace);
         return this;
      }
      
      private function parseStatmods(param1:Array, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:StatModDef = null;
         if(!param1)
         {
            return;
         }
         statmods = new Vector.<StatModDef>();
         for each(_loc3_ in param1)
         {
            _loc4_ = new StatModDefVars().fromJson(_loc3_,param2);
            statmods.push(_loc4_);
         }
      }
      
      private function parsePassive(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:int = param1.lastIndexOf("/");
         if(_loc2_ > 0)
         {
            _passive = param1.substr(0,_loc2_);
            _passiveRank = int(param1.substr(_loc2_ + 1));
         }
         else
         {
            _passive = param1;
         }
      }
   }
}
