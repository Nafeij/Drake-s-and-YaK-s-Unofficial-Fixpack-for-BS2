package game.gui.page
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleDeploymentArea;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.view.EntityView;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.core.fsm.FsmEvent;
   import engine.core.gp.GpControlButton;
   import engine.core.render.Camera;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.landscape.view.LandscapeViewController;
   import engine.saga.Saga;
   import engine.scene.SceneControllerConfig;
   import engine.tile.Tile;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import game.cfg.GameConfig;
   
   public class BattleHudGpOverlay extends Sprite
   {
      
      public static var mcClazz:Class;
       
      
      private var bhp:BattleHudPage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var board:BattleBoard;
      
      private var boardView:BattleBoardView;
      
      private var bmp_lstick:GuiGpBitmap;
      
      private var bmp_cross:GuiGpBitmap;
      
      private var bmp_square:GuiGpBitmap;
      
      private var bmp_dpad:GuiGpBitmap;
      
      private var fsm:BattleFsm;
      
      private var _ent:BattleEntity;
      
      private var scratchPt:Point;
      
      private var lastScale:Number = 1;
      
      private var landscapeController:LandscapeViewController;
      
      private var _displayDirty:Boolean = true;
      
      public function BattleHudGpOverlay(param1:BattleHudPage)
      {
         this.bmp_lstick = GuiGp.ctorPrimaryBitmap(GpControlButton.LSTICK);
         this.bmp_cross = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
         this.bmp_square = GuiGp.ctorPrimaryBitmap(GpControlButton.X);
         this.bmp_dpad = GuiGp.ctorPrimaryBitmap(GpControlButton.D_LR);
         this.scratchPt = new Point();
         super();
         this.name = "gp_overlay";
         this.bhp = param1;
         this.config = param1.config;
         this.mouseEnabled = this.mouseChildren = false;
         this.landscapeController = param1.battleHandler.page.controller.landscapeController;
         this.bmp_lstick.scale = 1;
         this.bmp_cross.scale = 0.75;
         this.bmp_square.scale = 0.75;
         this.bmp_dpad.scale = 1;
         addChild(this.bmp_lstick);
         addChild(this.bmp_cross);
         addChild(this.bmp_square);
         addChild(this.bmp_dpad);
         this.bmp_lstick.visible = false;
         this.bmp_cross.visible = false;
         this.bmp_square.visible = false;
         this.bmp_dpad.visible = false;
         this.fsm = param1.fsm;
         this.board = param1.board;
         this.boardView = param1.view;
         this.fsm.addEventListener(BattleFsmEvent.INTERACT,this.fsmInteractHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.dirtyHandler);
         this.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.fsm.addEventListener(BattleFsmEvent.BATTLE_FINISHED,this.battleFinishedHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.dirtyHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.dirtyHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.dirtyHandler);
         this.board.addEventListener(BattleBoardEvent.SELECT_TILE,this.boardSelectTileHandler);
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         this.landscapeController.addEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.dirtyHandler);
         this.config.sceneControllerConfig.addEventListener(SceneControllerConfig.EVENT_CHANGED,this.dirtyHandler);
      }
      
      private function battleFinishedHandler(param1:BattleFsmEvent) : void
      {
         this._displayDirty = true;
      }
      
      public function cleanup() : void
      {
         this.fsm.removeEventListener(BattleFsmEvent.INTERACT,this.fsmInteractHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.dirtyHandler);
         this.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.fsm.removeEventListener(BattleFsmEvent.BATTLE_FINISHED,this.battleFinishedHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.dirtyHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.dirtyHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_EXECUTING,this.dirtyHandler);
         this.board.removeEventListener(BattleBoardEvent.SELECT_TILE,this.boardSelectTileHandler);
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         this.landscapeController.removeEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.dirtyHandler);
         this.config.sceneControllerConfig.removeEventListener(SceneControllerConfig.EVENT_CHANGED,this.dirtyHandler);
         this.ent = null;
         this.fsm = null;
         this.board = null;
         this.boardView = null;
         GuiGp.releasePrimaryBitmap(this.bmp_lstick);
         GuiGp.releasePrimaryBitmap(this.bmp_cross);
         GuiGp.releasePrimaryBitmap(this.bmp_square);
         GuiGp.releasePrimaryBitmap(this.bmp_dpad);
         this.bmp_lstick = null;
         this.bmp_cross = null;
         this.bmp_square = null;
         this.bmp_dpad = null;
         if(this.board)
         {
            this.board = null;
         }
         this.boardView = null;
         if(this.saga)
         {
            this.saga = null;
         }
         this.landscapeController = null;
         this.bhp = null;
         this.config = null;
      }
      
      private function lastInputHandler(param1:Event) : void
      {
         this.dirty();
      }
      
      private function boardSelectTileHandler(param1:BattleBoardEvent) : void
      {
         this.dirty();
      }
      
      private function fsmInteractHandler(param1:BattleFsmEvent) : void
      {
         this.ent = this.fsm.interact as BattleEntity;
         this.dirty();
      }
      
      private function dirtyHandler(param1:Event) : void
      {
         this.dirty();
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         this.dirty();
      }
      
      private function entityMovedHandler(param1:BattleEntityEvent) : void
      {
         this.dirty();
      }
      
      public function dirty() : void
      {
         this._displayDirty = true;
      }
      
      private function resetDisplay() : void
      {
         var _loc5_:Tile = null;
         var _loc6_:Point = null;
         var _loc12_:BattleDeploymentArea = null;
         var _loc13_:BattleTurn = null;
         var _loc14_:BattleAbility = null;
         var _loc15_:Boolean = false;
         var _loc16_:* = false;
         var _loc17_:Boolean = false;
         this._displayDirty = false;
         this.bmp_lstick.visible = false;
         this.bmp_cross.visible = false;
         this.bmp_square.visible = false;
         this.bmp_dpad.visible = false;
         if(this.fsm.battleFinished)
         {
            return;
         }
         if(this.landscapeController.landscapeClickable)
         {
            return;
         }
         var _loc1_:SceneControllerConfig = this.config.sceneControllerConfig;
         if(_loc1_.restrictInput)
         {
            if(!_loc1_.allowHover && !_loc1_.allowMoveTile)
            {
               return;
            }
         }
         var _loc2_:BattleStateDeploy = this.fsm.current as BattleStateDeploy;
         var _loc3_:BattleStateTurnLocal = this.fsm.current as BattleStateTurnLocal;
         var _loc4_:IBattleEntity = null;
         _loc5_ = this.board.selectedTile;
         var _loc7_:IBattleMove = Boolean(this.fsm) && Boolean(this.fsm.turn) ? this.fsm.turn.move : null;
         if(_loc2_)
         {
            _loc4_ = this.fsm.interact;
            if(_loc4_)
            {
               if(!_loc4_.isPlayer || !_loc4_.party)
               {
                  return;
               }
               this.bmp_lstick.visible = true;
               if(!_loc5_)
               {
                  _loc5_ = _loc4_.tile;
               }
               if(_loc5_ != _loc4_.tile)
               {
                  _loc12_ = this.board.def.getDeploymentAreaById(_loc4_.party.deployment);
                  if(!_loc12_)
                  {
                     return;
                  }
                  if(!this.board._deploy.canDeployEitherWay(_loc4_,_loc12_.facing,_loc12_.area,_loc5_.location))
                  {
                     return;
                  }
                  this.bmp_cross.visible = true;
               }
            }
         }
         else
         {
            if(!_loc3_)
            {
               return;
            }
            _loc13_ = this.fsm.turn as BattleTurn;
            if(!_loc13_ || _loc13_.committed)
            {
               return;
            }
            if(_loc13_.attackMode)
            {
               _loc4_ = _loc13_.turnInteract;
               if(!_loc4_ || _loc4_ == _loc3_.entity)
               {
                  this.bmp_dpad.visible = true;
                  _loc4_ = _loc3_.entity;
               }
               _loc5_ = _loc4_.tile;
            }
            else if(_loc13_.ability)
            {
               _loc4_ = _loc13_.turnInteract;
               _loc14_ = _loc13_._ability;
               if(Boolean(_loc14_) && _loc14_.def.targetRule.isTile)
               {
                  if(_loc5_)
                  {
                     if(!_loc14_.targetSet.hasTile(_loc5_))
                     {
                        this.bmp_lstick.visible = true;
                        if(_loc13_.hasInRangeTile(_loc5_))
                        {
                           this.bmp_cross.visible = true;
                        }
                     }
                  }
               }
               else
               {
                  if(!_loc4_ || _loc4_ == _loc3_.entity && !_loc13_.ability.targetSet.hasTarget(_loc4_))
                  {
                     this.bmp_dpad.visible = true;
                     _loc4_ = _loc3_.entity;
                  }
                  _loc5_ = !!_loc4_ ? _loc4_.tile : null;
               }
            }
            else
            {
               if(!(_loc7_ && !_loc7_.committed && !this.fsm.interact && Boolean(_loc5_)))
               {
                  return;
               }
               _loc4_ = _loc3_.entity;
               _loc15_ = !_loc1_.restrictInput || _loc1_.allowMoveTile == _loc5_;
               _loc16_ = !_loc1_.restrictInput;
               _loc17_ = !_loc1_.restrictInput || _loc1_.allowWaypointTile == _loc5_;
               if(_loc5_ != _loc4_.tile)
               {
                  if(_loc5_ == _loc7_.wayPointTile)
                  {
                     this.bmp_cross.visible = _loc15_;
                  }
                  else
                  {
                     if(!(Boolean(this.fsm.turn.move.flood) && this.fsm.turn.move.flood.hasResultKey(_loc5_)))
                     {
                        return;
                     }
                     this.bmp_cross.visible = _loc15_;
                     if(_loc5_ != _loc7_.wayPointTile)
                     {
                        if(_loc7_.numSteps < _loc7_.flood.costLimit + _loc7_.wayPointSteps)
                        {
                           this.bmp_square.visible = _loc17_;
                        }
                     }
                  }
               }
               this.bmp_lstick.visible = true;
            }
         }
         if(!this.bhp || !this.bhp.view)
         {
            return;
         }
         var _loc8_:EntityView = this.bhp.view.getEntityView(_loc4_);
         if(!_loc4_ || !_loc8_ || !_loc5_)
         {
            return;
         }
         var _loc9_:Number = _loc5_.x + Number(_loc4_.boardWidth) / 2;
         var _loc10_:Number = _loc5_.y + Number(_loc4_.boardLength) / 2;
         var _loc11_:Number = this.board.scene.camera.scale;
         _loc6_ = this.boardView.getScreenPointFromBoardPoint(_loc9_,_loc10_);
         _loc6_.x *= _loc11_;
         _loc6_.y *= _loc11_;
         _loc8_.getBattleDamageFlagPosition(this.scratchPt);
         this.bmp_lstick.x = _loc6_.x - this.bmp_lstick.width / 2;
         this.bmp_lstick.y = _loc6_.y - this.bmp_lstick.height + 0;
         this.bmp_cross.x = this.bmp_lstick.x - this.bmp_cross.width;
         this.bmp_cross.y = this.bmp_lstick.y;
         this.bmp_square.x = this.bmp_lstick.x + this.bmp_lstick.width;
         this.bmp_square.y = this.bmp_lstick.y;
         this.bmp_dpad.x = _loc6_.x - this.bmp_dpad.width / 2;
         if(this.bmp_lstick.visible)
         {
            this.bmp_dpad.y = this.bmp_lstick.y - this.bmp_dpad.height;
         }
         else
         {
            this.bmp_dpad.y = _loc6_.y - this.bmp_dpad.height / 2;
         }
      }
      
      public function update() : void
      {
         var _loc4_:MovieClip = null;
         if(this._displayDirty)
         {
            this.resetDisplay();
         }
         if(!this.board || !this.boardView || !this.boardView.layerSprite)
         {
            return;
         }
         var _loc1_:Camera = this.board.scene.camera;
         var _loc2_:Number = !!_loc1_ ? _loc1_.scale : 1;
         this.x = this.bhp.width / 2 + (this.boardView.layerSprite.x + this.board.def.pos.x) * _loc2_;
         this.y = this.bhp.height / 2 + (this.boardView.layerSprite.y + this.board.def.pos.y) * _loc2_;
         var _loc3_:int = 0;
         var _loc5_:Number = Math.max(1,_loc2_);
      }
      
      public function get ent() : BattleEntity
      {
         return this._ent;
      }
      
      public function set ent(param1:BattleEntity) : void
      {
         if(this._ent == param1)
         {
            return;
         }
         if(this._ent)
         {
            this._ent.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
         }
         this._ent = param1;
         if(this._ent)
         {
            this._ent.addEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
         }
      }
   }
}
