package engine.battle.board.model
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.BattleAssetsDef;
   import engine.battle.BattleCameraEvent;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleAttractors;
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.board.def.BattleBoardTriggerDef;
   import engine.battle.board.def.BattleBoardTriggerSpawnerDef;
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.def.IsoVfxLibraryResource;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.model.BattleEntityFactory;
   import engine.battle.entity.model.BattleEntityMobility;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.sim.BattleParty;
   import engine.battle.sim.BattleSim;
   import engine.battle.sim.IBattleParty;
   import engine.battle.wave.BattleWave;
   import engine.battle.wave.BattleWaves;
   import engine.core.fsm.FsmEvent;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.entity.def.IAbilityAssetBundleManager;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.expression.ISymbols;
   import engine.math.Hash;
   import engine.resource.IResourceManager;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.resource.loader.SoundControllerManager;
   import engine.saga.IBattleTutorial;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaBucket;
   import engine.saga.SagaVar;
   import engine.scene.model.IScene;
   import engine.scene.model.Scene;
   import engine.sound.ISoundDriver;
   import engine.sound.view.ISoundController;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import engine.vfx.VfxLibrary;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class BattleBoard extends EventDispatcher implements IBattleBoard
   {
       
      
      private var _lastEntityNumericId:uint;
      
      public var _def:BattleBoardDef;
      
      internal var _entities:Dictionary;
      
      internal var _tiles:BattleBoardTiles;
      
      private var _sim:BattleSim;
      
      private var _logger:ILogger;
      
      public var abilityFactory:BattleAbilityDefFactory;
      
      public var _resman:ResourceManager;
      
      public var assets:BattleAssetsDef;
      
      public var phantasms:BattleBoardPhantasms;
      
      public var _triggers:BattleBoardTriggers;
      
      public var _abilityManager:BattleAbilityManager;
      
      private var _enabled:Boolean;
      
      private var soundDriver:ISoundDriver;
      
      public var _selectedTile:Tile;
      
      private var partiesById:Dictionary;
      
      public var parties:Vector.<IBattleParty>;
      
      public var _scene:Scene;
      
      public var suppressPartyVitality:Boolean;
      
      public var difficultyDisabled:Boolean;
      
      public var moraleDisabled:Boolean;
      
      public var rVfxLibrary:IsoVfxLibraryResource;
      
      public var vfxLibrary:VfxLibrary;
      
      public var soundControllerManager:SoundControllerManager;
      
      private var _fake:Boolean;
      
      private var _boardSetup:Boolean;
      
      private var _boardDeploymentStarted:Boolean;
      
      private var _deathOffset:Number = 0;
      
      public var movers:Dictionary;
      
      public var error:Boolean;
      
      private var _hoverEntity:IBattleEntity;
      
      private var vitalities:Dictionary;
      
      public var tutorial:IBattleTutorial;
      
      public var matchResolutionEnabled:Boolean = true;
      
      public var _scenario:BattleScenario;
      
      public var _tileConfiguration:int;
      
      public var resourceGroup:ResourceGroup;
      
      public var _spatial:BattleBoard_Spatial;
      
      public var _deploy:BattleBoard_Deploy;
      
      public var _spawn:BattleBoard_Spawn;
      
      public var _redeploy:BattleBoard_Redeploy;
      
      public var _waves:BattleWaves;
      
      public var saga:Saga;
      
      public var _attractors:BattleAttractors;
      
      public var _entityAssetBundleManager:IEntityAssetBundleManager;
      
      private var _artifactMaxUseCount:int;
      
      private var _isPostLoaded:Boolean;
      
      public var _hoverTile:Tile;
      
      public var _cleanedup:Boolean;
      
      private var _fsm:BattleFsm;
      
      private var _forceCameraCenterEntity:IBattleEntity;
      
      private var _lastNullTriggerDefId:int;
      
      private var _player_prefix:String = "*player";
      
      private var _npc_prefix:String = "*npc";
      
      private var updating:Boolean;
      
      private var _boardFinishedSetup:Boolean;
      
      private var _showInfoEntity:IBattleEntity;
      
      private var _showInfoBanners:Boolean;
      
      public var snapSrc:BattleSnapshot;
      
      private var _isUsingEntity:Boolean;
      
      public function BattleBoard(param1:BattleBoardDef, param2:BattleScenarioDef, param3:Scene, param4:ILogger, param5:ResourceManager, param6:BattleAbilityDefFactory, param7:BattleAssetsDef, param8:ISoundDriver, param9:String, param10:ISymbols)
      {
         this._entities = new Dictionary();
         this.partiesById = new Dictionary();
         this.parties = new Vector.<IBattleParty>();
         this.movers = new Dictionary();
         super();
         this.def = param1;
         this.saga = param3._context.saga as Saga;
         this._scene = param3;
         this._logger = param4;
         this.abilityFactory = param6;
         this._resman = param5;
         this.assets = param7;
         this._abilityManager = new BattleAbilityManager(param4,param6,param10);
         this.soundDriver = param8;
         this._tiles = new BattleBoardTiles(this);
         this.phantasms = new BattleBoardPhantasms(this);
         this._triggers = new BattleBoardTriggers(this);
         this._spatial = new BattleBoard_Spatial(this);
         this._deploy = new BattleBoard_Deploy(this);
         this._redeploy = new BattleBoard_Redeploy(this);
         this._spawn = new BattleBoard_Spawn(this);
         this._entityAssetBundleManager = this._scene.context.entityAssetBundleManager;
         if(param1.attractors)
         {
            this._attractors = new BattleAttractors(param1.attractors);
         }
         if(this._scene._context)
         {
            this.resourceGroup = this._scene.resourceGroup;
         }
         this._deathOffset = -6;
         this._spawn.spawn_tags = param9;
         this._abilityManager.addEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.incompletesEmptyHandler,false,255);
         this._abilityManager.addEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.abilityCompleteHandler);
         if(param2)
         {
            this._scenario = new BattleScenario(param2,this,this._scene._context.saga);
         }
         this._spawn.checkForRespawnActions();
         if(Boolean(param1.waves) && param1.waves.numWaves > 1)
         {
            this._waves = new BattleWaves(this,param1.waves);
         }
      }
      
      private static function _applyBoardPassives(param1:BattleEntity, param2:Vector.<IBattleAbilityDef>, param3:BattleAbilityManager) : void
      {
         var _loc4_:IBattleAbilityDef = null;
         var _loc5_:BattleAbility = null;
         if(!param1 || !param2 || !param3)
         {
            return;
         }
         for each(_loc4_ in param2)
         {
            _loc5_ = new BattleAbility(param1,_loc4_ as BattleAbilityDef,param3);
            _loc5_.execute(null);
         }
      }
      
      public function get isPostLoaded() : Boolean
      {
         return this._isPostLoaded;
      }
      
      public function postLoad() : void
      {
         var _loc2_:String = null;
         var _loc3_:BattleEntity = null;
         if(this._isPostLoaded)
         {
            throw new IllegalOperationError("double postload");
         }
         this._isPostLoaded = true;
         var _loc1_:Array = ArrayUtil.getDictionaryKeys(this._entities);
         _loc1_.sort();
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = this.entities[_loc2_];
            _loc3_.postLoad();
         }
      }
      
      public function loadVfxLibrary() : void
      {
         if(this._def.vfxlibUrl)
         {
            this.rVfxLibrary = this._resman.getResource(this._def.vfxlibUrl,IsoVfxLibraryResource,this.resourceGroup) as IsoVfxLibraryResource;
            if(this.rVfxLibrary)
            {
               this.rVfxLibrary.addResourceListener(this.vfxLoadedHandler);
            }
         }
      }
      
      public function loadSoundLibrary() : void
      {
         var _loc1_:ISoundDriver = null;
         var _loc2_:String = null;
         if(this._def.soundlibUrl)
         {
            _loc1_ = this._scene.context.soundDriver;
            _loc2_ = this._def.soundlibUrl;
            this.soundControllerManager = new SoundControllerManager("battleboard",_loc2_,this._resman,_loc1_,this.soundLoadedHandler,this.logger);
         }
      }
      
      private function soundLoadedHandler() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("sound library loaded");
         }
      }
      
      private function vfxLoadedHandler(param1:ResourceLoadedEvent) : void
      {
         if(this.rVfxLibrary)
         {
            this.rVfxLibrary.removeResourceListener(this.vfxLoadedHandler);
         }
         this.vfxLibrary = this.rVfxLibrary.library;
      }
      
      public function get waves() : BattleWaves
      {
         return this._waves;
      }
      
      private function abilityCompleteHandler(param1:BattleAbilityEvent) : void
      {
         var _loc3_:Effect = null;
         var _loc2_:BattleAbility = param1.ability as BattleAbility;
         if(_loc2_.fake || this._abilityManager.faking)
         {
            return;
         }
         if(this._scene._context.saga)
         {
            if(_loc2_.caster.def.id == "alette")
            {
               for each(_loc3_ in _loc2_.effects)
               {
                  if(Boolean(_loc3_.target) && Boolean(_loc3_.target.isEnemy))
                  {
                     if(_loc3_.hasTag(EffectTag.DAMAGED_ARM) || _loc3_.hasTag(EffectTag.DAMAGED_STR))
                     {
                        (this._scene._context.saga as Saga).triggerBattleUnitAttacked(_loc2_.caster,_loc3_.target);
                     }
                  }
               }
            }
         }
      }
      
      private function incompletesEmptyHandler(param1:BattleAbilityEvent) : void
      {
         this.expireDeadEntitiesEffects();
      }
      
      public function get selectedTile() : Tile
      {
         return this._selectedTile;
      }
      
      public function set selectedTile(param1:Tile) : void
      {
         if(this._selectedTile == param1)
         {
            return;
         }
         this._selectedTile = param1;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.SELECT_TILE));
      }
      
      public function get hoverTile() : Tile
      {
         return this._hoverTile;
      }
      
      public function set hoverTile(param1:Tile) : void
      {
         if(this._hoverTile == param1)
         {
            return;
         }
         this._hoverTile = param1;
         this._triggers.selectTriggersOnTile(this._hoverTile);
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.HOVER_TILE));
      }
      
      public function set hoverEntity(param1:IBattleEntity) : void
      {
         if(this._hoverEntity == param1)
         {
            return;
         }
         if(this._hoverEntity)
         {
            this._hoverEntity.hovering = false;
         }
         this._hoverEntity = param1;
         if(this._hoverEntity)
         {
            this._hoverEntity.hovering = true;
         }
      }
      
      public function get hoverEntity() : IBattleEntity
      {
         return this._hoverEntity;
      }
      
      public function get deathOffset() : Number
      {
         return this._deathOffset;
      }
      
      public function set deathOffset(param1:Number) : void
      {
         this._deathOffset = param1;
      }
      
      public function get cleanedup() : Boolean
      {
         return this._cleanedup;
      }
      
      public function cleanup() : void
      {
         var _loc1_:BattleParty = null;
         var _loc2_:BattleEntity = null;
         if(this.cleanedup)
         {
            return;
         }
         this._cleanedup = true;
         if(this.rVfxLibrary)
         {
            this.rVfxLibrary.removeResourceListener(this.vfxLoadedHandler);
         }
         if(this._attractors)
         {
            this._attractors.cleanup();
            this._attractors = null;
         }
         if(this._waves)
         {
            this._waves.cleanup();
            this._waves = null;
         }
         if(this._scenario)
         {
            this._scenario.cleanup();
            this._scenario = null;
         }
         this._abilityManager.removeEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.incompletesEmptyHandler);
         this._abilityManager.removeEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.abilityCompleteHandler);
         for each(_loc1_ in this.parties)
         {
            _loc1_.cleanup();
         }
         for each(_loc2_ in this.entities)
         {
            this.removeEntityListeners(_loc2_);
            _loc2_.cleanup();
         }
         if(this._triggers)
         {
            this._triggers.cleanup();
            this._triggers = null;
         }
         this._abilityManager.cleanup();
         this._abilityManager = null;
         this._tiles.cleanup();
         this._tiles = null;
         this.sim = null;
         this.phantasms.cleanup();
         this.phantasms = null;
         this._entities = null;
         this.parties = null;
         this._spatial = null;
      }
      
      override public function toString() : String
      {
         return this.def.id;
      }
      
      public function getDebugEntityList() : String
      {
         var _loc2_:String = null;
         var _loc1_:* = "";
         for(_loc2_ in this._entities)
         {
            _loc1_ += "\n";
            _loc1_ += _loc2_;
         }
         return _loc1_;
      }
      
      public function toDebugString() : String
      {
         return "[" + this._scene._def.name + ":" + this.def.id + "]";
      }
      
      public function get fsm() : IBattleFsm
      {
         return this._fsm;
      }
      
      public function set fsm(param1:IBattleFsm) : void
      {
         if(this._fsm == param1)
         {
            return;
         }
         if(this._fsm)
         {
            this._fsm.removeEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
            this._fsm.removeEventListener(BattleFsmEvent.PILLAGE,this.battlePillageCurrentHandler);
            this._fsm.removeEventListener(BattleFsmEvent.WAVE_RESPAWN_COMPLETED,this.battleWaveIncreasedCurrentHandler);
            this._fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
         }
         this._fsm = param1 as BattleFsm;
         if(this._fsm)
         {
            this._fsm.addEventListener(FsmEvent.CURRENT,this.battleFsmCurrentHandler);
            this._fsm.addEventListener(BattleFsmEvent.PILLAGE,this.battlePillageCurrentHandler);
            this._fsm.addEventListener(BattleFsmEvent.WAVE_RESPAWN_COMPLETED,this.battleWaveIncreasedCurrentHandler);
            this._fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
         }
         this.turnHandler(null);
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
         var _loc2_:IBattleTurn = !!this._fsm ? this._fsm.turn : null;
         var _loc3_:IBattleEntity = !!_loc2_ ? _loc2_.entity : null;
         if(this._triggers)
         {
            this._triggers.updateTurnEntity(_loc3_);
         }
      }
      
      public function get sim() : BattleSim
      {
         return this._sim;
      }
      
      public function set sim(param1:BattleSim) : void
      {
         if(this._sim)
         {
            this._sim.cleanup();
         }
         this._sim = param1;
         this.fsm = !!this._sim ? this._sim.fsm : null;
         if(this._sim)
         {
            if(this._sim.fsm.battleId)
            {
               this._abilityManager.seedRng = Hash.DJBHash(this._sim.fsm.battleId);
            }
            else
            {
               this._abilityManager.seedRng = this._scene._context.rng.nextInt();
            }
         }
      }
      
      private function isPlayerTeamWinning() : Boolean
      {
         var _loc3_:IBattleParty = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in this.parties)
         {
            if(_loc3_.isPlayer)
            {
               _loc1_ += _loc3_.numAlive;
            }
            else
            {
               _loc2_ += _loc3_.numAlive;
            }
         }
         return _loc1_ > _loc2_;
      }
      
      private function battleWaveIncreasedCurrentHandler(param1:BattleFsmEvent) : void
      {
         if(!this._scene)
         {
            return;
         }
         this._scene.handleBattleWaveIncrease(this.isPlayerTeamWinning());
         this.recomputePartyVitality();
      }
      
      private function battlePillageCurrentHandler(param1:BattleFsmEvent) : void
      {
         if(!this._scene)
         {
            return;
         }
         this._scene.handleBattlePillage(this.isPlayerTeamWinning());
      }
      
      private function battleFsmCurrentHandler(param1:FsmEvent) : void
      {
         if(!this._scene)
         {
            return;
         }
         this._scene.handleBattleState();
      }
      
      private function addEntity(param1:BattleEntity) : void
      {
         if(this._fake)
         {
            return;
         }
         if(Boolean(this.vitalities) && !this.vitalities[param1.def.id])
         {
            param1._includeVitality = false;
         }
         this.entities[param1.id] = param1;
         param1.addEventListener(BattleEntityEvent.DAMAGED,this.entityDamagedHandler);
         param1.addEventListener(BattleEntityEvent.FORCE_CAMERA_CENTER,this.entityForceCameraCenterHandler);
         param1.addEventListener(BattleEntityEvent.KILLING_EFFECT,this.entityKillingEffectHandler);
         param1.addEventListener(BattleEntityEvent.ALIVE,this.entityAliveHandler);
         param1.addEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.ADDED,param1));
         if(this.tiles)
         {
            this.tiles.blockTilesForEntity(param1);
         }
         var _loc2_:IEntityClassDef = param1.def.entityClass;
         if(!_loc2_.bounds.square)
         {
            param1.addEventListener(BattleEntityEvent.FACING,this.entityFacingHandler);
         }
         param1.mobility.addEventListener(BattleEntityMobilityEvent.MOVING,this.entityMovingHandler);
      }
      
      public function notifyWalkableChanged() : void
      {
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.WALKABLE));
         this.notifyTileConfigurationChanged();
      }
      
      private function notifyTileConfigurationChanged() : void
      {
         ++this._tileConfiguration;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_TILE_CONFIGURATION));
      }
      
      private function entityMovingHandler(param1:BattleEntityMobilityEvent) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:BattleEntityMobility = param1.target as BattleEntityMobility;
         var _loc3_:IBattleEntity = _loc2_.entity;
         if(_loc2_.moving)
         {
            if(!this.movers[_loc3_])
            {
               this.movers[_loc3_] = _loc3_;
               _loc4_ = true;
            }
         }
         else if(this.movers[_loc3_])
         {
            delete this.movers[_loc3_];
            _loc4_ = true;
         }
         if(_loc4_)
         {
            this.notifyTileConfigurationChanged();
            dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_MOVING,_loc3_));
         }
      }
      
      private function entityForceCameraCenterHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         if(this._forceCameraCenterEntity == _loc2_ && !_loc2_.forceCameraCenter)
         {
            this.forceCameraCenterEntity = null;
         }
         else if(_loc2_.forceCameraCenter)
         {
            this.forceCameraCenterEntity = _loc2_;
         }
      }
      
      public function get forceCameraCenterEntity() : IBattleEntity
      {
         return this._forceCameraCenterEntity;
      }
      
      public function set forceCameraCenterEntity(param1:IBattleEntity) : void
      {
         var _loc2_:IBattleEntity = null;
         if(param1 == this._forceCameraCenterEntity)
         {
            return;
         }
         if(this._forceCameraCenterEntity)
         {
            _loc2_ = this._forceCameraCenterEntity;
            this._forceCameraCenterEntity = null;
            _loc2_.forceCameraCenter = false;
         }
         this._forceCameraCenterEntity = param1;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_FORCE_CAMERA_CENTER,this._forceCameraCenterEntity));
      }
      
      private function entityDamagedHandler(param1:BattleEntityEvent) : void
      {
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_DAMAGED,param1.entity));
      }
      
      private function entityFacingHandler(param1:BattleEntityEvent) : void
      {
         this.notifyTileConfigurationChanged();
      }
      
      private function entityAliveHandler(param1:BattleEntityEvent) : void
      {
         this.notifyTileConfigurationChanged();
         var _loc2_:IBattleEntity = param1.entity;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_ALIVE,_loc2_));
         if(this._scene._context.saga)
         {
            if(!_loc2_.alive)
            {
               (this._scene._context.saga as Saga).triggerBattleUnitKilled(_loc2_);
            }
         }
      }
      
      public function handleBonusRenown(param1:BattleEntity) : void
      {
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_BONUS_RENOWN,param1));
      }
      
      private function entityEnabledHandler(param1:BattleEntityEvent) : void
      {
         this.notifyTileConfigurationChanged();
         var _loc2_:IBattleEntity = param1.entity;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_ENABLED,_loc2_));
      }
      
      private function entityKillingEffectHandler(param1:BattleEntityEvent) : void
      {
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,param1.entity));
      }
      
      public function removeEntity(param1:IBattleEntity) : void
      {
         if(this._fake)
         {
            return;
         }
         param1.enabled = false;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.REMOVING,param1));
         if(param1.party)
         {
            param1.party.removeMember(param1);
         }
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_PARTY_CHANGED));
         this.removeEntityListeners(param1);
         delete this.entities[param1.id];
         param1.handleRemovedFromBoard();
         this.notifyTileConfigurationChanged();
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.REMOVED,param1));
         if(this._tiles)
         {
            this._tiles.blockTilesForEntity(param1);
         }
         if(Saga.instance)
         {
            Saga.instance.triggerBattleUnitRemoved(param1);
         }
      }
      
      private function removeEntityListeners(param1:IBattleEntity) : void
      {
         param1.removeEventListener(BattleEntityEvent.FORCE_CAMERA_CENTER,this.entityForceCameraCenterHandler);
         param1.removeEventListener(BattleEntityEvent.DAMAGED,this.entityDamagedHandler);
         param1.removeEventListener(BattleEntityEvent.ALIVE,this.entityAliveHandler);
         param1.removeEventListener(BattleEntityEvent.FACING,this.entityFacingHandler);
         param1.removeEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         param1.removeEventListener(BattleEntityEvent.KILLING_EFFECT,this.entityKillingEffectHandler);
         if(param1.mobility)
         {
            param1.mobility.removeEventListener(BattleEntityMobilityEvent.MOVING,this.entityMovingHandler);
         }
      }
      
      public function createEntity(param1:IEntityDef, param2:String, param3:BattleFacing, param4:Number, param5:Number, param6:IBattleParty) : IBattleEntity
      {
         if(this._fake)
         {
            return null;
         }
         var _loc7_:BattleEntity = BattleEntityFactory.create(this,param2,param1,param6,this.soundDriver,this._logger);
         if(param3)
         {
            _loc7_.facing = param3;
         }
         _loc7_.setPos(param4,param5);
         this.addEntity(_loc7_);
         if(!_loc7_.incorporeal)
         {
            _loc7_.setVisible(false,0);
            _loc7_.setVisible(true,500);
         }
         if(this.waves)
         {
            _loc7_.waveSpawned = this.waves.waveNumber;
         }
         return _loc7_;
      }
      
      public function testRectTiles(param1:TileRect, param2:Boolean) : Boolean
      {
         if(param1.visitEnclosedTileLocations(this._visitTestRectTile,param2))
         {
            return false;
         }
         return true;
      }
      
      private function _visitTestRectTile(param1:int, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:Tile = this._tiles.getTile(param1,param2);
         if(!_loc4_)
         {
            return true;
         }
         if(param3 && !_loc4_.getWalkableFor(null))
         {
            return true;
         }
         return false;
      }
      
      public function findAllRectIntersectionEntities(param1:TileRect, param2:IBattleEntity, param3:Vector.<IBattleEntity>) : Boolean
      {
         return this._spatial.findAllRectIntersectionEntities(param1,param2,param3);
      }
      
      public function findAllAdjacentEntities(param1:IBattleEntity, param2:TileRect, param3:Vector.<IBattleEntity>, param4:Boolean) : Vector.<IBattleEntity>
      {
         return this._spatial.findAllAdjacentEntities(param1,param2,param3,param4);
      }
      
      public function findEntityOnTile(param1:Number, param2:Number, param3:Boolean, param4:*) : IBattleEntity
      {
         return this._spatial._findEntityOnTile(param1,param2,param3,param4,false);
      }
      
      public function findEntityOnTileDiameter(param1:Number, param2:Number, param3:Boolean, param4:*) : IBattleEntity
      {
         return this._spatial._findEntityOnTile(param1,param2,param3,param4,true);
      }
      
      public function _findEntityOnTile(param1:Number, param2:Number, param3:Boolean, param4:*, param5:Boolean) : IBattleEntity
      {
         return this._spatial._findEntityOnTile(param1,param2,param3,param4,param5);
      }
      
      public function spawn(param1:String, param2:String) : void
      {
         this._spawn.spawn(param1,param2);
      }
      
      public function spawnWave(param1:BattleWave) : void
      {
         this._spawn.spawnWave(param1);
      }
      
      public function spawnPlayers(param1:String, param2:String) : void
      {
         this._spawn.spawnPlayers(param1,param2);
      }
      
      public function cleanupEnemiesFromWave(param1:int) : void
      {
         var _loc2_:IBattleParty = null;
         var _loc3_:Vector.<IBattleEntity> = null;
         var _loc4_:IBattleEntity = null;
         for each(_loc2_ in this.parties)
         {
            if(!_loc2_.isPlayer)
            {
               _loc3_ = new Vector.<IBattleEntity>();
               _loc2_.getDeadMembers(_loc3_);
               for each(_loc4_ in _loc3_)
               {
                  if(_loc4_.waveSpawned == param1)
                  {
                     this.removeEntity(_loc4_);
                  }
               }
            }
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var value:Boolean = param1;
         if(this._enabled != value)
         {
            this._enabled = value;
            if(this._enabled)
            {
               if(this._waves)
               {
                  try
                  {
                     this._waves.handleBattleEnabled();
                  }
                  catch(error:Error)
                  {
                     logger.error(error.message + "\n" + error.getStackTrace());
                     _waves.cleanup();
                     _waves = null;
                  }
               }
               this._spawn.spawn(null,null);
               if(this.error || this._spawn.error)
               {
                  if(this._scene._context.saga)
                  {
                     this._scene._context.saga.setVar(SagaVar.VAR_BATTLE_VICTORY,1);
                  }
                  return;
               }
               this.addBoardTriggers();
            }
            if(this.error)
            {
               if(this._scene._context.saga)
               {
                  this._scene._context.saga.setVar(SagaVar.VAR_BATTLE_VICTORY,1);
               }
               return;
            }
            if(this._spawn)
            {
               this._spawn.performResourceCollection();
            }
            if(this._waves)
            {
               this._waves.performResourceCollection();
            }
            dispatchEvent(new BattleBoardEvent(BattleBoardEvent.ENABLED));
         }
      }
      
      public function createLocalParty(param1:String, param2:String, param3:String, param4:String, param5:int) : void
      {
         this.createParty(param1,param2,param3,param4,BattlePartyType.LOCAL,param5,true);
      }
      
      private function createParty(param1:String, param2:String, param3:String, param4:String, param5:BattlePartyType, param6:int, param7:Boolean) : BattleParty
      {
         var _loc8_:BattleParty = this.partiesById[param2];
         if(!_loc8_)
         {
            _loc8_ = new BattleParty(this,param1,param2,param3,param4,param5,param6,param7);
            this.partiesById[param2] = _loc8_;
            this.parties.push(_loc8_);
            dispatchEvent(new BattleBoardEvent(BattleBoardEvent.PARTY));
         }
         else
         {
            if(param5 != _loc8_.type)
            {
               throw new ArgumentError("Bad party type for [" + 0 + "].  Expected " + param5 + " but found existing party of type " + _loc8_.type);
            }
            if(param7 && !_loc8_.isAlly)
            {
               throw new ArgumentError("Bad enemy bool");
            }
         }
         return _loc8_;
      }
      
      public function addPlayerPartyMemberBattleEntity(param1:IBattleEntity, param2:int) : IBattleEntity
      {
         var _loc4_:Boolean = false;
         var _loc3_:IBattleParty = this.getPartyById("0");
         var _loc5_:BattleParty = this.createParty(null,_loc3_.id,_loc3_.team,_loc3_.deployment,_loc3_.type,param2,_loc4_);
         param1.board = this as IBattleBoard;
         param1.deploymentReady = false;
         this.addEntity(param1 as BattleEntity);
         param1.enabled = true;
         if(!param1.incorporeal)
         {
            param1.setVisible(false,0);
            param1.setVisible(true,500);
         }
         _loc5_.addMember(param1);
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_PARTY_CHANGED));
         return param1;
      }
      
      public function addPlayerPartyMember(param1:IEntityDef, param2:int, param3:BattleFacing, param4:TileLocation, param5:Boolean) : IBattleEntity
      {
         var _loc7_:Boolean = false;
         var _loc6_:IBattleParty = this.getPartyById("0");
         return this.addPartyMember(null,null,_loc6_.id,_loc6_.team,_loc6_.deployment,param1,_loc6_.type,param2,_loc7_,param3,param4,param5);
      }
      
      public function addPartyMember(param1:String, param2:String, param3:String, param4:String, param5:String, param6:IEntityDef, param7:BattlePartyType, param8:int, param9:Boolean, param10:BattleFacing, param11:TileLocation, param12:Boolean) : IBattleEntity
      {
         if(!param6)
         {
            this.logger.error("addPartyMember Invalid def, attempt id [" + param2 + "], partyId [" + param3 + "]");
            return null;
         }
         var _loc13_:BattleParty = this.createParty(param1,param3,param4,param5,param7,param8,param9);
         if(!_loc13_)
         {
            this.logger.error("addPartyMember Invalid party create name=[" + param1 + "] id=[" + param3 + "]");
            return null;
         }
         if(!param2)
         {
            param2 = this.makeEntityId(_loc13_,param6);
         }
         var _loc14_:int = !!param11 ? param11.x : -1;
         var _loc15_:int = !!param11 ? param11.y : -1;
         var _loc16_:IBattleEntity = this.createEntity(param6,param2,param10,_loc14_,_loc15_,_loc13_);
         _loc16_.enabled = param12;
         _loc13_.addMember(_loc16_);
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_PARTY_CHANGED));
         if(!this._scene._context.saga)
         {
         }
         return _loc16_;
      }
      
      internal function makeEntityId(param1:BattleParty, param2:IEntityDef) : String
      {
         return param1.id + "+" + param1.numMembers + "+" + param2.id;
      }
      
      public function addRemoteParty(param1:String, param2:String, param3:String, param4:String, param5:IEntityListDef, param6:int, param7:Boolean) : void
      {
         var _loc9_:IEntityDef = null;
         var _loc10_:String = null;
         var _loc11_:BattleFacing = null;
         var _loc12_:TileLocation = null;
         var _loc8_:int = 0;
         while(_loc8_ < param5.numEntityDefs)
         {
            _loc9_ = param5.getEntityDef(_loc8_);
            if(!_loc9_)
            {
               throw new IllegalOperationError("Found null def for party member " + _loc8_ + ", party=" + param5);
            }
            _loc10_ = null;
            _loc11_ = null;
            _loc12_ = null;
            this.addPartyMember(param1,_loc10_,param2,param3,param4,_loc9_,BattlePartyType.REMOTE,param6,param7,_loc11_,_loc12_,false);
            _loc8_++;
         }
      }
      
      public function changeLocale(param1:Locale) : void
      {
         this._spawn.changeLocale(param1);
      }
      
      private function getTriggerDefById(param1:String) : BattleBoardTriggerDef
      {
         return this.def.getTriggerDefById(param1);
      }
      
      protected function addBoardTriggers() : void
      {
         if(!this._def.triggerDefs_global && !this._def.triggerDefs)
         {
            return;
         }
         if(this._def.triggerSpawners)
         {
            this._def.triggerSpawners.visitTriggerSpawnerDefs(this._addBoardTrigger);
         }
      }
      
      private function _addBoardTrigger(param1:BattleBoardTriggerSpawnerDef) : void
      {
         var _loc2_:BattleBoardTriggerDef = null;
         if(param1.def_id)
         {
            _loc2_ = this.getTriggerDefById(param1.def_id);
            if(_loc2_ == null)
            {
               this.logger.error("Invalid board trigger spawner def_id " + param1.def_id + " for spawner " + param1);
               return;
            }
         }
         else
         {
            _loc2_ = new BattleBoardTriggerDef();
            _loc2_.id = "NullTriggerDef_" + ++this._lastNullTriggerDefId;
         }
         var _loc3_:Boolean = true;
         this.tiles.addTrigger(param1.trigger_id,_loc2_,param1.rect,_loc3_,null,param1.disabled);
      }
      
      public function get numParties() : int
      {
         return this.parties.length;
      }
      
      public function getParty(param1:int) : IBattleParty
      {
         return this.parties[param1];
      }
      
      public function getPartyById(param1:String) : IBattleParty
      {
         return this.partiesById[param1];
      }
      
      public function getPartyIndex(param1:IBattleParty) : int
      {
         return this.parties.indexOf(param1);
      }
      
      public function get entities() : Dictionary
      {
         return this._entities;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function get tiles() : Tiles
      {
         return this._tiles;
      }
      
      public function get triggers() : IBattleBoardTriggers
      {
         return this._triggers;
      }
      
      public function getEntityByIdOrByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity
      {
         var _loc4_:IBattleEntity = this._entities[param1];
         if(_loc4_)
         {
            return _loc4_;
         }
         return this.getEntityByDefId(param1,param2,param3);
      }
      
      public function getEntity(param1:String) : IBattleEntity
      {
         return this._entities[param1];
      }
      
      public function getEntityByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity
      {
         var _loc4_:IBattleEntity = null;
         var _loc8_:String = null;
         var _loc9_:IBattleEntity = null;
         var _loc10_:int = 0;
         if(!param2)
         {
            param2 = this.turnEntityRect;
         }
         var _loc5_:int = 10000000;
         if(!param1)
         {
            param1 = param1;
         }
         var _loc6_:* = param1.indexOf(this._player_prefix) == 0;
         var _loc7_:* = param1.indexOf(this._npc_prefix) == 0;
         for(_loc8_ in this._entities)
         {
            _loc9_ = this._entities[_loc8_];
            if(_loc9_)
            {
               if(!(!_loc9_.alive && !param3))
               {
                  if(_loc9_.def.id == param1 || Boolean(_loc9_.isPlayer) && _loc6_ || !_loc9_.isPlayer && _loc7_)
                  {
                     if(!param2)
                     {
                        return _loc9_;
                     }
                     _loc10_ = TileRectRange.computeRange(_loc9_.rect,param2);
                     if(_loc10_ < _loc5_)
                     {
                        _loc5_ = _loc10_;
                        _loc4_ = _loc9_;
                     }
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public function get abilityManager() : IBattleAbilityManager
      {
         return this._abilityManager;
      }
      
      public function autoDeployPartyById(param1:String) : void
      {
         var _loc3_:BattleDeployer_Saga = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:BattleDeployer_Factions = null;
         var _loc2_:IBattleParty = this.getPartyById(param1);
         if(!_loc2_)
         {
            return;
         }
         if(this._scene._context.saga)
         {
            _loc3_ = new BattleDeployer_Saga(this);
            _loc4_ = _loc2_.isPlayer;
            _loc5_ = _loc2_.isPlayer;
            _loc3_.autoDeployParty(_loc2_,_loc4_,_loc5_);
         }
         else
         {
            _loc6_ = new BattleDeployer_Factions(this);
            _loc6_.autoDeployParty(_loc2_);
         }
      }
      
      public function attemptDeploy(param1:IBattleEntity, param2:BattleFacing, param3:TileLocationArea, param4:TileLocation) : Boolean
      {
         return this._deploy.attemptDeploy(param1,param2,param3,param4);
      }
      
      public function findNextMoveFloodTile(param1:IBattleEntity, param2:IBattleMove, param3:TileLocation, param4:Point) : Tile
      {
         var _loc6_:TileLocation = null;
         var _loc7_:Tile = null;
         var _loc5_:int = 1;
         while(_loc5_ < param2.flood.costLimit + 1)
         {
            _loc6_ = TileLocation.fetch(param3.x + param4.x * _loc5_,param3.y + param4.y * _loc5_);
            _loc7_ = this.tiles.getTileByLocation(_loc6_);
            if(_loc7_)
            {
               if(param2.wayPointTile == _loc7_ || param2.flood.hasResultKey(_loc7_))
               {
                  return _loc7_;
               }
            }
            _loc5_++;
         }
         return null;
      }
      
      public function get def() : BattleBoardDef
      {
         return this._def;
      }
      
      public function set def(param1:BattleBoardDef) : void
      {
         this._def = param1;
      }
      
      public function get fake() : Boolean
      {
         return this._fake;
      }
      
      public function set fake(param1:Boolean) : void
      {
         var _loc2_:BattleEntity = null;
         if(this._fake == param1)
         {
            return;
         }
         this._fake = param1;
         this.abilityManager.setFaking(this._fake);
         for each(_loc2_ in this.entities)
         {
            _loc2_.setFakeEntityStats(this._fake,this._logger);
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:BattleEntity = null;
         this.updating = true;
         for each(_loc2_ in this.entities)
         {
            _loc2_.update(param1);
         }
         this.updating = false;
         this.fsm.update(param1);
      }
      
      public function get boardSetup() : Boolean
      {
         return this._boardSetup;
      }
      
      public function set boardSetup(param1:Boolean) : void
      {
         if(this._boardSetup != param1)
         {
            this._boardSetup = param1;
            dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARDSETUP));
            this._boardFinishedSetup = param1;
            if(param1)
            {
               if(this._scenario)
               {
                  this._scenario.handleBattleStarted();
               }
               if(this._triggers)
               {
                  this._triggers.validate();
               }
            }
         }
      }
      
      public function get boardDeploymentStarted() : Boolean
      {
         return this._boardDeploymentStarted;
      }
      
      public function set boardDeploymentStarted(param1:Boolean) : void
      {
         if(this._boardDeploymentStarted != param1)
         {
            this._boardDeploymentStarted = param1;
            if(param1)
            {
               dispatchEvent(new BattleBoardEvent(BattleBoardEvent.DEPLOYMENT_STARTED));
            }
         }
      }
      
      public function get boardFinishedSetup() : Boolean
      {
         return this._boardFinishedSetup;
      }
      
      public function get resman() : IResourceManager
      {
         return this._resman;
      }
      
      private function expireDeadEntitiesEffects() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in this.entities)
         {
            _loc1_.expireDeadEntitiesEffects();
         }
      }
      
      public function get scene() : IScene
      {
         return this._scene;
      }
      
      public function handleTraumaChanged(param1:IBattleParty) : void
      {
         if(this.suppressPartyVitality)
         {
            return;
         }
         if(this._scene)
         {
            this._scene.handleTraumaChanged(param1);
         }
      }
      
      public function setVitalities(param1:Dictionary) : void
      {
         this.vitalities = param1;
      }
      
      public function showInfoBanner(param1:IBattleEntity) : void
      {
         this._showInfoEntity = param1;
         this.updateInfoBanners();
      }
      
      public function updateInfoBanners() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in this.entities)
         {
            this.updateInfoBannerForEntity(_loc1_);
         }
      }
      
      public function updateInfoBannerForEntity(param1:BattleEntity) : void
      {
         var _loc2_:Boolean = param1.enabled && param1.alive && param1.attackable && (this._showInfoBanners || this._showInfoEntity == param1);
         if(!_loc2_)
         {
            if(PlatformInput.hasClicker && !PlatformInput.lastInputGp)
            {
               _loc2_ = param1.hovering;
            }
         }
         param1.battleInfoFlagVisible = _loc2_;
      }
      
      public function set showInfoBanners(param1:Boolean) : void
      {
         this._showInfoBanners = param1;
         this.updateInfoBanners();
      }
      
      public function get isTutorialActive() : Boolean
      {
         return Boolean(this.tutorial) && this.tutorial.isActive;
      }
      
      public function performBattleUnitEnable(param1:String, param2:Boolean) : void
      {
         var _loc4_:String = null;
         var _loc3_:IBattleEntity = this.getEntity(param1);
         if(_loc3_)
         {
            _loc3_.enabled = param2;
            return;
         }
         for(_loc4_ in this.entities)
         {
            _loc3_ = this.entities[_loc4_];
            if(_loc3_)
            {
               if(_loc3_.def.id == param1)
               {
                  _loc3_.enabled = param2;
               }
            }
         }
      }
      
      public function get turnEntity() : IBattleEntity
      {
         if(Boolean(this._fsm) && Boolean(this._fsm._turn))
         {
            return this._fsm._turn.entity;
         }
         return null;
      }
      
      public function get turnEntityRect() : TileRect
      {
         var _loc1_:IBattleEntity = this.turnEntity;
         return !!_loc1_ ? _loc1_.rect : null;
      }
      
      public function handleEntityTileChanged(param1:IBattleEntity) : void
      {
         if(this.tiles)
         {
            this.tiles.blockTilesForEntity(param1);
         }
         if(hasEventListener(BattleBoardEvent.BOARD_ENTITY_TILE_CHANGED))
         {
            dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_TILE_CHANGED,param1));
         }
      }
      
      public function get scenario() : IBattleScenario
      {
         return this._scenario;
      }
      
      public function fetchEntityId() : uint
      {
         ++this._lastEntityNumericId;
         if(this._lastEntityNumericId > 65535)
         {
            this.logger.error("BattleBoard.fetchEntityId out of ids, wrapping around");
         }
         return this._lastEntityNumericId;
      }
      
      public function applyBoardPassives(param1:BattleEntity) : void
      {
         if(param1.party)
         {
            if(param1.party.isPlayer)
            {
               _applyBoardPassives(param1,this._def.passivesPlayer_defs,this._abilityManager);
            }
            else if(param1.party.isEnemy)
            {
               _applyBoardPassives(param1,this._def.passivesEnemy_defs,this._abilityManager);
            }
         }
      }
      
      public function makeSnapshot() : BattleSnapshot
      {
         return new BattleSnapshot(this);
      }
      
      public function loadSnapshot(param1:BattleSnapshot) : void
      {
         if(!param1)
         {
            return;
         }
         this.snapSrc = param1;
         param1.applySnapshot(this);
      }
      
      public function recomputePartyVitality() : void
      {
         var _loc1_:BattleParty = null;
         for each(_loc1_ in this.parties)
         {
            _loc1_.recomputeVitality();
         }
      }
      
      public function get isUsingEntity() : Boolean
      {
         return this._isUsingEntity;
      }
      
      public function handleEntityUsingStart(param1:IBattleEntity, param2:IBattleEntity, param3:BattleAbility) : void
      {
         this._isUsingEntity = true;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_USING_START,param2,param1));
      }
      
      public function handleEntityUsingEnd(param1:IBattleEntity, param2:BattleAbility) : void
      {
         this._isUsingEntity = false;
         dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_USING_END,param1,null));
      }
      
      public function get deploy() : BattleBoard_Deploy
      {
         return this._deploy;
      }
      
      public function get redeploy() : BattleBoard_Redeploy
      {
         return this._redeploy;
      }
      
      public function getSaga() : ISaga
      {
         return this.saga;
      }
      
      public function get tileConfiguration() : int
      {
         return this._tileConfiguration;
      }
      
      public function get spatial() : BattleBoard_Spatial
      {
         return this._spatial;
      }
      
      public function getAttractorById(param1:String) : IBattleAttractor
      {
         return !!this._attractors ? this._attractors.getAttractorById(param1) : null;
      }
      
      public function get entityAssetBundleManager() : IEntityAssetBundleManager
      {
         return this._entityAssetBundleManager;
      }
      
      public function get abilityAssetBundleManager() : IAbilityAssetBundleManager
      {
         return this._entityAssetBundleManager.abilityAssetBundleManager;
      }
      
      public function recomputeIncorporealFades() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in this._entities)
         {
            _loc1_.computeIncorporealFade();
         }
      }
      
      public function onStartedTurn() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in this._entities)
         {
            _loc1_.onTurnChanged();
         }
         if(this._triggers)
         {
            this._triggers.onStartedTurn();
         }
         this._triggers.clearEntitiesHitThisTurn();
         this._abilityManager.handleStartTurn();
      }
      
      public function checkVars() : void
      {
         if(this._triggers)
         {
            this._triggers.checkTriggerVars();
         }
      }
      
      public function getAbilityDefFactory() : IBattleAbilityDefFactory
      {
         return this.abilityFactory;
      }
      
      public function performResourceCollectionBucket(param1:SagaBucket) : void
      {
         this._spawn && this._spawn.performResourceCollectionBucket(param1);
      }
      
      public function centerOnBoardPoint(param1:Number, param2:Number, param3:Function) : void
      {
         var _loc4_:BattleCameraEvent = null;
         _loc4_ = new BattleCameraEvent(BattleCameraEvent.CAMERA_CENTER_ON_ISO_POINT,param3);
         _loc4_.setIsoPoint(param1,param2);
         dispatchEvent(_loc4_);
      }
      
      public function get artifactMaxUseCount() : int
      {
         return this._artifactMaxUseCount;
      }
      
      public function set artifactMaxUseCount(param1:int) : void
      {
         this._artifactMaxUseCount = param1;
      }
      
      public function get soundController() : ISoundController
      {
         return !!this.soundControllerManager ? this.soundControllerManager.soundController : null;
      }
   }
}
