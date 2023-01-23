package engine.battle.board.view.underlay
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.def.BattleDeploymentArea;
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.sim.BattlePartyEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.FsmEvent;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapPool;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   
   public class WaveSpawnUnderlay extends EntityLinkedDirtyRenderSprite
   {
       
      
      private var pool:BitmapPool;
      
      private var rendered:Boolean;
      
      private var cleanedup:Boolean;
      
      private var lastEndpointDisplay:DisplayObjectWrapper;
      
      private var lastEndpointDisplayUrl:String;
      
      private var watchingEntities:Vector.<IBattleEntity>;
      
      private var wasRedeploying:Boolean;
      
      private var _pooledBmps:Vector.<DisplayObjectWrapper>;
      
      public function WaveSpawnUnderlay(param1:BattleBoardView)
      {
         this.watchingEntities = new Vector.<IBattleEntity>();
         this._pooledBmps = new Vector.<DisplayObjectWrapper>();
         super(param1);
         this.pool = view.bitmapPool;
         var _loc2_:BattleAssetsDef = view.board.assets;
         this.pool.addPool(_loc2_.tile_wave_spawn_indicator,10,40);
         fsm.addEventListener(FsmEvent.CURRENT,this.battleStateChangeHandler);
         this.pool.addEventListener(Event.CHANGE,this.eventDirty);
      }
      
      private function battleStateChangeHandler(param1:FsmEvent) : void
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:int = 0;
         var _loc5_:IBattleEntity = null;
         if(!fsm)
         {
            return;
         }
         var _loc2_:String = fsm.showDeploymentId;
         if(Boolean(_loc2_) && !this.wasRedeploying)
         {
            this.wasRedeploying = true;
            fsm.addEventListener(BattleFsmEvent.INTERACT,this.eventDirty);
            for each(_loc3_ in view.board.parties)
            {
               _loc3_.addEventListener(BattlePartyEvent.DEPLOYED,this.eventDirty);
               _loc4_ = 0;
               while(_loc4_ < _loc3_.numMembers)
               {
                  _loc5_ = _loc3_.getMember(_loc4_);
                  _loc5_.addEventListener(BattleEntityEvent.TILE_CHANGED,this.eventDirty);
                  this.watchingEntities.push(_loc5_);
                  _loc4_++;
               }
            }
         }
         else if(this.wasRedeploying)
         {
            this.cleanupBattleState();
         }
         this.eventDirty(null);
      }
      
      private function cleanupBattleState() : void
      {
         var _loc1_:IBattleEntity = null;
         var _loc2_:IBattleParty = null;
         if(!this.wasRedeploying)
         {
            return;
         }
         this.wasRedeploying = false;
         fsm.removeEventListener(BattleFsmEvent.INTERACT,this.eventDirty);
         for each(_loc1_ in this.watchingEntities)
         {
            _loc1_.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.eventDirty);
         }
         this.watchingEntities.splice(0,this.watchingEntities.length);
         for each(_loc2_ in view.board.parties)
         {
            _loc2_.removeEventListener(BattlePartyEvent.DEPLOYED,this.eventDirty);
         }
      }
      
      override public function cleanup() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this.cleanedup = true;
         fsm.removeEventListener(FsmEvent.CURRENT,this.battleStateChangeHandler);
         this.pool.removeEventListener(Event.CHANGE,this.eventDirty);
         this.cleanupBattleState();
         super.cleanup();
      }
      
      override protected function checkCanRender() : void
      {
         canRender = Boolean(_fsm) && Boolean(_fsm.showRespawnDeploymentId);
      }
      
      protected function eventDirty(param1:Event) : void
      {
         this.checkCanRender();
         if(canRender)
         {
            this.rendered = true;
            setRenderDirty();
         }
         else if(view && view.underlay && Boolean(view.underlay.tilesUnderlay))
         {
            if(this.rendered)
            {
            }
         }
      }
      
      private function clearChildren() : void
      {
         var _loc1_:DisplayObjectWrapper = null;
         displayObjectWrapper.removeAllChildren();
         for each(_loc1_ in this._pooledBmps)
         {
            _loc1_.scaleX = _loc1_.scaleY = 1;
            this.pool.reclaim(_loc1_);
         }
         this._pooledBmps.splice(0,this._pooledBmps.length);
      }
      
      override protected function onRender() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("Already cleaned up");
         }
         this.clearChildren();
         this.renderWaveSpawnAreas(_fsm.showRespawnDeploymentId);
      }
      
      private function renderWaveSpawnAreas(param1:String) : void
      {
         var _loc3_:BattleDeploymentArea = null;
         var _loc2_:BattleDeploymentAreas = _board.def.getDeploymentAreasById(param1,null);
         for each(_loc3_ in _loc2_.deployments)
         {
            this.renderWaveSpawnArea(displayObjectWrapper,_loc3_.area,_loc3_.facing);
         }
      }
      
      private function renderWaveSpawnArea(param1:DisplayObjectWrapper, param2:TileLocationArea, param3:BattleFacing) : void
      {
         var _loc6_:TileLocation = null;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:Tile = null;
         var _loc9_:IBattleEntity = null;
         var _loc10_:BattleAssetsDef = null;
         var _loc11_:Pt = null;
         var _loc12_:Number = NaN;
         var _loc4_:Tiles = view.board.tiles;
         var _loc5_:Pt = new Pt();
         for each(_loc6_ in param2.locations)
         {
            _loc7_ = null;
            _loc5_.x = _loc6_.x + param3.deltaX;
            _loc5_.y = _loc6_.y + param3.deltaY;
            _loc8_ = _loc4_.getTile(_loc5_.x,_loc5_.y);
            if(!(!_loc8_ || !_loc8_.getWalkableFor(null)))
            {
               _loc9_ = view.board.findEntityOnTile(_loc5_.x,_loc5_.y,true,null);
               if(_loc9_ == null)
               {
                  _loc10_ = view.board.assets;
                  _loc7_ = this.pool.pop(_loc10_.tile_wave_spawn_indicator);
                  this._pooledBmps.push(_loc7_);
                  if(_loc7_)
                  {
                     param1.addChild(_loc7_);
                     this.orientWaveSpawnUnderlay(_loc7_,param3,_loc5_);
                     _loc11_ = IsoMath.isoToScreen(_loc5_);
                     _loc12_ = view.units;
                     _loc7_.x = _loc11_.x * _loc12_ - _loc7_.width / 2;
                     _loc7_.y = _loc11_.y * _loc12_ - _loc7_.height / 2;
                  }
               }
            }
         }
      }
      
      private function orientWaveSpawnUnderlay(param1:DisplayObjectWrapper, param2:BattleFacing, param3:Pt) : void
      {
         switch(param2)
         {
            case BattleFacing.NW:
               param1.scaleX = -1;
               param1.scaleY = -1;
               param3.x += 2.5;
               param3.y += 0.5;
               break;
            case BattleFacing.NE:
               param1.scaleX = 1;
               param1.scaleY = -1;
               param3.x += 1.5;
               param3.y += 1.5;
               break;
            case BattleFacing.SW:
               param1.scaleX = -1;
               param1.scaleY = 1;
               param3.x += 1.5;
               param3.y += -0.5;
               break;
            case BattleFacing.SE:
            default:
               param1.scaleX = 1;
               param1.scaleY = 1;
               param3.x += 0.5;
               param3.y += 0.5;
         }
      }
   }
}
