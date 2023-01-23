package engine.battle.board.view.underlay
{
   import as3isolib.utils.IsoUtil;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.overlay.TileMarkerOverlay;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.BattleTurnEvent;
   import engine.core.fsm.FsmEvent;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceGroup;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class UnderlayGroupSprite
   {
      
      public static const BIT:uint = TilesUnderlay.nextBit("UnderlayGroupSprite.BIT");
       
      
      public var movePlanUnderlay:MovePlanUnderlay;
      
      public var tilesUnderlay:TilesUnderlay;
      
      private var deploymentUnderlay:DeploymentUnderlay;
      
      private var corpseTilesUnderlay:CorpseTilesUnderlay;
      
      private var waveSpawnUnderlay:WaveSpawnUnderlay;
      
      public var marker:TileMarkerOverlay;
      
      public var tileTriggerTilesUnderlay:TileTriggerTilesUnderlay;
      
      private var dirty:Boolean = true;
      
      private var view:BattleBoardView;
      
      private var _turn:BattleTurn;
      
      private var tileBmps:Dictionary;
      
      private var displays:Vector.<DisplayObjectWrapper>;
      
      private var resourceGroup:ResourceGroup;
      
      private var fsm:BattleFsm;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      private var _turnMove:IBattleMove;
      
      public function UnderlayGroupSprite(param1:BattleBoardView)
      {
         this.tileBmps = new Dictionary();
         this.displays = new Vector.<DisplayObjectWrapper>();
         super();
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         this.view = param1;
         this.displayObjectWrapper.name = "underlay";
         this.resourceGroup = new ResourceGroup(this,param1.board._scene._context.logger);
         this.marker = new TileMarkerOverlay(param1);
         this.movePlanUnderlay = new MovePlanUnderlay(param1);
         this.tilesUnderlay = new TilesUnderlay(param1);
         this.deploymentUnderlay = new DeploymentUnderlay(param1);
         this.corpseTilesUnderlay = new CorpseTilesUnderlay(param1);
         this.waveSpawnUnderlay = new WaveSpawnUnderlay(param1);
         this.tileTriggerTilesUnderlay = new TileTriggerTilesUnderlay(param1);
         this.displayObjectWrapper.addChild(this.tileTriggerTilesUnderlay.displayObjectWrapper);
         this.fsm = param1.board.sim.fsm;
         this.fsm.addEventListener(FsmEvent.CURRENT,this.eventDirtyHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN,this.eventDirtyHandler);
         this.fsm.addEventListener(BattleFsmEvent.INTERACT,this.eventDirtyHandler);
         this.displayObjectWrapper.addChild(this.tilesUnderlay.displayObjectWrapper);
         this.displayObjectWrapper.addChild(this.deploymentUnderlay.displayObjectWrapper);
         this.displayObjectWrapper.addChild(this.marker.displayObjectWrapper);
         this.displayObjectWrapper.addChild(this.movePlanUnderlay.displayObjectWrapper);
         this.displayObjectWrapper.addChild(this.corpseTilesUnderlay.displayObjectWrapper);
         this.displayObjectWrapper.addChild(this.waveSpawnUnderlay.displayObjectWrapper);
      }
      
      public function handleWalkableTilesChanged() : void
      {
         this.tilesUnderlay.handleWalkableTilesChanged();
      }
      
      private function removeAllDisplays() : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.displays.length)
         {
            _loc2_ = this.displays[_loc1_];
            this.view.bitmapPool.reclaim(_loc2_);
            _loc1_++;
         }
         this.displayObjectWrapper.removeAllChildren();
      }
      
      public function update(param1:int) : void
      {
         if(this.movePlanUnderlay)
         {
            this.movePlanUnderlay.update(param1);
         }
      }
      
      public function cleanup() : void
      {
         this.turn = null;
         this.fsm.removeEventListener(FsmEvent.CURRENT,this.eventDirtyHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN,this.eventDirtyHandler);
         this.fsm.removeEventListener(BattleFsmEvent.INTERACT,this.eventDirtyHandler);
         this.fsm = null;
         this.removeAllDisplays();
         this.displayObjectWrapper.removeAllChildren();
         this.resourceGroup.release();
         this.resourceGroup = null;
         this.marker.cleanup();
         this.marker = null;
         this.movePlanUnderlay.cleanup();
         this.movePlanUnderlay = null;
         this.tilesUnderlay.cleanup();
         this.tilesUnderlay = null;
         this.deploymentUnderlay.cleanup();
         this.deploymentUnderlay = null;
         this.corpseTilesUnderlay.cleanup();
         this.corpseTilesUnderlay = null;
         this.waveSpawnUnderlay.cleanup();
         this.waveSpawnUnderlay = null;
         this.tileTriggerTilesUnderlay.cleanup();
         this.tileTriggerTilesUnderlay = null;
         this.tileBmps = null;
         this.view = null;
      }
      
      private function eventDirtyHandler(param1:Event) : void
      {
         this.dirty = true;
         this.turn = this.fsm.turn as BattleTurn;
      }
      
      private function setBmpr(param1:DisplayObjectContainer, param2:TileLocation, param3:BitmapResource, param4:int) : Bitmap
      {
         var _loc5_:Bitmap = param3.bmp;
         if(_loc5_)
         {
            this.positionBmp(param2,_loc5_,param4);
            param1.addChild(_loc5_);
         }
         return _loc5_;
      }
      
      public function positionBmp(param1:TileLocation, param2:Bitmap, param3:int) : void
      {
         var _loc4_:Point = IsoBattleRectangleUtils.getIsoPointScreenPoint(this.view.units,param1.x + 0.5 * param3,param1.y + 0.5 * param3);
         param2.x = _loc4_.x - param2.width / 2;
         param2.y = _loc4_.y - param2.height / 2;
      }
      
      private function setTile(param1:int, param2:int, param3:String) : void
      {
         var _loc5_:DisplayObjectWrapper = null;
         var _loc4_:Tile = this.view.board.tiles.getTile(param1,param2);
         if(_loc4_)
         {
            if(!this.tileBmps[_loc4_])
            {
               if(param3)
               {
                  _loc5_ = this.view.bitmapPool.pop(param3);
                  this.displays.push(_loc5_);
                  this.tileBmps[_loc4_] = _loc5_;
               }
            }
         }
      }
      
      private function setTileForEntity(param1:BattleEntity, param2:String) : void
      {
         var _loc4_:int = 0;
         this.setTile(param1.x,param1.y,param2);
         var _loc3_:int = 0;
         while(_loc3_ < param1.boardWidth)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.boardLength)
            {
               if(_loc3_ != 0 || _loc4_ != 0)
               {
                  this.setTile(param1.x + _loc3_,param1.y + _loc4_,"");
               }
               _loc4_++;
            }
            _loc3_++;
         }
      }
      
      private function setActiveVisible(param1:DisplayObject, param2:DisplayObject) : void
      {
         if(param1)
         {
            param1.visible = param1 == param2;
         }
      }
      
      private function setupTiles() : void
      {
         this.tilesUnderlay.unhideAll(BIT);
         if(!this._turn)
         {
            return;
         }
      }
      
      private function get active() : BattleEntity
      {
         return !!this._turn ? this._turn.entity as BattleEntity : null;
      }
      
      public function render() : void
      {
         this.tilesUnderlay.render();
         this.movePlanUnderlay.render();
         this.deploymentUnderlay.render();
         this.corpseTilesUnderlay.render();
         this.waveSpawnUnderlay.render();
         this.marker.render();
         this.tileTriggerTilesUnderlay.render();
         if(!this.dirty)
         {
            return;
         }
         this.dirty = false;
         this.setupTiles();
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
         }
         this._turnMove = param1;
         if(this._turnMove)
         {
            this._turnMove.addEventListener(BattleMoveEvent.COMMITTED,this.eventDirtyHandler);
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTING,this.eventDirtyHandler);
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTED,this.eventDirtyHandler);
         }
      }
      
      public function get turn() : BattleTurn
      {
         return this._turn;
      }
      
      public function set turn(param1:BattleTurn) : void
      {
         if(this._turn == param1)
         {
            return;
         }
         if(this._turn)
         {
            this._turn.removeEventListener(BattleTurnEvent.COMPLETE,this.eventDirtyHandler);
            this._turn.removeEventListener(BattleTurnEvent.ABILITY,this.eventDirtyHandler);
         }
         this._turn = param1;
         this.turnMove = !!this._turn ? this._turn.move : null;
         if(this._turn)
         {
            this._turn.addEventListener(BattleTurnEvent.COMPLETE,this.eventDirtyHandler);
            this._turn.addEventListener(BattleTurnEvent.ABILITY,this.eventDirtyHandler);
         }
      }
   }
}
