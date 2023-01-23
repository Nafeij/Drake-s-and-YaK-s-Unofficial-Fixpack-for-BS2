package engine.battle.board.model
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.def.BattleSpawnerDef;
   import engine.battle.sim.BattleParty;
   import engine.battle.wave.BattleWave;
   import engine.battle.wave.BattleWave_Utils;
   import engine.battle.wave.def.BattleWaveBucketDef;
   import engine.battle.wave.def.GuaranteedSpawnDef;
   import engine.battle.wave.def.LootTableEntryDef;
   import engine.battle.wave.def.WaveSpawnEntryDef;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.EntityDef;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ItemDef;
   import engine.math.Rng;
   import engine.resource.ResourceCollector;
   import engine.saga.Saga;
   import engine.saga.SagaBucket;
   import engine.saga.SagaBucketEnt;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.scene.SceneContext;
   import engine.scene.model.Scene;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.tile.def.TileLocation;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class BattleBoard_Spawn
   {
       
      
      public var board:BattleBoard;
      
      public var spawn_tags_dict:Dictionary;
      
      public var logger:ILogger;
      
      public var _bucket:String;
      
      public var _bucket_quota:int;
      
      private var _spawn_tags:String;
      
      private var _potential_spawn_tags:String;
      
      public var potential_spawn_tags_dict:Dictionary;
      
      public var hasRespawnActions:Boolean;
      
      public var _bucket_deployment:String;
      
      public var error:Boolean;
      
      public var saga:Saga;
      
      public var bucketSpawner:BattleBoardBucketSpawner;
      
      public var sceneContext:SceneContext;
      
      public var shouldSpawnAi:Boolean = true;
      
      public var spawner2Entity:Dictionary;
      
      private var numProps:int = 0;
      
      public var spawnerIndexesSpawned:Dictionary;
      
      private var _spawnedEntityDefs:Dictionary;
      
      public var preloadEntityDefs:Vector.<IEntityDef>;
      
      public function BattleBoard_Spawn(param1:BattleBoard)
      {
         this.spawner2Entity = new Dictionary();
         this.spawnerIndexesSpawned = new Dictionary();
         this._spawnedEntityDefs = new Dictionary();
         this.preloadEntityDefs = new Vector.<IEntityDef>();
         super();
         this.board = param1;
         this.logger = param1.logger;
         this.saga = param1._scene._context.saga as Saga;
         this.sceneContext = param1._scene._context;
      }
      
      private function spawnerTagsOk(param1:BattleSpawnerDef, param2:String) : Boolean
      {
         if(param1.tags)
         {
            if(!this.spawn_tags_dict || !(param1.tags in this.spawn_tags_dict))
            {
               if(param1.tags != param2)
               {
                  return false;
               }
            }
         }
         if(Boolean(param2) && param1.tags != param2)
         {
            return false;
         }
         return true;
      }
      
      private function spawnEntity(param1:BattleSpawnerDef, param2:IEntityDef) : IBattleEntity
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Stat = null;
         var _loc7_:Stat = null;
         if(!param2)
         {
            return null;
         }
         this.spawnerIndexesSpawned[param1.index] = true;
         var _loc3_:IBattleEntity = null;
         if(param1.prop == true)
         {
            _loc4_ = param1.team + "+" + (this.numProps++).toString() + "+" + param2.id;
            _loc3_ = this.board.createEntity(param2,_loc4_,param1.facing,param1.location.x,param1.location.y,null);
            if(param1.usabilityDef)
            {
               _loc3_.usabilityDef = param1.usabilityDef;
            }
            if(param1.ambientMixAnim)
            {
               _loc3_.animController.ambientMix = param1.ambientMixAnim;
            }
            if(param1.facing)
            {
               _loc3_.animController.facing = param1.facing;
            }
         }
         else
         {
            _loc3_ = this.board.addPartyMember(param1.team,null,param1.team,param1.team,null,param2,BattlePartyType.AI,0,param1.isAlly,param1.facing,param1.location,!param1.disableUnit);
         }
         if(_loc3_)
         {
            if(param1.shitlistId)
            {
               _loc3_.setShitlistId(param1.shitlistId);
            }
            if(!this.board._tiles.getTileByLocation(param1.location))
            {
               this.logger.error("BattleBoard.spawnEntity: no such tile: " + param1.location + " for entity " + _loc3_);
               return null;
            }
            _loc3_.facing = param1.facing;
            _loc3_.active = !param1.deactivateUnit;
            if(param1.stats)
            {
               _loc5_ = 0;
               while(_loc5_ < param1.stats.numStats)
               {
                  _loc6_ = param1.stats.getStatByIndex(_loc5_);
                  _loc7_ = _loc3_.stats.getStat(_loc6_.type,false);
                  if(!_loc7_)
                  {
                     _loc3_.stats.addStat(_loc6_.type,_loc6_.base);
                  }
                  else
                  {
                     _loc7_.base = _loc6_.value;
                  }
                  _loc5_++;
               }
            }
            _loc3_.deploymentReady = true;
            return _loc3_;
         }
         return null;
      }
      
      private function _mightRespawnSpawnerTags(param1:String) : Boolean
      {
         var _loc3_:String = null;
         if(!param1 || !this.potential_spawn_tags_dict)
         {
            return false;
         }
         var _loc2_:Array = param1.split(",");
         for each(_loc3_ in _loc2_)
         {
            if(this.potential_spawn_tags_dict[_loc3_])
            {
               return true;
            }
         }
         return false;
      }
      
      public function spawnPlayers(param1:String, param2:String) : void
      {
         var _loc4_:BattleSpawnerDef = null;
         var _loc5_:EntityDef = null;
         var _loc3_:BattleParty = this.board.getPartyById(param1) as BattleParty;
         for each(_loc4_ in this.board._def.spawners)
         {
            if(!(_loc4_.prop || _loc4_.team != param2))
            {
               if(this.spawnerIndexesSpawned[_loc4_.index])
               {
                  this.logger.info("BattleBoard.spawnPlayers: previously spawned spawner, skipping: " + _loc4_);
               }
               else
               {
                  _loc5_ = !!this.saga ? this.saga.getCastMember(_loc4_.character) as EntityDef : null;
                  if(!_loc5_)
                  {
                     this.logger.error("BattleBoard.spawnPlayers: no such cast member: " + _loc4_.character);
                  }
                  else
                  {
                     if(this.saga)
                     {
                        if(!_loc4_.checkConditions(this.saga.expression,this.logger))
                        {
                           if(this.hasRespawnActions)
                           {
                              this.preloadEntityDefs.push(_loc5_);
                           }
                           continue;
                        }
                     }
                     if(!this.spawnerTagsOk(_loc4_,null))
                     {
                        if(this._mightRespawnSpawnerTags(_loc4_.tags))
                        {
                           this.preloadEntityDefs.push(_loc5_);
                        }
                     }
                     else if(_loc4_.deactivateSpawner)
                     {
                        this.preloadEntityDefs.push(_loc5_);
                     }
                     else if(!this.spawnPlayer(_loc4_,param1))
                     {
                        this.logger.info("Skipped player spawner " + _loc4_);
                     }
                  }
               }
            }
         }
      }
      
      public function spawnPlayer(param1:BattleSpawnerDef, param2:String) : IBattleEntity
      {
         var _loc6_:IBattleEntity = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Stat = null;
         var _loc3_:BattleParty = this.board.getPartyById(param2) as BattleParty;
         var _loc4_:IEntityListDef = Boolean(this.saga) && Boolean(this.saga.caravan) ? this.saga.caravan._legend.roster : null;
         var _loc5_:EntityDef = !!this.saga ? this.saga.getCastMember(param1.character) as EntityDef : null;
         if(!_loc5_)
         {
            this.logger.error("BattleBoard.spawnPlayers: no such cast member: " + param1.character);
            return null;
         }
         if(!this.board._tiles.getTileByLocation(param1.location))
         {
            this.logger.error("BattleBoard.spawnPlayers: no such tile: " + param1.location + " for entity " + _loc6_);
            return null;
         }
         _loc6_ = _loc3_.getMemberByDefId(_loc5_.id);
         if(!_loc6_)
         {
            if(param1.requireParty)
            {
               this.logger.info("Spawner [" + param1 + "] skipping [" + _loc5_.id + "] because she\'s not in the party");
               return null;
            }
            if(param1.requireRoster)
            {
               if(!_loc4_ || !_loc4_.getEntityDefById(_loc5_.id))
               {
                  this.logger.info("Spawner [" + param1 + "] skipping [" + _loc5_.id + "] because she\'s not in the roster");
                  return null;
               }
            }
            _loc7_ = this.board.makeEntityId(_loc3_,_loc5_);
            _loc6_ = this.board.createEntity(_loc5_,_loc7_,param1.facing,0,0,_loc3_);
            _loc3_.addMember(_loc6_);
         }
         _loc6_.setPos(param1.location.x,param1.location.y);
         _loc6_.deploymentReady = true;
         _loc6_.facing = param1.facing;
         _loc6_.deploymentFinalized = true;
         _loc6_.enabled = !param1.disableUnit;
         _loc6_.active = !param1.deactivateUnit;
         if(param1.stats)
         {
            _loc8_ = 0;
            while(_loc8_ < param1.stats.numStats)
            {
               _loc9_ = param1.stats.getStatByIndex(_loc8_);
               _loc6_.suppressFlytext = true;
               _loc6_.stats.setBase(_loc9_.type,_loc9_.base);
               _loc6_.suppressFlytext = false;
               _loc8_++;
            }
         }
         return _loc6_;
      }
      
      public function spawnSpawnerById(param1:String, param2:Boolean, param3:Boolean, param4:String) : IBattleEntity
      {
         var _loc5_:BattleSpawnerDef = this.board._def.getSpawnerById(param1);
         if(!_loc5_)
         {
            return null;
         }
         if(_loc5_.team && !_loc5_.prop && _loc5_.team.indexOf("player") == 0)
         {
            return this.spawnPlayer(_loc5_,"0");
         }
         return this.spawnSpawner(_loc5_,false,param2,param3,param4);
      }
      
      public function spawnSpawner(param1:BattleSpawnerDef, param2:Boolean, param3:Boolean, param4:Boolean, param5:String) : IBattleEntity
      {
         var _loc9_:EntityClassDefList = null;
         var _loc10_:IEntityClassDef = null;
         if(!param1)
         {
            return null;
         }
         var _loc6_:Scene = this.board._scene;
         var _loc7_:EntityDef = null;
         if(Boolean(param1.character) && Boolean(_loc6_._context.spawnables))
         {
            _loc7_ = _loc6_._context.spawnables.getEntityDefById(param1.character) as EntityDef;
            if(!_loc7_)
            {
               this.logger.error("BattleBoard.spawn: no such entity def: " + param1.character);
               return null;
            }
         }
         else if(Boolean(param1.entityClassId) && Boolean(_loc6_._context.classes))
         {
            _loc9_ = _loc6_._context.classes;
            _loc10_ = _loc9_.fetch(param1.entityClassId);
            if(!_loc10_)
            {
               this.logger.error("BattleBoard.spawn: no such class: " + param1.entityClassId);
               return null;
            }
            _loc7_ = this.getEntityDefForClass(_loc10_);
         }
         if(this.saga)
         {
            if(!param3 && !param1.checkConditions(this.saga.expression,this.logger))
            {
               if(this.hasRespawnActions)
               {
                  if(_loc7_)
                  {
                     this.preloadEntityDefs.push(_loc7_);
                  }
               }
               return null;
            }
         }
         if(param4 && !this.spawnerTagsOk(param1,param5))
         {
            if(_loc7_)
            {
               if(this._mightRespawnSpawnerTags(param1.tags))
               {
                  this.preloadEntityDefs.push(_loc7_);
               }
            }
            this.logger.info("BattleBoard.spawn: skipping tagged spawner " + param1);
            return null;
         }
         if(param2)
         {
            if(_loc7_)
            {
               this.preloadEntityDefs.push(_loc7_);
            }
            return null;
         }
         return this.spawnEntity(param1,_loc7_);
      }
      
      private function getEntityDefForClass(param1:IEntityClassDef) : EntityDef
      {
         var _loc2_:EntityDef = this._spawnedEntityDefs[param1.id];
         var _loc3_:Scene = this.board._scene;
         var _loc4_:EntityClassDefList = _loc3_._context.classes;
         if(!_loc2_)
         {
            _loc2_ = new EntityDef(_loc3_._context.locale);
            _loc2_.entityClass = param1;
            _loc2_.spawner = true;
            _loc2_.id = param1.id;
            _loc2_.applyClassStats(_loc4_.meta,1,_loc3_._context.unitStatCosts);
            _loc2_.setupClassAbilities(_loc3_._context.abilities,this.logger,_loc3_._context.unitStatCosts);
            this._spawnedEntityDefs[param1.id] = _loc2_;
         }
         return _loc2_;
      }
      
      public function spawnWave(param1:BattleWave) : void
      {
         this.destroyBucketSpawner();
         var _loc2_:BattleWaveBucketDef = param1.def.bucket;
         var _loc3_:String = _loc2_.bucketId;
         var _loc4_:Boolean = param1.waves.lostAWave;
         if(_loc4_ && _loc2_.lossBucketOverride && _loc2_.lossBucketOverride.length > 0)
         {
            _loc3_ = _loc2_.lossBucketOverride;
         }
         if(_loc2_ == null)
         {
            throw new IllegalOperationError("Wave did not define a valid bucket, terminating wave!");
         }
         _loc2_.deploymentId = this.getValidDeployment(_loc2_.deploymentId);
         this._bucket_quota = this.modDanger(this._bucket_quota,param1);
         this.clampDanger();
         this.logger.i("SPWN","bucket=[" + _loc2_ + "], bucketId=[" + _loc3_ + "], deployment=[" + _loc2_.deploymentId + "], quota=[" + this._bucket_quota + "]");
         var _loc5_:int = this.spawnWaveGuaranteedEntities(param1);
         if(_loc4_ && _loc2_.suppressBucketOnLoss)
         {
            return;
         }
         this.spawnFromBucket(_loc5_,_loc2_.deploymentId,_loc3_,this._bucket_quota);
      }
      
      public function spawn(param1:String, param2:String) : void
      {
         var _loc5_:BattleSpawnerDef = null;
         var _loc6_:* = false;
         var _loc7_:BattleParty = null;
         var _loc8_:IBattleEntity = null;
         param1 = this.getValidDeployment(param1);
         this.clampDanger();
         this.logger.i("SPWN","bucket=[" + this._bucket + "], deployment=[" + param1 + "], bucket_spawner_tag=[" + param2 + "], quota=[" + this._bucket_quota + "]");
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in this.board._def.spawners)
         {
            if(!_loc5_.prop)
            {
               if(!this.shouldSpawnAi)
               {
                  continue;
               }
               if(_loc5_.team != "npc")
               {
                  continue;
               }
            }
            if(this.spawnerIndexesSpawned[_loc5_.index])
            {
               this.logger.i("SPWN","previously spawned spawner, skipping: " + _loc5_);
            }
            else
            {
               _loc4_ += _loc5_.deactivateSpawner ? 1 : 0;
               _loc8_ = this.spawnSpawner(_loc5_,_loc5_.deactivateSpawner,false,true,param2);
               if(_loc8_)
               {
                  this.logger.i("SPWN","spawned " + _loc8_ + " @" + _loc8_.rect);
                  if(Boolean(_loc8_) && Boolean(_loc8_.isEnemy))
                  {
                     _loc3_ += _loc8_.stats.rank;
                     this.logger.i("SPWN",".... ranks total " + _loc3_);
                  }
               }
            }
         }
         if(Boolean(this._bucket) && Boolean(this._bucket_quota))
         {
            this._bucket_deployment = param1;
            this.spawnFromBucket(_loc3_,this._bucket_deployment,this._bucket,this._bucket_quota);
         }
         for each(_loc7_ in this.board.parties)
         {
            if(_loc7_.type == BattlePartyType.AI)
            {
               if(_loc7_.numAlive)
               {
                  _loc6_ = _loc7_.numMembers > 0;
                  _loc7_.deployed = true;
               }
            }
         }
         if(!_loc6_ && this.shouldSpawnAi)
         {
            if(!_loc4_)
            {
               this.logger.error("No AI spawned -- should terminate battle now");
               this.error = true;
            }
         }
      }
      
      private function spawnWaveGuaranteedEntities(param1:BattleWave) : int
      {
         var _loc9_:GuaranteedSpawnDef = null;
         var _loc10_:WaveSpawnEntryDef = null;
         var _loc11_:IEntityDef = null;
         var _loc12_:TileLocation = null;
         var _loc13_:BattleFacing = null;
         var _loc14_:IBattleEntity = null;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:ItemDef = null;
         var _loc2_:Vector.<GuaranteedSpawnDef> = param1.def.bucket.guaranteedSpawns;
         var _loc3_:Boolean = param1.waves.lostAWave;
         if(!_loc2_ || !_loc2_.length)
         {
            return 0;
         }
         var _loc4_:String = param1.def.bucket.deploymentId;
         var _loc5_:Scene = this.board._scene;
         var _loc6_:int = 0;
         if(!this.saga)
         {
            this.logger.error("ERROR: BattleBoard_Spawn.spawnWaveGuaranteedEntities attempting to spawn wave guaranteed spawn without valid saga! -- abort");
            return 0;
         }
         var _loc7_:int = 0;
         var _loc8_:int = 1;
         for each(_loc9_ in _loc2_)
         {
            if(!(_loc3_ && !_loc9_.spawnInLoss))
            {
               _loc10_ = BattleWave_Utils.selectRandomEntry(_loc9_.entityList,this.saga.rng,this.saga.logger);
               if(!_loc10_)
               {
                  this.logger.error("ERROR: Invalid GuaranteedSpawnDef found! Skipping this Guaranteed Spawn");
               }
               else
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.d("SPWN","spawnWaveGuaranteedEntities Entity=" + _loc10_.entityId + ", bucket_deployment=" + _loc4_);
                  }
                  _loc11_ = _loc5_._context.saga.cast.getEntityDefById(_loc10_.entityId);
                  if(!_loc11_)
                  {
                     this.logger.error("ERROR: BattleBoard_Spawn.spawnWaveGuaranteedEntities called with invalid entityId: " + _loc10_.entityId);
                  }
                  else
                  {
                     _loc14_ = this.board.addPartyMember("npc",null,"npc","npc",_loc4_,_loc11_,BattlePartyType.AI,0,false,_loc13_,_loc12_,true);
                     (_loc14_.party as BattleParty).changeDeployment(_loc4_);
                     _loc15_ = int(_loc14_.stats.getValue(StatType.RANK));
                     _loc6_ += _loc15_;
                     _loc16_ = BattleWave_Utils.generateItemIdFromLootTable(_loc10_.lootTableOverride.length > 0 ? _loc10_.lootTableOverride : _loc9_.lootTable,this.saga.rng,this.logger);
                     if(_loc16_ == "")
                     {
                        _loc17_ = this.saga.generateRandomItemDefForPartyRanks();
                     }
                     else if(_loc16_)
                     {
                        _loc17_ = this.saga.itemDefs.getItemDef(_loc16_);
                     }
                     if(Boolean(_loc17_) && _loc7_ < _loc8_)
                     {
                        _loc7_++;
                        _loc14_.entityItem = this.saga.createItemByDefId(_loc17_.id);
                     }
                     this.logger.i("SPWN","spawnFromBucket " + this.board.toDebugString() + " spawn=" + _loc14_.id + ", r=" + _loc15_ + ", ranks=" + _loc6_);
                  }
               }
            }
         }
         this.board.autoDeployPartyById("npc");
         return _loc6_;
      }
      
      private function spawnFromBucket(param1:int, param2:String, param3:String, param4:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:IEntityDef = null;
         var _loc11_:Boolean = false;
         var _loc12_:TileLocation = null;
         var _loc13_:BattleFacing = null;
         var _loc14_:IBattleEntity = null;
         var _loc15_:int = 0;
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("SPWN","spawnFromBucket ranks=" + param1 + ", quota=" + param4 + ", bucket_deployment=" + param2 + ", bucket=" + this._bucket);
         }
         if(!param3)
         {
            this.logger.info("BattleBoard.spawnFromBucket NO BUCKET! -- abort");
            return;
         }
         var _loc5_:Scene = this.board._scene;
         if(!this.saga)
         {
            this.logger.info("BattleBoard.spawnFromBucket NO SAGA! -- abort");
            return;
         }
         var _loc6_:SagaBucket = this.saga.getSagaBucket(param3);
         if(!_loc6_)
         {
            this.logger.error("BattleBoard.spawnFromBucket INVALID BUCKET: [" + param3 + "]");
            return;
         }
         this.createBucketSpawner(_loc6_);
         this.performResourceCollectionBucket(_loc6_);
         if(_loc6_._ents.length == 0)
         {
            this.logger.error("BattleBoard.spawnFromBucket: BUCKET IS EMPTY: [" + param3 + "]");
            return;
         }
         if(param1 >= param4)
         {
            this.logger.i("SPWN","spawnFromBucket " + this.board.toDebugString() + " ranks " + param1 + " already reached quota " + param4);
            return;
         }
         if(param1 == 0)
         {
            _loc7_ = this.bucketSpawner.findMinRankInBucket();
            if(_loc7_ > param4)
            {
               param4 = _loc7_;
            }
         }
         while(param1 < param4 || this.bucketSpawner.hasOutstandingCountRequirements)
         {
            _loc8_ = param4 - param1;
            _loc9_ = this.bucketSpawner.pickFromBucket(_loc8_);
            _loc10_ = _loc5_._context.saga.cast.getEntityDefById(_loc9_);
            if(!_loc10_)
            {
               this.logger.info("BattleBoard.spawnFromBucket " + this.board.toDebugString() + " failed to pick from bucket [" + param3 + "] ranks [" + _loc8_ + "]");
               break;
            }
            _loc14_ = this.board.addPartyMember("npc",null,"npc","npc",param2,_loc10_,BattlePartyType.AI,0,_loc11_,_loc13_,_loc12_,true);
            (_loc14_.party as BattleParty).changeDeployment(param2);
            _loc15_ = int(_loc14_.stats.getValue(StatType.RANK));
            param1 += _loc15_;
            if(_loc6_.shitlistId)
            {
               _loc14_.setShitlistId(_loc6_.shitlistId);
            }
            this.logger.i("SPWN","spawnFromBucket " + this.board.toDebugString() + " spawn=" + _loc14_.id + ", r=" + _loc15_ + ", ranks=" + param1);
         }
         this.board.autoDeployPartyById("npc");
      }
      
      private function getValidDeployment(param1:String) : String
      {
         if(!param1)
         {
            param1 = this._bucket_deployment;
            if(!param1)
            {
               param1 = "bucket_spawn";
               this.logger.i("SPWN","no deployment area supplied, defaulting to [" + param1 + "]");
            }
         }
         return param1;
      }
      
      private function clampDanger() : void
      {
         if(this._bucket_quota > BattleBoard_SpawnConstants.MAX_DANGER)
         {
            this.logger.i("SPWN","clamping bucket_quota " + this._bucket_quota + " to " + BattleBoard_SpawnConstants.MAX_DANGER);
            this._bucket_quota = BattleBoard_SpawnConstants.MAX_DANGER;
         }
      }
      
      private function modDanger(param1:int, param2:BattleWave) : int
      {
         var _loc3_:BattleWaveBucketDef = param2.def.bucket;
         param1 += !!(_loc3_.dangerMod + param2.waves.lostAWave) ? param2.lossDangerAdjustment : 0;
         if(_loc3_.dangerMin > _loc3_.dangerMax)
         {
            this.logger.i("WAVE","Wave bucket " + _loc3_.bucketId + " called with invalid dangerMin " + _loc3_.dangerMin + " & dangerMax " + _loc3_.dangerMax);
            return param1;
         }
         if(param1 < _loc3_.dangerMin)
         {
            param1 = _loc3_.dangerMin;
         }
         if(param1 > _loc3_.dangerMax)
         {
            param1 = _loc3_.dangerMax;
         }
         return param1;
      }
      
      public function set spawn_tags(param1:String) : void
      {
         this._spawn_tags = param1;
         this.spawn_tags_dict = this._makeCommaSepDict(this._spawn_tags,null);
      }
      
      public function checkForRespawnActions() : void
      {
         var _loc3_:ActionDef = null;
         var _loc1_:Scene = this.board._scene;
         if(!_loc1_._def.happenings)
         {
            return;
         }
         var _loc2_:Vector.<ActionDef> = _loc1_._def.findActionsByType(ActionType.BATTLE_RESPAWN,null);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               this.hasRespawnActions = true;
               this.addPotentialSpawnTags(_loc3_.spawn_tags);
            }
         }
      }
      
      public function addPotentialSpawnTags(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(this._potential_spawn_tags)
         {
            this._potential_spawn_tags += "," + param1;
         }
         else
         {
            this._potential_spawn_tags = param1;
         }
         this.potential_spawn_tags_dict = this._makeCommaSepDict(this._potential_spawn_tags,this.potential_spawn_tags_dict);
      }
      
      public function get spawn_tags() : String
      {
         return this._spawn_tags;
      }
      
      private function _makeCommaSepDict(param1:String, param2:Dictionary) : Dictionary
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         if(param1)
         {
            if(!param2)
            {
               param2 = new Dictionary();
            }
            _loc3_ = param1.split(",");
            for each(_loc4_ in _loc3_)
            {
               param2[_loc4_] = true;
            }
         }
         return param2;
      }
      
      public function changeLocale(param1:Locale) : void
      {
         var _loc2_:EntityDef = null;
         for each(_loc2_ in this._spawnedEntityDefs)
         {
            _loc2_.changeLocale(param1);
         }
      }
      
      private function _performSpawnerResourceCollection(param1:BattleSpawnerDef) : void
      {
         var _loc3_:IEntityDef = null;
         var _loc4_:IEntityClassDef = null;
         var _loc2_:IEntityAssetBundleManager = this.board.entityAssetBundleManager;
         if(param1.character)
         {
            _loc3_ = !!this.saga ? this.saga.getCastMember(param1.character) : null;
            if(_loc3_)
            {
               _loc2_.getEntityPreloadById(param1.character,null,false,false,true);
            }
            return;
         }
         if(param1.entityClassId)
         {
            _loc4_ = this.saga.def.classes.fetch(param1.entityClassId);
            if(_loc4_)
            {
               _loc2_.getEntityPreload(this.getEntityDefForClass(_loc4_),null,false,false,true);
            }
            return;
         }
      }
      
      public function performResourceCollection() : void
      {
         var _loc1_:BattleSpawnerDef = null;
         if(!ResourceCollector.ENABLED)
         {
            return;
         }
         if(!this.saga)
         {
            return;
         }
         for each(_loc1_ in this.board._def.spawners)
         {
            this._performSpawnerResourceCollection(_loc1_);
         }
      }
      
      public function performResourceCollectionBucket(param1:SagaBucket) : void
      {
         var _loc2_:SagaBucketEnt = null;
         var _loc4_:String = null;
         if(!ResourceCollector.ENABLED)
         {
            return;
         }
         if(!param1 || !this.board)
         {
            return;
         }
         this.logger.i("RESC","Collecting bucket [" + param1.name + "]");
         var _loc3_:IEntityAssetBundleManager = this.board.entityAssetBundleManager;
         for each(_loc2_ in param1._ents)
         {
            _loc4_ = _loc2_.entityId;
            this.logger.i("RESC","Collecting bucket ent [" + _loc4_ + "]");
            _loc3_.getEntityPreloadById(_loc4_,null,false,false,true);
         }
      }
      
      private function destroyBucketSpawner() : void
      {
         if(this.bucketSpawner)
         {
            this.bucketSpawner.cleanup();
            this.bucketSpawner = null;
         }
      }
      
      private function createBucketSpawner(param1:SagaBucket) : void
      {
         this.destroyBucketSpawner();
         var _loc2_:IEntityListDef = this.sceneContext.saga.cast;
         var _loc3_:Rng = this.sceneContext.rng;
         this.bucketSpawner = new BattleBoardBucketSpawner(param1,_loc2_,_loc3_,this.board,this.logger);
      }
   }
}
