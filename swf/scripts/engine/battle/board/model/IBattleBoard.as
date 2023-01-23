package engine.battle.board.model
{
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.battle.wave.BattleWaves;
   import engine.core.logging.ILogger;
   import engine.core.util.IDebugStringable;
   import engine.entity.def.IAbilityAssetBundleManager;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityDef;
   import engine.resource.IResourceManager;
   import engine.saga.ISaga;
   import engine.saga.SagaBucket;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.scene.model.IScene;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public interface IBattleBoard extends IEventDispatcher, IBattleEntityProvider, IDebugStringable
   {
       
      
      function get def() : BattleBoardDef;
      
      function get numParties() : int;
      
      function getParty(param1:int) : IBattleParty;
      
      function getPartyById(param1:String) : IBattleParty;
      
      function getPartyIndex(param1:IBattleParty) : int;
      
      function get entities() : Dictionary;
      
      function get logger() : ILogger;
      
      function get tiles() : Tiles;
      
      function get triggers() : IBattleBoardTriggers;
      
      function get abilityManager() : IBattleAbilityManager;
      
      function getAbilityDefFactory() : IBattleAbilityDefFactory;
      
      function set fake(param1:Boolean) : void;
      
      function getEntity(param1:String) : IBattleEntity;
      
      function get deathOffset() : Number;
      
      function set deathOffset(param1:Number) : void;
      
      function get scenario() : IBattleScenario;
      
      function get boardSetup() : Boolean;
      
      function set boardSetup(param1:Boolean) : void;
      
      function get fsm() : IBattleFsm;
      
      function get resman() : IResourceManager;
      
      function fetchEntityId() : uint;
      
      function findAllRectIntersectionEntities(param1:TileRect, param2:IBattleEntity, param3:Vector.<IBattleEntity>) : Boolean;
      
      function findAllAdjacentEntities(param1:IBattleEntity, param2:TileRect, param3:Vector.<IBattleEntity>, param4:Boolean) : Vector.<IBattleEntity>;
      
      function findEntityOnTile(param1:Number, param2:Number, param3:Boolean, param4:*) : IBattleEntity;
      
      function findEntityOnTileDiameter(param1:Number, param2:Number, param3:Boolean, param4:*) : IBattleEntity;
      
      function attemptDeploy(param1:IBattleEntity, param2:BattleFacing, param3:TileLocationArea, param4:TileLocation) : Boolean;
      
      function autoDeployPartyById(param1:String) : void;
      
      function get scene() : IScene;
      
      function get cleanedup() : Boolean;
      
      function get boardFinishedSetup() : Boolean;
      
      function addPlayerPartyMember(param1:IEntityDef, param2:int, param3:BattleFacing, param4:TileLocation, param5:Boolean) : IBattleEntity;
      
      function addPlayerPartyMemberBattleEntity(param1:IBattleEntity, param2:int) : IBattleEntity;
      
      function addPartyMember(param1:String, param2:String, param3:String, param4:String, param5:String, param6:IEntityDef, param7:BattlePartyType, param8:int, param9:Boolean, param10:BattleFacing, param11:TileLocation, param12:Boolean) : IBattleEntity;
      
      function get isTutorialActive() : Boolean;
      
      function handleEntityTileChanged(param1:IBattleEntity) : void;
      
      function get hoverTile() : Tile;
      
      function get selectedTile() : Tile;
      
      function set hoverTile(param1:Tile) : void;
      
      function set selectedTile(param1:Tile) : void;
      
      function get isUsingEntity() : Boolean;
      
      function get waves() : BattleWaves;
      
      function get deploy() : BattleBoard_Deploy;
      
      function get redeploy() : BattleBoard_Redeploy;
      
      function createEntity(param1:IEntityDef, param2:String, param3:BattleFacing, param4:Number, param5:Number, param6:IBattleParty) : IBattleEntity;
      
      function removeEntity(param1:IBattleEntity) : void;
      
      function getSaga() : ISaga;
      
      function get tileConfiguration() : int;
      
      function get spatial() : BattleBoard_Spatial;
      
      function get enabled() : Boolean;
      
      function get entityAssetBundleManager() : IEntityAssetBundleManager;
      
      function get abilityAssetBundleManager() : IAbilityAssetBundleManager;
      
      function onStartedTurn() : void;
      
      function checkVars() : void;
      
      function performResourceCollectionBucket(param1:SagaBucket) : void;
      
      function notifyWalkableChanged() : void;
      
      function centerOnBoardPoint(param1:Number, param2:Number, param3:Function) : void;
      
      function get artifactMaxUseCount() : int;
      
      function set artifactMaxUseCount(param1:int) : void;
   }
}
