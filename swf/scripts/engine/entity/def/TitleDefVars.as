package engine.entity.def
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class TitleDefVars extends TitleDef
   {
      
      public static const schema:Object = {
         "name":"TitleDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "icon":{
               "type":"string",
               "optional":true
            },
            "rank":{
               "type":"number",
               "optional":true
            },
            "iconBuff":{
               "type":"string",
               "optional":true
            },
            "unlockVarName":{
               "type":"string",
               "optional":true
            },
            "ranks":{
               "type":"array",
               "items":ItemDefVars.schema
            }
         }
      };
       
      
      public var DEFAULT_RANK:int = 11;
      
      public function TitleDefVars(param1:Locale)
      {
         super(param1);
      }
      
      public static function save(param1:TitleDef) : Object
      {
         var _loc2_:Object = {
            "id":(!!param1.id ? param1.id : ""),
            "icon":(!!param1.icon ? param1.icon : ""),
            "iconBuff":(!!param1.iconBuffUrl ? param1.iconBuffUrl : ""),
            "unlockVarName":(!!param1.unlockVarName ? param1.unlockVarName : "")
         };
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1.ranks.length)
         {
            _loc3_.push(ItemDefVars.save(param1.ranks[_loc4_]));
            _loc4_++;
         }
         _loc2_.ranks = _loc3_;
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:BattleAbilityDefFactory, param3:ILogger) : TitleDef
      {
         EngineJsonDef.validateThrow(param1,schema,param3);
         _id = param1.id;
         _icon = param1.icon;
         _iconBuffUrl = param1.iconBuff;
         _unlockVarName = param1.unlockVarName;
         this.parseRanks(param1.ranks as Array,param2,param3);
         return this;
      }
      
      public function parseRanks(param1:Array, param2:BattleAbilityDefFactory, param3:ILogger) : void
      {
         var _loc5_:ItemDef = null;
         if(!param1)
         {
            throw new ArgumentError("TitleDefVars.parseRanks attempted to create a title without valid rank data.");
         }
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = new ItemDefVars(_locale).fromJson(param1[_loc4_],param2,param3,false);
            _loc5_.id = _id + "_" + (_loc4_ + 1);
            if(_loc5_.rank == 0)
            {
               _loc5_.rank = this.DEFAULT_RANK;
            }
            _loc5_.resolve(param2);
            _loc5_.omitFromMarketplace = true;
            addRank(_loc5_);
            _loc4_++;
         }
      }
   }
}
