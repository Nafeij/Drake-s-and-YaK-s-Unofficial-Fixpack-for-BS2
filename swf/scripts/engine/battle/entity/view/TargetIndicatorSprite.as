package engine.battle.entity.view
{
   import as3isolib.utils.IsoUtil;
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.BattleEntityMobilityEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.overlay.MovePlanOverlay;
   import engine.battle.board.view.underlay.TilesUnderlay;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.AnimClipSpritePool;
   import engine.resource.BitmapPool;
   import engine.tile.def.TileRect;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class TargetIndicatorSprite
   {
      
      public static const BIT:uint = TilesUnderlay.nextBit("TargetIndicatorSprite.BIT");
       
      
      public var entity:IBattleEntity;
      
      public var poolBmp:BitmapPool;
      
      public var poolAnimClipSprite:AnimClipSpritePool;
      
      public var assets:BattleAssetsDef;
      
      public var fsm:BattleFsm;
      
      public var _url:String;
      
      private var _bmp:DisplayObjectWrapper;
      
      private var _animClipSprite:DisplayObjectWrapper;
      
      private var view:EntityView;
      
      private var _hoverBmp:DisplayObjectWrapper;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      private var oldRect:TileRect;
      
      private var oldRectValid:Boolean;
      
      public function TargetIndicatorSprite(param1:EntityView, param2:BattleFsm, param3:Number, param4:BitmapPool, param5:AnimClipSpritePool, param6:BattleAssetsDef)
      {
         this.oldRect = new TileRect(null,0,0);
         super();
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         this.displayObjectWrapper.name = "target";
         this.view = param1;
         this.entity = param1.entity;
         this.poolBmp = param4;
         this.poolAnimClipSprite = param5;
         this.assets = param6;
         this.fsm = param2;
         param4.addPool(param6.mouse_hover_1,1,3);
         param4.addPool(param6.mouse_hover_1x2,1,3);
         param4.addPool(param6.mouse_hover_2,1,3);
         param4.addPool(param6.board_enemy_target_1,1,3);
         param4.addPool(param6.board_enemy_target_1x2,1,3);
         param4.addPool(param6.board_enemy_target_2,1,3);
         param4.addPool(param6.board_friend_target_1,1,3);
         param4.addPool(param6.board_friend_target_1x2,1,3);
         param4.addPool(param6.board_friend_target_2,1,3);
         param4.addPool(param6.board_ability_target_1,1,3);
         param4.addPool(param6.board_ability_target_1x2,1,3);
         param4.addPool(param6.board_ability_target_2,1,3);
         param4.addPool(param6.board_enemy_1,1,3);
         param4.addPool(param6.board_enemy_1x2,1,3);
         param4.addPool(param6.board_enemy_2,1,3);
         param4.addPool(param6.board_friend_1,1,3);
         param4.addPool(param6.board_friend_1x2,1,3);
         param4.addPool(param6.board_friend_2,1,3);
         this.poolAnimClipSprite.addPool(param6.board_active_enemy_1,1,1);
         this.poolAnimClipSprite.addPool(param6.board_active_enemy_1x2,1,1);
         this.poolAnimClipSprite.addPool(param6.board_active_enemy_2,1,1);
         this.poolAnimClipSprite.addPool(param6.board_active_1,1,1);
         this.poolAnimClipSprite.addPool(param6.board_active_1x2,1,1);
         this.poolAnimClipSprite.addPool(param6.board_active_2,1,1);
         this.poolAnimClipSprite.addPool(param6.board_enemy_range_1,1,3);
         this.poolAnimClipSprite.addPool(param6.board_enemy_range_1x2,1,3);
         this.poolAnimClipSprite.addPool(param6.board_enemy_range_2,1,3);
         this.poolAnimClipSprite.addPool(param6.board_friend_range_1,1,3);
         this.poolAnimClipSprite.addPool(param6.board_friend_range_1x2,1,3);
         this.poolAnimClipSprite.addPool(param6.board_friend_range_2,1,3);
         this.poolAnimClipSprite.addPool(param6.board_ability_range_1,1,3);
         this.poolAnimClipSprite.addPool(param6.board_ability_range_1x2,1,3);
         this.poolAnimClipSprite.addPool(param6.board_ability_range_2,1,3);
         param2.addEventListener(BattleFsmEvent.TURN,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.DEPLOY,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.TURN_ABILITY,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.INTERACT,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.TURN_IN_RANGE,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.TURN_COMPLETE,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.battleFsmEventHandler);
         param2.addEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.battleFsmEventHandler);
         this.entity.mobility.addEventListener(BattleEntityMobilityEvent.MOVING,this.entityMobilityMovingHandler);
         this.entity.addEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         this.entity.addEventListener(BattleEntityEvent.HOVERING,this.entityHoveringHandler);
         this.entity.addEventListener(BattleEntityEvent.VISIBLE,this.entityVisibleHandler);
         this.entity.addEventListener(BattleEntityEvent.SUBMERGED,this.entitySubmergedHandler);
         this.entity.addEventListener(BattleEntityEvent.FACING,this.entityFacingHandler);
         this.entity.addEventListener(BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE,this.battleHudIndicatorVisibilityChangedHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_TILES_ENABLE,this.battleHudGuiTilesEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleHudGuiTilesEnableHandler);
      }
      
      public static function positionRectangle(param1:DisplayObjectWrapper, param2:Boolean, param3:TileRect, param4:Number) : void
      {
         var _loc5_:* = param3._localLength == param3._localWidth;
         var _loc6_:BattleFacing = param3.facing as BattleFacing;
         MovePlanOverlay.centerTheDisplayObject(_loc6_,param1,param2,_loc5_);
         var _loc7_:Number = 0.5;
         var _loc8_:Number = param4;
         var _loc9_:Point = param3.localTail;
         var _loc10_:Number = _loc8_ * param3.diameter;
         var _loc11_:Number = _loc8_ * param3.tail;
         if(param3.tail == 0)
         {
            param1.y += _loc10_ / 2;
         }
         else if(_loc6_ == BattleFacing.NE)
         {
            param1.y += _loc10_ / 2 + _loc11_ / 4;
            param1.x -= _loc10_ / 2;
         }
         else if(_loc6_ == BattleFacing.NW)
         {
            param1.y += _loc10_ / 2 + _loc11_ / 4;
            param1.x += _loc10_ / 2;
         }
         else if(_loc6_ == BattleFacing.SW)
         {
            param1.y += _loc10_ / 2 + _loc11_ / 4;
            param1.x -= _loc10_ / 2;
         }
         else if(_loc6_ == BattleFacing.SE)
         {
            param1.y += _loc10_ / 2 + _loc11_ / 4;
            param1.x += _loc10_ / 2;
         }
         if(_loc5_)
         {
         }
      }
      
      private function battleHudIndicatorVisibilityChangedHandler(param1:BattleEntityEvent) : void
      {
         this.url = this.evaluate();
      }
      
      private function battleHudGuiTilesEnableHandler(param1:Event) : void
      {
         this.url = this.evaluate();
      }
      
      private function entityEnabledHandler(param1:BattleEntityEvent) : void
      {
         this.updateTilesFromState();
      }
      
      private function entityFacingHandler(param1:BattleEntityEvent) : void
      {
         this._positionSomething(this._bmp,true);
         this._positionSomething(this._hoverBmp,true);
         this._positionSomething(this._animClipSprite,false);
      }
      
      private function entityVisibleHandler(param1:BattleEntityEvent) : void
      {
         this.entityHoveringHandler(null);
         this.updateTilesFromState();
         this.url = this.evaluate();
      }
      
      private function entitySubmergedHandler(param1:BattleEntityEvent) : void
      {
         this.entityHoveringHandler(null);
         this.updateTilesFromState();
         this.url = this.evaluate();
      }
      
      private function entityHoveringHandler(param1:BattleEntityEvent) : void
      {
         if(this.entity.hovering && Boolean(this.entity.visible) && Boolean(this.entity.active) && Boolean(this.entity.enabled))
         {
            if(this.entity.isLocalRect(1,2))
            {
               this.hoverBmp = this.poolBmp.pop(this.assets.mouse_hover_1x2);
            }
            else if(this.entity.diameter == 1)
            {
               this.hoverBmp = this.poolBmp.pop(this.assets.mouse_hover_1);
            }
            else
            {
               this.hoverBmp = this.poolBmp.pop(this.assets.mouse_hover_2);
            }
         }
         else
         {
            this.hoverBmp = null;
         }
      }
      
      private function entityMobilityMovingHandler(param1:BattleEntityMobilityEvent) : void
      {
         this.updateTilesFromState();
      }
      
      private function updateTilesFromState() : void
      {
         if(this.entity.isSubmerged)
         {
            this.setTilesHidden(false);
            return;
         }
         if(this.entity.mobility.moving || !this.entity.enabled || !this.entity.active || !this.entity.visibleToPlayer)
         {
            this.setTilesHidden(false);
            return;
         }
         if(!this._checkAliveness())
         {
            this.setTilesHidden(false);
            return;
         }
         this.setTilesHidden(true);
      }
      
      private function _checkAliveness() : Boolean
      {
         var _loc1_:BattleAbility = null;
         if(!this.fsm)
         {
            return false;
         }
         if(this.fsm.currentClass == BattleStateDeploy)
         {
            return true;
         }
         if(!this.fsm.turn)
         {
            return true;
         }
         if(!this.entity.alive)
         {
            _loc1_ = this.fsm.turn.ability;
            if(!_loc1_ || _loc1_.executed || _loc1_.def.targetRule != BattleAbilityTargetRule.DEAD)
            {
               return false;
            }
         }
         return true;
      }
      
      public function cleanup() : void
      {
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_TILES_ENABLE,this.battleHudGuiTilesEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleHudGuiTilesEnableHandler);
         this.entity.removeEventListener(BattleEntityEvent.HOVERING,this.entityHoveringHandler);
         this.entity.removeEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         this.entity.removeEventListener(BattleEntityEvent.VISIBLE,this.entityVisibleHandler);
         this.entity.removeEventListener(BattleEntityEvent.SUBMERGED,this.entitySubmergedHandler);
         this.entity.removeEventListener(BattleEntityEvent.FACING,this.entityFacingHandler);
         this.entity.removeEventListener(BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE,this.battleHudIndicatorVisibilityChangedHandler);
         this.entity.mobility.removeEventListener(BattleEntityMobilityEvent.MOVING,this.entityMobilityMovingHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.DEPLOY,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.INTERACT,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_IN_RANGE,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_COMPLETE,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.battleFsmEventHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.battleFsmEventHandler);
      }
      
      private function set url(param1:String) : void
      {
         if(param1 == this._url)
         {
            return;
         }
         this._url = param1;
         if(this._url)
         {
            if(this._url.indexOf(".png") > 0)
            {
               this.bmp = this.poolBmp.pop(this._url);
            }
            else
            {
               this.animClipSprite = this.poolAnimClipSprite.pop(this._url);
            }
            this.setTilesHidden(true);
         }
         else
         {
            this.setTilesHidden(false);
            this.bmp = null;
            this.animClipSprite = null;
         }
      }
      
      private function setTilesHidden(param1:Boolean) : void
      {
         if(!this.entity.tile)
         {
            return;
         }
         var _loc2_:TileRect = this.entity.rect;
         var _loc3_:TilesUnderlay = this.view.battleBoardView.underlay.tilesUnderlay;
         if(this.oldRectValid && _loc2_ != this.oldRect && !_loc2_.equals(this.oldRect))
         {
            this.oldRect.visitEnclosedTileLocations(_loc3_.unhide,BIT);
            this.oldRectValid = false;
         }
         if(param1)
         {
            this.oldRect.copyFrom(_loc2_);
            this.oldRectValid = true;
            _loc3_.hideRect(_loc2_,BIT);
         }
         else
         {
            _loc3_.unhideRect(_loc2_,BIT);
         }
      }
      
      public function get bmp() : DisplayObjectWrapper
      {
         return this._bmp;
      }
      
      public function set bmp(param1:DisplayObjectWrapper) : void
      {
         if(this._bmp == param1)
         {
            return;
         }
         if(this._bmp)
         {
            this.displayObjectWrapper.removeChild(this._bmp);
            this.poolBmp.reclaim(this._bmp);
            this._bmp = null;
         }
         this._bmp = param1;
         if(this._bmp)
         {
            this.animClipSprite = null;
            this.displayObjectWrapper.addChild(this._bmp);
            this._positionSomething(this._bmp,true);
         }
      }
      
      private function _positionSomething(param1:DisplayObjectWrapper, param2:Boolean) : void
      {
         if(!this.entity || !param1)
         {
            return;
         }
         positionRectangle(param1,param2,this.entity.rect,this.view.battleBoardView.units);
      }
      
      public function get hoverBmp() : DisplayObjectWrapper
      {
         return this._hoverBmp;
      }
      
      public function set hoverBmp(param1:DisplayObjectWrapper) : void
      {
         if(this._hoverBmp == param1)
         {
            return;
         }
         if(this._hoverBmp)
         {
            this.displayObjectWrapper.removeChild(this._hoverBmp);
            this.poolBmp.reclaim(this._hoverBmp);
            this._hoverBmp = null;
         }
         this._hoverBmp = param1;
         if(this._hoverBmp)
         {
            this.displayObjectWrapper.addChild(this._hoverBmp);
            this._positionSomething(this._hoverBmp,true);
         }
      }
      
      public function get animClipSprite() : DisplayObjectWrapper
      {
         return this._animClipSprite;
      }
      
      public function set animClipSprite(param1:DisplayObjectWrapper) : void
      {
         if(this._animClipSprite == param1)
         {
            return;
         }
         if(this._animClipSprite)
         {
            this.displayObjectWrapper.removeChild(this._animClipSprite);
            this.poolAnimClipSprite.reclaim(this._animClipSprite);
            this._animClipSprite = null;
         }
         this._animClipSprite = param1;
         if(this._animClipSprite)
         {
            this.bmp = null;
            this._positionSomething(this._animClipSprite,false);
            this.displayObjectWrapper.addChild(this._animClipSprite);
            if(this._animClipSprite.anim)
            {
               this._animClipSprite.anim.clip.restart();
            }
         }
      }
      
      private function battleFsmEventHandler(param1:BattleFsmEvent) : void
      {
         this.updateTilesFromState();
         this.url = this.evaluate();
      }
      
      private function _evaluateInRangeTile() : String
      {
         if(this.fsm.turn.ability)
         {
            if(this.entity.isLocalRect(1,2))
            {
               return this.assets.board_ability_range_1x2;
            }
            if(this.entity.diameter == 1)
            {
               return this.assets.board_ability_range_1;
            }
            return this.assets.board_ability_range_2;
         }
         if(this.entity.isPlayer)
         {
            if(this.entity.isLocalRect(1,2))
            {
               return this.assets.board_friend_range_1x2;
            }
            if(this.entity.diameter == 1)
            {
               return this.assets.board_friend_range_1;
            }
            return this.assets.board_friend_range_2;
         }
         if(this.entity.isLocalRect(1,2))
         {
            return this.assets.board_enemy_range_1x2;
         }
         if(this.entity.diameter == 1)
         {
            return this.assets.board_enemy_range_1;
         }
         return this.assets.board_enemy_range_2;
      }
      
      private function _evaluateBasicTile() : String
      {
         if(this.entity.isEnemy)
         {
            if(this.entity.isLocalRect(1,2))
            {
               return this.assets.board_enemy_1x2;
            }
            if(this.entity.diameter == 1)
            {
               return this.assets.board_enemy_1;
            }
            return this.assets.board_enemy_2;
         }
         if(this.entity.isLocalRect(1,2))
         {
            return this.assets.board_friend_1x2;
         }
         if(this.entity.diameter == 1)
         {
            return this.assets.board_friend_1;
         }
         return this.assets.board_friend_2;
      }
      
      private function _evaluateActiveTile() : String
      {
         if(this.entity.isLocalRect(1,2))
         {
            return this.assets.board_active_1x2;
         }
         if(this.entity.diameter == 1)
         {
            return this.assets.board_active_1;
         }
         return this.assets.board_active_2;
      }
      
      private function _evaluateTargetTile() : String
      {
         var _loc1_:BattleTurn = this.fsm.turn as BattleTurn;
         if(Boolean(_loc1_) && Boolean(_loc1_._ability))
         {
            if(this.entity.isLocalRect(1,2))
            {
               return this.assets.board_ability_target_1x2;
            }
            if(this.entity.diameter == 1)
            {
               return this.assets.board_ability_target_1;
            }
            return this.assets.board_ability_target_2;
         }
         if(this.entity.isPlayer)
         {
            if(this.entity.isLocalRect(1,2))
            {
               return this.assets.board_friend_target_1x2;
            }
            if(this.entity.diameter == 1)
            {
               return this.assets.board_friend_target_1;
            }
            return this.assets.board_friend_target_2;
         }
         if(this.entity.isLocalRect(1,2))
         {
            return this.assets.board_enemy_target_1x2;
         }
         if(this.entity.diameter == 1)
         {
            return this.assets.board_enemy_target_1;
         }
         return this.assets.board_enemy_target_2;
      }
      
      private function evaluate() : String
      {
         var _loc2_:BattleAbility = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         if(!this.fsm)
         {
            return null;
         }
         if(!this._checkAliveness())
         {
            return null;
         }
         if(!this.entity.enabled || !BattleFsmConfig.guiTilesShouldRender || !this.entity.visibleToPlayer || !this.entity.active)
         {
            return null;
         }
         if(this.entity.isSubmerged)
         {
            return null;
         }
         if(!this.entity.battleHudIndicatorVisible)
         {
            return null;
         }
         if(!this.entity.attackable)
         {
            return null;
         }
         if(this.fsm.currentClass == BattleStateDeploy)
         {
            if(!this.entity.mobile || this.entity.deploymentFinalized)
            {
               return null;
            }
            if(this.fsm.interact == this.entity)
            {
               if(this.entity.isEnemy)
               {
                  return this._evaluateTargetTile();
               }
               return this._evaluateActiveTile();
            }
            return this._evaluateBasicTile();
         }
         if(!this.fsm.turn)
         {
            return null;
         }
         if(this.fsm.turn.entity == this.entity && !this.fsm.turn.complete)
         {
            if(this.entity.isPlayer)
            {
               return this._evaluateActiveTile();
            }
            if(this.entity.isLocalRect(1,2))
            {
               return this.assets.board_active_enemy_1x2;
            }
            if(this.entity.diameter == 1)
            {
               return this.assets.board_active_enemy_1;
            }
            return this.assets.board_active_enemy_2;
         }
         var _loc1_:* = !this.fsm.turn.committed;
         if(_loc1_ && Boolean(this.fsm.turn.ability))
         {
            _loc1_ = !this.fsm.turn.ability.executed && !this.fsm.turn.ability.executing;
         }
         if(_loc1_)
         {
            _loc2_ = this.fsm._turn._ability;
            _loc3_ = Boolean(_loc2_) && (_loc2_.targetSet.hasTarget(this.entity) || _loc2_.hasAssociatedTarget(this.entity));
            _loc4_ = !_loc2_ && Boolean(this.fsm.turn.entity.playerControlled) && this.fsm.interact == this.entity && this.entity in this.fsm.turn.inRange;
            if(_loc3_ || _loc4_)
            {
               return this._evaluateTargetTile();
            }
            if(this.fsm.turn.inRange[this.entity])
            {
               return this._evaluateInRangeTile();
            }
         }
         if(!this.entity.mobile)
         {
            return null;
         }
         return this._evaluateBasicTile();
      }
   }
}
