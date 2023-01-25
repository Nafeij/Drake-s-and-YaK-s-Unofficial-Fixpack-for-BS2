package engine.battle.entity.model
{
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.anim.view.AnimController;
   import engine.anim.view.ColorPulsator;
   import engine.anim.view.ColorPulsatorDef;
   import engine.anim.view.IAnimControllerListener;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.model.PersistedEffects;
   import engine.battle.ability.effect.model.PersistedEffectsEvent;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.BattleRecord;
   import engine.battle.ability.model.BattleTargetSet;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.ability.phantasm.model.IChainPhantasms;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.def.Usability;
   import engine.battle.board.def.UsabilityDef;
   import engine.battle.board.def.UsabilityExecutor;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleEntityMobility;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.state.BattleStateTurnLocalBase;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.State;
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemApply;
   import engine.entity.def.ItemDef;
   import engine.entity.def.ShitlistDef;
   import engine.entity.model.Entity;
   import engine.math.Box;
   import engine.resource.ResourceGroup;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaLegend;
   import engine.saga.SagaVar;
   import engine.sound.ISoundDriver;
   import engine.sound.view.SoundController;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.talent.BonusedTalents;
   import engine.talent.TalentDef;
   import engine.talent.TalentRankDef;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class BattleEntity extends Entity implements IBattleEntity, IAnimControllerListener
   {
      
      public static var REWARD_RENOWN_PER_RANK:Boolean = true;
       
      
      private var _board:BattleBoard;
      
      public var pos:Point;
      
      private var _rect:TileRect;
      
      private var _facing:BattleFacing;
      
      private var _collidable:Boolean = true;
      
      private var _traversable:Boolean = false;
      
      private var _incorporeal:Boolean;
      
      public var _party:IBattleParty;
      
      private var _enabled:Boolean;
      
      private var _active:Boolean = true;
      
      private var _mobility:BattleEntityMobility;
      
      public var _animController:AnimController;
      
      public var _soundController:SoundController;
      
      public var _deploymentReady:Boolean;
      
      private var _logger:ILogger;
      
      private var _locoId:String;
      
      private var _ignoreTargetRotation:int;
      
      private var _ignoreFacing:Boolean = false;
      
      private var _killingEffect:Effect;
      
      private var diedThisTurn:Boolean;
      
      private var _lightStepping:Boolean;
      
      private var _kingStepping:Boolean;
      
      public var _width:Number;
      
      public var _length:Number;
      
      public var _height:Number;
      
      public var _diameter:Number;
      
      public var _includeVitality:Boolean = true;
      
      public var aiChoseAbilityLastTurn:Boolean = false;
      
      private var _battleInfoFlagVisible:Boolean;
      
      private var _battleDamageFlagVisible:Boolean;
      
      private var _battleDamageFlagValue:int;
      
      private var _rectDirty:Boolean = true;
      
      private var _tileDirty:Boolean = true;
      
      private var _tile:Tile;
      
      private var _pulsatorsById:Dictionary;
      
      private var _pulsators:Vector.<ColorPulsator>;
      
      private var _isSubmerged:Boolean;
      
      private var armstat:Stat;
      
      private var _bonusedTalents:BonusedTalents;
      
      public var saga:Saga;
      
      private var _waveSpawned:int;
      
      private var _battleHudIndicatorVisible:Boolean;
      
      private var _isTeleporting:Boolean;
      
      private var _entityPassives:int = 0;
      
      private var _itemPassives:int = 0;
      
      private var _suppressMoveEvents:Boolean;
      
      public var _flyText:String;
      
      public var _flyTextColor:uint;
      
      public var _flyTextFontName:String;
      
      public var _flyTextFontSize:int;
      
      private var _postLoadedEntity:Boolean;
      
      public var _deferredExecuteEntityAbilityDefs:Vector.<IBattleAbilityDef>;
      
      private var _effects:PersistedEffects;
      
      private var _selected:Boolean;
      
      private var _hilighted:Boolean;
      
      private var _targeted:Boolean;
      
      private var _triggering:Boolean;
      
      private var _record:BattleRecord;
      
      private var _fakeRecord:BattleRecord;
      
      private var _alive:Boolean = true;
      
      private var _teamOverride:String;
      
      private var _talentRankResults:Vector.<TalentRankDef>;
      
      public var _deathAnim:String = "die";
      
      public var _deathVocalization:String = "vocalize_die";
      
      public var _skipInjury:Boolean;
      
      public var _spawnedCasterRenownLimit:Boolean;
      
      public var _spawnedCaster:IBattleEntity;
      
      public var _spawningCasterRenownCount:int;
      
      private var _killRenown:int;
      
      private var _deploymentFinalized:Boolean;
      
      private var _forceCameraCenter:Boolean;
      
      private var _hovering:Boolean;
      
      private var _suppressFlytext:Boolean;
      
      private var _bonusRenown:int;
      
      private var _unconsumedBonusRenown:int;
      
      private var _freeTurns:int;
      
      private var _attackable:Boolean = true;
      
      private var _defAttackable:Boolean = true;
      
      private var _usability:Usability;
      
      private var _defUsabilityDef:UsabilityDef;
      
      private var _usabilityDef:UsabilityDef;
      
      private var _deathCount:int;
      
      private var _usabilityExecutor:UsabilityExecutor;
      
      private var _attractorCoreReached:Boolean;
      
      private var _attractor:IBattleAttractor;
      
      private var _hasSubmergedMove:Boolean;
      
      private var _incorporealFade:Boolean;
      
      public function BattleEntity(param1:IEntityDef, param2:String, param3:IBattleBoard, param4:ISoundDriver, param5:ILogger, param6:IBattleParty)
      {
         var _loc8_:int = 0;
         var _loc9_:Stat = null;
         var _loc10_:Stat = null;
         this.pos = new Point();
         this._facing = BattleFacing.SE;
         this._bonusedTalents = BonusedTalents.NullBonusedTalents;
         this._record = new BattleRecord();
         this._fakeRecord = new BattleRecord(true);
         this._talentRankResults = new Vector.<TalentRankDef>();
         super(param1,param2,param3.fetchEntityId());
         if(param1 == null)
         {
            throw new ArgumentError("can\'t entity without a def, def.");
         }
         this._board = param3 as BattleBoard;
         this.saga = !!this._board._scene._context ? this._board._scene._context.saga as Saga : null;
         this._defAttackable = param1.entityClass.mobile || param1.statRanges && param1.statRanges.hasStatRange(StatType.STRENGTH);
         this._defUsabilityDef = param1.usabilityDef;
         this._makeLocalUsability();
         var _loc7_:Box = param1.entityClass.bounds;
         this._width = _loc7_.width;
         this._length = _loc7_.length;
         this._height = _loc7_.height;
         this._diameter = Math.min(this._width,this._length);
         this._waveSpawned = 0;
         this._entityPassives = 0;
         this._itemPassives = 0;
         this._battleHudIndicatorVisible = true;
         this._party = param6;
         this._logger = param5;
         _loc8_ = 0;
         while(_loc8_ < param1.stats.numStats)
         {
            _loc9_ = param1.stats.getStatByIndex(_loc8_);
            _loc10_ = stats.addStat(_loc9_.type,_loc9_.base);
            _loc8_++;
         }
         this._animController = new AnimController(this.id,null,this,param5);
         this._soundController = new SoundController(this.id,param4,this.soundControllerCompleteHandler,param5);
         this._mobility = new BattleEntityMobility(this);
         this._hasSubmergedMove = param1 && param1.entityClass && param1.entityClass.hasSubmergedMove;
         this._isTeleporting = false;
         this.collidable = param1.entityClass.collidable;
         this._traversable = false;
         if(stats.hasStat(StatType.STRENGTH))
         {
            stats.getStat(StatType.STRENGTH).addEventListener(StatEvent.CHANGE,this.strengthChangeHandler);
         }
         if(this._defAttackable || this._defUsabilityDef)
         {
            this.temporaryCharacterCtor();
            if(param1.entityClass.mobile)
            {
               this._bonusedTalents = new BonusedTalents(param1.talents,stats);
            }
         }
         this._checkUsabilitySetup();
         this.executeEntityPassives();
         if(this._entityPassives + this._itemPassives >= 3)
         {
            SagaAchievements.unlockAchievementById("acv_3_31_passive_aggressive",this.saga.minutesPlayed,true);
         }
      }
      
      public function get locoId() : String
      {
         return this._locoId;
      }
      
      public function set locoId(param1:String) : void
      {
         this._locoId = param1;
      }
      
      public function get waveSpawned() : int
      {
         return this._waveSpawned;
      }
      
      public function set waveSpawned(param1:int) : void
      {
         this._waveSpawned = param1;
      }
      
      public function get battleHudIndicatorVisible() : Boolean
      {
         return this._battleHudIndicatorVisible;
      }
      
      public function set battleHudIndicatorVisible(param1:Boolean) : void
      {
         if(this._battleHudIndicatorVisible == param1)
         {
            return;
         }
         this._battleHudIndicatorVisible = param1;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE,this));
         this.board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE,this));
      }
      
      protected function soundControllerCompleteHandler(param1:SoundController) : void
      {
      }
      
      public function cleanup() : void
      {
         var _loc1_:ColorPulsator = null;
         if(_cleanedup)
         {
            return;
         }
         if(this._pulsators)
         {
            for each(_loc1_ in this._pulsators)
            {
               _loc1_.cleanup();
            }
            this._pulsators = null;
            this._pulsatorsById = null;
         }
         if(stats.hasStat(StatType.STRENGTH))
         {
            stats.getStat(StatType.STRENGTH).removeEventListener(StatEvent.CHANGE,this.strengthChangeHandler);
         }
         if(def.entityClass.mobile)
         {
            this.cleanupTemporaryCharacter();
         }
         if(this._soundController)
         {
            this._soundController.cleanup();
            this._soundController = null;
         }
         this._animController.cleanup();
         this._animController = null;
         this._mobility.cleanup();
         this._mobility = null;
         this._board = null;
         _def = null;
         this._facing = null;
         this.killingEffect = null;
         this._record = null;
         this._logger = null;
         super.cleanupEntity();
      }
      
      public function get centerX() : Number
      {
         return this.rect.center.x;
      }
      
      public function get centerY() : Number
      {
         return this.rect.center.y;
      }
      
      public function set suppressMoveEvents(param1:Boolean) : void
      {
         this._suppressMoveEvents = param1;
      }
      
      public function setPos(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Tile = null;
         if(fake || cleanedup)
         {
            return;
         }
         if(this.pos.y != param2 || this.pos.x != param1)
         {
            if(param3)
            {
            }
            _loc4_ = hasEventListener(BattleEntityEvent.TILE_CHANGED);
            _loc5_ = _loc4_ || this._lightStepping ? this.tile : null;
            this._rectDirty = true;
            this._tileDirty = true;
            this.pos.x = param1;
            this.pos.y = param2;
            if(!this._suppressMoveEvents)
            {
               dispatchEvent(new BattleEntityEvent(BattleEntityEvent.MOVED,this));
               if(_loc5_ != this.tile)
               {
                  if(this._lightStepping)
                  {
                     if(this.soundController && this.soundController.library)
                     {
                        if(this.tile.numResidents > 1)
                        {
                           if(this.soundController.library.getSoundDef("lightstep"))
                           {
                              this.soundController.playSound("lightstep",null);
                           }
                           if(this.saga)
                           {
                              if(this.board.boardFinishedSetup)
                              {
                                 this.saga.triggerBattleAbilityCompleted(this.def.id,"pas_light_step",this.isPlayer);
                              }
                           }
                        }
                     }
                  }
                  if(_loc4_)
                  {
                     dispatchEvent(new BattleEntityEvent(BattleEntityEvent.TILE_CHANGED,this));
                  }
                  if(this.board)
                  {
                     this.board.handleEntityTileChanged(this);
                  }
               }
            }
         }
      }
      
      public function get diameter() : Number
      {
         return this._diameter;
      }
      
      public function get localWidth() : Number
      {
         return this._width;
      }
      
      public function get localLength() : Number
      {
         return this._length;
      }
      
      public function get isSquare() : Boolean
      {
         return this._length == this._width;
      }
      
      public function isLocalRect(param1:int, param2:int) : Boolean
      {
         return this._length == param2 && this._width == param1;
      }
      
      public function get boardWidth() : Number
      {
         if(this.rect)
         {
            return this.rect.width;
         }
         return this._diameter;
      }
      
      public function get boardLength() : Number
      {
         if(this.rect)
         {
            return this.rect.length;
         }
         return this._diameter;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function get tile() : Tile
      {
         if(!this._tileDirty)
         {
            return this._tile;
         }
         if(this._board && this._board.tiles)
         {
            this._tile = this._board.tiles.getTile(this.pos.x,this.pos.y);
            this._tileDirty = false;
         }
         return this._tile;
      }
      
      public function get rect() : TileRect
      {
         var _loc2_:Box = null;
         if(!this._rectDirty)
         {
            return this._rect;
         }
         var _loc1_:TileLocation = TileLocation.fetch(this.pos.x,this.pos.y);
         if(_loc1_ == null)
         {
            return null;
         }
         this._rectDirty = false;
         if(this._rect == null)
         {
            _loc2_ = def.entityClass.bounds;
            this._rect = new TileRect(_loc1_,_loc2_.width,_loc2_.length,this._facing);
         }
         else
         {
            this._rect.setLocation(_loc1_);
            this._rect.facing = this._facing;
         }
         return this._rect;
      }
      
      public function setPosFromTileRect(param1:TileRect) : void
      {
         this._rectDirty = true;
         this.facing = param1.facing as BattleFacing;
         this.setPos(param1.loc.x,param1.loc.y);
      }
      
      public function playGoAnimation() : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.GO_ANIMATION,this));
      }
      
      public function emitFlyText(param1:String, param2:uint, param3:String, param4:int) : void
      {
         if(fake)
         {
            return;
         }
         this._flyText = param1;
         this._flyTextColor = param2;
         this._flyTextFontName = param3;
         this._flyTextFontSize = param4;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.FLY_TEXT,this));
      }
      
      public function get facing() : BattleFacing
      {
         return this._facing;
      }
      
      public function set facing(param1:BattleFacing) : void
      {
         if(fake)
         {
            return;
         }
         if(this._ignoreFacing)
         {
            return;
         }
         if(this._facing != param1)
         {
            this._rectDirty = true;
            this._facing = param1;
            if(this.board && this._width != this._length)
            {
               this.board.tiles.blockTilesForEntity(this);
            }
            if(!this._suppressMoveEvents)
            {
               dispatchEvent(new BattleEntityEvent(BattleEntityEvent.FACING,this));
            }
         }
      }
      
      public function flipFacing(param1:Boolean) : void
      {
         var _loc2_:TileRect = null;
         if(this.localLength != this.localWidth)
         {
            if(param1)
            {
               _loc2_ = this.rect;
               this.setPosFromTileRect(_loc2_.flip());
               return;
            }
         }
         this.facing = this._facing.flip as BattleFacing;
      }
      
      public function get collidable() : Boolean
      {
         return this._collidable;
      }
      
      public function set collidable(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._collidable != param1)
         {
            this._collidable = param1;
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.COLLIDABLE,this));
         }
      }
      
      public function get tiles() : Tiles
      {
         return !!this._board ? this._board.tiles : null;
      }
      
      public function get isTeleporting() : Boolean
      {
         return this._isTeleporting;
      }
      
      public function set isTeleporting(param1:Boolean) : void
      {
         var _loc2_:Boolean = this._isTeleporting && !param1;
         this._isTeleporting = param1;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.TELEPORTING,this));
         if(_loc2_)
         {
            this._board.triggers.checkTriggers(this,this.rect,true);
         }
      }
      
      private function executeEntityPassives() : void
      {
         var _loc4_:int = 0;
         var _loc5_:IAbilityDefLevel = null;
         var _loc6_:IBattleAbilityDef = null;
         var _loc1_:BattleBoard = this._board as BattleBoard;
         if(!_loc1_)
         {
            return;
         }
         var _loc3_:IAbilityDefLevels = _def.passives;
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numAbilities)
            {
               _loc5_ = _loc3_.getAbilityDefLevel(_loc4_);
               _loc6_ = _loc5_.def as IBattleAbilityDef;
               if(_loc5_.level > 0)
               {
                  _loc6_ = _loc6_.getBattleAbilityDefLevel(_loc5_.level);
                  this.executeEntityAbilityDef(_loc6_);
                  ++this._entityPassives;
               }
               else
               {
                  this.logger.info("BattleEntity SKIP PASSIVE [" + _loc6_.id + "]");
               }
               _loc4_++;
            }
         }
      }
      
      public function postLoad() : void
      {
         var _loc1_:IBattleAbilityDef = null;
         if(this._postLoadedEntity)
         {
            throw new IllegalOperationError("double postLoad");
         }
         this._postLoadedEntity = true;
         if(!this._deferredExecuteEntityAbilityDefs)
         {
            return;
         }
         for each(_loc1_ in this._deferredExecuteEntityAbilityDefs)
         {
            this.executeEntityAbilityDef(_loc1_);
         }
         this._deferredExecuteEntityAbilityDefs = null;
      }
      
      public function executeEntityAbilityDef(param1:IBattleAbilityDef) : void
      {
         var _loc2_:BattleBoard = null;
         var _loc3_:IBattleAbilityManager = null;
         var _loc4_:BattleAbility = null;
         if(param1)
         {
            _loc2_ = this._board as BattleBoard;
            if(!_loc2_.isPostLoaded)
            {
               if(!this._deferredExecuteEntityAbilityDefs)
               {
                  this._deferredExecuteEntityAbilityDefs = new Vector.<IBattleAbilityDef>();
               }
               this._deferredExecuteEntityAbilityDefs.push(param1);
               return;
            }
            _loc3_ = _loc2_._abilityManager;
            _loc4_ = new BattleAbility(this,param1,_loc3_);
            _loc4_.execute(null);
         }
      }
      
      public function executeEntityAbilityId(param1:String, param2:int) : void
      {
         var _loc3_:BattleBoard = this._board as BattleBoard;
         var _loc4_:IBattleAbilityManager = _loc3_._abilityManager;
         var _loc5_:IBattleAbilityDef = _loc4_.getFactory.fetchIBattleAbilityDef(param1);
         var _loc6_:IBattleAbilityDef = _loc5_.getBattleAbilityDefLevel(param2);
         this.executeEntityAbilityDef(_loc6_);
      }
      
      private function temporaryCharacterCtor() : void
      {
         var _loc3_:EffectTag = null;
         var _loc4_:int = 0;
         var _loc5_:BattleAbilityDef = null;
         var _loc6_:BattleAbility = null;
         this._effects = new PersistedEffects(this,this.logger);
         if(_def.tags)
         {
            for each(_loc3_ in _def.tags)
            {
               this._effects.addTag(_loc3_);
            }
         }
         this._effects.addEventListener(PersistedEffectsEvent.CHANGED,this.effectsChangedHandler);
         var _loc1_:BattleBoard = this._board as BattleBoard;
         this._itemPassives = 0;
         if(_loc1_)
         {
            _loc1_.applyBoardPassives(this);
            if(item)
            {
               if(!Saga.instance || !Saga.instance.battleItemsDisabled)
               {
                  this._itemPassives += ItemApply.applyPassive(item,this);
                  ItemApply.applyStatMods(item,this);
               }
            }
            if(this.titleItem)
            {
               this._itemPassives += ItemApply.applyPassive(this.titleItem,this);
               ItemApply.applyStatMods(this.titleItem,this);
            }
            _loc4_ = stats.getValue(StatType.INJURY);
            if(_loc4_)
            {
               _loc5_ = _loc1_.abilityManager.getFactory.fetch("pas_injury") as BattleAbilityDef;
               _loc6_ = new BattleAbility(this,_loc5_,_loc1_.abilityManager);
               _loc6_.execute(null);
            }
         }
         this.armstat = stats.getStat(StatType.ARMOR,false);
         if(this.armstat)
         {
            this.armstat.addEventListener(StatEvent.CHANGE,this.armorChangeHandler);
         }
      }
      
      override public function set entityItem(param1:Item) : void
      {
         if(param1 != _entityItem)
         {
            _entityItem = param1;
            if(param1)
            {
               ItemApply.apply(param1,this);
            }
         }
      }
      
      override public function get titleItem() : Item
      {
         var _loc1_:ItemDef = null;
         if(_titleItem)
         {
            return _titleItem;
         }
         if(_def.defTitle && stats.titleRank > 0)
         {
            _loc1_ = _def.defTitle.getRank(stats.titleRank - 1);
            if(_loc1_)
            {
               _titleItem = new Item();
               _titleItem.id = Item.createName(_loc1_.id,0);
               _titleItem.def = _loc1_;
               _titleItem.defid = _loc1_.id;
               return _titleItem;
            }
         }
         return null;
      }
      
      override public function set titleItem(param1:Item) : void
      {
         if(param1 != _titleItem)
         {
            _titleItem = param1;
            if(param1)
            {
               ItemApply.apply(param1,this);
            }
         }
      }
      
      private function effectsChangedHandler(param1:PersistedEffectsEvent) : void
      {
         this._lightStepping = this._effects.hasTag(EffectTag.LIGHT_STEPPING);
         this._kingStepping = this._effects.hasTag(EffectTag.KING_STEPPING);
      }
      
      public function cleanupTemporaryCharacter() : void
      {
         if(this.armstat)
         {
            this.armstat.removeEventListener(StatEvent.CHANGE,this.armorChangeHandler);
            this.armstat = null;
         }
         this._effects.removeEventListener(PersistedEffectsEvent.CHANGED,this.effectsChangedHandler);
         this._effects.cleanup();
         this._effects = null;
      }
      
      protected function strengthChangeHandler(param1:StatEvent) : void
      {
         if(cleanedup)
         {
            return;
         }
         var _loc2_:Stat = stats.getStat(StatType.STRENGTH);
         if(_loc2_.base < _loc2_.original && param1.delta < 0)
         {
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.DAMAGED,this));
         }
         if(_loc2_.value <= 0)
         {
            this.alive = false;
         }
      }
      
      protected function armorChangeHandler(param1:StatEvent) : void
      {
         if(!this.armstat)
         {
            return;
         }
         if(this.armstat.base < this.armstat.original && param1.delta < 0)
         {
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.DAMAGED,this));
         }
      }
      
      public function get triggering() : Boolean
      {
         return this._triggering;
      }
      
      public function set triggering(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._triggering != param1)
         {
            this._triggering = param1;
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.TRIGGERING,this));
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._selected == param1)
         {
            return;
         }
         this._selected = param1;
         if(!_cleanedup)
         {
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.SELECTED,this));
            this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.SELECTED,this));
         }
      }
      
      public function get targeted() : Boolean
      {
         return this._targeted;
      }
      
      public function set targeted(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._targeted != param1)
         {
            this._targeted = param1;
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.TARGETED,this));
         }
      }
      
      public function get effects() : IPersistedEffects
      {
         return this._effects;
      }
      
      public function hasTag(param1:EffectTag) : Boolean
      {
         if(this._effects)
         {
            return this._effects.hasTag(param1);
         }
         return false;
      }
      
      public function setTeamOverride(param1:String) : void
      {
         this._teamOverride = param1;
      }
      
      public function get team() : String
      {
         if(this._teamOverride)
         {
            return this._teamOverride;
         }
         return !!this.party ? this.party.team : null;
      }
      
      public function onTurnChanged() : void
      {
         this.mobility.moved = false;
         if(this._effects)
         {
            this._effects.clearTag(EffectTag.KNOCKBACK_SOMEWHERE);
            this._effects.clearTag(EffectTag.MOVED_THIS_TURN);
            this._effects.clearTag(EffectTag.RANAWAY);
            this._effects.clearTag(EffectTag.SPECIAL_PUNCTURE_BONUS);
            this._effects.clearTag(EffectTag.BLOODY_FLAIL_STR_DAMAGE);
            this._effects.handleTurnChanged();
         }
         if(stats.hasStat(StatType.MISS_CHANCE_OVERRIDE))
         {
            stats.setBase(StatType.MISS_CHANCE_OVERRIDE,0);
         }
         if(stats.hasStat(StatType.RUNTHROUGH_DISTANCE))
         {
            stats.setBase(StatType.RUNTHROUGH_DISTANCE,0);
         }
         if(stats.hasStat(StatType.KNOCKBACK_DEFERRED))
         {
            stats.removeStat(StatType.KNOCKBACK_DEFERRED);
         }
         this.computeIncorporealFade();
      }
      
      public function onStartTurn() : void
      {
         this.checkPulsingTriggers();
         if(!this.alive || cleanedup)
         {
            return;
         }
         this._effects.handleStartTurn();
      }
      
      public function onEndTurn() : void
      {
         if(cleanedup)
         {
            return;
         }
         this.hovering = false;
         this.handleTurnRegen();
         if(this._effects)
         {
            this._effects.handleEndTurn();
         }
         if(this._party && this._party.isPlayer && this._board && this._board._waves)
         {
            this._board._waves.handlePlayerTurnEnd();
         }
      }
      
      private function handleTurnRegen() : void
      {
         var _loc3_:TalentDef = null;
         var _loc4_:TalentDef = null;
         var _loc5_:TalentRankDef = null;
         var _loc6_:Stat = null;
         var _loc7_:int = 0;
         var _loc8_:Stat = null;
         var _loc9_:int = 0;
         var _loc11_:Stat = null;
         var _loc12_:int = 0;
         if(!this.alive)
         {
            return;
         }
         var _loc1_:int = stats.getValue(StatType.REGEN_WILLPOWER);
         var _loc2_:int = stats.getValue(StatType.REGEN_ARMOR);
         var _loc10_:int = stats.getValue(StatType.REGEN_STR);
         if(this._bonusedTalents)
         {
            this._bonusedTalents.generateTalentResults(StatType.REGEN_ARMOR,this.board.abilityManager.rng,this._talentRankResults);
            for each(_loc5_ in this._talentRankResults)
            {
               _loc2_ += _loc5_.value;
               _loc3_ = _loc5_.talentDef;
            }
            this._bonusedTalents.generateTalentResults(StatType.REGEN_WILLPOWER,this.board.abilityManager.rng,this._talentRankResults);
            for each(_loc5_ in this._talentRankResults)
            {
               _loc1_ += _loc5_.value;
               _loc4_ = _loc5_.talentDef;
            }
         }
         if(_loc1_)
         {
            _loc6_ = stats.getStat(StatType.WILLPOWER);
            _loc7_ = Math.max(0,Math.min(_loc6_.base + _loc1_,Math.max(_loc6_.base,_loc6_.original)));
            if(_loc7_ != _loc6_.base)
            {
               _loc6_.base = _loc7_;
               if(_loc4_)
               {
                  this.handleTalent(_loc4_);
               }
            }
         }
         if(_loc2_)
         {
            _loc8_ = stats.getStat(StatType.ARMOR);
            _loc9_ = Math.max(0,Math.min(_loc8_.base + _loc2_,_loc8_.original));
            if(_loc9_ != _loc8_.base)
            {
               _loc8_.base = _loc9_;
               if(_loc3_)
               {
                  this.handleTalent(_loc3_);
               }
            }
         }
         if(_loc10_)
         {
            _loc11_ = stats.getStat(StatType.STRENGTH);
            _loc12_ = Math.max(0,_loc11_.base + _loc10_);
            if(_loc12_ != _loc11_.base)
            {
               _loc11_.base = _loc12_;
            }
         }
      }
      
      protected function checkPulsingTriggers() : void
      {
         if(this.board.boardSetup)
         {
            this.board.triggers.checkPulsingTriggers(this,this.rect);
         }
      }
      
      public function endTurn(param1:Boolean, param2:String, param3:Boolean) : void
      {
         if(cleanedup)
         {
            throw new IllegalOperationError("Cannot end turn on a cleaned up entity");
         }
         if(fake)
         {
            return;
         }
         var _loc4_:IBattleTurn = this._board && this._board.fsm ? this._board.fsm.turn : null;
         var _loc5_:IBattleEntity = !!_loc4_ ? _loc4_.entity : null;
         if(_loc5_ != this)
         {
            this.logger.info("BattleEntity.endTurn not your turn: " + this);
            return;
         }
         var _loc6_:State = this._board.fsm.current;
         var _loc7_:BattleStateTurnLocalBase = _loc6_ as BattleStateTurnLocalBase;
         if(_loc7_)
         {
            _loc7_.skip(param1,"BattleEntity.endTurn " + param2,param3);
         }
         else
         {
            this.logger.info("BattleEntity.endTurn wrong state [" + _loc6_ + "] for " + this);
         }
      }
      
      public function setTurnSuspended(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         var _loc2_:BattleBoard = this._board as BattleBoard;
         var _loc3_:IBattleTurn = !!_loc2_ ? _loc2_.fsm.turn : null;
         if(_loc3_)
         {
            if(_loc3_.entity == this)
            {
               _loc3_.suspended = true;
            }
            else
            {
               this.logger.info("BattleEntity.setTurnSuspended " + this + " suspend=" + param1 + " is NOT THE TURN ENTITY");
            }
         }
      }
      
      public function createChainForEffect(param1:IEffect) : IChainPhantasms
      {
         if(fake)
         {
            return null;
         }
         var _loc2_:BattleBoard = this._board as BattleBoard;
         if(_loc2_)
         {
            return _loc2_.phantasms.createChainForEffect(param1 as Effect);
         }
         return null;
      }
      
      public function get record() : BattleRecord
      {
         return !!this._fakeRecord ? this._fakeRecord : this._record;
      }
      
      public function get alive() : Boolean
      {
         return this._alive;
      }
      
      public function set alive(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(fake)
         {
            return;
         }
         if(cleanedup)
         {
            return;
         }
         if(this._alive != param1)
         {
            if(this.logger.isDebugEnabled)
            {
               _loc2_ = stats.getValue(StatType.WILLPOWER);
               this.logger.debug("BattleEntity.alive " + this + " " + param1 + " with willpower " + _loc2_);
            }
            this._alive = param1;
            this.collidable = param1 && def.entityClass.collidable;
            if(!this._alive)
            {
               ++this._deathCount;
               if(this._deathCount == 1)
               {
                  this.computeKillRenown();
               }
            }
            if(cleanedup)
            {
               return;
            }
            if(!this.alive)
            {
               this._handleDeath_pre();
            }
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.ALIVE,this));
            if(!this._alive)
            {
               this._handleDeath();
            }
         }
      }
      
      public function set skipInjury(param1:Boolean) : void
      {
         this._skipInjury = param1;
      }
      
      private function _handleDeath_pre() : void
      {
         var _loc2_:IPartyDef = null;
         var _loc3_:Item = null;
         if(cleanedup || !this._board || !this._board._scene)
         {
            return;
         }
         var _loc1_:SagaLegend = this.saga && this.saga.caravan ? this.saga.caravan._legend : null;
         if(this.isPlayer)
         {
            if(this.saga)
            {
               if(this.saga.def.survival)
               {
                  _loc2_ = this.saga.caravan._legend.party;
                  this.saga.injure(_def,true);
                  _loc2_.removeMember(def.id);
                  this.saga.caravan._legend.roster.sortEntities();
                  this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_SURVIVAL_DIED,this,null));
               }
               else if(!this._skipInjury)
               {
                  this.saga.injure(_def,false,this.stats);
               }
            }
         }
         else if(this.saga)
         {
            _loc3_ = item;
            if(_loc3_ && !this._effects.hasTag(EffectTag.UNPOSSESSABLE) && !this._effects.hasTag(EffectTag.WARPED_POSSESSED))
            {
               this._board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_SURVIVAL_ITEM,this,null));
               this.entityItem = null;
               this.saga.gainItem(_loc3_,true);
            }
         }
         this.diedThisTurn = true;
         this.mobility.stopMoving("BattleEntity._handleDeath");
      }
      
      private function _handleDeath() : void
      {
         if(cleanedup || !this._board || !this._board._scene || this._board.cleanedup)
         {
            return;
         }
         this.setBattleDamageFlagVisible(false,0);
         if(this._effects)
         {
            this._effects.handleTargetDeath();
         }
         if(this.playerControlled == true)
         {
            this.endTurn(true,"BattleEntity._handleDeath",false);
         }
      }
      
      public function get animEventDispatcher() : IEventDispatcher
      {
         return this;
      }
      
      public function get nonexistant() : Boolean
      {
         return !this.enabled || this.incorporeal && !visible;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.ENABLED,this));
         this._board.updateInfoBannerForEntity(this);
         if(this._battleInfoFlagVisible && this._board)
         {
            this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE,this));
         }
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         if(fake || _cleanedup)
         {
            return;
         }
         if(this._active == param1)
         {
            return;
         }
         this._active = param1;
         this.logger.info("BattleEntity.active [" + id + "] " + param1);
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.ACTIVE,this));
         this._board.updateInfoBannerForEntity(this);
         if(this._battleInfoFlagVisible && this._board)
         {
            this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE,this));
         }
      }
      
      public function get board() : IBattleBoard
      {
         return this._board;
      }
      
      public function set board(param1:IBattleBoard) : void
      {
         this._board = param1 as BattleBoard;
      }
      
      public function get party() : IBattleParty
      {
         return this._party;
      }
      
      public function set party(param1:IBattleParty) : void
      {
         this._party = param1;
      }
      
      public function get mobility() : IBattleEntityMobility
      {
         return this._mobility;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      private function computeKillRenown() : void
      {
         var _loc2_:int = 0;
         var _loc3_:BattleEntity = null;
         if(!this.mobile)
         {
            this._killRenown = 0;
            return;
         }
         var _loc1_:int = 1;
         if(REWARD_RENOWN_PER_RANK)
         {
            _loc1_ = Math.max(1,stats.rank - 1);
         }
         this._killRenown = _loc1_;
         if(this._spawnedCasterRenownLimit && this.mobile)
         {
            _loc2_ = this._killRenown - this.spawnedCasterRenownCount;
            this.logger.info("BattleEntity.computeKillRenown " + this + " limiting [" + this._killRenown + "] to remaining [" + _loc2_ + "]");
            this._killRenown = Math.min(_loc2_,this._killRenown);
            if(this._spawnedCaster)
            {
               _loc3_ = this._spawnedCaster as BattleEntity;
               _loc3_.deductSpawningRenown(this._killRenown);
            }
         }
      }
      
      private function deductSpawningRenown(param1:int) : void
      {
         this._spawningCasterRenownCount += param1;
         this.logger.info("BattleEntity.deductSpawningRenown " + this + " by " + param1 + " now " + this._spawningCasterRenownCount);
      }
      
      public function get killRenown() : int
      {
         return this._killRenown;
      }
      
      public function set spawnedCasterRenownLimit(param1:Boolean) : void
      {
         this._spawnedCasterRenownLimit = param1;
      }
      
      public function set spawnedCaster(param1:IBattleEntity) : void
      {
         this._spawnedCaster = param1;
      }
      
      public function get spawnedCasterRenownLimit() : Boolean
      {
         return this._spawnedCasterRenownLimit;
      }
      
      public function get spawnedCaster() : IBattleEntity
      {
         return this._spawnedCaster;
      }
      
      public function get spawningCasterRenownCount() : int
      {
         return this._spawningCasterRenownCount;
      }
      
      public function get spawnedCasterRenownCount() : int
      {
         if(this._spawnedCaster)
         {
            return this._spawnedCaster.spawningCasterRenownCount;
         }
         return 0;
      }
      
      public function set deploymentReady(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._deploymentReady != param1)
         {
            this._deploymentReady = param1;
            dispatchEvent(new BattleEntityEvent(BattleEntityEvent.DEPLOYMENT_READY,this));
            this.enabled = this.enabled || this._deploymentReady;
         }
      }
      
      public function get deploymentReady() : Boolean
      {
         return this._deploymentReady;
      }
      
      public function get deploymentFinalized() : Boolean
      {
         return this._deploymentFinalized;
      }
      
      public function set deploymentFinalized(param1:Boolean) : void
      {
         this._deploymentFinalized = param1;
      }
      
      public function get mobile() : Boolean
      {
         return _def.entityClass.mobile;
      }
      
      override public function get isPlayer() : Boolean
      {
         return this._party && this._party.isPlayer;
      }
      
      override public function get isEnemy() : Boolean
      {
         return this._party && this._party.isEnemy;
      }
      
      override public function get playerControlled() : Boolean
      {
         if(!this._party || !this._alive)
         {
            return false;
         }
         switch(this.party.type)
         {
            case BattlePartyType.REMOTE:
               return false;
            case BattlePartyType.LOCAL:
               return !BattleFsmConfig.playerAi;
            case BattlePartyType.AI:
               return !BattleFsmConfig.globalEnableAi && !this.board.isTutorialActive;
            default:
               throw new IllegalOperationError("no such type " + this.party.type);
         }
      }
      
      override public function update(param1:int) : void
      {
         var _loc4_:ColorPulsator = null;
         if(cleanedup)
         {
            throw new IllegalOperationError("cleanedup update!?");
         }
         super.update(param1);
         if(this._mobility)
         {
            this._mobility.update(param1);
         }
         if(this._effects)
         {
            this._effects.update(param1);
         }
         var _loc2_:uint = 16777215;
         var _loc3_:* = 1;
         if(this._pulsators)
         {
            for each(_loc4_ in this._pulsators)
            {
               if(_loc4_)
               {
                  _loc4_.update(param1);
                  _loc2_ = ColorUtil.multiply(_loc2_,_loc4_.color);
                  _loc3_ *= _loc4_.alpha;
               }
            }
            if(this._animController)
            {
               this._animController.color = _loc2_;
               this._animController.alpha = _loc3_;
            }
         }
         if(this._animController)
         {
            this._animController.update(param1);
         }
      }
      
      public function addColorPulsator(param1:ColorPulsatorDef) : String
      {
         if(!this._pulsators)
         {
            this._pulsators = new Vector.<ColorPulsator>();
            this._pulsatorsById = new Dictionary();
         }
         var _loc2_:ColorPulsator = new ColorPulsator(param1);
         this._pulsators.push(_loc2_);
         this._pulsatorsById[_loc2_.id] = _loc2_;
         return _loc2_.id;
      }
      
      public function removeColorPulsator(param1:String) : void
      {
         var _loc2_:ColorPulsator = null;
         var _loc3_:int = 0;
         if(this._pulsators)
         {
            _loc2_ = this._pulsatorsById[param1];
            delete this._pulsatorsById[param1];
            if(_loc2_)
            {
               _loc3_ = this._pulsators.indexOf(_loc2_);
               if(_loc3_ >= 0)
               {
                  this._pulsators.splice(_loc3_,1);
               }
               _loc2_.cleanup();
            }
            if(this._pulsators.length == 0)
            {
               this._pulsators = null;
               this._pulsatorsById = null;
               this._animController.color = 16777215;
               this._animController.alpha = 1;
            }
         }
      }
      
      public function handleTalent(param1:TalentDef) : void
      {
         dispatchEvent(new BattleEntityTalentEvent(this,param1));
      }
      
      public function handleKillStop(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.KILL_STOP,this));
      }
      
      public function handleTwiceBorn(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.TWICEBORN,this));
      }
      
      public function getSaga() : Saga
      {
         if(this.board && this.board.scene && this.board.scene.context)
         {
            return this.board.scene.context.saga as Saga;
         }
         return null;
      }
      
      public function handleMissed(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.MISSED,this));
      }
      
      public function handleResisted(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.RESISTED,this));
      }
      
      public function handleDiverted(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.DIVERTED,this));
      }
      
      public function handleDodge(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.DODGE,this));
      }
      
      public function handleCrit(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.CRIT,this));
      }
      
      public function handleAbsorbing(param1:IEffect) : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.ABSORBING,this));
      }
      
      public function get ignoreTargetRotation() : Boolean
      {
         return this._ignoreTargetRotation > 0 || this._length != this._width;
      }
      
      public function incrementIgnoreTargetRotation() : void
      {
         ++this._ignoreTargetRotation;
      }
      
      public function decrementIgnoreTargetRotation() : void
      {
         if(this._ignoreTargetRotation == 0)
         {
            throw new IllegalOperationError("Too many");
         }
         --this._ignoreTargetRotation;
      }
      
      public function get ignoreFacing() : Boolean
      {
         return this._ignoreFacing;
      }
      
      public function set ignoreFacing(param1:Boolean) : void
      {
         this._ignoreFacing = param1;
      }
      
      public function get ignoreFreezeFrame() : Boolean
      {
         return this._animController.ignoreFreezeFrame;
      }
      
      public function set ignoreFreezeFrame(param1:Boolean) : void
      {
         if(!this._animController)
         {
            return;
         }
         this._animController.ignoreFreezeFrame = param1;
      }
      
      public function get killingEffect() : IEffect
      {
         return this._killingEffect;
      }
      
      private function applyKillerResults(param1:IBattleEntity, param2:IBattleEntity) : void
      {
         var _loc3_:int = 0;
         if(!param1 || param1 == this)
         {
            return;
         }
         if(param1.alive)
         {
            _loc3_ = int(param1.stats.getValue(StatType.KILL_WILLPOWER));
            if(_loc3_)
            {
               param1.stats.getStat(StatType.WILLPOWER).base = param1.stats.getStat(StatType.WILLPOWER).base + _loc3_;
            }
            _loc3_ = int(param1.stats.getValue(StatType.KILL_STR));
            if(_loc3_)
            {
               param1.stats.getStat(StatType.STRENGTH).base = param1.stats.getStat(StatType.STRENGTH).base + _loc3_;
            }
         }
         if(param1.isPlayer)
         {
            if(this.saga)
            {
               if(this.saga.caravan)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("BattleEntity.applyKillerResults for player " + param1 + " KILLED " + param2);
                  }
                  SagaAchievements.handlePlayerKill(param1);
                  this.saga.caravan.vars.incrementVar("tot_kills",1);
                  if(this.saga.inTrainingBattle)
                  {
                     if(this.saga.getVarBool(SagaVar.VAR_TRAINING_SPARRING))
                     {
                        this.saga.caravan.vars.incrementVar("tot_kills_sparring",1);
                     }
                     if(this.saga.getVarBool(SagaVar.VAR_TRAINING_SCENARIO))
                     {
                        this.saga.caravan.vars.incrementVar("tot_kills_challenge",1);
                     }
                  }
               }
               if(this.saga.isSurvival)
               {
                  this.saga.incrementGlobalVar("survival_win_kills_num",1);
               }
            }
         }
      }
      
      public function resetKillingEffect() : void
      {
         this._killingEffect = null;
      }
      
      public function set killingEffect(param1:IEffect) : void
      {
         var _loc2_:IBattleAbility = null;
         var _loc3_:IBattleEntity = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:IBattleEntity = null;
         if(this._killingEffect)
         {
            return;
         }
         this._killingEffect = param1 as Effect;
         if(_cleanedup)
         {
            return;
         }
         if(this._killingEffect)
         {
            _loc2_ = this._killingEffect.ability;
            _loc3_ = _loc2_.caster;
            _loc4_ = _loc2_.root.caster;
            _loc5_ = this._killingEffect.target;
            if(_loc5_ && _loc5_.mobile)
            {
               this.applyKillerResults(_loc3_,_loc5_);
               if(_loc4_ != _loc3_ && _loc5_)
               {
                  this.applyKillerResults(_loc4_,_loc5_);
               }
            }
         }
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.KILLING_EFFECT,this));
      }
      
      public function highestAvailableAbilityDef(param1:String) : IBattleAbilityDef
      {
         var _loc6_:IBattleAbilityDef = null;
         var _loc7_:BattleAbilityDef = null;
         var _loc8_:int = 0;
         var _loc2_:IAbilityDefLevel = !!def.actives ? def.actives.getAbilityDefLevelById(param1) : null;
         if(!_loc2_)
         {
            _loc6_ = this.saga.abilityFactory.fetchBattleAbilityDef(param1,false);
            if(_loc6_ && _loc6_.artifactChargeCost > 0)
            {
               return _loc6_;
            }
            return null;
         }
         var _loc3_:int = stats.getValue(StatType.WILLPOWER);
         var _loc4_:int = Math.min(_loc2_.level,_loc2_.def.maxLevel);
         var _loc5_:* = _loc4_;
         while(_loc5_ >= 1)
         {
            _loc7_ = _loc2_.def.getAbilityDefForLevel(_loc5_) as BattleAbilityDef;
            if(_loc7_)
            {
               _loc8_ = _loc7_.getCost(StatType.WILLPOWER);
               if(_loc8_ <= _loc3_)
               {
                  return _loc7_;
               }
            }
            _loc5_--;
         }
         return null;
      }
      
      public function lowestValidAbilityDef(param1:String, param2:IBattleEntity, param3:Tile, param4:IBattleMove) : IBattleAbilityDef
      {
         var _loc8_:IBattleAbilityDef = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:BattleAbilityValidation = null;
         var _loc5_:BattleAbilityDef = this.highestAvailableAbilityDef(param1) as BattleAbilityDef;
         if(!_loc5_)
         {
            return null;
         }
         var _loc6_:* = _loc5_.level;
         var _loc7_:int = 1;
         while(_loc7_ <= _loc6_)
         {
            _loc8_ = _loc5_.getBattleAbilityDefLevel(_loc7_);
            _loc9_ = true;
            _loc10_ = true;
            _loc11_ = BattleAbilityValidation.validate(_loc8_,this,param4 as BattleMove,param2,param3,_loc9_,_loc10_,true);
            if(_loc11_ == BattleAbilityValidation.OK)
            {
               return _loc8_;
            }
            _loc7_++;
         }
         return null;
      }
      
      public function lowestValidAbilityDefForTargetCount(param1:String, param2:IBattleMove, param3:BattleTargetSet) : IBattleAbilityDef
      {
         var _loc11_:BattleAbilityValidation = null;
         var _loc14_:IBattleAbilityDef = null;
         var _loc15_:Tile = null;
         var _loc16_:IBattleEntity = null;
         var _loc4_:BattleAbilityDef = this.highestAvailableAbilityDef(param1) as BattleAbilityDef;
         if(!_loc4_)
         {
            this.logger.error("No such highest def?");
            return null;
         }
         var _loc5_:* = _loc4_.level;
         var _loc6_:int = int(param3.targets.length);
         var _loc7_:int = int(param3.tiles.length);
         var _loc8_:Boolean = _loc4_.targetRule.isTile;
         var _loc12_:Boolean = false;
         var _loc13_:int = 1;
         while(true)
         {
            if(_loc13_ > _loc5_)
            {
               return null;
            }
            _loc14_ = _loc4_.getBattleAbilityDefLevel(_loc13_);
            _loc12_ = false;
            if(_loc8_)
            {
               if(_loc14_.targetCount >= _loc7_)
               {
                  for each(_loc15_ in param3.tiles)
                  {
                     _loc11_ = BattleAbilityValidation.validate(_loc14_,this,param2 as BattleMove,null,_loc15_,true,true,true);
                     if(_loc11_ != BattleAbilityValidation.OK)
                     {
                        _loc12_ = true;
                        break;
                     }
                  }
                  if(!_loc12_)
                  {
                     break;
                  }
               }
            }
            if(!_loc8_)
            {
               if(_loc14_.targetCount >= _loc6_ || _loc14_.conditions && _loc14_.conditions.maximumEnemies && _loc14_.conditions.maximumEnemies >= _loc6_)
               {
                  for each(_loc16_ in param3.targets)
                  {
                     _loc11_ = BattleAbilityValidation.validate(_loc14_,this,param2 as BattleMove,_loc16_,null,true,true,true);
                     if(_loc11_ != BattleAbilityValidation.OK)
                     {
                        _loc12_ = true;
                        break;
                     }
                  }
                  if(!_loc12_)
                  {
                     return _loc14_;
                  }
               }
            }
            _loc13_++;
         }
         return _loc14_;
      }
      
      public function expireDeadEntitiesEffects() : void
      {
         if(this._effects && this.diedThisTurn)
         {
            this.diedThisTurn = false;
            this.effects.handleEndTurn();
         }
      }
      
      public function get x() : Number
      {
         return this.pos.x;
      }
      
      public function get y() : Number
      {
         return this.pos.y;
      }
      
      public function canPass(param1:ITileResident) : Boolean
      {
         if(param1 == this)
         {
            return true;
         }
         if(this._hasSubmergedMove)
         {
            return true;
         }
         if(this._incorporeal)
         {
            return true;
         }
         var _loc2_:BattleEntity = param1 as BattleEntity;
         if(!_loc2_)
         {
            return true;
         }
         if(_loc2_._incorporeal)
         {
            return true;
         }
         if(!this.awareOf(_loc2_))
         {
            return true;
         }
         if(this.team == _loc2_.team && this._lightStepping)
         {
            return true;
         }
         if(this.team == _loc2_.team && this._kingStepping)
         {
            if(_loc2_.effects && _loc2_.effects.hasTag(EffectTag.KING_STEPPABLE))
            {
               return true;
            }
         }
         if(_loc2_.traversable && this.team != _loc2_.team)
         {
            return true;
         }
         return false;
      }
      
      public function awareOf(param1:ITileResident) : Boolean
      {
         if(param1 == this)
         {
            return true;
         }
         var _loc2_:BattleEntity = param1 as BattleEntity;
         if(!_loc2_ || !_loc2_._enabled || !_loc2_._active)
         {
            return true;
         }
         if(_loc2_._visible)
         {
            return true;
         }
         if(this._party && _loc2_._party)
         {
            if(this._party == _loc2_._party)
            {
               return true;
            }
            if(this._party.team == _loc2_._party.team)
            {
               return true;
            }
         }
         return false;
      }
      
      public function set forceCameraCenter(param1:Boolean) : void
      {
         if(param1 == this._forceCameraCenter)
         {
            return;
         }
         this._forceCameraCenter = param1;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.FORCE_CAMERA_CENTER,this));
      }
      
      public function get forceCameraCenter() : Boolean
      {
         return this._forceCameraCenter;
      }
      
      public function set hovering(param1:Boolean) : void
      {
         if(this._hovering == param1)
         {
            return;
         }
         this._hovering = param1;
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.HOVERING,this));
         this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.HOVERING,this));
         this._board.updateInfoBannerForEntity(this);
      }
      
      public function get hovering() : Boolean
      {
         return this._hovering;
      }
      
      public function get traversable() : Boolean
      {
         return this._traversable;
      }
      
      public function set traversable(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._traversable != param1)
         {
            this._traversable = param1;
            this.logger.info("BattleEntity.traversable " + this + " = " + param1);
         }
      }
      
      public function get incorporeal() : Boolean
      {
         return this._incorporeal;
      }
      
      public function set incorporeal(param1:Boolean) : void
      {
         if(fake)
         {
            return;
         }
         if(this._incorporeal != param1)
         {
            this._incorporeal = param1;
            this.logger.info("BattleEntity.incorporeal " + this + " = " + param1);
            this._board.recomputeIncorporealFades();
         }
      }
      
      public function get includeVitality() : Boolean
      {
         return this._includeVitality;
      }
      
      public function get suppressFlytext() : Boolean
      {
         return this._suppressFlytext;
      }
      
      public function set suppressFlytext(param1:Boolean) : void
      {
         this._suppressFlytext = param1;
      }
      
      public function get bonusRenown() : int
      {
         return this._bonusRenown;
      }
      
      public function set bonusRenown(param1:int) : void
      {
         var _loc2_:* = this._bonusRenown;
         this._bonusRenown = param1;
         var _loc3_:int = this._bonusRenown - _loc2_;
         this._unconsumedBonusRenown += _loc3_;
         if(this.party)
         {
            this.party.bonusRenown += _loc3_;
         }
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BONUS_RENOWN,this));
         if(this._board)
         {
            this._board.handleBonusRenown(this);
         }
      }
      
      public function consumeBonusRenown() : int
      {
         var _loc1_:* = this._unconsumedBonusRenown;
         this._unconsumedBonusRenown = 0;
         return _loc1_;
      }
      
      public function get battleInfoFlagVisible() : Boolean
      {
         return this._battleInfoFlagVisible;
      }
      
      public function set battleInfoFlagVisible(param1:Boolean) : void
      {
         if(this._battleInfoFlagVisible != param1)
         {
            this._battleInfoFlagVisible = param1;
            this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE,this));
         }
      }
      
      public function get battleDamageFlagVisible() : Boolean
      {
         return this._battleDamageFlagVisible;
      }
      
      public function setBattleDamageFlagVisible(param1:Boolean, param2:int) : void
      {
         param1 = param1 && this._alive;
         if(this._battleDamageFlagValue != param2)
         {
            this._battleDamageFlagValue = param2;
            this.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VALUE,this));
         }
         if(this._battleDamageFlagVisible != param1)
         {
            this._battleDamageFlagVisible = param1;
            this.board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VISIBLE,this));
         }
      }
      
      public function get battleDamageFlagValue() : int
      {
         return this._battleDamageFlagValue;
      }
      
      public function centerCameraOnEntity() : void
      {
         if(this.board)
         {
            this.board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.CAMERA_CENTER,this));
         }
      }
      
      override protected function handleSetVisible() : void
      {
         this.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.VISIBLE,this));
         if(this._board)
         {
            this._board.updateInfoBannerForEntity(this);
            if(this._battleInfoFlagVisible)
            {
               this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE,this));
            }
            if(this._battleDamageFlagVisible)
            {
               this._board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VISIBLE,this));
            }
         }
      }
      
      override protected function handleFlashVisible() : void
      {
         this.logger.info("BattleEntity.handleFlashVisible " + this + " visible=" + _visible + " fade=" + _visibleFadeMs);
         this.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.FLASH_VISIBLE,this));
      }
      
      public function notifyCollision(param1:IBattleEntity) : void
      {
         if(!param1)
         {
            return;
         }
         if(this._board && this._board.hasEventListener(BattleBoardEvent.BOARD_ENTITY_COLLIDED))
         {
            this._board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_COLLIDED,this,param1));
         }
         if(this.hasEventListener(BattleEntityEvent.COLLISION))
         {
            this.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.COLLISION,this,param1 as BattleEntity));
         }
         if(param1.hasEventListener(BattleEntityEvent.COLLISION))
         {
            param1.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.COLLISION,this,param1 as BattleEntity));
         }
      }
      
      public function faceTile(param1:Tile, param2:Tile) : Point
      {
         var _loc3_:Point = new Point(param2.x - param1.x,param2.y - param1.y);
         this.facing = BattleFacing.findFacing(_loc3_.x,_loc3_.y);
         return _loc3_;
      }
      
      private function printFlag(param1:Boolean, param2:String) : String
      {
         if(param1)
         {
            return "  " + param2;
         }
         return " !" + param2.toLowerCase();
      }
      
      public function getSummaryLine() : String
      {
         var _loc1_:Tile = this.tile;
         var _loc2_:int = stats.rank;
         return StringUtil.padLeft(id," ",30) + "  R " + StringUtil.padLeft(_loc2_.toString()," ",2) + this.printFlag(this._enabled,"ABL") + this.printFlag(this._active,"ACT") + this.printFlag(this._alive,"ALIVE") + this.printFlag(_visible,"VIS") + this.printFlag(this._collidable,"COL") + this.printFlag(this._traversable,"TRV") + this.printFlag(this._incorporeal,"INC") + this.printFlag(_def.isInjured,"INJ") + " @" + (!!_loc1_ ? _loc1_.location.toString() : "null");
      }
      
      public function getDebugInfo() : String
      {
         var _loc2_:int = 0;
         var _loc3_:IAbilityDefLevel = null;
         var _loc4_:Stat = null;
         var _loc5_:String = null;
         var _loc6_:IEffect = null;
         var _loc7_:* = null;
         var _loc1_:* = this.getSummaryLine() + "\n";
         _loc1_ += "   " + StringUtil.padRight("STATS: "," ",30) + "  val" + " base" + "  mod" + " orig" + "\n";
         _loc2_ = 0;
         while(_loc2_ < stats.numStats)
         {
            _loc4_ = stats.getStatByIndex(_loc2_);
            _loc1_ += "   " + StringUtil.padRight(_loc4_.type.name," ",30) + StringUtil.padLeft(_loc4_.value.toString()," ",5) + StringUtil.padLeft(_loc4_.base.toString()," ",5) + StringUtil.padLeft(!!_loc4_.modDelta ? StringUtil.numberWithSign(_loc4_.modDelta,0) : ""," ",5) + StringUtil.padLeft(_loc4_.original.toString()," ",5) + "\n";
            _loc5_ = _loc4_.getDebugStringMods("            ");
            if(_loc5_)
            {
               _loc1_ += _loc5_;
            }
            _loc2_++;
         }
         _loc1_ += "EFFECTS:\n";
         if(this.effects)
         {
            _loc1_ += "  TAGS: " + this.effects.getDebugTagInfo() + "\n";
            for each(_loc6_ in this.effects.effects)
            {
               _loc1_ += "  " + StringUtil.padRight(_loc6_.phase.name," ",12);
               _loc1_ += "  " + _loc6_ + "\n";
               _loc1_ += "    ABILITY: " + _loc6_.ability + "\n";
               if(_loc6_.tags)
               {
                  _loc1_ += "    TAGS: ";
                  for(_loc7_ in _loc6_.tags)
                  {
                     _loc1_ += _loc7_ + " ";
                  }
                  _loc1_ += "\n";
               }
            }
         }
         if(def.passives && def.passives.numAbilities)
         {
            _loc1_ += "PASSIVES:\n";
            _loc2_ = 0;
            while(_loc2_ < def.passives.numAbilities)
            {
               _loc3_ = def.passives.getAbilityDefLevel(_loc2_);
               _loc1_ += "  " + _loc3_ + "\n";
               _loc2_++;
            }
         }
         if(def.actives && def.actives.numAbilities)
         {
            _loc1_ += "ACTIVES:\n";
            _loc2_ = 0;
            while(_loc2_ < def.actives.numAbilities)
            {
               _loc3_ = def.actives.getAbilityDefLevel(_loc2_);
               _loc1_ += "  " + _loc3_ + "\n";
               _loc2_++;
            }
         }
         if(item)
         {
            _loc1_ += "ITEM:\n   " + item;
            if(Saga.instance && Saga.instance.battleItemsDisabled)
            {
               _loc1_ += " (SAGA DISABLED)";
            }
            _loc1_ += "\n";
         }
         return _loc1_;
      }
      
      public function get freeTurns() : int
      {
         return this._freeTurns;
      }
      
      public function set freeTurns(param1:int) : void
      {
         this._freeTurns = param1;
      }
      
      public function findFacingRect(param1:TileRect, param2:Boolean) : TileRect
      {
         var _loc4_:BattleFacing = null;
         var _loc3_:TileRect = this.rect;
         if(this._width == this._length)
         {
            _loc4_ = BattleFacing.findFacing(param1.center.x - _loc3_.center.x,param1.center.y - _loc3_.center.y);
            if(param2)
            {
               _loc4_ = _loc4_.flip as BattleFacing;
            }
            if(_loc4_ != _loc3_.facing)
            {
               _loc3_ = _loc3_.clone();
               _loc3_.facing = _loc4_;
            }
            return _loc3_;
         }
         if(!_loc3_.facing)
         {
            return _loc3_;
         }
         var _loc5_:* = Math.abs(param1.center.x - _loc3_.center.x) + Math.abs(param1.center.y - _loc3_.center.y);
         var _loc6_:TileRect = _loc3_.flip(null);
         var _loc7_:* = Math.abs(param1.center.x - _loc6_.center.x) + Math.abs(param1.center.y - _loc6_.center.y);
         if(!param2 && _loc5_ < _loc7_ || param2 && _loc5_ > _loc7_)
         {
            return _loc3_;
         }
         return _loc6_;
      }
      
      public function turnToFace(param1:TileRect, param2:Boolean) : void
      {
         var _loc3_:TileRect = this.findFacingRect(param1,param2);
         if(_loc3_ && !_loc3_.equals(this.rect))
         {
            this.setPosFromTileRect(_loc3_);
         }
      }
      
      public function get attackable() : Boolean
      {
         return this._attackable && this._defAttackable && !this._incorporeal;
      }
      
      public function get usable() : Boolean
      {
         return this._usability && this._usability.enabled;
      }
      
      public function set attackable(param1:Boolean) : void
      {
         this._attackable = param1;
      }
      
      public function set usable(param1:Boolean) : void
      {
         if(this._usability)
         {
            this._usability.enabled = param1;
         }
      }
      
      private function _checkUsabilitySetup() : void
      {
         if(!this._board || _cleanedup)
         {
            return;
         }
         if(this.usable)
         {
            if(!this._effects)
            {
               this.temporaryCharacterCtor();
            }
         }
      }
      
      private function _makeLocalUsability() : void
      {
         if(!this._board || _cleanedup)
         {
            return;
         }
         var _loc1_:UsabilityDef = !!this._usabilityDef ? this._usabilityDef : this._defUsabilityDef;
         if(this._usability && this._usability.def != _loc1_)
         {
            this._usability.cleanup();
            this._usability = null;
         }
         if(!this._usability && _loc1_)
         {
            this._usability = new Usability(this,_loc1_,this._board.abilityFactory,this.logger);
         }
      }
      
      public function get interactable() : Boolean
      {
         return this.usable || this.attackable;
      }
      
      public function canAttack(param1:IBattleEntity) : Boolean
      {
         return this._attackable && param1 && param1.team != this.team && param1.attackable;
      }
      
      public function get bonusedTalents() : BonusedTalents
      {
         return this._bonusedTalents;
      }
      
      public function get resourceGroup() : ResourceGroup
      {
         return !!this._board ? this._board.resourceGroup : null;
      }
      
      public function get deathCount() : int
      {
         return this._deathCount;
      }
      
      public function get animController() : AnimController
      {
         return this._animController;
      }
      
      public function get soundController() : SoundController
      {
         return this._soundController;
      }
      
      public function get flyText() : String
      {
         return this._flyText;
      }
      
      public function get flyTextColor() : uint
      {
         return this._flyTextColor;
      }
      
      public function get flyTextFontName() : String
      {
         return this._flyTextFontName;
      }
      
      public function get flyTextFontSize() : int
      {
         return this._flyTextFontSize;
      }
      
      public function get deathAnim() : String
      {
         return this._deathAnim;
      }
      
      public function get deathVocalization() : String
      {
         return this._deathVocalization;
      }
      
      public function handleUsed(param1:IBattleEntity) : void
      {
         if(!this._usability)
         {
            return;
         }
         if(!this._usabilityExecutor)
         {
            this._usabilityExecutor = new UsabilityExecutor(this,this.logger);
         }
         this._usabilityExecutor.execute(param1);
      }
      
      public function get usability() : Usability
      {
         return this._usability;
      }
      
      public function get usabilityDef() : UsabilityDef
      {
         return this._usabilityDef;
      }
      
      public function set usabilityDef(param1:UsabilityDef) : void
      {
         this._usabilityDef = param1;
         this._makeLocalUsability();
         this._checkUsabilitySetup();
      }
      
      public function discoverAttractor() : IBattleAttractor
      {
         if(this._attractor)
         {
            if(this._attractor.enabled)
            {
               return this._attractor;
            }
            this.attractor = null;
         }
         if(this._board._attractors)
         {
            this.attractor = this._board._attractors.findClosestValidAttractor(this);
         }
         return this._attractor;
      }
      
      public function set attractorCoreReached(param1:Boolean) : void
      {
         this._attractorCoreReached = param1;
      }
      
      public function get attractorCoreReached() : Boolean
      {
         return this._attractorCoreReached;
      }
      
      public function set attractor(param1:IBattleAttractor) : void
      {
         if(this._attractor == param1)
         {
            return;
         }
         this.attractorCoreReached = false;
         this._attractor = param1;
         this.logger.i("ATRC","atttacting " + this + " to " + this._attractor);
      }
      
      public function get attractor() : IBattleAttractor
      {
         return this._attractor;
      }
      
      public function handleRemovedFromBoard() : void
      {
         this._board = null;
      }
      
      public function handleImmortalStopped() : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.IMMORTAL_STOPPED,this));
      }
      
      public function handleEndTurnIfNoEnemiesRemain() : void
      {
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.END_TURN_IF_NO_ENEMIES_REMAIN,this));
      }
      
      private function _createTestShitlistDef(param1:ILogger) : void
      {
         if(_shitlistDef)
         {
            return;
         }
         _shitlistDef = new ShitlistDef().fromJson({"entries":[{
            "weight":10,
            "target":{"entityDefId":{"all":["yrsa"]}}
         },{
            "weight":5,
            "target":{"entityDefId":{"all":["gunnulf"]}}
         }]},param1);
      }
      
      public function setShitlistId(param1:String) : void
      {
         var _loc2_:Saga = Saga.instance;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:ShitlistDef = !!param1 ? _loc2_.def.getShitlistDefById(param1) : null;
         if(param1 && !_loc3_)
         {
            this.logger.error("invalid shitlist id [" + param1 + "] for " + this);
         }
         _shitlistDef = _loc3_;
      }
      
      public function get isDisabledMove() : Boolean
      {
         var _loc1_:Boolean = stats && stats.getValue(StatType.DISABLE_MOVE);
         var _loc2_:Boolean = !_loc1_ && this._effects && this._effects.hasTag(EffectTag.DISABLE_MOVE);
         return _loc1_ || _loc2_;
      }
      
      public function get hasSubmergedMove() : Boolean
      {
         return this._hasSubmergedMove;
      }
      
      public function cameraFollowEntity(param1:Boolean) : void
      {
         var _loc2_:String = param1 ? BattleBoardEvent.CAMERA_FOLLOW : BattleBoardEvent.CAMERA_UNFOLLOW;
         var _loc3_:BattleBoardEvent = new BattleBoardEvent(_loc2_,this);
         this._board.dispatchEvent(_loc3_);
      }
      
      public function get isSubmerged() : Boolean
      {
         return this._isSubmerged;
      }
      
      public function set isSubmerged(param1:Boolean) : void
      {
         if(this._isSubmerged == param1)
         {
            return;
         }
         this._isSubmerged = param1;
         this._board.updateInfoBannerForEntity(this);
         dispatchEvent(new BattleEntityEvent(BattleEntityEvent.SUBMERGED,this));
         if(_cleanedup || !this._enabled || !this._active || !this._alive)
         {
            return;
         }
         this._board.triggers.checkTriggers(this,this.rect,true);
      }
      
      public function animControllerHandler_current(param1:AnimController) : void
      {
         if(this._animController != param1)
         {
            return;
         }
      }
      
      public function animControllerHandler_event(param1:AnimController, param2:String, param3:String) : void
      {
         if(param3 == "submerge_on")
         {
            if(this._hasSubmergedMove)
            {
               this.isSubmerged = true;
            }
         }
         else if(param3 == "submerge_off")
         {
            if(this._hasSubmergedMove)
            {
               this.isSubmerged = false;
            }
         }
      }
      
      public function animControllerHandler_loco(param1:AnimController, param2:String) : void
      {
         if(this._animController != param1)
         {
            return;
         }
         if(this._hasSubmergedMove)
         {
            if(param2 == "starting")
            {
            }
            if(param2 == "started")
            {
               if(this._mobility && !this._mobility.forcedMove)
               {
                  this.isSubmerged = true;
               }
            }
            else if(param2 != "ending")
            {
               if(param2 == "ended")
               {
                  this.isSubmerged = false;
               }
            }
         }
      }
      
      public function get incorporealFade() : Boolean
      {
         return this._incorporealFade;
      }
      
      public function computeIncorporealFade() : void
      {
         var _loc1_:IBattleFsm = this.board.fsm;
         var _loc2_:IBattleTurn = !!_loc1_ ? _loc1_.turn : null;
         var _loc3_:IBattleEntity = !!_loc2_ ? _loc2_.entity : null;
         if(_loc2_ == null || _loc3_ == null)
         {
            this._incorporealFade = false;
            return;
         }
         if(_loc3_ == this || _loc3_.incorporeal == this.incorporeal)
         {
            this._incorporealFade = false;
         }
         else
         {
            this._incorporealFade = true;
         }
      }
   }
}