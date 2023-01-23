package engine.battle.board.view
{
   import as3isolib.display.IsoView;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import as3isolib.utils.IsoUtil;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleBoardTrigger;
   import engine.battle.board.model.BattleBoardTriggersEvent;
   import engine.battle.board.model.BattleBoard_Spawn;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.indicator.EntityFlyText;
   import engine.battle.board.view.overlay.AbilityDestinationOverlay;
   import engine.battle.board.view.overlay.DamageFlagOverlay;
   import engine.battle.board.view.overlay.MovePlanOverlay;
   import engine.battle.board.view.overlay.TileHoverOverlay;
   import engine.battle.board.view.overlay.TileTargetOverlay;
   import engine.battle.board.view.phantasm.CombatScenePhantasmsView;
   import engine.battle.board.view.underlay.TileTargetUnderlay;
   import engine.battle.board.view.underlay.UnderlayGroupSprite;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.view.EntityView;
   import engine.battle.entity.view.EntityViewFactory;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.sim.BattleParty;
   import engine.battle.sim.BattlePartyEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.core.render.Camera;
   import engine.entity.def.AssetBundle;
   import engine.entity.def.EntityDef;
   import engine.entity.def.IAbilityAssetBundleManager;
   import engine.entity.def.IAssetBundle;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityDef;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.LandscapeViewBase;
   import engine.resource.AnimClipSpritePool;
   import engine.resource.BitmapPool;
   import engine.resource.IResourceManager;
   import engine.saga.SpeakEvent;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.action.Action_BattleUnitAbility;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.IHappeningDefProvider;
   import engine.scene.SceneContext;
   import engine.scene.view.ISpeechBubblePositioner;
   import engine.scene.view.SpeechBubble;
   import engine.sound.ISoundDriver;
   import engine.tile.Tile;
   import engine.tile.TilesEvent;
   import engine.tile.def.TileLocation;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class BattleBoardView implements ISpeechBubblePositioner
   {
      
      private static const SMOOTH_TRIGGER_VIEWS:Boolean = true;
      
      public static var instance:BattleBoardView;
      
      private static var scratchSbp:Point = new Point();
       
      
      public var isoOverlay:DisplayObjectWrapper;
      
      public var underlay:UnderlayGroupSprite;
      
      public var entityViews:Dictionary;
      
      public var entityViewsByDefId:Dictionary;
      
      private var phantasmsView:CombatScenePhantasmsView;
      
      public var bitmapPool:BitmapPool;
      
      public var animClipSpritePool:AnimClipSpritePool;
      
      private var moveOverlay:MovePlanOverlay;
      
      private var tileTargetOverlay:TileTargetOverlay;
      
      private var tileHoverOverlay:TileHoverOverlay;
      
      private var tileTargetUnderlay:TileTargetUnderlay;
      
      private var abilityDestinationOverlay:AbilityDestinationOverlay;
      
      public var triggerViews:Dictionary;
      
      public var triggerViewsByDefStringId:Dictionary;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      public var layerSprite:DisplayObjectWrapper;
      
      private var isoView:IsoView;
      
      public var isoScenes:IsoSceneLayers;
      
      private var damageFlagOverlay:DamageFlagOverlay;
      
      public var board:BattleBoard;
      
      public var units:Number = 64;
      
      public var soundDriver:ISoundDriver;
      
      private var parties:Vector.<IBattleParty>;
      
      public var sceneOffset:Point;
      
      public var logger:ILogger;
      
      public var shell:ShellCmdManager;
      
      private var landscapeView:LandscapeViewBase;
      
      private var _preloadAssetBundle:IAssetBundle;
      
      private var updatingVfxs:Boolean;
      
      private var _removeTriggerViews:Vector.<BattleBoardTrigger>;
      
      private var _hasPlayedMatchStart:Boolean;
      
      private var tileFlyText:Dictionary;
      
      private var _speechBubblePreloads:Dictionary;
      
      private var _cameraFollowingEntity:IBattleEntity;
      
      private var _postLoadViewsTriggered:Boolean = false;
      
      public function BattleBoardView(param1:BattleBoard, param2:LandscapeViewBase, param3:ISoundDriver)
      {
         this.entityViews = new Dictionary();
         this.entityViewsByDefId = new Dictionary();
         this.triggerViews = new Dictionary();
         this.triggerViewsByDefStringId = new Dictionary();
         this.parties = new Vector.<IBattleParty>();
         this.sceneOffset = new Point();
         this._removeTriggerViews = new Vector.<BattleBoardTrigger>();
         this.tileFlyText = new Dictionary();
         this._speechBubblePreloads = new Dictionary();
         super();
         instance = this;
         this.layerSprite = param2.getLayerSprite(param1.def.layer);
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         this.displayObjectWrapper.name = "battle_board_view";
         this.isoOverlay = IsoUtil.createDisplayObjectWrapper();
         this.isoOverlay.name = "overlay";
         this.landscapeView = param2;
         this.soundDriver = param3;
         this.logger = param1.logger;
         this.board = param1;
         this.shell = new ShellCmdManager(param1.logger);
         this.shell.add("overlay",this.shellCmdFuncOverlay);
         this.shell.add("underlay",this.shellCmdFuncUnderlay);
         this.shell.add("entities",this.shellCmdFuncEntities);
         this.bitmapPool = new BitmapPool(param1.resman,2,20);
         this.animClipSpritePool = new AnimClipSpritePool(param1.resman,2,20);
         this.phantasmsView = new CombatScenePhantasmsView(this);
         this.isoView = new IsoView("iso");
         this.isoScenes = new IsoSceneLayers(this.isoView);
         this.isoScenes.render();
         this.damageFlagOverlay = new DamageFlagOverlay(this);
         this.moveOverlay = new MovePlanOverlay(this);
         this.tileTargetOverlay = new TileTargetOverlay(this);
         this.tileHoverOverlay = new TileHoverOverlay(this);
         this.tileHoverOverlay.mpo = this.moveOverlay;
         this.tileTargetUnderlay = new TileTargetUnderlay(this);
         this.abilityDestinationOverlay = new AbilityDestinationOverlay(this);
         this.isoOverlay.addChild(this.moveOverlay.displayObjectWrapper);
         this.isoOverlay.addChild(this.abilityDestinationOverlay.displayObjectWrapper);
         this.isoOverlay.addChild(this.tileTargetOverlay.displayObjectWrapper);
         this.isoOverlay.addChild(this.tileTargetUnderlay.displayObjectWrapper);
         this.isoOverlay.addChild(this.tileHoverOverlay.displayObjectWrapper);
         this.underlay = new UnderlayGroupSprite(this);
         this.displayObjectWrapper.addChild(this.underlay.displayObjectWrapper);
         this.displayObjectWrapper.addChild(this.isoView.display);
         this.displayObjectWrapper.addChild(this.isoOverlay);
         this.isoView.setSize(0,0);
         this.isoView.clipContent = false;
         param1.def.addEventListener(BattleBoardDef.EVENT_POS,this.boardPosHandler);
         this.boardPosHandler(null);
         param1.addEventListener(BattleEntityEvent.ADDED,this.entityAddedHandler);
         param1.addEventListener(BattleEntityEvent.CAMERA_CENTER,this.entityCameraCenterHandler);
         param1.addEventListener(BattleBoardEvent.BOARD_ENTITY_FORCE_CAMERA_CENTER,this.forceCameraCenterHandler);
         param1.addEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         param1.tiles.addEventListener(TilesEvent.TILE_FLYTEXT,this.tileFlytextHandler);
         param1.addEventListener(BattleBoardEvent.PARTY,this.boardPartyHandler);
         param1.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
         param1.addEventListener(BattleBoardEvent.WALKABLE,this.boardWalkableHandler);
         param1.addEventListener(BattleBoardEvent.CAMERA_FOLLOW,this.entityCameraFollowHandler);
         param1.addEventListener(BattleBoardEvent.CAMERA_UNFOLLOW,this.entityCameraUnfollowHandler);
         param1._scene._def.getSpeechBubbleEntities(this._speechBubblePreloads);
         var _loc4_:SceneContext = param1._scene.context;
         this.createEntityViews();
         param1.triggers.addEventListener(BattleBoardTriggersEvent.ADDED,this.battleBoardTriggersAddedHandler);
         param1.triggers.addEventListener(BattleBoardTriggersEvent.REMOVED,this.battleBoardTriggersRemovedHandler);
         param1.triggers.addEventListener(BattleBoardTriggersEvent.ENABLED,this.battleBoardTriggersEnabledHandler);
         this.createTriggerViews();
         this.addParties();
         this.boardEnabledHandler(null);
      }
      
      public function handleWalkableTilesChanged() : void
      {
         this.underlay.handleWalkableTilesChanged();
      }
      
      public function handlePreloadEntityDefs() : void
      {
         var _loc4_:EntityDef = null;
         if(this._preloadAssetBundle)
         {
            throw new IllegalOperationError("preload bundle exists");
         }
         this._preloadAssetBundle = new AssetBundle(this.toString(),this.logger);
         var _loc1_:BattleBoard_Spawn = this.board._spawn;
         var _loc2_:IEntityAssetBundleManager = this.board.entityAssetBundleManager;
         var _loc3_:Vector.<IEntityDef> = _loc1_.preloadEntityDefs;
         if(Boolean(_loc3_) && Boolean(_loc3_.length))
         {
            for each(_loc4_ in _loc3_)
            {
               _loc2_.getEntityPreload(_loc4_,this._preloadAssetBundle,false,false,true);
            }
         }
         this.handlePreloadHappeningAbilities();
      }
      
      private function handlePreloadHappeningAbilities() : void
      {
         var _loc7_:HappeningDef = null;
         var _loc8_:Dictionary = null;
         var _loc9_:Dictionary = null;
         var _loc10_:ActionDef = null;
         var _loc11_:String = null;
         var _loc1_:IHappeningDefProvider = this.board.scene.def.getHappeningDefProvider;
         if(!_loc1_ || !_loc1_.numHappenings)
         {
            return;
         }
         var _loc2_:IAbilityAssetBundleManager = this.board.abilityAssetBundleManager;
         var _loc3_:SceneContext = this.board.scene.context;
         var _loc4_:BattleAbilityDefFactory = _loc3_.abilities;
         var _loc5_:IResourceManager = this.board.resman;
         var _loc6_:int = 0;
         while(_loc6_ < _loc1_.numHappenings)
         {
            _loc7_ = _loc1_.getHappeningDefByIndex(_loc6_);
            if(!(!_loc7_.enabled || !_loc7_.actions))
            {
               _loc8_ = null;
               _loc9_ = null;
               for each(_loc10_ in _loc7_.actions)
               {
                  if(_loc10_.type == ActionType.BATTLE_UNIT_ABILITY)
                  {
                     _loc11_ = Action_BattleUnitAbility.getAbilityId(_loc10_);
                     if(_loc11_)
                     {
                        _loc2_.preloadAbilityDefById(_loc11_,this._preloadAssetBundle);
                     }
                  }
               }
            }
            _loc6_++;
         }
      }
      
      private function boardPosHandler(param1:Event) : void
      {
         this.displayObjectWrapper.x = this.board.def.pos.x;
         this.displayObjectWrapper.y = this.board.def.pos.y;
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:EntityView = null;
         var _loc3_:BattleBoardTriggerView = null;
         var _loc4_:BattleBoardTrigger = null;
         var _loc5_:Point = null;
         this.animClipSpritePool.update(param1);
         this.phantasmsView.update(param1);
         for each(_loc2_ in this.entityViews)
         {
            _loc2_.update(param1);
         }
         this.updatingVfxs = true;
         for each(_loc3_ in this.triggerViews)
         {
            _loc3_.update(param1);
            if(_loc3_.playedOut)
            {
               this._removeTriggerViews.push(_loc3_.trigger);
            }
         }
         if(this._removeTriggerViews.length)
         {
            for each(_loc4_ in this._removeTriggerViews)
            {
               _loc3_ = this.triggerViews[_loc4_];
               _loc3_.cleanup();
               delete this.triggerViews[_loc4_];
               delete this.triggerViewsByDefStringId[_loc4_.def.stringId];
            }
            this._removeTriggerViews.splice(0,this._removeTriggerViews.length);
         }
         this.updatingVfxs = false;
         if(this._cameraFollowingEntity)
         {
            _loc5_ = this.getEntityScenePoint(this._cameraFollowingEntity);
            this.board._scene._camera.drift.anchor = _loc5_;
         }
         if(this.underlay)
         {
            this.underlay.update(param1);
         }
         this.render();
      }
      
      private function entityCameraFollowHandler(param1:BattleBoardEvent) : void
      {
         this.cameraFollowEntity(param1.entity,false);
      }
      
      private function entityCameraUnfollowHandler(param1:BattleBoardEvent) : void
      {
         this.cameraStopFollowingEntity(param1.entity);
      }
      
      private function boardWalkableHandler(param1:BattleBoardEvent) : void
      {
         this.handleWalkableTilesChanged();
      }
      
      private function boardSetupHandler(param1:BattleBoardEvent) : void
      {
         if(!this._hasPlayedMatchStart)
         {
            this._hasPlayedMatchStart = true;
            if(this.board._scene._context.staticSoundController != null)
            {
               this.board._scene._context.staticSoundController.playSound("ui_match_start",null);
            }
         }
         this.render();
      }
      
      private function addParties() : void
      {
         var _loc2_:IBattleParty = null;
         var _loc1_:int = this.parties.length;
         while(_loc1_ < this.board.numParties)
         {
            _loc2_ = this.board.getParty(this.board.numParties - 1);
            this.parties.push(_loc2_);
            _loc2_.addEventListener(BattlePartyEvent.DEPLOYED,this.partyDeployedHandler);
            _loc1_++;
         }
      }
      
      private function boardPartyHandler(param1:BattleBoardEvent) : void
      {
         this.addParties();
      }
      
      private function partyDeployedHandler(param1:BattlePartyEvent) : void
      {
         if(param1.party.deployed)
         {
            this.board._scene._context.staticSoundController.playSound("ui_deploy",null);
            param1.party.removeEventListener(BattlePartyEvent.DEPLOYED,this.partyDeployedHandler);
         }
      }
      
      public function cleanup() : void
      {
         var party:IBattleParty = null;
         var ev:EntityView = null;
         var tv:BattleBoardTriggerView = null;
         var eft:EntityFlyText = null;
         var evid:String = null;
         if(instance == this)
         {
            instance = null;
         }
         try
         {
            if(this.tileFlyText)
            {
               for each(eft in this.tileFlyText)
               {
                  eft.cleanup();
               }
            }
         }
         catch(e:Error)
         {
            logger.error("Failed to cleanup BattleBoardView.tileFlyText:\n" + e.getStackTrace());
         }
         this.tileFlyText = null;
         this.board.addEventListener(BattleBoardEvent.CAMERA_FOLLOW,this.entityCameraFollowHandler);
         this.board.addEventListener(BattleBoardEvent.CAMERA_UNFOLLOW,this.entityCameraUnfollowHandler);
         this.board.def.removeEventListener(BattleBoardDef.EVENT_POS,this.boardPosHandler);
         this.board.triggers.removeEventListener(BattleBoardTriggersEvent.ADDED,this.battleBoardTriggersAddedHandler);
         this.board.triggers.removeEventListener(BattleBoardTriggersEvent.REMOVED,this.battleBoardTriggersRemovedHandler);
         this.board.removeEventListener(BattleEntityEvent.ADDED,this.entityAddedHandler);
         this.board.removeEventListener(BattleEntityEvent.CAMERA_CENTER,this.entityCameraCenterHandler);
         this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_FORCE_CAMERA_CENTER,this.forceCameraCenterHandler);
         this.board.removeEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         this.board.tiles.removeEventListener(TilesEvent.TILE_FLYTEXT,this.tileFlytextHandler);
         this.board.removeEventListener(BattleBoardEvent.PARTY,this.boardPartyHandler);
         this.board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
         this.board.removeEventListener(BattleBoardEvent.WALKABLE,this.boardWalkableHandler);
         for each(party in this.parties)
         {
            party.removeEventListener(BattlePartyEvent.DEPLOYED,this.partyDeployedHandler);
            (party as BattleParty).cleanup();
         }
         this.parties = null;
         for each(ev in this.entityViews)
         {
            evid = "";
            this.isoScenes.getIsoScene(ev.layer).removeChild(ev);
            if(ev.entity)
            {
               evid = ev.entity.id;
               ev.entity.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
            }
            try
            {
               ev.cleanup();
            }
            catch(e:Error)
            {
               logger.error("Failed to cleanup entity view for " + evid + ":\n" + e.getStackTrace());
            }
         }
         this.entityViews = null;
         this.entityViewsByDefId = null;
         for each(tv in this.triggerViews)
         {
            if(tv)
            {
               tv.cleanup();
            }
         }
         this.triggerViews = null;
         this.triggerViewsByDefStringId = null;
         this.displayObjectWrapper.removeAllChildren();
         this.underlay.cleanup();
         this.underlay = null;
         this.isoOverlay.removeAllChildren();
         this.abilityDestinationOverlay.cleanup();
         this.abilityDestinationOverlay = null;
         this.moveOverlay.cleanup();
         this.moveOverlay = null;
         this.tileHoverOverlay.cleanup();
         this.tileHoverOverlay = null;
         this.tileTargetOverlay.cleanup();
         this.tileTargetOverlay = null;
         this.tileTargetUnderlay.cleanup();
         this.tileTargetUnderlay = null;
         this.damageFlagOverlay.cleanup();
         this.damageFlagOverlay = null;
         this.isoScenes.cleanup();
         this.isoScenes = null;
         this.isoView.removeAllScenes();
         this.isoView = null;
         this.phantasmsView.cleanup();
         this.phantasmsView = null;
         this.animClipSpritePool.cleanup();
         this.animClipSpritePool = null;
         this.bitmapPool.cleanup();
         this.bitmapPool = null;
         this.shell.cleanup();
         this.shell = null;
         this.logger = null;
         this.landscapeView = null;
         if(this._preloadAssetBundle)
         {
            this._preloadAssetBundle.releaseReference();
            this._preloadAssetBundle.cleanup();
            this._preloadAssetBundle = null;
         }
      }
      
      public function toString() : String
      {
         return this.board.toString();
      }
      
      protected function boardEnabledHandler(param1:BattleBoardEvent) : void
      {
         if(this.board.logger.isDebugEnabled)
         {
            this.board.logger.debug("BattleBoardView.boardEnabledHandler " + this.board.enabled);
         }
         this.displayObjectWrapper.visible = this.board.enabled;
      }
      
      public function get isoDisplayObject() : IsoView
      {
         return this.isoView;
      }
      
      protected function tileFlytextHandler(param1:TilesEvent) : void
      {
         if(!BattleFsmConfig.guiFlytextShouldRender)
         {
            return;
         }
         var _loc2_:Tile = this.board.tiles.flyTextTile;
         var _loc3_:EntityFlyText = this.tileFlyText[_loc2_];
         if(!_loc3_)
         {
            _loc3_ = new EntityFlyText(null,_loc2_);
            _loc3_.moveTo(_loc2_.x * this.units,_loc2_.y * this.units,0);
            this.isoScenes.getIsoScene("fg0").addChild(_loc3_);
            this.tileFlyText[_loc2_] = _loc3_;
         }
         _loc3_.push(this.board.tiles.flyText,this.board.tiles.flyTextColor,this.board.tiles.flyTextFontName,this.board.tiles.flyTextFontSize);
      }
      
      public function getIsoPointUnderMouse(param1:Number, param2:Number) : Pt
      {
         var _loc3_:Point = this.isoView.display.globalToLocal(new Point(param1,param2));
         return this.isoView.localToIso(new Pt(_loc3_.x,_loc3_.y));
      }
      
      public function getTileLocationUnderMouse(param1:Number, param2:Number) : TileLocation
      {
         var _loc3_:Pt = this.getIsoPointUnderMouse(param1,param2);
         if(!_loc3_)
         {
            return null;
         }
         return TileLocation.fetch(Math.floor(_loc3_.x / this.units),Math.floor(_loc3_.y / this.units));
      }
      
      public function getScreenPoint(param1:Number, param2:Number) : Pt
      {
         var _loc3_:Pt = new Pt(param1,param2);
         return IsoMath.isoToScreen(_loc3_);
      }
      
      public function getScreenPointPt(param1:Pt) : Pt
      {
         return IsoMath.isoToScreen(param1);
      }
      
      public function getScreenPointGlobal(param1:Number, param2:Number) : Point
      {
         var _loc3_:Pt = this.getScreenPoint(param1,param2);
         return this.isoDisplayObject.mainContainer.localToGlobal(_loc3_);
      }
      
      public function getScreenPointGlobalPt(param1:Pt) : Point
      {
         var _loc2_:Pt = this.getScreenPointPt(param1);
         return this.isoDisplayObject.mainContainer.localToGlobal(_loc2_);
      }
      
      private function createEntityViews() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in this.board.entities)
         {
            this.createEntityView(_loc1_);
         }
      }
      
      private function createEntityView(param1:IBattleEntity) : EntityView
      {
         var _loc2_:Boolean = Boolean(this._speechBubblePreloads[param1.id]) || Boolean(this._speechBubblePreloads[param1.def.id]);
         var _loc3_:EntityView = EntityViewFactory.create(this,param1,this.board._resman,_loc2_,this.board.entityAssetBundleManager);
         this.isoScenes.getIsoScene(_loc3_.layer).addChild(_loc3_);
         this.entityViews[_loc3_.entity.id] = _loc3_;
         this.entityViewsByDefId[_loc3_.entity.def.id] = _loc3_;
         param1.addEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
         return _loc3_;
      }
      
      private function entityMovedHandler(param1:BattleEntityEvent) : void
      {
         if(param1.entity.forceCameraCenter)
         {
            this.centerOnEntity(param1.entity);
         }
      }
      
      private function forceCameraCenterHandler(param1:BattleBoardEvent) : void
      {
         if(param1.entity)
         {
            this.centerOnEntity(param1.entity);
         }
      }
      
      protected function entityAddedHandler(param1:BattleEntityEvent) : void
      {
         this.createEntityView(param1.entity);
      }
      
      protected function entityRemovedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:EntityView = this.getEntityView(param1.entity);
         if(!_loc2_)
         {
            return;
         }
         this.isoScenes.getIsoScene(_loc2_.layer).removeChild(_loc2_);
         _loc2_.cleanup();
         delete this.entityViews[param1.entity.id];
         delete this.entityViewsByDefId[param1.entity.def.id];
      }
      
      public function moveToLayer(param1:EntityView, param2:String) : void
      {
         if(param1.layer == param2)
         {
            return;
         }
         this.isoScenes.getIsoScene(param1.layer).removeChild(param1);
         this.isoScenes.getIsoScene(param2).addChild(param1);
         param1.layer = param2;
      }
      
      private function render() : void
      {
         this.isoScenes.render();
         this.isoView.render();
         this.underlay.render();
         this.damageFlagOverlay.render();
         this.moveOverlay.render();
         this.tileTargetOverlay.render();
         this.tileHoverOverlay.render();
         this.tileTargetUnderlay.render();
         this.abilityDestinationOverlay.render();
      }
      
      public function getEntityView(param1:IBattleEntity) : EntityView
      {
         if(Boolean(param1) && Boolean(this.entityViews))
         {
            return this.entityViews[param1.id];
         }
         return null;
      }
      
      public function onEntityViewReady(param1:EntityView) : void
      {
      }
      
      public function getEntityScenePoint(param1:IBattleEntity) : Point
      {
         var _loc2_:EntityView = null;
         if(param1)
         {
            _loc2_ = this.getEntityView(param1);
            if(_loc2_)
            {
               return this.getScenePoint(_loc2_.x,_loc2_.y);
            }
         }
         return null;
      }
      
      public function getScenePoint(param1:Number, param2:Number) : Point
      {
         var _loc3_:Point = this.getScreenPoint(param1,param2);
         _loc3_.x += this.sceneOffset.x + this.displayObjectWrapper.x;
         _loc3_.y += this.sceneOffset.y + this.displayObjectWrapper.y;
         return _loc3_;
      }
      
      public function getScenePointFromBoardPoint(param1:Number, param2:Number) : Point
      {
         var _loc3_:Number = param1 * this.units;
         var _loc4_:Number = param2 * this.units;
         return this.getScenePoint(_loc3_,_loc4_);
      }
      
      public function getScreenPointFromBoardPoint(param1:Number, param2:Number) : Point
      {
         var _loc3_:Number = param1 * this.units;
         var _loc4_:Number = param2 * this.units;
         return this.getScreenPoint(_loc3_,_loc4_);
      }
      
      private function entityCameraCenterHandler(param1:BattleEntityEvent) : void
      {
         this.cameraCenterOnEntity(param1.entity,false,0,0);
      }
      
      public function centerOnEntity(param1:IBattleEntity) : void
      {
         this.cameraCenterOnEntity(param1,false,0,0);
      }
      
      public function cameraCenterOnEntity(param1:IBattleEntity, param2:Boolean, param3:int, param4:int) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc5_:Point = this.getEntityScenePoint(param1);
         if(!_loc5_)
         {
            this.logger.error("Entity " + param1 + " has no scene point");
            return;
         }
         _loc5_.x += param3;
         _loc5_.y += param4;
         var _loc6_:Camera = this.board._scene._camera;
         if(param2)
         {
            _loc6_.setPosition(_loc5_.x,_loc5_.y);
         }
         _loc6_.drift.anchor = _loc5_;
         this._cameraFollowingEntity = null;
      }
      
      public function cameraFollowEntity(param1:IBattleEntity, param2:Boolean) : void
      {
         if(param1)
         {
            this.cameraCenterOnEntity(param1,param2,0,0);
         }
         this._cameraFollowingEntity = param1;
      }
      
      public function cameraStopFollowingEntity(param1:IBattleEntity) : void
      {
         if(this._cameraFollowingEntity == param1)
         {
            this._cameraFollowingEntity = null;
         }
      }
      
      public function centerOnBoardPoint(param1:Number, param2:Number) : void
      {
         var _loc3_:Point = this.getScenePoint(param1 * this.units,param2 * this.units);
         this.board._scene._camera.drift.anchor = _loc3_;
      }
      
      public function centerOnPartyById(param1:String) : void
      {
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:IBattleEntity = null;
         var _loc7_:Point = null;
         var _loc2_:IBattleParty = this.board.getPartyById(param1);
         if(_loc2_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_.numMembers)
            {
               _loc6_ = _loc2_.getMember(_loc5_);
               _loc7_ = this.getEntityScenePoint(_loc6_);
               if(_loc7_)
               {
                  if(!_loc3_)
                  {
                     _loc3_ = new Point(_loc7_.x,_loc7_.y);
                  }
                  else
                  {
                     _loc3_.x += _loc7_.x;
                     _loc3_.y += _loc7_.y;
                  }
                  _loc4_++;
               }
               _loc5_++;
            }
            if(Boolean(_loc3_) && Boolean(_loc4_))
            {
               _loc3_.x /= _loc4_;
               _loc3_.y /= _loc4_;
               if(_loc3_)
               {
                  this.board._scene._camera.drift.anchor = _loc3_;
               }
            }
         }
      }
      
      public function setSceneOffset(param1:Number, param2:Number) : void
      {
         this.sceneOffset.setTo(param1,param2);
      }
      
      private function shellCmdFuncOverlay(param1:CmdExec) : void
      {
         this.isoOverlay.visible = !this.isoOverlay.visible;
         this.logger.info("isoOverlay.visible = " + this.isoOverlay.visible);
      }
      
      private function shellCmdFuncUnderlay(param1:CmdExec) : void
      {
         this.underlay..displayObjectWrapper.visible = !this.underlay..displayObjectWrapper.visible;
         this.logger.info("underlay.visible = " + this.underlay..displayObjectWrapper.visible);
      }
      
      private function shellCmdFuncEntities(param1:CmdExec) : void
      {
         this.isoView.display.visible = !this.isoView.display.visible;
         this.logger.info("isoView.visible = " + this.isoView.display.visible);
      }
      
      private function battleBoardTriggersRemovedHandler(param1:BattleBoardTriggersEvent) : void
      {
         var _loc2_:BattleBoardTriggerView = this.triggerViews[param1.trigger];
         if(_loc2_)
         {
            _loc2_.playOut();
         }
      }
      
      private function battleBoardTriggersEnabledHandler(param1:BattleBoardTriggersEvent) : void
      {
         if(!param1.trigger.enabled)
         {
            this.battleBoardTriggersRemovedHandler(param1);
         }
         else
         {
            this.battleBoardTriggersAddedHandler(param1);
         }
      }
      
      private function createTriggerViews() : void
      {
         var _loc1_:IBattleBoardTrigger = null;
         if(!this.board.triggers)
         {
            return;
         }
         for each(_loc1_ in this.board.triggers.triggers)
         {
            this.addTriggerView(_loc1_,false);
         }
      }
      
      private function postLoadTriggerViews() : void
      {
         var _loc1_:BattleBoardTriggerView = null;
         this._postLoadViewsTriggered = true;
         for each(_loc1_ in this.triggerViews)
         {
            _loc1_.postLoadTriggerView();
         }
      }
      
      public function postLoad() : void
      {
         this.postLoadTriggerViews();
         if(this.board)
         {
            this.board.postLoad();
         }
      }
      
      private function addTriggerView(param1:IBattleBoardTrigger, param2:Boolean) : void
      {
         if(!param1.enabled)
         {
            return;
         }
         var _loc3_:BattleBoardTriggerView = new BattleBoardTriggerView(this,param1,this.board.logger,SMOOTH_TRIGGER_VIEWS);
         if(param2 && this._postLoadViewsTriggered)
         {
            _loc3_.postLoadTriggerView();
         }
         this.triggerViews[param1] = _loc3_;
         this.triggerViewsByDefStringId[param1.def.stringId] = _loc3_;
      }
      
      private function battleBoardTriggersAddedHandler(param1:BattleBoardTriggersEvent) : void
      {
         this.addTriggerView(param1.trigger,true);
      }
      
      public function handleSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         var _loc3_:EntityView = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(param1.speakerEnt)
         {
            _loc3_ = this.entityViews[param1.speakerEnt.id];
            if(!_loc3_ || !_loc3_.entity.alive)
            {
               return true;
            }
         }
         else if(param1.speakerDef)
         {
            _loc3_ = this.entityViewsByDefId[param1.speakerDef.id];
            if(!_loc3_ || !_loc3_.entity.alive)
            {
               return true;
            }
         }
         else if(param2)
         {
            _loc4_ = "battle.";
            if(param2.indexOf(_loc4_) == 0)
            {
               _loc5_ = param2.substr(_loc4_.length);
               _loc3_ = this.entityViews[_loc5_];
               if(!_loc3_)
               {
                  _loc3_ = this.entityViewsByDefId[_loc5_];
               }
            }
         }
         if(_loc3_)
         {
            this.board._scene._context.createSpeechBubble(param1,_loc3_,this);
            return true;
         }
         return false;
      }
      
      public function positionSpeechBubble(param1:SpeechBubble) : void
      {
         var _loc3_:Camera = null;
         var _loc4_:Point = null;
         var _loc2_:EntityView = param1.positionerInfo as EntityView;
         if(Boolean(_loc2_) && Boolean(this.landscapeView))
         {
            _loc3_ = this.landscapeView.camera;
            _loc2_.getSpeechBubblePosition(scratchSbp);
            scratchSbp.x += this.layerSprite.x + this.displayObjectWrapper.x;
            scratchSbp.y += this.layerSprite.y + this.displayObjectWrapper.y;
            _loc4_ = this.landscapeView.localToGlobal(scratchSbp);
            param1.setPosition(_loc4_.x,_loc4_.y,false);
            param1.alpha = _loc2_.alpha;
         }
      }
      
      public function findBattleBoardObject(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(!param1)
         {
            return null;
         }
         _loc2_ = this.findBattleBoardObject_tile(param1);
         if(_loc2_)
         {
         }
         return _loc2_;
      }
      
      public function findBattleBoardObject_tile(param1:String) : Point
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         var _loc2_:String = "tile@";
         if(param1.indexOf(_loc2_) == 0)
         {
            _loc3_ = param1.substr(_loc2_.length);
            if(_loc3_)
            {
               _loc4_ = _loc3_.split(",");
               if(Boolean(_loc4_) && _loc4_.length == 2)
               {
                  _loc5_ = int(_loc4_[0]);
                  _loc6_ = int(_loc4_[1]);
                  _loc5_ *= this.units;
                  _loc6_ *= this.units;
                  return this.getScreenPointGlobal(_loc5_,_loc6_);
               }
            }
         }
         return null;
      }
   }
}
