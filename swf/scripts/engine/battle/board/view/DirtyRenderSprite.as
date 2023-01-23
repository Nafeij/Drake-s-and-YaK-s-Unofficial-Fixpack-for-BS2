package engine.battle.board.view
{
   import as3isolib.utils.IsoUtil;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapPool;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class DirtyRenderSprite
   {
       
      
      protected var view:BattleBoardView;
      
      private var _renderDirty:Boolean = true;
      
      protected var _canRender:Boolean = true;
      
      protected var _fsm:BattleFsm;
      
      protected var _board:BattleBoard;
      
      private var bitmapPool:BitmapPool;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      private var _allowRender:Boolean;
      
      protected var hoverScaleableDicts:Vector.<Dictionary>;
      
      private var HOVER_SCALE:Number = 1.3;
      
      protected var _hoverTileLocation:TileLocation;
      
      public function DirtyRenderSprite(param1:BattleBoardView)
      {
         this.hoverScaleableDicts = new Vector.<Dictionary>();
         super();
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_TILES_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         this.view = param1;
         this._board = param1.board;
         this._fsm = param1.board.sim.fsm;
         this.bitmapPool = param1.bitmapPool;
         this.bitmapPool.addEventListener(Event.CHANGE,this.bitmapPoolChangeHandler);
      }
      
      private function battleGuiEnableHandler(param1:Event) : void
      {
         this.checkCanRender();
         this.setRenderDirty();
      }
      
      protected function bitmapPoolChangeHandler(param1:Event) : void
      {
         this.setRenderDirty();
      }
      
      public function get board() : BattleBoard
      {
         return this._board;
      }
      
      public function get fsm() : BattleFsm
      {
         return this._fsm;
      }
      
      public function cleanup() : void
      {
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_TILES_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         if(this.bitmapPool)
         {
            this.bitmapPool.removeEventListener(Event.CHANGE,this.bitmapPoolChangeHandler);
            this.bitmapPool = null;
         }
         this.view = null;
         this._board = null;
         this._fsm = null;
      }
      
      protected function checkCanRender() : void
      {
         this.canRender = this._canRender;
      }
      
      public function get canRender() : Boolean
      {
         return this._canRender;
      }
      
      public function set canRender(param1:Boolean) : void
      {
         this._canRender = param1;
         var _loc2_:Boolean = BattleFsmConfig.guiTilesShouldRender;
         var _loc3_:Boolean = this._canRender && _loc2_;
         if(this._allowRender != _loc3_)
         {
            this._allowRender = _loc3_;
            this.handleCanRenderChanged();
            this.setRenderDirty();
         }
      }
      
      protected function handleCanRenderChanged() : void
      {
      }
      
      final protected function setRenderDirty() : void
      {
         this._renderDirty = true;
         this.checkCanRender();
      }
      
      final protected function unsetRenderDirty() : void
      {
         this._renderDirty = false;
      }
      
      final public function render() : void
      {
         if(this._renderDirty)
         {
            if(this._allowRender)
            {
               this.displayObjectWrapper.visible = true;
               this._renderDirty = false;
               this.onRender();
            }
            else
            {
               this.displayObjectWrapper.visible = false;
            }
         }
      }
      
      protected function positionTileBmp(param1:TileLocation, param2:DisplayObjectWrapper, param3:int) : void
      {
         var _loc4_:Point = IsoBattleRectangleUtils.getIsoPointScreenPoint(this.view.units,param1.x + 0.5 * param3,param1.y + 0.5 * param3);
         param2.x = int(_loc4_.x - param2.width / 2);
         param2.y = int(_loc4_.y - param2.height / 2);
      }
      
      public function get logger() : ILogger
      {
         return this.view.board.logger;
      }
      
      protected function onRender() : void
      {
      }
      
      protected function checkBmpScale(param1:TileLocation, param2:DisplayObjectWrapper, param3:int) : void
      {
         var _loc4_:TileLocation = Boolean(this._board) && Boolean(this._board._hoverTile) ? this._board._hoverTile.location : null;
         if(_loc4_ == param1)
         {
            param2.scale = this.HOVER_SCALE;
         }
         else
         {
            param2.scale = 1;
         }
      }
      
      public function set hoverTileLocation(param1:TileLocation) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         if(this._hoverTileLocation == param1)
         {
            return;
         }
         this.hoverScaleAt(this._hoverTileLocation,1);
         this._hoverTileLocation = param1;
         this.hoverScaleAt(this._hoverTileLocation,this.HOVER_SCALE);
      }
      
      public function get hoverTileLocation() : TileLocation
      {
         return this._hoverTileLocation;
      }
      
      private function hoverScaleAt(param1:TileLocation, param2:Number) : void
      {
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:Dictionary = null;
         if(!param1)
         {
            return;
         }
         for each(_loc4_ in this.hoverScaleableDicts)
         {
            _loc3_ = _loc4_[param1];
            if(_loc3_)
            {
               _loc3_.scale = param2;
               this.positionTileBmp(param1,_loc3_,1);
            }
         }
      }
   }
}
