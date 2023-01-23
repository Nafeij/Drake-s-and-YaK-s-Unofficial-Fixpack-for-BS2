package engine.battle.board.view.overlay
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.BattleAssetsDef;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.DirtyRenderSprite;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.tile.Tile;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class TileHoverOverlay extends DirtyRenderSprite
   {
       
      
      private var bmp:DisplayObjectWrapper;
      
      private var _mpo:MovePlanOverlay;
      
      public function TileHoverOverlay(param1:BattleBoardView)
      {
         super(param1);
         canRender = false;
         _board.addEventListener(BattleBoardEvent.HOVER_TILE,this.tileHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.bitmapPool.addPool(_loc2_.mouse_hover_tile,1,1);
      }
      
      public function get mpo() : MovePlanOverlay
      {
         return this._mpo;
      }
      
      public function set mpo(param1:MovePlanOverlay) : void
      {
         if(this._mpo)
         {
            this._mpo.tho = null;
         }
         this._mpo = param1;
         if(this._mpo)
         {
            this._mpo.tho = this;
         }
      }
      
      public function makeHoverDirty() : void
      {
         setRenderDirty();
      }
      
      override public function cleanup() : void
      {
         this.mpo = null;
         if(_board)
         {
            _board.removeEventListener(BattleBoardEvent.HOVER_TILE,this.tileHandler);
         }
         if(_fsm)
         {
            _fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
         }
         if(this.bmp)
         {
            view.bitmapPool.reclaim(this.bmp);
            this.bmp = null;
         }
         super.cleanup();
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
      }
      
      private function _computeCanRender() : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:IBattleMove = null;
         var _loc5_:IBattleEntity = null;
         if(!PlatformInput.lastInputGp)
         {
            return false;
         }
         var _loc1_:* = _board._hoverTile != null;
         if(!_loc1_)
         {
            return false;
         }
         var _loc2_:BattleTurn = !!_fsm ? _fsm._turn : null;
         if(!_loc2_ || !_loc2_._ability || _loc2_.ability.executed || _loc2_.committed)
         {
            return false;
         }
         if(!_loc2_.ability.def.targetRule.isTile)
         {
            return false;
         }
         return true;
      }
      
      override protected function checkCanRender() : void
      {
         canRender = this._computeCanRender();
      }
      
      private function tileHandler(param1:Event) : void
      {
         setRenderDirty();
      }
      
      override protected function onRender() : void
      {
         var _loc1_:Tile = !!_board ? _board._hoverTile : null;
         if(!_loc1_)
         {
            canRender = false;
            return;
         }
         if(!this.bmp)
         {
            this.bmp = view.bitmapPool.pop(view.board.assets.mouse_hover_tile);
            this.bmp.visible = true;
            this.bmp.name = "tile_select_hover";
            displayObjectWrapper.addChild(this.bmp);
         }
         var _loc2_:Number = _loc1_.location.x + 0.5;
         var _loc3_:Number = _loc1_.location.y + 0.5;
         var _loc4_:Point = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,_loc2_,_loc3_);
         this.bmp.x = int(_loc4_.x - this.bmp.width / 2);
         this.bmp.y = int(_loc4_.y - this.bmp.height / 2);
      }
   }
}
