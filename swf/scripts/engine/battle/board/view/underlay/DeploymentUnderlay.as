package engine.battle.board.view.underlay
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.battle.board.view.overlay.MovePlanOverlay;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.sim.BattlePartyEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.FsmEvent;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapPool;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class DeploymentUnderlay extends EntityLinkedDirtyRenderSprite
   {
      
      public static const BIT:uint = TilesUnderlay.nextBit("DeploymentUnderlay");
       
      
      private var pool:BitmapPool;
      
      private var rendered:Boolean;
      
      private var cleanedup:Boolean;
      
      private var lastEndpointDisplay:DisplayObjectWrapper;
      
      private var lastEndpointDisplayUrl:String;
      
      private var watchingEntities:Vector.<IBattleEntity>;
      
      private var wasDeploying:Boolean;
      
      private var _pooledBmps:Vector.<DisplayObjectWrapper>;
      
      public function DeploymentUnderlay(param1:BattleBoardView)
      {
         this.watchingEntities = new Vector.<IBattleEntity>();
         this._pooledBmps = new Vector.<DisplayObjectWrapper>();
         super(param1);
         this.pool = view.bitmapPool;
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.animClipSpritePool.addPool(_loc2_.board_active_1,1,16);
         view.animClipSpritePool.addPool(_loc2_.board_active_1x2,1,16);
         view.animClipSpritePool.addPool(_loc2_.board_active_2,1,16);
         this.pool.addPool(_loc2_.board_tile_move_a,20,80);
         this.pool.addPool(_loc2_.board_tile_move_b,20,80);
         fsm.addEventListener(FsmEvent.CURRENT,this.battleStateChangeHandler);
         this.pool.addEventListener(Event.CHANGE,this.eventDirty);
         if(view.board)
         {
            view.board.addEventListener(BattleBoardEvent.BOARD_PARTY_CHANGED,this.updateBattleEntityListeners);
         }
      }
      
      private function battleStateChangeHandler(param1:FsmEvent) : void
      {
         if(!fsm)
         {
            return;
         }
         var _loc2_:String = fsm.showDeploymentId;
         if(Boolean(_loc2_) && !this.wasDeploying)
         {
            this.wasDeploying = true;
            fsm.addEventListener(BattleFsmEvent.INTERACT,this.eventDirty);
            _board.addEventListener(BattleBoardEvent.SELECT_TILE,this.selectTileHandler);
            this.addBattleEntityListeners();
         }
         else if(this.wasDeploying)
         {
            this.cleanupBattleState();
         }
         this.eventDirty(null);
      }
      
      public function updateBattleEntityListeners(param1:Event) : void
      {
         this.removeBattleEntityListeners();
         this.addBattleEntityListeners();
         this.eventDirty(null);
      }
      
      private function addBattleEntityListeners() : void
      {
         var _loc1_:IBattleParty = null;
         var _loc2_:int = 0;
         var _loc3_:IBattleEntity = null;
         for each(_loc1_ in view.board.parties)
         {
            _loc1_.addEventListener(BattlePartyEvent.DEPLOYED,this.eventDirty);
            _loc2_ = 0;
            while(_loc2_ < _loc1_.numMembers)
            {
               _loc3_ = _loc1_.getMember(_loc2_);
               _loc3_.addEventListener(BattleEntityEvent.TILE_CHANGED,this.eventDirty);
               this.watchingEntities.push(_loc3_);
               _loc2_++;
            }
         }
      }
      
      private function removeBattleEntityListeners() : void
      {
         var _loc1_:IBattleParty = null;
         var _loc2_:IBattleEntity = null;
         for each(_loc1_ in view.board.parties)
         {
            _loc1_.removeEventListener(BattlePartyEvent.DEPLOYED,this.eventDirty);
         }
         for each(_loc2_ in this.watchingEntities)
         {
            _loc2_.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.eventDirty);
         }
         this.watchingEntities.splice(0,this.watchingEntities.length);
      }
      
      private function cleanupBattleState() : void
      {
         var _loc1_:IBattleParty = null;
         if(!this.wasDeploying)
         {
            return;
         }
         this.wasDeploying = false;
         fsm.removeEventListener(BattleFsmEvent.INTERACT,this.eventDirty);
         _board.removeEventListener(BattleBoardEvent.SELECT_TILE,this.selectTileHandler);
         this.removeBattleEntityListeners();
         for each(_loc1_ in view.board.parties)
         {
            _loc1_.removeEventListener(BattlePartyEvent.DEPLOYED,this.eventDirty);
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
         if(view.board)
         {
            view.board.removeEventListener(BattleBoardEvent.BOARD_PARTY_CHANGED,this.updateBattleEntityListeners);
         }
         this.cleanupBattleState();
         super.cleanup();
      }
      
      override protected function checkCanRender() : void
      {
         canRender = Boolean(_fsm) && Boolean(_fsm.showDeploymentId);
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
               view.underlay.tilesUnderlay.unhideAll(BIT);
            }
         }
      }
      
      private function clearChildren() : void
      {
         var _loc1_:DisplayObjectWrapper = null;
         this.setEndpointDisplay(null,null,null);
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
         var _loc2_:int = 0;
         var _loc3_:IBattleParty = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("Already cleaned up");
         }
         view.underlay.tilesUnderlay.unhideAll(BIT);
         this.clearChildren();
         var _loc1_:IBattleEntity = fsm.interact;
         if(_loc1_)
         {
            if(!_loc1_.party)
            {
               return;
            }
            if(!_loc1_.isPlayer)
            {
               return;
            }
            if(_loc1_.deploymentFinalized)
            {
               return;
            }
            if(!_loc1_.party.deployed)
            {
               this.renderDeploymentAreas(_loc1_.party.deployment,_loc1_);
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < view.board.numParties)
            {
               _loc3_ = view.board.getParty(_loc2_);
               if(_loc3_.type == BattlePartyType.LOCAL)
               {
                  if(!_loc3_.deployed)
                  {
                     this.renderDeploymentAreas(_loc3_.deployment,null);
                  }
               }
               _loc2_++;
            }
         }
         this.renderEndpoint(_board.selectedTile);
      }
      
      private function renderDeploymentAreas(param1:String, param2:IBattleEntity) : void
      {
         var _loc3_:BattleDeploymentAreas = _board.def.getDeploymentAreasById(param1,null);
         this.renderDeploymentArea(displayObjectWrapper,_loc3_.area,param2);
      }
      
      private function getMoveTile(param1:TileLocation) : String
      {
         var _loc2_:int = int((param1.x + param1.y) / 2) * 2;
         var _loc3_:int = param1.x + param1.y;
         var _loc4_:* = _loc2_ == _loc3_;
         if(_loc4_)
         {
            return view.board.assets.board_tile_move_a;
         }
         return view.board.assets.board_tile_move_b;
      }
      
      private function renderDeploymentArea(param1:DisplayObjectWrapper, param2:TileLocationArea, param3:IBattleEntity) : void
      {
         var _loc5_:TileLocation = null;
         var _loc6_:DisplayObjectWrapper = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:String = null;
         var _loc9_:Pt = null;
         var _loc10_:Number = NaN;
         var _loc4_:Pt = new Pt();
         for each(_loc5_ in param2.locations)
         {
            if(!view.underlay.tilesUnderlay.isHiddenBit(_loc5_.x,_loc5_.y,BIT))
            {
               _loc6_ = null;
               _loc4_.x = _loc5_.x + 0.5;
               _loc4_.y = _loc5_.y + 0.5;
               _loc7_ = view.board.findEntityOnTile(_loc5_.x,_loc5_.y,true,null);
               if(!_loc7_)
               {
                  _loc8_ = this.getMoveTile(_loc5_);
                  _loc6_ = this.pool.pop(_loc8_);
                  view.underlay.tilesUnderlay.hide(_loc5_.x,_loc5_.y,BIT);
                  this._pooledBmps.push(_loc6_);
               }
               if(_loc6_)
               {
                  param1.addChild(_loc6_);
                  _loc9_ = IsoMath.isoToScreen(_loc4_);
                  _loc10_ = view.units;
                  _loc6_.x = _loc9_.x * _loc10_ - _loc6_.width / 2;
                  _loc6_.y = _loc9_.y * _loc10_ - _loc6_.height / 2;
               }
            }
         }
      }
      
      private function setEndpointDisplay(param1:DisplayObjectWrapper, param2:String, param3:Tile) : void
      {
         if(this.lastEndpointDisplay == param1)
         {
            return;
         }
         if(this.lastEndpointDisplay)
         {
            this.clearDisplay(this.lastEndpointDisplay);
            this.lastEndpointDisplayUrl = null;
         }
         this.lastEndpointDisplay = param1;
         if(this.lastEndpointDisplay)
         {
            this.lastEndpointDisplayUrl = param2;
            displayObjectWrapper.addChild(this.lastEndpointDisplay);
            this.positionEndpointDisplay(param3);
         }
      }
      
      private function positionEndpointDisplay(param1:Tile) : void
      {
         var _loc2_:Number = view.units;
         var _loc3_:BattleEntity = fsm.interact as BattleEntity;
         if(!_loc3_ || !_loc3_.tile)
         {
            return;
         }
         var _loc4_:BattleFacing = _loc3_.facing;
         var _loc5_:* = _loc3_._length == _loc3_._width;
         MovePlanOverlay.centerTheDisplayObject(_loc4_,this.lastEndpointDisplay,false,_loc5_);
         var _loc6_:Number = 0.5;
         var _loc7_:TileRect = _loc3_.rect.clone();
         _loc7_.setLocation(param1.location);
         var _loc8_:Point = _loc7_.localTail;
         var _loc9_:Pt = new Pt(_loc7_.center.x + _loc8_.x / 2,_loc7_.center.y + _loc8_.y / 2);
         var _loc10_:Pt = IsoMath.isoToScreen(_loc9_);
         this.lastEndpointDisplay.x += int(_loc10_.x * _loc2_);
         this.lastEndpointDisplay.y += int(_loc10_.y * _loc2_);
      }
      
      private function clearDisplay(param1:DisplayObjectWrapper) : void
      {
         displayObjectWrapper.removeChild(param1);
         param1.scaleX = param1.scaleY = 1;
         this.pool.reclaim(param1);
         view.animClipSpritePool.reclaim(param1);
      }
      
      private function renderEndpoint(param1:Tile) : void
      {
         var _loc4_:Boolean = false;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc2_:BattleEntity = fsm.interact as BattleEntity;
         if(!param1 || !_loc2_ || param1 == _loc2_.tile || !_loc2_.isPlayer || !_loc2_._party)
         {
            this.setEndpointDisplay(null,null,null);
            return;
         }
         var _loc3_:BattleDeploymentAreas = board.def.getDeploymentAreasById(_loc2_._party.deployment,null);
         var _loc5_:BattleFacing = _loc3_.getLocationFacing(param1.location);
         if(_board._deploy.canDeployEitherWay(_loc2_,_loc5_,_loc3_.area,param1.location))
         {
            _loc4_ = true;
         }
         if(!_loc4_)
         {
            this.setEndpointDisplay(null,null,null);
            return;
         }
         var _loc6_:String = this._evaluateActiveTile(_loc2_);
         if(_loc6_ != this.lastEndpointDisplayUrl)
         {
            _loc7_ = view.animClipSpritePool.pop(_loc6_);
            this.setEndpointDisplay(_loc7_,_loc6_,param1);
         }
         else
         {
            this.positionEndpointDisplay(param1);
         }
      }
      
      private function selectTileHandler(param1:BattleBoardEvent) : void
      {
         this.renderEndpoint(_board.selectedTile);
      }
      
      private function _evaluateActiveTile(param1:BattleEntity) : String
      {
         var _loc2_:BattleAssetsDef = view.board.assets;
         if(param1._length == 2 && param1._width == 1)
         {
            return _loc2_.board_active_1x2;
         }
         if(param1._diameter == 1)
         {
            return _loc2_.board_active_1;
         }
         return _loc2_.board_active_2;
      }
   }
}
