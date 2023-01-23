package engine.battle.board.def
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.stat.model.StatsVars;
   import engine.tile.TileLocationVars;
   
   public class BattleSpawnerDefVars extends BattleSpawnerDef
   {
      
      public static const schema:Object = {
         "name":"BattleSpawnerDefVars",
         "properties":{
            "location":{"type":TileLocationVars.schema},
            "facing":{"type":"string"},
            "id":{
               "type":"string",
               "optional":true
            },
            "character":{
               "type":"string",
               "optional":true
            },
            "entityClass":{
               "type":"string",
               "optional":true
            },
            "tags":{
               "type":"string",
               "optional":true
            },
            "team":{"type":"string"},
            "prop":{
               "type":"boolean",
               "optional":true
            },
            "ally":{
               "type":"boolean",
               "optional":true
            },
            "stats":{
               "type":StatsVars.schema,
               "optional":true
            },
            "requireParty":{
               "type":"boolean",
               "optional":true
            },
            "requireRoster":{
               "type":"boolean",
               "optional":true
            },
            "deactivateUnit":{
               "type":"boolean",
               "optional":true
            },
            "disableUnit":{
               "type":"boolean",
               "optional":true
            },
            "deactivateSpawner":{
               "type":"boolean",
               "optional":true
            },
            "appearanceIndex":{
               "type":"number",
               "optional":true
            },
            "ifCondition":{
               "type":"string",
               "optional":true
            },
            "notCondition":{
               "type":"string",
               "optional":true
            },
            "usability":{
               "type":UsabilityDef.schema,
               "optional":true
            },
            "shitlistId":{
               "type":"string",
               "optional":true
            },
            "ambientMixAnim":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function BattleSpawnerDefVars()
      {
         super();
      }
      
      public static function save(param1:BattleSpawnerDef) : Object
      {
         var _loc2_:Object = {};
         _loc2_.location = TileLocationVars.save(param1.location);
         _loc2_.facing = param1.facing.name;
         if(param1.character)
         {
            _loc2_.character = param1.character;
         }
         if(param1.shitlistId)
         {
            _loc2_.shitlistId = param1.shitlistId;
         }
         if(param1.usabilityDef)
         {
            _loc2_.usability = param1.usabilityDef.save();
         }
         _loc2_.team = param1.team;
         if(param1.appearanceIndex)
         {
            _loc2_.appearanceIndex = param1.appearanceIndex;
         }
         if(param1.prop)
         {
            _loc2_.prop = param1.prop;
         }
         if(param1.requireParty)
         {
            _loc2_.requireParty = true;
         }
         if(param1.requireRoster)
         {
            _loc2_.requireRoster = true;
         }
         if(param1.isAlly)
         {
            _loc2_.ally = true;
         }
         if(param1.entityClassId)
         {
            _loc2_.entityClass = param1.entityClassId;
         }
         if(Boolean(param1.stats) && Boolean(param1.stats.numStats))
         {
            _loc2_.stats = new Object();
            _loc2_.stats.stats = StatsVars.save(param1.stats);
         }
         if(param1.tags)
         {
            _loc2_.tags = param1.tags;
         }
         if(param1.deactivateUnit)
         {
            _loc2_.deactivateUnit = param1.deactivateUnit;
         }
         if(param1.disableUnit)
         {
            _loc2_.disableUnit = param1.disableUnit;
         }
         if(param1.deactivateSpawner)
         {
            _loc2_.deactivateSpawner = param1.deactivateSpawner;
         }
         if(param1.id)
         {
            _loc2_.id = param1.id;
         }
         if(param1.ifCondition)
         {
            _loc2_.ifCondition = param1.ifCondition;
         }
         if(param1.notCondition)
         {
            _loc2_.notCondition = param1.notCondition;
         }
         if(param1.ambientMixAnim)
         {
            _loc2_.ambientMixAnim = param1.ambientMixAnim;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleSpawnerDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.character = param1.character;
         this._location = TileLocationVars.parse(param1.location,param2);
         this.facing = Enum.parse(BattleFacing,param1.facing) as BattleFacing;
         this.team = param1.team;
         this.requireParty = param1.requireParty;
         this.requireRoster = param1.requireRoster;
         this.entityClassId = param1.entityClass;
         this.appearanceIndex = param1.appearanceIndex;
         this.deactivateUnit = param1.deactivateUnit;
         this.disableUnit = param1.disableUnit;
         this.deactivateSpawner = param1.deactivateSpawner;
         this.id = param1.id;
         this.ifCondition = param1.ifCondition;
         this.notCondition = param1.notCondition;
         this.ambientMixAnim = param1.ambientMixAnim;
         if(param1.prop != undefined)
         {
            this.prop = BooleanVars.parse(param1.prop);
         }
         this.isAlly = BooleanVars.parse(param1.ally);
         if(param1.stats != undefined)
         {
            this.stats = StatsVars.parse(null,param1.stats,param2);
         }
         this.tags = param1.tags;
         if(param1.usability)
         {
            usabilityDef = new UsabilityDef().fromJson(param1.usability,param2);
         }
         this.shitlistId = param1.shitlist;
         return this;
      }
   }
}
