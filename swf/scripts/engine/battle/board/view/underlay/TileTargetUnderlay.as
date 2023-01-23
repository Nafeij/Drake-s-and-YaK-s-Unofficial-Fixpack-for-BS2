package engine.battle.board.view.underlay
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class TileTargetUnderlay extends EntityLinkedDirtyRenderSprite
   {
      
      public static const BIT:uint = TilesUnderlay.nextBit("TileTargetUnderlay.BIT");
       
      
      private var tileTargets:Vector.<DisplayObjectWrapper>;
      
      private var _shownTiles:Dictionary;
      
      public function TileTargetUnderlay(param1:BattleBoardView)
      {
         this.tileTargets = new Vector.<DisplayObjectWrapper>();
         this._shownTiles = new Dictionary();
         super(param1);
         hoverScaleableDicts.push(this._shownTiles);
         view.bitmapPool.addPool(view.board.assets.board_enemy_target_1,1,40);
         _fsm.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.eventDirtyHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.eventDirtyHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.eventDirtyHandler);
         _board.addEventListener(BattleBoardEvent.HOVER_TILE,this.hoverHandler);
      }
      
      private function removeAllArrows() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObjectWrapper = null;
         if(this.tileTargets.length)
         {
            _loc1_ = 0;
            while(_loc1_ < this.tileTargets.length)
            {
               _loc2_ = this.tileTargets[_loc1_];
               view.bitmapPool.reclaim(_loc2_);
               _loc1_++;
            }
            this.tileTargets.splice(0,this.tileTargets.length);
         }
         displayObjectWrapper.removeAllChildren();
      }
      
      override public function cleanup() : void
      {
         _board.removeEventListener(BattleBoardEvent.HOVER_TILE,this.hoverHandler);
         _fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.eventDirtyHandler);
         _fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.eventDirtyHandler);
         _fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.eventDirtyHandler);
         this.removeAllArrows();
         this.tileTargets = null;
         super.cleanup();
      }
      
      private function hoverHandler(param1:BattleBoardEvent) : void
      {
         hoverTileLocation = Boolean(_board) && Boolean(_board._hoverTile) ? _board._hoverTile.location : null;
      }
      
      override protected function checkCanRender() : void
      {
         var _loc1_:BattleAbility = !!_fsm ? _fsm._ability : null;
         canRender = _loc1_ && _loc1_.caster && _loc1_.caster.playerControlled && !_loc1_.executed && !_loc1_.executing && _loc1_.def.targetRule.isTile;
      }
      
      private function eventDirtyHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      override protected function handleCanRenderChanged() : void
      {
         if(!canRender)
         {
            if(Boolean(view) && Boolean(view.underlay))
            {
               view.underlay.tilesUnderlay.unhideAll(BIT);
            }
         }
      }
      
      override protected function onRender() : void
      {
         var _loc1_:DisplayObjectWrapper = null;
         var _loc2_:BattleAbility = null;
         var _loc4_:Tile = null;
         var _loc5_:* = null;
         if(!view || !view.underlay || !view.underlay.tilesUnderlay || !view.bitmapPool)
         {
            return;
         }
         view.underlay.tilesUnderlay.unhideAll(BIT);
         if(!this.tileTargets)
         {
            return;
         }
         for each(_loc1_ in this.tileTargets)
         {
            if(_loc1_)
            {
               _loc1_.visible = false;
            }
         }
         _loc2_ = Boolean(fsm) && Boolean(fsm.turn) ? fsm.turn.ability : null;
         if(!_loc2_ || !_loc2_.def || !_loc2_.def.tileTargetUrl || !_loc2_.targetSet || !_loc2_.targetSet.tiles)
         {
            return;
         }
         var _loc3_:int = 0;
         for(_loc5_ in this._shownTiles)
         {
            delete this._shownTiles[_loc5_];
         }
         for each(_loc4_ in _loc2_.targetSet.tiles)
         {
            _loc3_ = this._showTile(_loc4_,_loc2_.def,_loc3_);
         }
      }
      
      private function _showTile(param1:Tile, param2:BattleAbilityDef, param3:int) : int
      {
         if(!param1)
         {
            return param3;
         }
         var _loc4_:DisplayObjectWrapper = null;
         if(param3 >= this.tileTargets.length)
         {
            _loc4_ = view.bitmapPool.pop(param2.tileTargetUrl);
            if(!_loc4_)
            {
               view.board.logger.error("TileTargetUnderlay could not pop target tile [" + param2.tileTargetUrl + "] for " + param2);
               return param3;
            }
            this.tileTargets.push(_loc4_);
            displayObjectWrapper.addChild(_loc4_);
         }
         _loc4_ = this.tileTargets[param3];
         _loc4_.visible = true;
         positionTileBmp(param1.location,_loc4_,1);
         param3++;
         view.underlay.tilesUnderlay.hide(param1.location.x,param1.location.y,BIT);
         this._shownTiles[param1.location] = _loc4_;
         return param3;
      }
   }
}
