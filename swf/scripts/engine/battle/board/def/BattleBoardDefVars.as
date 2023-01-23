package engine.battle.board.def
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.wave.def.BattleWavesDef;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.EntityListDefVars;
   import engine.scene.def.SceneDef;
   import engine.tile.TileLocationAreaVars;
   import engine.tile.def.TileLocation;
   
   public class BattleBoardDefVars extends BattleBoardDef
   {
      
      public static var WAVE_TEST:Boolean = false;
      
      public static const schema:Object = {
         "name":"BattleBoardDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "pos":{"type":PointVars.schema},
            "layer":{"type":"string"},
            "deploymentAreas":{
               "type":"array",
               "items":BattleDeploymentAreaVars.schema
            },
            "walkableTiles":{"type":TileLocationAreaVars.schema},
            "unwalkableTiles":{"type":TileLocationAreaVars.schema},
            "triggers":{
               "type":"array",
               "items":BattleBoardTriggerSpawnerDef.schema,
               "optional":true
            },
            "triggerSpawners":{
               "type":BattleBoardTriggerSpawnerDefs.schema,
               "optional":true
            },
            "triggerdefs":{
               "type":BattleBoardTriggerDefList.schema,
               "optional":true
            },
            "spawners":{
               "type":"array",
               "items":BattleSpawnerDefVars.schema,
               "optional":true
            },
            "chars":{
               "type":EntityListDefVars.schema,
               "optional":true
            },
            "passivesPlayer":{
               "type":"array",
               "optional":true
            },
            "passivesEnemy":{
               "type":"array",
               "optional":true
            },
            "waves":{
               "type":BattleWavesDef.schema,
               "optional":true
            },
            "attractors":{
               "type":BattleAttractorsDef.schema,
               "optional":true
            },
            "vfxlibUrl":{
               "type":"string",
               "optional":true
            },
            "soundlibUrl":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function BattleBoardDefVars(param1:SceneDef, param2:Object, param3:ILogger, param4:Locale, param5:EntityClassDefList, param6:BattleAbilityDefFactory, param7:BattleBoardTriggerDefList, param8:Boolean)
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:BattleDeploymentArea = null;
         var _loc12_:TileLocation = null;
         var _loc13_:BattleSpawnerDef = null;
         super(param1);
         EngineJsonDef.validateThrow(param2,schema,param3);
         id = param2.id;
         this.triggerDefs_global = param7;
         unwalkableTiles = TileLocationAreaVars.parse(param2.unwalkableTiles,param3);
         walkableTiles = TileLocationAreaVars.parse(param2.walkableTiles,param3);
         layer = param2.layer;
         this.passivesEnemy = param2.passivesEnemy;
         this.passivesPlayer = param2.passivesPlayer;
         this.passivesEnemy_defs = _resolvePassives(this.passivesEnemy,param6);
         this.passivesPlayer_defs = _resolvePassives(this.passivesPlayer,param6);
         _pos = PointVars.parse(param2.pos,param3,_pos);
         for each(_loc9_ in param2.deploymentAreas)
         {
            _loc11_ = new BattleDeploymentAreaVars().fromJson(_loc9_,param3);
            addDeploymentArea(_loc11_);
            for each(_loc12_ in _loc11_.area.locations)
            {
               if(!unwalkableTiles.hasTile(_loc12_) && !walkableTiles.hasTile(_loc12_))
               {
                  param3.error("Board " + id + " Deployment Area [" + _loc11_.id + "] has invalid tile " + _loc12_);
                  if(param8)
                  {
                     param3.error("FORCING WALKABLE " + _loc12_);
                     walkableTiles.addTile(_loc12_);
                  }
               }
            }
         }
         for each(_loc10_ in param2.spawners)
         {
            _loc13_ = new BattleSpawnerDefVars().fromJson(_loc10_,param3);
            addSpawner(_loc13_);
            _loc12_ = _loc13_.location;
            if(!unwalkableTiles.hasTile(_loc12_) && !walkableTiles.hasTile(_loc12_))
            {
               param3.error("Board " + id + " Spawner [" + _loc13_.labelString + "] has invalid tile " + _loc12_ + " FORCING WALKABLE");
               if(param8)
               {
                  param3.error("FORCING WALKABLE " + _loc12_);
                  walkableTiles.addTile(_loc12_);
               }
            }
         }
         if(param2.triggerSpawners)
         {
            triggerSpawners = new BattleBoardTriggerSpawnerDefs().fromJson(param2.triggerSpawners,param3);
         }
         else if(param2.triggers)
         {
            param3.info("TRIGGER LEGACY CONVERT " + this);
            triggerSpawners = new BattleBoardTriggerSpawnerDefs().fromJsonArray(param2.triggers,param3);
         }
         if(param2.waves)
         {
            waves = new BattleWavesDef().fromJson(param2.waves,param3);
         }
         else
         {
            waves = new BattleWavesDef();
         }
         if(param2.attractors)
         {
            attractors = new BattleAttractorsDef().fromJson(param2.attractors,param3);
         }
         if(param2.triggerdefs)
         {
            triggerDefs = new BattleBoardTriggerDefList().fromJson(param2.triggerdefs,param3);
         }
         this.vfxlibUrl = param2.vfxlibUrl;
         this.soundlibUrl = param2.soundlibUrl;
      }
      
      private static function _resolvePassives(param1:Array, param2:BattleAbilityDefFactory) : Vector.<IBattleAbilityDef>
      {
         var _loc3_:Vector.<IBattleAbilityDef> = null;
         var _loc4_:String = null;
         var _loc5_:BattleAbilityDef = null;
         if(param2 && param1 && Boolean(param1.length))
         {
            _loc3_ = new Vector.<IBattleAbilityDef>();
            for each(_loc4_ in param1)
            {
               _loc5_ = param2.fetch(_loc4_) as BattleAbilityDef;
               _loc3_.push(_loc5_);
            }
         }
         return _loc3_;
      }
      
      public static function save(param1:BattleBoardDef) : Object
      {
         var _loc3_:BattleDeploymentArea = null;
         var _loc4_:BattleSpawnerDef = null;
         var _loc5_:Object = null;
         var _loc2_:Object = {};
         _loc2_.id = param1.id;
         _loc2_.walkableTiles = TileLocationAreaVars.save(param1.walkableTiles);
         _loc2_.unwalkableTiles = TileLocationAreaVars.save(param1.unwalkableTiles);
         _loc2_.pos = PointVars.save(param1.pos);
         _loc2_.layer = param1.layer;
         if(Boolean(param1.passivesEnemy) && Boolean(param1.passivesEnemy.length))
         {
            _loc2_.passivesEnemy = param1.passivesEnemy;
         }
         if(Boolean(param1.passivesPlayer) && Boolean(param1.passivesPlayer.length))
         {
            _loc2_.passivesPlayer = param1.passivesPlayer;
         }
         _loc2_.deploymentAreas = [];
         for each(_loc3_ in param1.deploymentAreas)
         {
            _loc5_ = BattleDeploymentAreaVars.save(_loc3_);
            _loc2_.deploymentAreas.push(_loc5_);
         }
         _loc2_.spawners = [];
         for each(_loc4_ in param1.spawners)
         {
            _loc2_.spawners.push(BattleSpawnerDefVars.save(_loc4_));
         }
         if(param1.triggerSpawners)
         {
            _loc2_.triggerSpawners = param1.triggerSpawners.toJson();
         }
         if(Boolean(param1.waves) && param1.waves.numWaves > 1)
         {
            _loc2_.waves = param1.waves.toJson();
         }
         if(Boolean(param1.triggerDefs) && Boolean(param1.triggerDefs.numTriggerDefs))
         {
            _loc2_.triggerdefs = param1.triggerDefs.toJson();
         }
         if(Boolean(param1.attractors) && Boolean(param1.attractors.numAttractors))
         {
            _loc2_.attractors = param1.attractors.toJson();
         }
         if(param1.vfxlibUrl)
         {
            _loc2_.vfxlibUrl = param1.vfxlibUrl;
         }
         if(param1.soundlibUrl)
         {
            _loc2_.soundlibUrl = param1.soundlibUrl;
         }
         return _loc2_;
      }
   }
}
