package engine.battle.board.view.overlay
{
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.DirtyRenderSprite;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.sim.TileDiamond;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class TileTargetOverlay extends DirtyRenderSprite
   {
       
      
      private var bmps:Vector.<DisplayObjectWrapper>;
      
      private var spawner:DisplayObjectWrapper;
      
      private var _showTiles:Vector.<Tile>;
      
      public function TileTargetOverlay(param1:BattleBoardView)
      {
         this.bmps = new Vector.<DisplayObjectWrapper>();
         this._showTiles = new Vector.<Tile>();
         super(param1);
         canRender = false;
         _fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.dirtyHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.dirtyHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.dirtyHandler);
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.bitmapPool.addPool(_loc2_.board_ability_target_1,1,32);
         view.bitmapPool.addPool(_loc2_.mouse_hover_1x2,2,32);
      }
      
      override public function cleanup() : void
      {
         var _loc1_:DisplayObjectWrapper = null;
         if(_fsm)
         {
            _fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.dirtyHandler);
            _fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.dirtyHandler);
            _fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.dirtyHandler);
         }
         for each(_loc1_ in this.bmps)
         {
            view.bitmapPool.reclaim(_loc1_);
         }
         this.bmps = new Vector.<DisplayObjectWrapper>();
         super.cleanup();
      }
      
      private function dirtyHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      override protected function checkCanRender() : void
      {
         var _loc1_:BattleAbility = !!_fsm ? _fsm._ability : null;
         canRender = _loc1_ && _loc1_.caster && _loc1_.caster.playerControlled && !_loc1_.executed && !_loc1_.executing && _loc1_.def.targetRule.isTile;
      }
      
      override protected function onRender() : void
      {
         var _loc2_:Tile = null;
         var _loc4_:DisplayObjectWrapper = null;
         var _loc6_:Tiles = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TileDiamond = null;
         var _loc10_:TileLocation = null;
         var _loc11_:BattleFacing = null;
         var _loc12_:Tile = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Point = null;
         var _loc1_:BattleAbility = !!_fsm ? _fsm._ability : null;
         if(!_loc1_)
         {
            canRender = false;
            return;
         }
         if(!this.spawner)
         {
            this.spawner = view.bitmapPool.pop(view.board.assets.mouse_hover_1x2);
            this.spawner.visible = false;
            this.spawner.name = "spawn_indicator";
         }
         this._showTiles.splice(0,this._showTiles.length);
         var _loc3_:Tile = _loc1_.targetSet.baseTile;
         if(_loc1_.def.targetRule == BattleAbilityTargetRule.TILE_EMPTY_RANDOM)
         {
            if(_loc3_)
            {
               _loc6_ = board.tiles;
               _loc7_ = _loc1_.def.minResultDistance;
               _loc8_ = _loc1_.def.maxResultDistance;
               _loc9_ = new TileDiamond(_loc6_,_loc3_.rect,_loc7_,_loc8_,null,0);
               for each(_loc10_ in _loc9_.hugs)
               {
                  _loc2_ = _loc6_.getTileByLocation(_loc10_);
                  if(_loc2_)
                  {
                     if(!_loc2_.numResidents)
                     {
                        this._showTiles.push(_loc2_);
                     }
                  }
               }
            }
         }
         else
         {
            for each(_loc2_ in _loc1_.targetSet.tiles)
            {
               if(this._showTiles.indexOf(_loc2_) < 0)
               {
                  this._showTiles.push(_loc2_);
               }
            }
         }
         while(this.bmps.length < this._showTiles.length)
         {
            _loc4_ = view.bitmapPool.pop(view.board.assets.board_ability_target_1);
            if(_loc4_)
            {
               displayObjectWrapper.addChild(_loc4_);
               _loc4_.name = "tile_target_overlay";
               this.bmps.push(_loc4_);
            }
         }
         this.spawner.removeFromParent();
         if(_loc1_._def.targetRule == BattleAbilityTargetRule.TILE_EMPTY_1x2_FACING_CASTER)
         {
            _loc11_ = BattleAbilityValidation.findValidFacingFor1x2(_loc1_.caster,_loc1_.targetSet.baseTile);
            if(_loc11_)
            {
               this.spawner.visible = true;
               displayObjectWrapper.addChild(this.spawner);
               this._positionSpawner(_loc3_,_loc11_);
            }
         }
         if(!_board || !this.bmps || this.bmps.length == 0)
         {
            for each(_loc4_ in this.bmps)
            {
               _loc4_.visible = false;
            }
            return;
         }
         var _loc5_:uint = 0;
         while(_loc5_ < this._showTiles.length)
         {
            _loc12_ = this._showTiles[_loc5_];
            _loc4_ = this.bmps[_loc5_];
            if(!_loc12_ || _loc1_.executed || _loc1_.executing || Boolean(_loc1_.def.tileTargetUrl))
            {
               _loc4_.visible = false;
            }
            else
            {
               _loc4_.visible = true;
               _loc13_ = _loc12_.location.x + 0.5;
               _loc14_ = _loc12_.location.y + 0.5;
               _loc15_ = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,_loc13_,_loc14_);
               _loc4_.x = int(_loc15_.x - _loc4_.width / 2);
               _loc4_.y = int(_loc15_.y - _loc4_.height / 2);
            }
            _loc5_++;
         }
         while(_loc5_ < this.bmps.length)
         {
            _loc4_ = this.bmps[_loc5_];
            _loc4_.visible = false;
            _loc5_++;
         }
         if(_loc1_.executed || _loc1_.executing)
         {
            canRender = false;
            return;
         }
      }
      
      private function _positionSpawner(param1:Tile, param2:BattleFacing) : void
      {
         var _loc3_:Number = param1.location.x + 0.5;
         var _loc4_:Number = param1.location.y + 0.5;
         var _loc5_:Number = view.units;
         var _loc6_:Point = IsoBattleRectangleUtils.getIsoPointScreenPoint(_loc5_,_loc3_,_loc4_);
         var _loc7_:Boolean = false;
         var _loc8_:DisplayObjectWrapper = this.spawner;
         var _loc9_:TileRect = new TileRect(param1.location,1,2,param2);
         MovePlanOverlay.centerTheDisplayObject(param2,_loc8_,false,_loc7_);
         var _loc10_:Number = _loc5_ * _loc9_.diameter;
         var _loc11_:Number = _loc5_ * _loc9_.tail;
         this.spawner.x = int(_loc6_.x);
         this.spawner.y = int(_loc6_.y);
         if(_loc9_.tail == 0)
         {
            _loc8_.y += _loc10_ / 2;
         }
         else if(param2 == BattleFacing.NE)
         {
            _loc8_.y -= _loc10_ / 4;
            _loc8_.x -= _loc5_ + _loc10_ / 2;
         }
         else if(param2 == BattleFacing.NW)
         {
            _loc8_.y -= _loc10_ / 4;
            _loc8_.x += _loc5_ + _loc10_ / 2;
         }
         else if(param2 == BattleFacing.SW)
         {
            _loc8_.y += _loc10_ / 2 + _loc11_ / 4 - _loc5_ / 2;
            _loc8_.x += _loc5_ + _loc10_ / 2;
         }
         else if(param2 == BattleFacing.SE)
         {
            _loc8_.y += _loc10_ / 2 + _loc11_ / 4 - _loc5_ / 2;
            _loc8_.x -= _loc5_ + _loc10_ / 2;
         }
      }
   }
}
