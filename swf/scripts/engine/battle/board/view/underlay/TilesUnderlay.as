package engine.battle.board.view.underlay
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import com.greensock.TweenMax;
   import engine.battle.BattleUtilFunctions;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleDeploymentArea;
   import engine.battle.board.model.BattleEntityMobilityEvent;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.DirtyRenderSprite;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.sim.BattlePartyEvent;
   import engine.battle.sim.IBattleParty;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapResource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class TilesUnderlay extends DirtyRenderSprite
   {
      
      private static var lastBit:int = 0;
      
      private static var s_bitnames:Array = [];
      
      private static const BIT_TILE_TARGET:int = TilesUnderlay.nextBit("TilesUnderlay.BIT_TILE_TARGET");
      
      private static const BIT_BIG_ENTITY:int = TilesUnderlay.nextBit("TilesUnderlay.BIT_BIG_ENTITY");
      
      private static const BIT_ENTITY:int = TilesUnderlay.nextBit("TilesUnderlay.BIT_ENTITY");
       
      
      private var tile_1_res:BitmapResource;
      
      private var tiles:Dictionary;
      
      private var rangeTiles:Dictionary;
      
      private var destinationTiles:Dictionary;
      
      private var blocked:Dictionary;
      
      private var hiddenBytes:ByteArray;
      
      private var tileTargetBmps:Dictionary;
      
      private var ttbCount:int = 0;
      
      private var bitnames:Array;
      
      private var board_x:int;
      
      private var board_y:int;
      
      private var board_width:int;
      
      private var board_length:int;
      
      private var board_right:int;
      
      private var board_back:int;
      
      private var hasRendered:Boolean;
      
      private var tweenCenter:Point = null;
      
      private var suppressDirty:Boolean;
      
      public function TilesUnderlay(param1:BattleBoardView)
      {
         this.tiles = new Dictionary();
         this.rangeTiles = new Dictionary();
         this.destinationTiles = new Dictionary();
         this.blocked = new Dictionary();
         this.hiddenBytes = new ByteArray();
         this.tileTargetBmps = new Dictionary();
         this.bitnames = s_bitnames;
         super(param1);
         hoverScaleableDicts.push(this.tiles);
         hoverScaleableDicts.push(this.rangeTiles);
         hoverScaleableDicts.push(this.destinationTiles);
         var _loc2_:TileRect = _board.def.walkableTiles.rect;
         this.board_x = _loc2_.loc.x;
         this.board_y = _loc2_.loc.y;
         this.board_width = _loc2_.width;
         this.board_length = _loc2_.length;
         this.board_right = this.board_x + this.board_width;
         this.board_back = this.board_y + this.board_length;
         this.hiddenBytes.length = _loc2_.width * _loc2_.length * 4;
         fsm.addEventListener(BattleFsmEvent.TURN_IN_RANGE,this.turnInRangeHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.attackHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.turnCommittedHandler);
         this.tile_1_res = _board.resman.getResource(_board.assets.board_tile_1,BitmapResource) as BitmapResource;
         this.tile_1_res.addResourceListener(this.tileResLoadedHandler);
         _board.addEventListener(BattleEntityEvent.ADDED,this.entityAddedHandler);
         _board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.entityAliveHandler);
         _board.addEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         _board.addEventListener(BattleBoardEvent.PARTY,this.boardPartyHandler);
         _board.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
         _board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.boardEntityEnabledHandler);
         _board.addEventListener(BattleBoardEvent.HOVER_TILE,this.hoverTileHandler);
         param1.bitmapPool.addPool(_board.assets.tile_range_attack,8,40);
         param1.bitmapPool.addPool(_board.assets.tile_range_special,8,140);
         this.tileTargetBmps[_board.assets.tile_range_attack] = new Vector.<DisplayObjectWrapper>();
         this.tileTargetBmps[_board.assets.tile_range_special] = new Vector.<DisplayObjectWrapper>();
         this.boardPartyHandler(null);
         this.setupStaticBlockers();
      }
      
      public static function nextBit(param1:String) : uint
      {
         if(lastBit >= 10)
         {
            throw new IllegalOperationError("too... many... bits");
         }
         var _loc2_:uint = uint(1 << lastBit++);
         s_bitnames.push({
            "bit":_loc2_,
            "name":param1
         });
         return _loc2_;
      }
      
      private function boardSetupHandler(param1:BattleBoardEvent) : void
      {
         setRenderDirty();
      }
      
      private function boardEntityEnabledHandler(param1:BattleBoardEvent) : void
      {
         setRenderDirty();
      }
      
      private function turnAbilityHandler(param1:BattleFsmEvent) : void
      {
         setRenderDirty();
      }
      
      private function turnCommittedHandler(param1:BattleFsmEvent) : void
      {
         setRenderDirty();
      }
      
      private function turnInRangeHandler(param1:BattleFsmEvent) : void
      {
         var _loc3_:BattleAbilityTargetRule = null;
         var _loc2_:BattleAbility = fsm.turn.ability;
         if(_loc2_)
         {
            _loc3_ = _loc2_.def.targetRule;
            if(_loc3_ == BattleAbilityTargetRule.TILE_EMPTY || _loc3_ == BattleAbilityTargetRule.TILE_ANY || _loc3_ == BattleAbilityTargetRule.SPECIAL_RUN_THROUGH || _loc3_ == BattleAbilityTargetRule.SPECIAL_RUN_TO || _loc3_ == BattleAbilityTargetRule.SPECIAL_TRAMPLE || _loc3_ == BattleAbilityTargetRule.TILE_EMPTY_RANDOM || _loc3_ == BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE)
            {
               setRenderDirty();
            }
         }
      }
      
      private function boardPartyHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleParty = null;
         for each(_loc2_ in _board.parties)
         {
            _loc2_.addEventListener(BattlePartyEvent.DEPLOYED,this.eventDirtyHandler);
         }
      }
      
      protected function hoverTileHandler(param1:BattleBoardEvent) : void
      {
         hoverTileLocation = Boolean(_board) && Boolean(_board._hoverTile) ? _board._hoverTile.location : null;
      }
      
      override public function cleanup() : void
      {
         var _loc1_:IBattleEntity = null;
         var _loc2_:IBattleParty = null;
         fsm.removeEventListener(BattleFsmEvent.TURN_IN_RANGE,this.turnInRangeHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.attackHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.turnCommittedHandler);
         _board.removeEventListener(BattleBoardEvent.PARTY,this.boardPartyHandler);
         _board.removeEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         _board.removeEventListener(BattleEntityEvent.ADDED,this.entityAddedHandler);
         _board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.entityAliveHandler);
         _board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
         _board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.boardEntityEnabledHandler);
         _board.removeEventListener(BattleBoardEvent.HOVER_TILE,this.hoverTileHandler);
         this.tileTargetBmps = null;
         for each(_loc1_ in _board.entities)
         {
            if(_loc1_.mobility)
            {
               _loc1_.mobility.removeEventListener(BattleEntityMobilityEvent.MOVING,this.eventDirtyHandler);
            }
            _loc1_.removeEventListener(BattleEntityEvent.VISIBLE,this.eventDirtyHandler);
         }
         for each(_loc2_ in _board.parties)
         {
            _loc2_.removeEventListener(BattlePartyEvent.DEPLOYED,this.eventDirtyHandler);
         }
         this.tile_1_res.removeResourceListener(this.tileResLoadedHandler);
         this.tile_1_res.release();
         this.tile_1_res = null;
         super.cleanup();
      }
      
      public function unhideAll(param1:uint) : void
      {
         var _loc3_:Boolean = false;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc2_:int = this.hiddenBytes.length / 4;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            this.hiddenBytes.position = _loc4_ * 4;
            _loc5_ = this.hiddenBytes.readUnsignedInt();
            _loc6_ = uint(_loc5_ & ~param1);
            if(_loc6_ != _loc5_)
            {
               this.hiddenBytes.position = _loc4_ * 4;
               this.hiddenBytes.writeUnsignedInt(_loc6_);
               _loc3_ = true;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            if(!this.suppressDirty)
            {
               setRenderDirty();
            }
         }
      }
      
      public function unhide(param1:int, param2:int, param3:uint) : void
      {
         if(param1 < this.board_x || param2 < this.board_y || param1 >= this.board_right || param2 >= this.board_back)
         {
            return;
         }
         var _loc4_:int = 4 * (param1 - this.board_x + (param2 - this.board_y) * this.board_width);
         this.hiddenBytes.position = _loc4_;
         var _loc5_:uint = this.hiddenBytes.readUnsignedInt();
         var _loc6_:uint = uint(_loc5_ & ~param3);
         if(_loc6_ != _loc5_)
         {
            this.hiddenBytes.position = _loc4_;
            this.hiddenBytes.writeUnsignedInt(_loc6_);
            if(!this.suppressDirty)
            {
               setRenderDirty();
            }
         }
      }
      
      public function hide(param1:int, param2:int, param3:uint) : void
      {
         if(param1 < this.board_x || param2 < this.board_y || param1 >= this.board_right || param2 >= this.board_back)
         {
            return;
         }
         var _loc4_:int = 4 * (param1 - this.board_x + (param2 - this.board_y) * this.board_width);
         this.hiddenBytes.position = _loc4_;
         if(this.board_x == param1 && this.board_y == param2)
         {
            param3 = param3;
         }
         var _loc5_:uint = this.hiddenBytes.readUnsignedInt();
         var _loc6_:uint = uint(_loc5_ | param3);
         if(_loc6_ != _loc5_)
         {
            this.hiddenBytes.position = _loc4_;
            this.hiddenBytes.writeUnsignedInt(_loc6_);
            if(!this.suppressDirty)
            {
               setRenderDirty();
            }
         }
      }
      
      public function hideRect(param1:TileRect, param2:uint) : void
      {
         param1.visitEnclosedTileLocations(this.hide,param2);
      }
      
      public function unhideRect(param1:TileRect, param2:uint) : void
      {
         param1.visitEnclosedTileLocations(this.unhide,param2);
      }
      
      public function isHidden(param1:int, param2:int) : Boolean
      {
         if(param1 < this.board_x || param2 < this.board_y || param1 >= this.board_right || param2 >= this.board_back)
         {
            return false;
         }
         var _loc3_:int = 4 * (param1 - this.board_x + (param2 - this.board_y) * this.board_width);
         this.hiddenBytes.position = _loc3_;
         var _loc4_:uint = this.hiddenBytes.readUnsignedInt();
         return _loc4_ != 0;
      }
      
      public function isHiddenBit(param1:int, param2:int, param3:uint) : Boolean
      {
         if(param1 < this.board_x || param2 < this.board_y || param1 >= this.board_right || param2 >= this.board_back)
         {
            return false;
         }
         var _loc4_:int = 4 * (param1 - this.board_x + (param2 - this.board_y) * this.board_width);
         this.hiddenBytes.position = _loc4_;
         var _loc5_:uint = this.hiddenBytes.readUnsignedInt();
         return (_loc5_ & param3) != 0;
      }
      
      public function getHiddenBits(param1:int, param2:int) : uint
      {
         if(param1 < this.board_x || param2 < this.board_y || param1 >= this.board_right || param2 >= this.board_back)
         {
            return 0;
         }
         var _loc3_:int = 4 * (param1 - this.board_x + (param2 - this.board_y) * this.board_width);
         this.hiddenBytes.position = _loc3_;
         return this.hiddenBytes.readUnsignedInt();
      }
      
      private function entityRemovedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         if(_loc2_.mobility)
         {
            _loc2_.mobility.removeEventListener(BattleEntityMobilityEvent.MOVING,this.eventDirtyHandler);
         }
         _loc2_.removeEventListener(BattleEntityEvent.VISIBLE,this.eventDirtyHandler);
         this.checkRemoveStaticBlocker(_loc2_);
         setRenderDirty();
      }
      
      private function entityAliveHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         if(Boolean(_loc2_) && !_loc2_.alive)
         {
            this.checkRemoveStaticBlocker(_loc2_);
            setRenderDirty();
         }
      }
      
      private function entityAddedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         this.checkAddStaticBlocker(_loc2_);
         if(_loc2_.mobility)
         {
            _loc2_.mobility.addEventListener(BattleEntityMobilityEvent.MOVING,this.eventDirtyHandler);
         }
         _loc2_.addEventListener(BattleEntityEvent.VISIBLE,this.eventDirtyHandler);
         setRenderDirty();
      }
      
      private function eventDirtyHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      private function checkRemoveStaticBlocker(param1:IBattleEntity) : void
      {
         param1.rect.visitEnclosedTileLocations(this._visitCheckRemoveStaticBlocker,param1);
      }
      
      private function _visitCheckRemoveStaticBlocker(param1:int, param2:int, param3:IBattleEntity) : void
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         delete this.blocked[_loc4_];
         var _loc5_:DisplayObjectWrapper = this.tiles[_loc4_];
         if(!_loc5_)
         {
            logger.info("TilesUnderlay RESTORE BLOCKED " + _loc4_ + " by " + param3);
            this.addTile(_loc4_);
         }
      }
      
      private function checkAddStaticBlocker(param1:IBattleEntity) : void
      {
         if(param1.collidable)
         {
            if(!param1.mobile)
            {
               param1.rect.visitEnclosedTileLocations(this._visitCheckAddStaticBlocker,param1);
            }
         }
      }
      
      private function _visitCheckAddStaticBlocker(param1:int, param2:int, param3:IBattleEntity) : void
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         this.blocked[_loc4_] = param3;
         var _loc5_:DisplayObjectWrapper = this.tiles[_loc4_];
         if(_loc5_)
         {
            displayObjectWrapper.removeChild(_loc5_);
            logger.info("TilesUnderlay REMOVE BLOCKED " + _loc4_ + " by " + param3);
            delete this.tiles[_loc4_];
         }
      }
      
      private function setupStaticBlockers() : void
      {
         var _loc1_:IBattleEntity = null;
         for each(_loc1_ in _board.entities)
         {
            if(_loc1_.mobility)
            {
               _loc1_.mobility.addEventListener(BattleEntityMobilityEvent.MOVING,this.eventDirtyHandler);
            }
            _loc1_.addEventListener(BattleEntityEvent.VISIBLE,this.eventDirtyHandler);
            this.checkAddStaticBlocker(_loc1_);
         }
      }
      
      private function attackHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      private function tileResLoadedHandler(param1:ResourceLoadedEvent) : void
      {
         if(!this.tile_1_res)
         {
            return;
         }
         this.tile_1_res.removeResourceListener(this.tileResLoadedHandler);
         this._addAllTiles();
      }
      
      private function _addAllTiles() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Tile = null;
         if(!this.tile_1_res.ok)
         {
            return;
         }
         for each(_loc2_ in _board.tiles.tiles)
         {
            if(!this.blocked[_loc2_.location])
            {
               if(!_loc2_.getWalkableFor(null))
               {
                  this.removeTile(_loc2_.location);
               }
               else if(!this.tiles[_loc2_.location])
               {
                  this.addTile(_loc2_.location);
                  _loc1_++;
               }
            }
         }
         if(_loc1_)
         {
            setRenderDirty();
         }
      }
      
      public function handleWalkableTilesChanged() : void
      {
         this._addAllTiles();
      }
      
      private function removeTile(param1:TileLocation) : void
      {
         var _loc2_:DisplayObjectWrapper = this.tiles[param1];
         if(!_loc2_)
         {
            return;
         }
         delete this.tiles[param1];
         this.hide(param1.x,param1.y,4294967295);
         _loc2_.cleanup();
      }
      
      private function addTile(param1:TileLocation) : void
      {
         if(!this.tile_1_res.ok)
         {
            return;
         }
         var _loc2_:DisplayObjectWrapper = this.tile_1_res.getWrapper();
         this.tiles[param1] = _loc2_;
         this.unhide(param1.x,param1.y,4294967295);
         checkBmpScale(param1,_loc2_,1);
         positionTileBmp(param1,_loc2_,1);
         _loc2_.visible = false;
         displayObjectWrapper.addChild(_loc2_);
      }
      
      public function editorRemoveTile(param1:TileLocation) : void
      {
         var _loc2_:DisplayObjectWrapper = this.tiles[param1];
         if(_loc2_)
         {
            displayObjectWrapper.removeChild(_loc2_);
         }
         logger.info("TilesUnderlay EDITOR REMOVE " + param1);
         delete this.tiles[param1];
         setRenderDirty();
      }
      
      public function editorAddTile(param1:TileLocation) : void
      {
         this.addTile(param1);
         setRenderDirty();
      }
      
      private function renderEntityTiles() : void
      {
         var _loc1_:IBattleEntity = null;
         var _loc2_:TileLocation = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:TileRect = null;
         if(!_board.boardSetup)
         {
            return;
         }
         for each(_loc1_ in _board.entities)
         {
            _loc7_ = _loc1_.rect;
            if(!_loc1_.tile || !_loc1_.enabled || !_loc1_.active || !_loc1_.visibleToPlayer || !_loc1_.alive || _loc1_.party && !_loc1_.party.deployed && _loc1_.party.type == BattlePartyType.REMOTE)
            {
               this.unhideRect(_loc7_,BIT_BIG_ENTITY | BIT_ENTITY | BIT_TILE_TARGET);
            }
            else
            {
               this.hideRect(_loc7_,BIT_ENTITY);
            }
         }
      }
      
      private function _visitRenderEntityTiles(param1:int, param2:int, param3:*) : void
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         this.unhide(_loc4_.x,_loc4_.y,BIT_BIG_ENTITY | BIT_ENTITY | BIT_TILE_TARGET);
      }
      
      private function renderDestinationTiles() : void
      {
         var _loc8_:Object = null;
         var _loc9_:Tile = null;
         var _loc10_:DisplayObjectWrapper = null;
         var _loc11_:DisplayObjectWrapper = null;
         if(!_board.boardSetup)
         {
            return;
         }
         if(!fsm.turn || fsm.turn.committed)
         {
            return;
         }
         if(!fsm.turn.ability || fsm.turn.ability.def.targetRule != BattleAbilityTargetRule.SPECIAL_BATTERING_RAM)
         {
            return;
         }
         var _loc1_:IBattleEntity = fsm.turn.entity;
         if(!_loc1_.playerControlled)
         {
            return;
         }
         if(_loc1_.mobility.moving)
         {
            return;
         }
         if(!fsm.turn.attackMode && !fsm.turn.ability)
         {
            return;
         }
         var _loc2_:IBattleEntity = fsm.turn.ability.targetSet.baseTarget;
         if(_loc2_ == null || _loc2_ == _loc1_)
         {
            return;
         }
         var _loc3_:Array = new Array();
         var _loc4_:Tile = null;
         var _loc5_:int = fsm.turn.ability.def.maxResultDistance;
         while(_loc5_ >= fsm.turn.ability.def.minResultDistance)
         {
            _loc4_ = BattleUtilFunctions.getTileAvailableBehindAtDist(_loc1_.rect,_loc2_,_loc5_);
            if(_loc4_ != null)
            {
               break;
            }
            _loc5_--;
         }
         if(_loc4_ == null)
         {
            return;
         }
         _loc2_.rect.visitEnclosedTileLocations(this._visitRenderDestinationTiles,_loc3_);
         var _loc6_:String = Boolean(fsm.turn.ability) && fsm.turn.ability.def.tag == BattleAbilityTag.SPECIAL ? _board.assets.tile_range_special : _board.assets.tile_range_attack;
         var _loc7_:Vector.<DisplayObjectWrapper> = this.tileTargetBmps[_loc6_];
         for(_loc8_ in this.destinationTiles)
         {
            delete this.destinationTiles[_loc8_];
         }
         for each(_loc9_ in _loc3_)
         {
            _loc10_ = this.tiles[_loc9_.location];
            _loc11_ = null;
            if(_loc7_.length <= this.ttbCount)
            {
               _loc11_ = view.bitmapPool.pop(_loc6_);
               _loc7_.push(_loc11_);
               displayObjectWrapper.addChild(_loc11_);
            }
            else
            {
               _loc11_ = _loc7_[this.ttbCount];
            }
            ++this.ttbCount;
            _loc11_.visible = true;
            checkBmpScale(_loc9_.location,_loc11_,1);
            positionTileBmp(_loc9_.location,_loc11_,1);
            this.destinationTiles[_loc9_.location] = _loc11_;
            this.hide(_loc9_.location.x,_loc9_.location.y,BIT_TILE_TARGET);
         }
      }
      
      private function _visitRenderDestinationTiles(param1:int, param2:int, param3:Array) : void
      {
         var _loc4_:Tile = _board.tiles.getTile(param1,param2);
         param3.push(_loc4_);
      }
      
      private function getTileFadeInDuration(param1:TileLocation) : Number
      {
         return 0.25;
      }
      
      private function getTileFadeInStart(param1:TileLocation) : Number
      {
         var _loc2_:TileRect = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.tweenCenter)
         {
            _loc2_ = _board.def.walkableTiles.rect;
            _loc3_ = Math.max(10,Math.max(_loc2_.width,_loc2_.length));
            _loc4_ = _loc3_ * 2;
            return (Math.abs(this.tweenCenter.x - param1.x) + Math.abs(this.tweenCenter.y - param1.y)) / _loc4_;
         }
         return 0;
      }
      
      private function computeFirstRender() : void
      {
         var _loc1_:IBattleParty = null;
         var _loc3_:IBattleParty = null;
         var _loc4_:BattleDeploymentArea = null;
         var _loc2_:int = 0;
         while(_loc2_ < _board.numParties)
         {
            _loc3_ = _board.getParty(_loc2_);
            if(_loc3_.isPlayer)
            {
               _loc1_ = _loc3_;
               break;
            }
            _loc2_++;
         }
         if(_loc1_)
         {
            _loc4_ = _board.def.getDeploymentAreaById(_loc1_.deployment);
            if(_loc4_)
            {
               this.tweenCenter = _loc4_.area.rect.center;
               return;
            }
         }
         this.tweenCenter = _board.def.walkableTiles.rect.center;
      }
      
      private function showTileBitmap(param1:DisplayObjectWrapper, param2:TileLocation, param3:int, param4:Number, param5:Number) : void
      {
         var _loc6_:Number = param3 / 2;
         var _loc7_:Pt = IsoMath.isoToScreen(new Pt(param2.x + _loc6_,param2.y + _loc6_));
         var _loc8_:Number = view.units;
         param1.scaleX = this.tile_1_res.scaleX;
         param1.scaleY = this.tile_1_res.scaleY;
         var _loc9_:int = int(_loc7_.x * _loc8_ - param1.width / 2);
         var _loc10_:int = int(_loc7_.y * _loc8_ - param1.height / 2);
         if(param5 > 0 || param4 > 0)
         {
            param1.x = int(_loc7_.x * _loc8_);
            param1.y = int(_loc7_.y * _loc8_);
            param1.scaleX = param1.scaleY = 0;
            TweenMax.to(param1,param5,{
               "scaleX":this.tile_1_res.scaleX,
               "scaleY":this.tile_1_res.scaleY,
               "x":_loc9_,
               "y":_loc10_,
               "delay":param4
            });
         }
         else
         {
            param1.x = _loc9_;
            param1.y = _loc10_;
         }
      }
      
      private function hideAllTiles() : void
      {
         var _loc1_:Object = null;
         var _loc2_:TileLocation = null;
         var _loc3_:DisplayObjectWrapper = null;
         for(_loc1_ in this.tiles)
         {
            _loc2_ = _loc1_ as TileLocation;
            _loc3_ = this.tiles[_loc2_];
            _loc3_.visible = false;
         }
      }
      
      private function renderTiles() : void
      {
         var _loc1_:Object = null;
         var _loc2_:TileLocation = null;
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = false;
         if(!_board.boardSetup)
         {
            return;
         }
         for(_loc1_ in this.tiles)
         {
            _loc2_ = _loc1_ as TileLocation;
            _loc3_ = this.tiles[_loc2_];
            _loc4_ = this.isHiddenBit(_loc2_.x,_loc2_.y,~BIT_ENTITY);
            _loc5_ = !_loc4_;
            _loc3_.visible = _loc5_;
            if(!this.hasRendered)
            {
               this.showTileBitmap(_loc3_,_loc2_,1,this.getTileFadeInStart(_loc2_),this.getTileFadeInDuration(_loc2_));
            }
         }
         this.hasRendered = true;
      }
      
      override protected function onRender() : void
      {
         var _loc1_:Boolean = Boolean(_board) && _board.boardSetup;
         if(!this.hasRendered)
         {
            if(_loc1_)
            {
               this.computeFirstRender();
            }
         }
         else if(!_loc1_)
         {
            this.hideAllTiles();
            this.hasRendered = false;
         }
         this.unhideAll(BIT_ENTITY);
         this.unhideAll(BIT_BIG_ENTITY);
         this.unhideAll(BIT_TILE_TARGET);
         this.hideAllTileTargets();
         if(!_loc1_)
         {
            return;
         }
         this.renderEntityTiles();
         this.ttbCount = 0;
         this.renderRangeTiles();
         this.renderDestinationTiles();
         this.renderTiles();
         unsetRenderDirty();
      }
      
      private function hideAllTileTargets() : void
      {
         var _loc1_:Vector.<DisplayObjectWrapper> = null;
         var _loc2_:DisplayObjectWrapper = null;
         this.unhideAll(BIT_TILE_TARGET);
         for each(_loc1_ in this.tileTargetBmps)
         {
            for each(_loc2_ in _loc1_)
            {
               TweenMax.killTweensOf(_loc2_);
               _loc2_.visible = false;
            }
         }
      }
      
      private function renderRangeTiles() : void
      {
         var _loc5_:Object = null;
         var _loc6_:TileLocation = null;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:BattleAbilityTargetRule = null;
         if(!fsm.turn || !fsm.turn.inRangeTiles || fsm.turn.committed)
         {
            return;
         }
         var _loc1_:IBattleEntity = fsm.turn.entity;
         if(!_loc1_.playerControlled)
         {
            return;
         }
         if(_loc1_.mobility.moving)
         {
            return;
         }
         if(!fsm.turn.attackMode && !fsm.turn.ability)
         {
            return;
         }
         var _loc2_:String = Boolean(fsm.turn.ability) && fsm.turn.ability.def.tag == BattleAbilityTag.SPECIAL ? _board.assets.tile_range_special : _board.assets.tile_range_attack;
         var _loc3_:Vector.<DisplayObjectWrapper> = this.tileTargetBmps[_loc2_];
         var _loc4_:BattleAbility = fsm.turn.ability;
         for(_loc5_ in this.rangeTiles)
         {
            delete this.rangeTiles[_loc5_];
         }
         for each(_loc6_ in fsm.turn.inRangeTiles)
         {
            if(this.isHidden(_loc6_.x,_loc6_.y))
            {
               _loc8_ = !!_loc4_ ? _loc4_.def.targetRule : null;
               if(!_loc4_ || _loc8_ != BattleAbilityTargetRule.TILE_ANY && _loc8_ != BattleAbilityTargetRule.SPECIAL_SLAG_AND_BURN && _loc8_ != BattleAbilityTargetRule.FORWARD_ARC && _loc8_ != BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE)
               {
                  continue;
               }
            }
            _loc7_ = null;
            if(_loc3_.length <= this.ttbCount)
            {
               _loc7_ = view.bitmapPool.pop(_loc2_);
               _loc3_.push(_loc7_);
               displayObjectWrapper.addChild(_loc7_);
            }
            else
            {
               _loc7_ = _loc3_[this.ttbCount];
            }
            ++this.ttbCount;
            _loc7_.visible = true;
            checkBmpScale(_loc6_,_loc7_,1);
            positionTileBmp(_loc6_,_loc7_,1);
            this.hide(_loc6_.x,_loc6_.y,BIT_TILE_TARGET);
            this.rangeTiles[_loc6_] = _loc7_;
         }
      }
   }
}
