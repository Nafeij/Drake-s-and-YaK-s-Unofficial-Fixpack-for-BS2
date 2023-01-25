package engine.battle.board.view.underlay
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.model.BattleEntityMobilityEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleEntityMobility;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.battle.board.view.overlay.MovePlanOverlay;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.path.PathFloodSolver;
   import engine.path.PathFloodSolverNode;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class MovePlanUnderlay extends EntityLinkedDirtyRenderSprite
   {
      
      public static const BIT_FLOOD:uint = TilesUnderlay.nextBit("MovePlanUnderlay.BIT_FLOOD");
      
      public static const BIT_ENDPOINTS:uint = TilesUnderlay.nextBit("MovePlanUnderlay.BIT_ENDPOINTS");
       
      
      private var _turn:BattleTurn;
      
      private var lastFlood:PathFloodSolver;
      
      private var lastWaypointDisplay:DisplayObjectWrapper;
      
      private var lastWaypointDisplayUrl:String;
      
      private var lastEndpointDisplay:DisplayObjectWrapper;
      
      private var lastEndpointDisplayUrl:String;
      
      private var floodDisplays:Vector.<DisplayObjectWrapper>;
      
      private var appears:DisplayAppears;
      
      private var interactMove:BattleMove;
      
      private var _turnMove:IBattleMove;
      
      private var _entityMobility:IBattleEntityMobility;
      
      public function MovePlanUnderlay(param1:BattleBoardView)
      {
         this.floodDisplays = new Vector.<DisplayObjectWrapper>();
         super(param1);
         this.appears = new DisplayAppears(90,90);
         fsm.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.turnCommittedHandler);
         fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
         fsm.addEventListener(BattleFsmEvent.INTERACT,this.eventDirtyHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.attackHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.eventDirtyHandler);
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.animClipSpritePool.addPool(_loc2_.board_active_1,2,16);
         view.animClipSpritePool.addPool(_loc2_.board_active_1x2,2,16);
         view.animClipSpritePool.addPool(_loc2_.board_active_2,2,16);
         view.bitmapPool.addPool(_loc2_.board_tile_move_a,16,80);
         view.bitmapPool.addPool(_loc2_.board_tile_move_b,16,80);
         view.bitmapPool.addPool(_loc2_.board_tile_move_star,16,128);
         view.bitmapPool.addPool(_loc2_.board_tile_move_other_a,16,80);
         view.bitmapPool.addPool(_loc2_.board_tile_move_other_b,16,80);
         view.bitmapPool.addPool(_loc2_.board_tile_move_other_star,16,64);
         if(PathFloodSolver.ENABLE_REJECTED_DEBUG)
         {
            view.bitmapPool.addPool("common/battle/tile/tile_rejected_closed.png",6,16);
            view.bitmapPool.addPool("common/battle/tile/tile_rejected_disabled.png",6,16);
            view.bitmapPool.addPool("common/battle/tile/tile_rejected_cost.png",6,16);
            view.bitmapPool.addPool("common/battle/tile/tile_rejected_blocked.png",6,16);
            view.bitmapPool.addPool("common/battle/tile/tile_rejected_render.png",6,16);
         }
      }
      
      public static function computeCanRender(param1:BattleFsm) : Boolean
      {
         var _loc2_:BattleTurn = !!param1 ? param1._turn : null;
         var _loc3_:IBattleEntity = !!_loc2_ ? _loc2_.entity : null;
         if(!_loc2_ || _loc2_.committed || !_loc2_.move || _loc2_.move.executing || _loc2_.attackMode || Boolean(_loc2_.ability))
         {
            return false;
         }
         var _loc4_:IBattleEntity = param1.interact;
         if(_loc4_)
         {
            if(_loc4_ == _loc3_)
            {
               return !_loc2_.move.executing && !_loc3_.playerControlled && !param1.interact.mobility.moving;
            }
            if(Boolean(_loc2_.ability) && _loc2_.ability.def.targetRule == BattleAbilityTargetRule.TILE_ANY)
            {
               return false;
            }
            if(Boolean(_loc4_.visible) && Boolean(_loc4_.enabled) && Boolean(_loc4_.active) && Boolean(_loc4_.mobile))
            {
               return true;
            }
            return false;
         }
         if(_loc3_.playerControlled)
         {
            return !_loc2_.move.committed && !_loc2_.ability && !_loc2_.attackMode && !_loc3_.mobility.moving && Boolean(_loc3_.enabled) && Boolean(_loc3_.active);
         }
         return false;
      }
      
      private function turnCommittedHandler(param1:BattleFsmEvent) : void
      {
         this.checkCanRender();
      }
      
      override public function cleanup() : void
      {
         fsm.removeEventListener(BattleFsmEvent.INTERACT,this.eventDirtyHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.attackHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.turnCommittedHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.eventDirtyHandler);
         this.turn = null;
         this.appears.cleanup();
         super.cleanup();
      }
      
      private function comparePathFloodSolverNodes(param1:PathFloodSolverNode, param2:PathFloodSolverNode) : int
      {
         return param1.g - param2.g;
      }
      
      private function renderRejectedTiles(param1:DisplayObjectWrapper, param2:IBattleMove, param3:Dictionary) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Tile = null;
         var _loc6_:String = null;
         var _loc7_:* = null;
         if(!entity || !this._turn || !param2.flood.rejected)
         {
            return;
         }
         for(_loc4_ in param2.flood.rejected)
         {
            _loc5_ = _loc4_ as Tile;
            _loc6_ = String(param2.flood.rejected[_loc4_]);
            if(!param2.flood.resultSet[_loc5_])
            {
               _loc7_ = "common/battle/tile/tile_rejected_" + _loc6_ + ".png";
               this.renderTile(param1,true,null,param3,_loc7_,_loc5_,null,1,0,BIT_FLOOD);
            }
         }
      }
      
      private function renderCommands(param1:DisplayObjectWrapper, param2:IBattleMove, param3:Dictionary, param4:Dictionary, param5:int, param6:String, param7:String, param8:String) : void
      {
         var _loc9_:PathFloodSolverNode = null;
         var _loc10_:Tile = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:Tile = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:* = false;
         if(!entity || !this._turn)
         {
            return;
         }
         for each(_loc9_ in param4)
         {
            _loc10_ = _loc9_.node.key as Tile;
            if(_loc10_)
            {
               if(!_loc10_.getWalkableFor(param2.entity))
               {
                  if(Boolean(param2.entity) && !param2.entity.playerControlled)
                  {
                     continue;
                  }
               }
               _loc11_ = param2.wayPointSteps + _loc9_.g - 1;
               if(_loc11_ <= param5)
               {
                  if(_loc10_ != param2.wayPointTile)
                  {
                     _loc12_ = int(param2.entity.diameter);
                     _loc13_ = 0;
                     while(_loc13_ < _loc12_)
                     {
                        _loc14_ = 0;
                        while(_loc14_ < _loc12_)
                        {
                           _loc15_ = view.board.tiles.getTile(_loc10_.x + _loc13_,_loc10_.y + _loc14_);
                           if(_loc15_ != null)
                           {
                              if(param8 == null)
                              {
                                 _loc16_ = int((_loc15_.location.x + _loc15_.location.y) / 2) * 2;
                                 _loc17_ = _loc15_.location.x + _loc15_.location.y;
                                 _loc18_ = _loc16_ == _loc17_;
                                 if(_loc18_)
                                 {
                                    this.renderTile(param1,false,null,param3,param6,_loc15_,null,1,_loc9_.g,BIT_FLOOD);
                                 }
                                 else
                                 {
                                    this.renderTile(param1,false,null,param3,param7,_loc15_,null,1,_loc9_.g,BIT_FLOOD);
                                 }
                              }
                              else
                              {
                                 this.renderTile(param1,false,null,param3,param8,_loc15_,null,1,_loc9_.g,BIT_FLOOD);
                              }
                           }
                           _loc14_++;
                        }
                        _loc13_++;
                     }
                  }
               }
            }
         }
      }
      
      private function markTile(param1:Tile, param2:DisplayObjectWrapper, param3:int, param4:Dictionary, param5:uint) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Tile = null;
         var _loc9_:TileLocation = null;
         var _loc6_:int = 0;
         while(_loc6_ < param3)
         {
            _loc7_ = 0;
            while(_loc7_ < param3)
            {
               _loc8_ = view.board.tiles.getTile(param1.x + _loc6_,param1.y + _loc7_);
               if(_loc8_)
               {
                  param4[_loc8_] = param2;
                  _loc9_ = _loc8_.location;
                  view.underlay.tilesUnderlay.hide(_loc9_.x,_loc9_.y,param5);
               }
               _loc7_++;
            }
            _loc6_++;
         }
      }
      
      private function placeTileBitmap(param1:Tile, param2:DisplayObjectWrapper, param3:int, param4:int) : void
      {
         var _loc5_:Number = param3 / 2;
         var _loc6_:Pt = IsoMath.isoToScreen(new Pt(param1.x + _loc5_,param1.y + _loc5_));
         var _loc7_:Number = view.units;
         var _loc8_:Number = param2.scaleX;
         var _loc9_:Number = param2.scaleY;
         var _loc10_:int = int(_loc6_.x * _loc7_ - param2.width / 2);
         var _loc11_:int = int(_loc6_.y * _loc7_ - param2.height / 2);
         if(param4 > 0)
         {
            param2.x = int(_loc6_.x * _loc7_);
            param2.y = int(_loc6_.y * _loc7_);
            param2.scaleX = param2.scaleY = 0;
            this.appears.beginAppear(1000 * (0.05 + param4 * 0.05),param2,_loc8_,_loc9_,_loc10_,_loc11_);
         }
         else
         {
            param2.x = _loc10_;
            param2.y = _loc11_;
         }
      }
      
      private function placeTileSprite(param1:TileRect, param2:DisplayObjectWrapper, param3:int) : void
      {
         var _loc4_:BattleFacing = param1.facing as BattleFacing;
         var _loc5_:* = param1._localLength == param1._localWidth;
         MovePlanOverlay.centerTheDisplayObject(_loc4_,param2,false,_loc5_);
         var _loc6_:Point = param1.localTail;
         var _loc7_:Pt = new Pt(param1.center.x + _loc6_.x / 2,param1.center.y + _loc6_.y / 2);
         var _loc8_:Pt = IsoMath.isoToScreen(_loc7_);
         var _loc9_:Number = view.units;
         param2.x += int(_loc8_.x * _loc9_);
         param2.y += int(_loc8_.y * _loc9_);
         var _loc10_:Number = param2.scaleX;
         var _loc11_:Number = param2.scaleY;
         if(param3 > 0)
         {
            param2.scaleX = param2.scaleY = 0;
            this.appears.beginAppear(1000 * (0.05 + param3 * 0.05),param2,_loc10_,_loc11_,param2.x,param2.y);
         }
         else
         {
            this.appears.removeAppear(param2);
         }
      }
      
      private function renderTile(param1:DisplayObjectWrapper, param2:Boolean, param3:DisplayObjectWrapper, param4:Dictionary, param5:String, param6:Tile, param7:BattleFacing, param8:int, param9:int, param10:uint) : DisplayObjectWrapper
      {
         var _loc12_:Tiles = null;
         var _loc13_:TileRect = null;
         if(!param6)
         {
            return null;
         }
         if(!param2)
         {
            if(param4[param6])
            {
               return null;
            }
            if(param8 > 1)
            {
               _loc12_ = param6.tiles;
               if(param4[_loc12_.getTile(param6.x + 1,param6.y + 0)])
               {
                  return null;
               }
               if(param4[_loc12_.getTile(param6.x + 1,param6.y + 1)])
               {
                  return null;
               }
               if(param4[_loc12_.getTile(param6.x + 0,param6.y + 1)])
               {
                  return null;
               }
            }
         }
         var _loc11_:* = param5.indexOf(".png") > 0;
         if(!param3)
         {
            if(_loc11_)
            {
               param3 = view.bitmapPool.pop(param5);
            }
            else
            {
               param3 = view.animClipSpritePool.pop(param5);
            }
            this.markTile(param6,param3,param8,param4,param10);
         }
         if(param3)
         {
            if(_loc11_)
            {
               this.placeTileBitmap(param6,param3,param8,param9);
            }
            else
            {
               _loc13_ = _entity.rect.clone();
               _loc13_.setLocation(param6.location);
               _loc13_.facing = param7;
               this.placeTileSprite(_loc13_,param3,param9);
            }
            if(!param3.hasParent)
            {
               param1.addChild(param3);
            }
            if(param10 == BIT_FLOOD)
            {
               this.floodDisplays.push(param3);
            }
         }
         return param3;
      }
      
      private function setWaypointDisplay(param1:DisplayObjectWrapper, param2:DisplayObjectWrapper, param3:String) : void
      {
         if(this.lastWaypointDisplay == param2)
         {
            return;
         }
         if(this.lastWaypointDisplay)
         {
            this.clearDisplay(param1,this.lastWaypointDisplay);
            this.lastWaypointDisplayUrl = null;
         }
         this.lastWaypointDisplay = param2;
         if(this.lastWaypointDisplay)
         {
            this.lastWaypointDisplayUrl = param3;
         }
      }
      
      private function setEndpointDisplay(param1:DisplayObjectWrapper, param2:DisplayObjectWrapper, param3:String) : void
      {
         if(this.lastEndpointDisplay == param2)
         {
            return;
         }
         if(this.lastEndpointDisplay)
         {
            this.clearDisplay(param1,this.lastEndpointDisplay);
            this.lastEndpointDisplayUrl = null;
         }
         this.lastEndpointDisplay = param2;
         if(this.lastEndpointDisplay)
         {
            this.lastEndpointDisplayUrl = param3;
         }
      }
      
      private function _evaluateActiveTile(param1:BattleEntity) : String
      {
         var _loc2_:BattleAssetsDef = view.board.assets;
         if(entity._length == 2 && entity._width == 1)
         {
            return _loc2_.board_active_1x2;
         }
         if(entity._diameter == 1)
         {
            return _loc2_.board_active_1;
         }
         return _loc2_.board_active_2;
      }
      
      private function renderWaypoint(param1:DisplayObjectWrapper, param2:IBattleMove, param3:Dictionary) : void
      {
         if(param2.wayPointSteps <= 1)
         {
            this.setWaypointDisplay(param1,null,null);
            return;
         }
         var _loc4_:BattleEntity = _entity as BattleEntity;
         var _loc5_:String = this._evaluateActiveTile(_loc4_);
         var _loc6_:int = 1;
         if(this.lastWaypointDisplay)
         {
            if(this.lastWaypointDisplayUrl != _loc5_)
            {
               this.setWaypointDisplay(param1,null,null);
            }
            else
            {
               _loc6_ = 0;
            }
         }
         var _loc7_:Tile = param2.wayPointTile;
         var _loc8_:BattleFacing = param2.wayPointFacing;
         var _loc9_:DisplayObjectWrapper = this.renderTile(param1,true,this.lastWaypointDisplay,param3,_loc5_,_loc7_,_loc8_,_loc4_._diameter,_loc6_,BIT_ENDPOINTS);
         this.setWaypointDisplay(param1,_loc9_,_loc5_);
      }
      
      private function renderEndpoint(param1:DisplayObjectWrapper, param2:IBattleMove, param3:Dictionary) : void
      {
         var _loc4_:Saga = Saga.instance;
         var _loc5_:Boolean = param2.pathEndBlocked && _loc4_ && _loc4_.logger.isDebugEnabled ? true : false;
         if(param2.numSteps <= 1 || param2.last == param2.wayPointTile || _loc5_)
         {
            this.setEndpointDisplay(param1,null,null);
            return;
         }
         var _loc6_:BattleEntity = _entity as BattleEntity;
         var _loc7_:Number = _loc6_._diameter;
         var _loc8_:String = this._evaluateActiveTile(_loc6_);
         var _loc9_:int = 1;
         if(this.lastEndpointDisplay)
         {
            if(this.lastEndpointDisplayUrl != _loc8_)
            {
               this.setEndpointDisplay(param1,null,null);
            }
            else
            {
               _loc9_ = 0;
            }
         }
         var _loc10_:Tile = param2.last;
         var _loc11_:BattleFacing = param2.lastFacing;
         var _loc12_:DisplayObjectWrapper = this.renderTile(param1,true,this.lastEndpointDisplay,param3,_loc8_,_loc10_,_loc11_,_loc7_,_loc9_,BIT_ENDPOINTS);
         this.setEndpointDisplay(param1,_loc12_,_loc8_);
      }
      
      private function cutoutCharacter(param1:IBattleMove, param2:Dictionary) : void
      {
         var _loc3_:BattleEntity = param1.entity as BattleEntity;
         _loc3_.rect.visitEnclosedTileLocations(this._visitCutoutCharacter,param2);
      }
      
      private function _visitCutoutCharacter(param1:int, param2:int, param3:Dictionary) : void
      {
         var _loc4_:Tile = view.board.tiles.getTile(param1,param2);
         if(!param3[_loc4_])
         {
            param3[_loc4_] = null;
         }
      }
      
      private function clearDisplays(param1:DisplayObjectWrapper, param2:Vector.<DisplayObjectWrapper>) : void
      {
         var _loc3_:DisplayObjectWrapper = null;
         for each(_loc3_ in param2)
         {
            this.clearDisplay(param1,_loc3_);
         }
         param2.splice(0,param2.length);
      }
      
      private function clearDisplay(param1:DisplayObjectWrapper, param2:DisplayObjectWrapper) : void
      {
         param1.removeChild(param2);
         this.appears.removeAppear(param2);
         param2.scaleX = param2.scaleY = 1;
         view.bitmapPool.reclaim(param2);
         view.animClipSpritePool.reclaim(param2);
      }
      
      private function renderFlood(param1:DisplayObjectWrapper, param2:IBattleMove, param3:Dictionary, param4:String, param5:String, param6:String) : void
      {
         var _loc7_:int = 0;
         if(param2.flood == this.lastFlood)
         {
            return;
         }
         view.underlay.tilesUnderlay.unhideAll(BIT_FLOOD);
         this.clearDisplays(displayObjectWrapper,this.floodDisplays);
         this.lastFlood = param2.flood;
         if(param2.flood)
         {
            _loc7_ = int(param2.entity.stats.getValue(StatType.MOVEMENT));
            if(PathFloodSolver.ENABLE_REJECTED_DEBUG)
            {
               this.renderRejectedTiles(param1,param2,param3);
            }
            this.renderCommands(param1,param2,param3,param2.flood.resultSet,_loc7_,param4,param5,null);
            this.renderCommands(param1,param2,param3,param2.flood.resultSet,100000000,param4,param5,param6);
         }
      }
      
      override protected function onRender() : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:IBattleMove = null;
         displayObjectWrapper.visible = true;
         var _loc1_:BattleAssetsDef = view.board.assets;
         var _loc6_:IBattleEntity = _fsm.interact;
         if(Boolean(_loc6_) && (_loc6_ != this._turn.entity || !this._turn.entity.playerControlled))
         {
            if(!this.interactMove || this.interactMove.entity != fsm.interact || this.interactMove.first != fsm.interact.tile)
            {
               this.interactMove = new BattleMove(fsm.interact);
            }
            _loc5_ = this.interactMove;
            _loc2_ = _loc1_.board_tile_move_other_a;
            _loc3_ = _loc1_.board_tile_move_other_b;
            _loc4_ = _loc1_.board_tile_move_other_star;
         }
         else
         {
            _loc5_ = this._turn.move;
            _loc2_ = _loc1_.board_tile_move_a;
            _loc3_ = _loc1_.board_tile_move_b;
            _loc4_ = _loc1_.board_tile_move_star;
         }
         var _loc7_:Dictionary = new Dictionary();
         this.cutoutCharacter(_loc5_,_loc7_);
         view.underlay.tilesUnderlay.unhideAll(BIT_ENDPOINTS);
         this.renderWaypoint(displayObjectWrapper,_loc5_,_loc7_);
         this.renderFlood(displayObjectWrapper,_loc5_,_loc7_,_loc2_,_loc3_,_loc4_);
         this.appears.sortByRemaining();
         this.renderEndpoint(displayObjectWrapper,_loc5_,_loc7_);
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
         this.turn = view.board.sim.fsm.turn as BattleTurn;
      }
      
      public function get turn() : BattleTurn
      {
         return this._turn;
      }
      
      public function get turnMove() : IBattleMove
      {
         return this._turnMove;
      }
      
      public function set turnMove(param1:IBattleMove) : void
      {
         if(this._turnMove == param1)
         {
            return;
         }
         if(this._turnMove)
         {
            this._turnMove.removeEventListener(BattleMoveEvent.COMMITTED,this.eventDirtyHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.EXECUTING,this.eventDirtyHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.EXECUTED,this.eventDirtyHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.MOVE_CHANGED,this.eventDirtyHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.FLOOD_CHANGED,this.eventDirtyHandler);
         }
         this._turnMove = param1;
         if(this._turnMove)
         {
            this._turnMove.addEventListener(BattleMoveEvent.COMMITTED,this.eventDirtyHandler);
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTING,this.eventDirtyHandler);
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTED,this.eventDirtyHandler);
            this._turnMove.addEventListener(BattleMoveEvent.MOVE_CHANGED,this.eventDirtyHandler);
            this._turnMove.addEventListener(BattleMoveEvent.FLOOD_CHANGED,this.eventDirtyHandler);
         }
      }
      
      public function get entityMobility() : IBattleEntityMobility
      {
         return this._entityMobility;
      }
      
      public function set entityMobility(param1:IBattleEntityMobility) : void
      {
         if(param1 == this._entityMobility)
         {
            return;
         }
         if(this._entityMobility)
         {
            this._entityMobility.removeEventListener(BattleEntityMobilityEvent.MOVING,this.eventDirtyHandler);
         }
         this._entityMobility = param1;
         if(this._entityMobility)
         {
            this._entityMobility.addEventListener(BattleEntityMobilityEvent.MOVING,this.eventDirtyHandler);
         }
      }
      
      override protected function onEntityAdded() : void
      {
         if(_entity)
         {
            _entity.addEventListener(BattleEntityEvent.ENABLED,this.eventDirtyHandler);
            _entity.addEventListener(BattleEntityEvent.VISIBLE,this.eventDirtyHandler);
         }
         this.entityMobility = !!_entity ? _entity.mobility : null;
         super.onEntityAdded();
      }
      
      override protected function onEntityRemoved() : void
      {
         if(_entity)
         {
            _entity.removeEventListener(BattleEntityEvent.ENABLED,this.eventDirtyHandler);
            _entity.removeEventListener(BattleEntityEvent.VISIBLE,this.eventDirtyHandler);
         }
         this.entityMobility = null;
         super.onEntityRemoved();
      }
      
      public function set turn(param1:BattleTurn) : void
      {
         this._turn = param1;
         entity = !!this.turn ? this.turn.entity as BattleEntity : null;
         this.turnMove = !!this.turn ? this.turn.move : null;
         this.checkCanRender();
         setRenderDirty();
      }
      
      private function eventDirtyHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      private function attackHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      private function _computeCanRender() : Boolean
      {
         return computeCanRender(_fsm);
      }
      
      override protected function checkCanRender() : void
      {
         canRender = this._computeCanRender();
         var _loc1_:IBattleEntity = !!_fsm ? _fsm.interact : null;
         if(!_loc1_)
         {
            if(Boolean(this._turn) && Boolean(this._turn.entity))
            {
               if(this._turn.entity.playerControlled)
               {
                  this.interactMove = null;
               }
            }
         }
         if(!canRender)
         {
            this.interactMove = null;
         }
      }
      
      override protected function handleCanRenderChanged() : void
      {
         if(!canRender)
         {
            this.lastFlood = null;
            this.clearDisplays(displayObjectWrapper,this.floodDisplays);
            this.setWaypointDisplay(displayObjectWrapper,null,null);
            this.setEndpointDisplay(displayObjectWrapper,null,null);
            if(Boolean(view.underlay) && Boolean(view.underlay.tilesUnderlay))
            {
               view.underlay.tilesUnderlay.unhideAll(BIT_FLOOD);
               view.underlay.tilesUnderlay.unhideAll(BIT_ENDPOINTS);
            }
         }
      }
      
      public function update(param1:int) : void
      {
         if(this.appears)
         {
            this.appears.update(param1);
         }
      }
   }
}
