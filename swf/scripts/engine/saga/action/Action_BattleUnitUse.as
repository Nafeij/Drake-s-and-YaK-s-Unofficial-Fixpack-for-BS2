package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityRangeType;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntityMobility;
   import engine.battle.fsm.BattleMove;
   import engine.core.BoxBoolean;
   import engine.saga.Saga;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleUnitUse extends Action
   {
      
      private static var gtg:BoxBoolean = new BoxBoolean();
       
      
      private var entity:IBattleEntity;
      
      private var cameraFollowing:Boolean;
      
      private var target:IBattleEntity;
      
      private var _suspended:Boolean;
      
      private var mv:BattleMove;
      
      public function Action_BattleUnitUse(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleEnded() : void
      {
         var _loc1_:BattleBoardView = null;
         if(this._suspended)
         {
            this.entity.setTurnSuspended(false);
            this.entity.endTurn(true,"battle unit used",false);
         }
         TweenMax.killDelayedCallsTo(this._performUse);
         TweenMax.killDelayedCallsTo(this.performMovement);
         if(this.entity)
         {
            _loc1_ = BattleBoardView.instance;
            if(_loc1_)
            {
               if(this.cameraFollowing && !def.instant)
               {
                  _loc1_.cameraStopFollowingEntity(this.entity);
               }
            }
         }
      }
      
      override protected function handleStarted() : void
      {
         if(!def.id || !def.anchor)
         {
            throw new ArgumentError("missing id=" + def.id + " or anchor=" + def.anchor);
         }
         this.entity = findBattleEntity(def.id,false);
         this.target = findBattleEntity(def.anchor,false);
         if(!this.entity)
         {
            throw new ArgumentError("bad entity [" + def.id + "]");
         }
         if(!this.target)
         {
            throw new ArgumentError("bad target [" + def.anchor + "]");
         }
         if(!this.target.usability)
         {
            throw new ArgumentError("target " + this.target + " is not usable");
         }
         if(!this.target.usability.enabled)
         {
            logger.info("Usability not enabled " + this.target.usability + " for " + this);
            end();
            return;
         }
         var _loc1_:Boolean = Boolean(def.param) && def.param.indexOf("camera") >= 0;
         var _loc2_:Boolean = Boolean(def.param) && def.param.indexOf("follow") >= 0;
         this.handleEntityCamera(_loc1_,_loc2_);
         if(this.target.usability.canUse(this.entity))
         {
            this.schedulePerformUse(1);
            return;
         }
         this.performMovement();
      }
      
      private function schedulePerformUse(param1:Number) : void
      {
         param1 = BattleEntityMobility.FAST_FORWARD ? 0.01 : param1;
         if(!this.target.usability.canUse(this.entity))
         {
            logger.info("Cannot use it.  skipping" + this);
            end();
            return;
         }
         this.entity.setTurnSuspended(true);
         this._suspended = true;
         TweenMax.delayedCall(param1,this._performUse);
      }
      
      private function _performUse() : void
      {
         var _loc1_:BattleBoardView = BattleBoardView.instance;
         _loc1_.cameraStopFollowingEntity(this.entity);
         this.target.handleUsed(this.entity);
         end();
      }
      
      protected function performMovement() : void
      {
         var _loc1_:int = this.target.usabilityDef.range;
         var _loc2_:int = TileRectRange.computeRange(this.target.rect,this.entity.rect);
         if(_loc1_ >= _loc2_)
         {
            throw new IllegalOperationError("should have already performed");
         }
         var _loc3_:BattleAbilityDef = new BattleAbilityDef(null,null);
         _loc3_.rangeType = BattleAbilityRangeType.MELEE;
         _loc3_._rangeMax = _loc1_;
         _loc3_._targetRule = BattleAbilityTargetRule.USABLE;
         var _loc4_:int = 0;
         gtg.value = false;
         this.mv = BattleMove.computeMoveToRange(_loc3_,this.entity,this.target,null,logger,_loc4_,gtg,null,false,true);
         if(!this.mv)
         {
            logger.info("Cannot get to diamond on target " + this.target + " for " + this);
            end();
            return;
         }
         if(this.mv.numSteps == 1)
         {
            throw new IllegalOperationError("should have already performed, numSteps");
         }
         this.entity.setTurnSuspended(true);
         this._suspended = true;
         var _loc5_:Number = BattleEntityMobility.FAST_FORWARD ? 0.01 : 1;
         TweenMax.delayedCall(_loc5_,this._executeMovement);
      }
      
      private function _executeMovement() : void
      {
         var _loc1_:BattleBoardView = null;
         if(this.entity.alive)
         {
            this.mv.callbackExecuted = this.moveCompleteHandler;
            this.mv.setCommitted("Action_BattleUnitUse");
            this.entity.mobility.executeMove(this.mv);
         }
         else
         {
            _loc1_ = BattleBoardView.instance;
            if(_loc1_)
            {
               _loc1_.cameraStopFollowingEntity(this.entity);
            }
            end();
         }
      }
      
      private function handleEntityCamera(param1:Boolean, param2:Boolean) : void
      {
         if(!this.entity)
         {
            return;
         }
         var _loc3_:BattleBoardView = BattleBoardView.instance;
         if(param2)
         {
            this.cameraFollowing = true;
            _loc3_.cameraFollowEntity(this.entity,false);
         }
         else if(param1)
         {
            _loc3_.centerOnEntity(this.entity);
            _loc3_.board.scene.disableStartPan();
         }
      }
      
      private function moveCompleteHandler(param1:BattleMove) : void
      {
         this.schedulePerformUse(0.5);
      }
   }
}
