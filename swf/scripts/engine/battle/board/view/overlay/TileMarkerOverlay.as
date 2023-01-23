package engine.battle.board.view.overlay
{
   import engine.battle.BattleAssetsDef;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.tile.def.TileLocation;
   import flash.geom.Point;
   
   public class TileMarkerOverlay extends EntityLinkedDirtyRenderSprite
   {
       
      
      private var _loc:TileLocation;
      
      private var _tileWidth:int = 2;
      
      public var tile:DisplayObjectWrapper;
      
      public function TileMarkerOverlay(param1:BattleBoardView)
      {
         super(param1);
         displayObjectWrapper.name = "tile_marker";
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.animClipSpritePool.addPool(_loc2_.board_active_enemy_1,1,1);
         view.animClipSpritePool.addPool(_loc2_.board_active_enemy_2,1,1);
      }
      
      public function get tileLocation() : TileLocation
      {
         return this._loc;
      }
      
      public function set tileLocation(param1:TileLocation) : void
      {
         if(this._loc != param1)
         {
            this._loc = param1;
            setRenderDirty();
            this.checkCanRender();
         }
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override protected function handleCanRenderChanged() : void
      {
         this.clearChildren();
      }
      
      private function clearChildren() : void
      {
         if(this.tile)
         {
            view.animClipSpritePool.reclaim(this.tile);
            this.tile = null;
         }
         displayObjectWrapper.removeAllChildren();
      }
      
      override protected function onRender() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Point = null;
         this.clearChildren();
         if(this._loc)
         {
            if(this._tileWidth == 1)
            {
               _loc1_ = view.board.assets.board_active_enemy_1;
            }
            else
            {
               _loc1_ = view.board.assets.board_active_enemy_2;
            }
            this.tile = view.animClipSpritePool.pop(_loc1_);
            this.tile.name = "tile";
            displayObjectWrapper.addChild(this.tile);
            _loc2_ = this._loc.x + this._tileWidth / 2;
            _loc3_ = this._loc.y + this._tileWidth / 2;
            _loc4_ = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,_loc2_,_loc3_);
            this.tile.x = _loc4_.x;
            this.tile.y = _loc4_.y;
         }
      }
      
      override protected function checkCanRender() : void
      {
         canRender = this._loc != null;
      }
      
      public function get tileWidth() : int
      {
         return this._tileWidth;
      }
      
      public function set tileWidth(param1:int) : void
      {
         if(this._tileWidth == param1)
         {
            return;
         }
         this._tileWidth = param1;
         setRenderDirty();
      }
   }
}
