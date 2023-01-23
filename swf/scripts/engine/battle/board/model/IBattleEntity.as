package engine.battle.board.model
{
   import engine.anim.view.AnimController;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.model.BattleRecord;
   import engine.battle.ability.model.BattleTargetSet;
   import engine.battle.ability.phantasm.model.IChainPhantasms;
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.def.Usability;
   import engine.battle.board.def.UsabilityDef;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.entity.model.IEntity;
   import engine.resource.ResourceGroup;
   import engine.sound.view.SoundController;
   import engine.talent.BonusedTalents;
   import engine.talent.TalentDef;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   
   public interface IBattleEntity extends IEntity, ITileResident
   {
       
      
      function get suppressFlytext() : Boolean;
      
      function set suppressFlytext(param1:Boolean) : void;
      
      function get alive() : Boolean;
      
      function set alive(param1:Boolean) : void;
      
      function get deathCount() : int;
      
      function get team() : String;
      
      function setTeamOverride(param1:String) : void;
      
      function get board() : IBattleBoard;
      
      function set board(param1:IBattleBoard) : void;
      
      function set suppressMoveEvents(param1:Boolean) : void;
      
      function setPos(param1:Number, param2:Number, param3:Boolean = false) : void;
      
      function setPosFromTileRect(param1:TileRect) : void;
      
      function get bonusedTalents() : BonusedTalents;
      
      function canAttack(param1:IBattleEntity) : Boolean;
      
      function get triggering() : Boolean;
      
      function set triggering(param1:Boolean) : void;
      
      function get party() : IBattleParty;
      
      function set party(param1:IBattleParty) : void;
      
      function get mobility() : IBattleEntityMobility;
      
      function get facing() : BattleFacing;
      
      function set facing(param1:BattleFacing) : void;
      
      function get ignoreTargetRotation() : Boolean;
      
      function incrementIgnoreTargetRotation() : void;
      
      function decrementIgnoreTargetRotation() : void;
      
      function get ignoreFacing() : Boolean;
      
      function set ignoreFacing(param1:Boolean) : void;
      
      function get ignoreFreezeFrame() : Boolean;
      
      function set ignoreFreezeFrame(param1:Boolean) : void;
      
      function get record() : BattleRecord;
      
      function emitFlyText(param1:String, param2:uint, param3:String, param4:int) : void;
      
      function playGoAnimation() : void;
      
      function get animEventDispatcher() : IEventDispatcher;
      
      function get effects() : IPersistedEffects;
      
      function createChainForEffect(param1:IEffect) : IChainPhantasms;
      
      function get logger() : ILogger;
      
      function set deploymentReady(param1:Boolean) : void;
      
      function get deploymentReady() : Boolean;
      
      function handleMissed(param1:IEffect) : void;
      
      function handleResisted(param1:IEffect) : void;
      
      function handleDiverted(param1:IEffect) : void;
      
      function handleCrit(param1:IEffect) : void;
      
      function handleAbsorbing(param1:IEffect) : void;
      
      function handleTalent(param1:TalentDef) : void;
      
      function handleDodge(param1:IEffect) : void;
      
      function handleKillStop(param1:IEffect) : void;
      
      function handleTwiceBorn(param1:IEffect) : void;
      
      function set locoId(param1:String) : void;
      
      function get locoId() : String;
      
      function centerCameraOnEntity() : void;
      
      function consumeBonusRenown() : int;
      
      function endTurn(param1:Boolean, param2:String, param3:Boolean) : void;
      
      function setTurnSuspended(param1:Boolean) : void;
      
      function onStartTurn() : void;
      
      function onEndTurn() : void;
      
      function onTurnChanged() : void;
      
      function get killingEffect() : IEffect;
      
      function set killingEffect(param1:IEffect) : void;
      
      function resetKillingEffect() : void;
      
      function highestAvailableAbilityDef(param1:String) : IBattleAbilityDef;
      
      function lowestValidAbilityDef(param1:String, param2:IBattleEntity, param3:Tile, param4:IBattleMove) : IBattleAbilityDef;
      
      function lowestValidAbilityDefForTargetCount(param1:String, param2:IBattleMove, param3:BattleTargetSet) : IBattleAbilityDef;
      
      function get cleanedup() : Boolean;
      
      function set forceCameraCenter(param1:Boolean) : void;
      
      function get forceCameraCenter() : Boolean;
      
      function set hovering(param1:Boolean) : void;
      
      function get hovering() : Boolean;
      
      function set incorporeal(param1:Boolean) : void;
      
      function get incorporeal() : Boolean;
      
      function set traversable(param1:Boolean) : void;
      
      function get traversable() : Boolean;
      
      function get includeVitality() : Boolean;
      
      function get bonusRenown() : int;
      
      function set bonusRenown(param1:int) : void;
      
      function get deploymentFinalized() : Boolean;
      
      function set deploymentFinalized(param1:Boolean) : void;
      
      function notifyCollision(param1:IBattleEntity) : void;
      
      function faceTile(param1:Tile, param2:Tile) : Point;
      
      function getSummaryLine() : String;
      
      function getDebugInfo() : String;
      
      function get freeTurns() : int;
      
      function set freeTurns(param1:int) : void;
      
      function get resourceGroup() : ResourceGroup;
      
      function get killRenown() : int;
      
      function set spawnedCasterRenownLimit(param1:Boolean) : void;
      
      function set spawnedCaster(param1:IBattleEntity) : void;
      
      function get spawnedCasterRenownLimit() : Boolean;
      
      function get spawnedCaster() : IBattleEntity;
      
      function get spawningCasterRenownCount() : int;
      
      function get spawnedCasterRenownCount() : int;
      
      function flipFacing(param1:Boolean) : void;
      
      function get animController() : AnimController;
      
      function get soundController() : SoundController;
      
      function get flyText() : String;
      
      function get flyTextColor() : uint;
      
      function get flyTextFontName() : String;
      
      function get flyTextFontSize() : int;
      
      function get deathAnim() : String;
      
      function get deathVocalization() : String;
      
      function get height() : Number;
      
      function get battleDamageFlagVisible() : Boolean;
      
      function get battleDamageFlagValue() : int;
      
      function get battleInfoFlagVisible() : Boolean;
      
      function turnToFace(param1:TileRect, param2:Boolean) : void;
      
      function set skipInjury(param1:Boolean) : void;
      
      function handleUsed(param1:IBattleEntity) : void;
      
      function get usability() : Usability;
      
      function get usabilityDef() : UsabilityDef;
      
      function set usabilityDef(param1:UsabilityDef) : void;
      
      function cleanup() : void;
      
      function discoverAttractor() : IBattleAttractor;
      
      function set attractorCoreReached(param1:Boolean) : void;
      
      function get attractorCoreReached() : Boolean;
      
      function set attractor(param1:IBattleAttractor) : void;
      
      function get attractor() : IBattleAttractor;
      
      function handleRemovedFromBoard() : void;
      
      function handleImmortalStopped() : void;
      
      function handleEndTurnIfNoEnemiesRemain() : void;
      
      function executeEntityAbilityId(param1:String, param2:int) : void;
      
      function setShitlistId(param1:String) : void;
      
      function get isDisabledMove() : Boolean;
      
      function get hasSubmergedMove() : Boolean;
      
      function get isTeleporting() : Boolean;
      
      function set isTeleporting(param1:Boolean) : void;
      
      function cameraFollowEntity(param1:Boolean) : void;
      
      function get isSubmerged() : Boolean;
      
      function set isSubmerged(param1:Boolean) : void;
      
      function get waveSpawned() : int;
      
      function set waveSpawned(param1:int) : void;
      
      function get incorporealFade() : Boolean;
   }
}
