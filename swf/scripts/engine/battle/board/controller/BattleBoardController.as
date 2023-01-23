package engine.battle.board.controller
{
   import as3isolib.geom.Pt;
   import com.stoicstudio.platform.PlatformFlash;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.op.model.Op_ArcLightningAoe;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.FsmEvent;
   import engine.core.logging.ILogger;
   import engine.core.render.Camera;
   import engine.scene.SceneControllerConfig;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class BattleBoardController
   {
      
      public static var instance:BattleBoardController;
       
      
      public var board:BattleBoard;
      
      public var view:BattleBoardView;
      
      public var isoPtUnderMouse:Pt;
      
      public var modelPointUnderMouse:Point;
      
      public var tileUnderMouse:Point;
      
      private var _selected:BattleEntity;
      
      private var _hilighted:BattleEntity;
      
      private var _turn:BattleTurn;
      
      private var logger:ILogger;
      
      private var lastTileClickedIndex:int = 0;
      
      private var fsm:BattleFsm;
      
      private var lastStageX:Number = 0;
      
      private var lastStageY:Number = 0;
      
      private var camera:Camera;
      
      private var cameraHelper:BattleBoardCameraHelper;
      
      private var _turnMove:IBattleMove;
      
      private var lastMouseMoveHandledX:Number = 1.7976931348623157e+308;
      
      private var lastMouseMoveHandledY:Number = 1.7976931348623157e+308;
      
      private var MOUSE_MOVE_THRESHOLD:Number = 2;
      
      public function BattleBoardController(param1:BattleBoard, param2:BattleBoardView)
      {
         this.modelPointUnderMouse = new Point();
         this.tileUnderMouse = new Point();
         super();
         instance = this;
         this.board = param1;
         this.view = param2;
         this.logger = param1.logger;
         this.fsm = param1.sim.fsm;
         this.fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
         this.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.camera = param1._scene._camera;
         this.cameraHelper = new BattleBoardCameraHelper(param1,param2);
         this.camera.drift.pauseBreaksAnchor = true;
         this.camera.addEventListener(Camera.EVENT_CAMERA_VIEW_CHANGED,this.cameraViewChangedHandler);
         param1.addEventListener(BattleBoardEvent.BOARD_ENTITY_MOVING,this.handleRefreshHover);
         param1.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.handleRefreshHover);
         param1.addEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.handleRefreshHover);
         this.turnHandler(null);
         this.fsmCurrentHandler(null);
      }
      
      public static function handleMoveHover_static(param1:BattleFsm, param2:BattleTurn, param3:Point, param4:Boolean) : Boolean
      {
         var _loc8_:IBattleEntity = null;
         var _loc9_:IBattleMove = null;
         var _loc5_:IBattleEntity = !!param2 ? param2.entity : null;
         if(!param2 || param2.move.committed || !_loc5_ || !_loc5_.playerControlled || param2.attackMode)
         {
            return false;
         }
         var _loc6_:BattleAbility = param2._ability;
         if(_loc6_ && !_loc6_.executing && !_loc6_.executed && _loc6_.def.targetRule.isTile)
         {
            return false;
         }
         if(param4 && param2.turnInteract && param2.turnInteract != _loc5_)
         {
            return false;
         }
         if(!param4 && param2.turnInteract == _loc5_)
         {
            return false;
         }
         if(param2.ability)
         {
            return false;
         }
         var _loc7_:Tile = param1.board.selectedTile;
         if(Boolean(_loc7_) && Boolean(_loc7_._numResidents))
         {
            var _loc10_:int = 0;
            var _loc11_:* = _loc7_.residents;
            while(true)
            {
               for each(_loc8_ in _loc11_)
               {
                  if(_loc5_.awareOf(_loc8_))
                  {
                     _loc9_ = param2.move;
                     if(_loc9_)
                     {
                        if(_loc9_.entity == _loc8_)
                        {
                           if(!param3)
                           {
                              continue;
                           }
                        }
                        param2.move.trimStepsToWaypoint(true);
                        break;
                     }
                     break;
                  }
                  continue;
               }
            }
            return false;
         }
         return BattleBoardTileTargetHelper._findMoveTileWaypoint(param1,param2,param3);
      }
      
      private function cameraViewChangedHandler(param1:Event) : void
      {
         var _loc2_:Stage = PlatformFlash.stage;
         this.mouseMoveHandler(_loc2_.mouseX,_loc2_.mouseY);
      }
      
      private function handleRefreshHover(param1:BattleBoardEvent) : void
      {
         this.hilightAt(this.lastStageX,this.lastStageY,true);
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         if(Boolean(this.board) && Boolean(this.board.sim))
         {
            if(this.isDeploying)
            {
               this.view.centerOnPartyById(this.board.sim.fsm.session.credentials.vbb_name);
            }
         }
      }
      
      protected function turnHandler(param1:Event) : void
      {
         var _loc2_:IBattleEntity = null;
         this.turn = !!this.board.sim ? this.board.sim.fsm.turn as BattleTurn : null;
         if(this._turn)
         {
            _loc2_ = this._turn.entity;
            if(_loc2_ && _loc2_.enabled && Boolean(_loc2_.active))
            {
               if(Boolean(_loc2_.visible) || Boolean(_loc2_.playerControlled))
               {
                  this.view.centerOnEntity(_loc2_);
               }
            }
         }
      }
      
      private function update() : void
      {
         this.selected = !!this.turn ? this.turn.entity as BattleEntity : null;
      }
      
      public function cleanup() : void
      {
         if(instance == this)
         {
            instance = null;
         }
         this.cameraHelper.cleanup();
         this.camera.removeEventListener(Camera.EVENT_CAMERA_VIEW_CHANGED,this.cameraViewChangedHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
         this.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.turn = null;
         this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_MOVING,this.handleRefreshHover);
         this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.handleRefreshHover);
         this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.handleRefreshHover);
         this.board = null;
      }
      
      final public function get selected() : BattleEntity
      {
         return this._selected;
      }
      
      final public function set selected(param1:BattleEntity) : void
      {
         if(this._selected == param1)
         {
            return;
         }
         if(this._selected)
         {
            this._selected.selected = false;
         }
         this._selected = param1;
         if(this._selected)
         {
            this._selected.selected = true;
         }
      }
      
      private function getEntityAtTilePosition(param1:Number, param2:Number, param3:Boolean, param4:Boolean) : BattleEntity
      {
         this.isoPtUnderMouse = this.view.getIsoPointUnderMouse(param1,param2);
         this.modelPointUnderMouse.x = this.isoPtUnderMouse.x / this.view.units;
         this.modelPointUnderMouse.y = this.isoPtUnderMouse.y / this.view.units;
         this.tileUnderMouse.x = Math.floor(this.modelPointUnderMouse.x);
         this.tileUnderMouse.y = Math.floor(this.modelPointUnderMouse.y);
         var _loc5_:Tile = this.findTile();
         var _loc6_:BattleEntity = this.findClick(_loc5_,param3,param4);
         if(_loc6_)
         {
            if(_loc6_.mobility.moving)
            {
               return null;
            }
            if(!_loc6_.alive && param4)
            {
               return null;
            }
            if(!_loc6_.visibleToPlayer || !_loc6_.enabled || !_loc6_.active)
            {
               return null;
            }
         }
         return _loc6_;
      }
      
      public function set hoverEntity(param1:IBattleEntity) : void
      {
         if(this.board)
         {
            this.board.hoverEntity = param1;
         }
      }
      
      public function get hoverEntity() : IBattleEntity
      {
         return !!this.board ? this.board.hoverEntity : null;
      }
      
      public function set hilighted(param1:IBattleEntity) : void
      {
         this.hoverEntity = param1;
      }
      
      public function get hilighted() : IBattleEntity
      {
         return this.hoverEntity;
      }
      
      public function hilightAt(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         var _loc5_:IBattleEntity = null;
         var _loc8_:String = null;
         var _loc9_:BattleDeploymentAreas = null;
         var _loc10_:Boolean = false;
         var _loc11_:Tile = null;
         if(!BattleFsmConfig.guiTilesEnabled)
         {
            this.hoverEntity = null;
            return true;
         }
         var _loc4_:BattleEntity = this.getEntityAtTilePosition(param1,param2,true,param3);
         if(!_loc4_)
         {
            _loc4_ = this.getEntityAtTilePosition(param1,param2,false,param3);
            if(this.fsm._turn)
            {
               if(_loc4_ == this.fsm._turn.entity)
               {
                  _loc4_ = null;
               }
            }
         }
         if(_loc4_ != null)
         {
            if(!_loc4_.interactable && !_loc4_.isPlayer)
            {
               _loc4_ = null;
            }
            else if(!_loc4_.visible && !_loc4_.isPlayer)
            {
               _loc4_ = null;
            }
         }
         if(!_loc4_)
         {
         }
         if(_loc4_)
         {
            this.board.selectedTile = this.findTile();
         }
         else
         {
            this.board.selectedTile = null;
         }
         this.board.hoverTile = this.findTile();
         if(!_loc4_ && this._turn && !this._turn.complete && !this._turn.committed && !this._turn.move.committed && !this._turn.ability)
         {
            _loc5_ = this._turn.entity;
         }
         else if(this.isDeploying && (!this.hilighted || _loc4_ == this.board.sim.fsm.interact))
         {
            _loc5_ = this.board.sim.fsm.interact;
         }
         var _loc6_:Tile = null;
         if(_loc5_)
         {
            _loc6_ = this.findTile();
         }
         var _loc7_:SceneControllerConfig = SceneControllerConfig.instance;
         if(_loc7_.restrictInput)
         {
            if(_loc5_)
            {
               if(!_loc6_)
               {
                  return false;
               }
            }
            else if(!_loc4_ || _loc7_.allowEntities.indexOf(_loc4_) == -1)
            {
               return false;
            }
         }
         this.hoverEntity = _loc4_;
         this.hilighted = _loc4_;
         if(_loc5_)
         {
            this.board.selectedTile = _loc6_;
            if(this.isDeploying && Boolean(_loc5_.isPlayer))
            {
               _loc8_ = _loc5_.party.deployment;
               _loc9_ = this.board.def.getDeploymentAreasById(_loc8_,null);
               _loc11_ = BattleBoardTileTargetHelper._findMoveTileDeploy(_loc5_,_loc9_.area,this.modelPointUnderMouse);
               if(_loc11_)
               {
                  this.board.selectedTile = _loc11_;
                  _loc10_ = true;
               }
               if(!_loc10_)
               {
                  this.board.selectedTile = null;
               }
            }
         }
         return true;
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
            this._turnMove.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         }
         this._turnMove = param1;
         if(this._turnMove)
         {
            this._turnMove.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
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
         this._turn = param1;
         this.turnMove = !!this._turn ? this._turn.move : null;
         this.update();
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         this.update();
      }
      
      private function findTile() : Tile
      {
         var _loc1_:Number = Math.floor(this.tileUnderMouse.x);
         var _loc2_:Number = Math.floor(this.tileUnderMouse.y);
         return this.board.tiles.getTile(_loc1_,_loc2_);
      }
      
      private function findClick(param1:Tile, param2:Boolean, param3:Boolean) : BattleEntity
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1)
         {
            _loc4_ = param1.x;
            _loc5_ = param1.y;
            return this.view.board._findEntityOnTile(_loc4_,_loc5_,param3,null,param2) as BattleEntity;
         }
         return null;
      }
      
      final public function mouseWheelHandler(param1:MouseEvent) : void
      {
      }
      
      final public function mouseMoveHandler(param1:Number, param2:Number) : void
      {
         if(!BattleFsmConfig.guiTilesEnabled)
         {
            return;
         }
         this.lastStageX = param1;
         this.lastStageY = param2;
         var _loc3_:Number = param1 - this.lastMouseMoveHandledX;
         var _loc4_:Number = param2 - this.lastMouseMoveHandledY;
         if(Math.abs(_loc3_) < this.MOUSE_MOVE_THRESHOLD && Math.abs(_loc4_) < this.MOUSE_MOVE_THRESHOLD)
         {
            return;
         }
         this.lastMouseMoveHandledX = param1;
         this.lastMouseMoveHandledY = param2;
         var _loc5_:SceneControllerConfig = SceneControllerConfig.instance;
         if(_loc5_.restrictInput)
         {
            if(!_loc5_.allowHover)
            {
               return;
            }
         }
         if(this.turn && this.turn.ability && (this.turn.ability.def.targetRule == BattleAbilityTargetRule.TILE_ANY || this.turn.ability.def.targetRule == BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE))
         {
            return;
         }
         this.hilightAt(param1,param2,true);
         this.handleMoveHover();
      }
      
      final private function handleMoveHover() : void
      {
         handleMoveHover_static(this.fsm,this._turn,this.modelPointUnderMouse,false);
      }
      
      private function get isDeploying() : Boolean
      {
         return this.board.sim.fsm.current is IBattleStateUserDeploying && BattleFsmConfig.guiWaveDeployEnabled;
      }
      
      private function handleDeploymentClick() : void
      {
         var _loc2_:Tile = null;
         var _loc3_:IBattleParty = null;
         var _loc4_:BattleDeploymentAreas = null;
         var _loc5_:BattleFacing = null;
         if(!this.isDeploying)
         {
            return;
         }
         var _loc1_:IBattleEntity = this.board.sim.fsm.interact;
         if(Boolean(this.hilighted) && this.hilighted != _loc1_)
         {
            if(this.hilighted.mobile == true && Boolean(this.hilighted.playerControlled) && !this.hilighted.party.deployed)
            {
               this.board.sim.fsm.interact = this.hilighted;
               this.board.scene.context.staticSoundController.playSound("ui_generic",null);
            }
            else
            {
               this.board.scene.context.staticSoundController.playSound("ui_dismiss",null);
               this.board.sim.fsm.interact = this.hilighted;
            }
         }
         else if(_loc1_ && _loc1_.playerControlled && !_loc1_.party.deployed && !_loc1_.deploymentFinalized)
         {
            _loc2_ = this.board.selectedTile;
            if(_loc2_)
            {
               _loc3_ = _loc1_.party;
               _loc4_ = this.board.def.getDeploymentAreasById(_loc3_.deployment,null);
               if(_loc4_.area.hasTile(_loc2_.location))
               {
                  _loc5_ = _loc4_.getLocationFacing(_loc2_.location);
                  if(this.board.attemptDeploy(_loc1_,_loc5_,_loc4_.area,_loc2_.location))
                  {
                     this.board.scene.context.staticSoundController.playSound("ui_movement_button",null);
                     return;
                  }
               }
            }
            this.board.logger.info("Cannot deploy there");
            this.board.scene.context.staticSoundController.playSound("ui_error",null);
         }
      }
      
      final public function mouseUpHandler(param1:Number, param2:Number) : void
      {
         var _loc8_:SceneControllerConfig = null;
         if(!BattleFsmConfig.guiTilesEnabled)
         {
            return;
         }
         var _loc3_:IBattleEntity = !!this._turn ? this._turn.entity : null;
         if(_loc3_)
         {
            if(_loc3_.playerControlled)
            {
               if(!_loc3_.battleHudIndicatorVisible)
               {
                  return;
               }
            }
         }
         this.lastStageX = param1;
         this.lastStageY = param2;
         var _loc4_:Boolean = true;
         var _loc5_:BattleAbility = !!this._turn ? this._turn.ability : null;
         if(Boolean(_loc5_) && _loc5_.def.targetRule == BattleAbilityTargetRule.DEAD)
         {
            _loc4_ = false;
         }
         var _loc6_:Boolean = this.hilightAt(param1,param2,_loc4_);
         if(!this._turn)
         {
            this.handleDeploymentClick();
            return;
         }
         if(!_loc6_)
         {
            return;
         }
         var _loc7_:IBattleEntity = this.board.sim.fsm.interact;
         if(!this.turn.entity.playerControlled || this.turn.committed)
         {
            this.board.sim.fsm.interact = this.hilighted;
            this.board.showInfoBanner(this.hilighted);
            return;
         }
         if(this._turn.attackMode)
         {
            this.board.sim.fsm.interact = null;
            this.board.sim.fsm.interact = this.hilighted;
            if(!this.hilighted || this.hilighted.team == this.board.sim.fsm.turn.entity.team)
            {
               this.board.sim.fsm.interact = this.turn.entity;
               this._turn.attackMode = false;
               this.board.sim.fsm.dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ATTACK));
               return;
            }
         }
         if(this.turn.ability)
         {
            this.board.sim.fsm.interact = null;
            this.board.sim.fsm.interact = this.hilighted;
            this.handleAbilityClick();
            if(!this.turn.ability)
            {
               this.handleMoveHover();
            }
         }
         else if(this.handleMoveClick())
         {
            this.board.sim.fsm.interact = null;
         }
         else
         {
            _loc8_ = SceneControllerConfig.instance;
            if(_loc8_.restrictInput)
            {
               if(!this.hilighted)
               {
                  return;
               }
               if(Boolean(_loc8_.allowEntities) && _loc8_.allowEntities.indexOf(this.hilighted) < 0)
               {
                  return;
               }
            }
            this.board.sim.fsm.interact = null;
            this.board.sim.fsm.interact = this.hilighted;
         }
      }
      
      private function handleMoveClick() : Boolean
      {
         var _loc3_:Tile = null;
         if(this.board.abilityManager.numIncompleteAbilities > 0 || !this._turn)
         {
            return false;
         }
         var _loc1_:IBattleMove = this._turn.move;
         if(!_loc1_ || _loc1_.committed || this._turn.committed)
         {
            return false;
         }
         if(this.turn.selfPopupAnimating)
         {
            return false;
         }
         var _loc2_:SceneControllerConfig = SceneControllerConfig.instance;
         if(handleMoveHover_static(this.fsm,this._turn,this.modelPointUnderMouse,true))
         {
            _loc3_ = _loc1_.last;
            if(_loc3_ == _loc1_.wayPointTile)
            {
               if(_loc1_.numSteps > 1)
               {
                  if(_loc1_.pathEndBlocked)
                  {
                     this.logger.info("Cannot move to blocked tile [" + _loc1_.last + "] " + _loc1_.lastFacing);
                     this.board.scene.context.staticSoundController.playSound("ui_error",null);
                  }
                  else
                  {
                     _loc1_.setCommitted("handleMoveClick");
                  }
               }
            }
            else
            {
               if(_loc2_.restrictInput)
               {
                  if(_loc3_ != _loc2_.allowMoveTile && _loc3_ != _loc2_.allowWaypointTile)
                  {
                     this.logger.info("SceneControllerConfig prevents tile " + _loc3_);
                     this.board.scene.context.staticSoundController.playSound("ui_error",null);
                     return false;
                  }
               }
               _loc1_.setWayPoint(_loc3_);
            }
            return true;
         }
         _loc2_ = _loc2_;
         if(_loc2_.restrictInput)
         {
            return false;
         }
         this.turn.move.reset(_loc1_.first);
         this.fsm.interact = null;
         this.handleMoveHover();
         return false;
      }
      
      public function handleAbilityTileClick(param1:Tile) : void
      {
         var _loc8_:BattleAbilityDef = null;
         var _loc9_:BattleAbility = null;
         var _loc12_:BattleAbilityDef = null;
         var _loc13_:int = 0;
         var _loc14_:Tile = null;
         var _loc2_:BattleAbilityValidation = null;
         var _loc3_:BattleAbility = this._turn.ability;
         var _loc4_:BattleAbilityDef = this._turn.ability.def as BattleAbilityDef;
         var _loc5_:BattleAbilityTargetRule = _loc3_.def.targetRule;
         var _loc6_:IBattleEntity = this._turn.entity;
         var _loc7_:IBattleMove = this._turn.move;
         if(!_loc5_.isTile && _loc5_ != BattleAbilityTargetRule.FORWARD_ARC)
         {
            return;
         }
         this.board.selectedTile = param1;
         if(!param1 || !(param1.location in this._turn._inRangeTiles))
         {
            this.turn.ability = null;
            return;
         }
         if(this.hilighted != null)
         {
            if(!(_loc5_ == BattleAbilityTargetRule.TILE_ANY || _loc5_ == BattleAbilityTargetRule.FORWARD_ARC || _loc5_ == BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE))
            {
               this.turn.ability = null;
               return;
            }
            this.hilighted = null;
         }
         _loc2_ = BattleAbilityValidation.validate(_loc4_,_loc6_,_loc7_,null,param1,false,true,true);
         if(_loc2_ != BattleAbilityValidation.OK)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("handleAbilityTileClick Invalid: -- bonk: " + _loc2_);
            }
            this.turn.ability = null;
            return;
         }
         _loc3_._targetSet.supressEvents = true;
         if(_loc5_ == BattleAbilityTargetRule.TILE_EMPTY_RANDOM)
         {
            _loc3_._targetSet.setTile(this.board._selectedTile);
         }
         else if(_loc5_ == BattleAbilityTargetRule.FORWARD_ARC)
         {
            BattleBoardTargetHelper.forwardArc_setupAbility(_loc3_,param1);
         }
         else if(_loc3_.targetSet.hasTile(this.board._selectedTile))
         {
            _loc3_._targetSet.removeTile(this.board._selectedTile);
         }
         else
         {
            _loc3_._targetSet.addTile(this.board._selectedTile);
            _loc12_ = this._turn.entity.highestAvailableAbilityDef(_loc3_.def.id) as BattleAbilityDef;
            if(_loc12_)
            {
               _loc13_ = _loc3_.targetSet.tiles.length - _loc12_.targetCount;
               while(_loc13_ > 0)
               {
                  _loc13_--;
                  _loc14_ = _loc3_._targetSet.tiles[0];
                  this.logger.info("Ability " + _loc12_ + " cannot handle " + _loc3_._targetSet.tiles.length + " tiles, stripping off " + _loc14_);
                  _loc3_._targetSet.removeTile(_loc14_);
               }
            }
         }
         var _loc10_:IBattleEntity = this._turn.entity;
         var _loc11_:IBattleMove = this._turn.move;
         _loc8_ = _loc10_.lowestValidAbilityDefForTargetCount(_loc3_.def.id,_loc11_,_loc3_._targetSet) as BattleAbilityDef;
         if(_loc8_ != null && _loc8_.level != _loc3_._def.level)
         {
            this.logger.info("Ability " + _loc3_ + " at wrong rank for " + _loc3_._targetSet.tiles.length + " tiles, changing to " + _loc8_);
            _loc9_ = new BattleAbility(this._turn.entity,_loc8_,this.board.abilityManager);
            _loc9_.targetSet = _loc3_.targetSet.clone(_loc9_);
            _loc3_ = _loc9_;
            this.turn.ability = _loc9_;
         }
         _loc3_._targetSet.supressEvents = false;
         this._turn.notifyTargetsUpdated();
      }
      
      public function handleAbilityClick() : void
      {
         var _loc5_:BattleAbility = null;
         var _loc6_:Tile = null;
         var _loc7_:BattleAbilityDef = null;
         var _loc8_:int = 0;
         if(this._turn.ability.executed || this._turn.ability.executing)
         {
            return;
         }
         var _loc1_:BattleAbility = this._turn.ability;
         var _loc2_:BattleAbilityDef = _loc1_.def;
         var _loc3_:BattleAbilityTargetRule = _loc2_.targetRule;
         if(_loc3_.isTile || _loc3_ == BattleAbilityTargetRule.FORWARD_ARC)
         {
            _loc6_ = this.findTile();
            this.handleAbilityTileClick(_loc6_);
            return;
         }
         if(this._turn.turnInteract == this.turn.entity)
         {
            this._turn.ability = null;
            this.board.sim.fsm.interact = this.turn.entity;
            return;
         }
         var _loc4_:BattleAbilityDef = this._turn.entity.lowestValidAbilityDef(this.turn.ability.def.id,this.fsm.interact,null,this.turn.move) as BattleAbilityDef;
         if(_loc4_ == null)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("handleAbilityClick Invalid: -- bonk");
            }
            this._turn.ability = null;
            this.fsm.interact = this._turn.entity;
            return;
         }
         this._turn.ability.lowestLevelAllowed = _loc4_.level;
         if(this._turn.ability.def.targetCount == 0)
         {
            this.logger.info("Needs no targets: " + this.turn.ability);
            return;
         }
         if(this._turn.ability.def.targetRule == BattleAbilityTargetRule.ADJACENT_BATTLEENTITY)
         {
            this.handleAbilityAdjacentClick();
            return;
         }
         if(this._turn.ability.def.targetRule == BattleAbilityTargetRule.ARC_LIGHTNING)
         {
            this.handleAbilityClick_ArcLightning();
            return;
         }
         if(this._turn.ability.def.targetRule == BattleAbilityTargetRule.NEEDLE_TARGET_ENEMY_OTHER_ALL || this._turn.ability.def.targetRule == BattleAbilityTargetRule.CROSS_TARGET_ENEMY_OTHER_ALL)
         {
            this.handleAbilityNeedleClick(this.turn.ability.def.targetRule);
            return;
         }
         if(_loc1_.targetSet.hasTarget(this.fsm.interact))
         {
            _loc1_.targetSet.supressEvents = true;
            _loc1_.targetSet.removeTarget(this.fsm.interact);
         }
         else
         {
            _loc1_.targetSet.supressEvents = true;
            _loc1_.targetSet.addTarget(this.fsm.interact);
            _loc7_ = this._turn.entity.highestAvailableAbilityDef(_loc1_.def.id) as BattleAbilityDef;
            if(_loc7_)
            {
               _loc8_ = _loc1_.targetSet.targets.length - _loc7_.targetCount;
               while(_loc8_ > 0)
               {
                  _loc8_--;
                  _loc1_.targetSet.removeTarget(_loc1_.targetSet.targets[0]);
               }
            }
         }
         _loc4_ = this._turn.entity.lowestValidAbilityDefForTargetCount(_loc1_.def.id,this._turn.move,_loc1_._targetSet) as BattleAbilityDef;
         if(_loc4_ != null && _loc4_.level != this.turn.ability.def.level)
         {
            _loc5_ = new BattleAbility(this._turn.entity,_loc4_,this.board.abilityManager);
            _loc5_.lowestLevelAllowed = _loc4_.level;
            _loc5_.targetSet = _loc1_.targetSet.clone(_loc5_);
            _loc1_ = _loc5_;
            this._turn.ability = _loc5_;
         }
         _loc1_.targetSet.supressEvents = false;
         this._turn.ability.lowestLevelAllowed = this.turn.ability.def.level;
         this._turn.notifyTargetsUpdated();
      }
      
      private function handleAbilityNeedleClick(param1:BattleAbilityTargetRule) : void
      {
         var _loc11_:IBattleEntity = null;
         var _loc2_:IBattleEntity = this._turn._ability.caster;
         var _loc3_:IBattleEntity = this._turn.turnInteract;
         var _loc4_:BattleAbility = this._turn._ability;
         if(!_loc3_)
         {
            _loc4_.targetSet.setTarget(null);
            return;
         }
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:TileRect = _loc2_.rect;
         var _loc8_:TileRect = _loc3_.rect;
         if(_loc8_.back <= _loc7_.front)
         {
            _loc6_ = -1;
         }
         else if(_loc8_.front >= _loc7_.back)
         {
            _loc6_ = 1;
         }
         else if(_loc8_.left >= _loc7_.right)
         {
            _loc5_ = 1;
         }
         else if(_loc8_.right <= _loc7_.left)
         {
            _loc5_ = -1;
         }
         var _loc9_:int = _loc7_.left;
         var _loc10_:int = _loc7_.front;
         var _loc12_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc13_:int = 0;
         while(_loc13_ < 100)
         {
            _loc9_ += _loc5_;
            _loc10_ += _loc6_;
            _loc11_ = _loc2_.board.findEntityOnTile(_loc9_,_loc10_,true,_loc2_);
            if(_loc11_)
            {
               if(_loc12_.indexOf(_loc11_) < 0)
               {
                  if(param1 == BattleAbilityTargetRule.NEEDLE_TARGET_ENEMY_OTHER_ALL)
                  {
                  }
                  _loc12_.push(_loc11_);
                  if(param1 == BattleAbilityTargetRule.CROSS_TARGET_ENEMY_OTHER_ALL)
                  {
                     break;
                  }
                  if(_loc11_ == _loc3_)
                  {
                     break;
                  }
               }
            }
            _loc13_++;
         }
         this.setTargets(_loc12_);
      }
      
      private function setTargets(param1:Vector.<IBattleEntity>) : void
      {
         var _loc5_:IBattleEntity = null;
         var _loc2_:BattleAbility = this._turn._ability;
         _loc2_.targetSet.supressEvents = true;
         _loc2_.targetSet.setTarget(null);
         var _loc3_:int = this.turn.ability.def.targetCount;
         var _loc4_:int = 0;
         while(_loc2_.targetSet.targets.length < _loc3_ && _loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            if(!_loc2_.targetSet.hasTarget(_loc5_))
            {
               _loc2_.targetSet.addTarget(_loc5_);
            }
            _loc4_++;
         }
         _loc2_.targetSet.supressEvents = false;
         this.turn.notifyTargetsUpdated();
      }
      
      private function handleAbilityClick_ArcLightning() : void
      {
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:IBattleEntity = this._turn.turnInteract;
         if(!_loc2_)
         {
            this._turn.ability = null;
            return;
         }
         _loc1_ = Op_ArcLightningAoe.computeAssociatedTargets(_loc2_,_loc1_);
         var _loc3_:BattleAbility = this._turn.ability;
         delete _loc1_[_loc2_];
         _loc3_.setAssociatedTargets(_loc1_);
         var _loc4_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         _loc4_.push(_loc2_);
         this.setTargets(_loc4_);
      }
      
      private function handleAbilityAdjacentClick() : void
      {
         var _loc1_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc2_:IBattleAbility = this.turn.ability;
         var _loc3_:IBattleEntity = _loc2_.caster;
         var _loc4_:BattleAbilityTargetRule = _loc2_.def.targetRule;
         var _loc5_:IBattleMove = this._turn.move;
         var _loc6_:TileRect = _loc5_.interrupted ? _loc3_.rect : _loc5_.lastTileRect;
         BattleBoardTargetHelper.selectAdjacent(_loc3_,_loc6_,_loc4_,_loc1_);
         var _loc7_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         BattleBoardTargetHelper.sortClockwise(_loc3_,this.turn.turnInteract,_loc1_,_loc7_);
         var _loc8_:BattleAbility = this._turn.ability;
         if(_loc7_.length > _loc8_.def.targetCount)
         {
            _loc7_.splice(_loc8_.def.targetCount,_loc7_.length - _loc8_.def.targetCount);
         }
         this.setTargets(_loc7_);
      }
      
      final public function mouseDownHandler(param1:Number, param2:Number) : void
      {
         if(!BattleFsmConfig.guiTilesEnabled)
         {
            return;
         }
         this.lastStageX = param1;
         this.lastStageY = param2;
         this.hilightAt(param1,param2,true);
      }
   }
}
