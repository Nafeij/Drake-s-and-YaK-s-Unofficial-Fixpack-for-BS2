package engine.battle.fsm.state
{
   import com.greensock.TweenMax;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.aimodule.AiGlobalConfig;
   import engine.battle.fsm.aimodule.AiModuleBase;
   import engine.battle.fsm.aimodule.AiModuleDredge;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class BattleStateTurnAi extends BattleStateTurnLocalBase
   {
       
      
      protected var aiModule:AiModuleBase = null;
      
      private var _willskip:Boolean;
      
      private var _skipReason:String;
      
      public function BattleStateTurnAi(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3,true);
         this.aiModule = new AiModuleDredge(this);
      }
      
      override public function skip(param1:Boolean, param2:String, param3:Boolean) : void
      {
         if(BattleTurnCmdAction.SUPPRESS_TURN_END)
         {
            return;
         }
         if(Boolean(battleFsm) && battleFsm.halted)
         {
            this._willskip = false;
            logger.info("BattleStateTurn.skip reason=" + param2 + " NOPE, BattleFsm.halted! " + this);
            return;
         }
         if(!this._willskip)
         {
            this._willskip = true;
            this._skipReason = param2;
            if(this.aiModule)
            {
               this.aiModule.stopped = true;
            }
            return;
         }
         if(Boolean(_board) && Boolean(_board.abilityManager))
         {
            if(_board.abilityManager.numIncompleteAbilities)
            {
               return;
            }
         }
         advanceToNextState();
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc2_:IBattleAbilityManager = null;
         var _loc3_:BattleAbilityDef = null;
         var _loc4_:BattleAbility = null;
         super.handleEnteredState();
         battleFsm.addEventListener(BattleFsmEvent.TURN_COMPLETE,this.turnCompleteHandler);
         battleFsm.addEventListener(BattleFsmEvent.TURN_MOVE_EXECUTED,this.moveExecutedHandler);
         battleFsm.addEventListener(BattleFsmEvent.TURN_MOVE_INTERRUPTED,this.moveInterruptedHandler);
         if(!this.aiModule.caster.tile || !this.aiModule.caster.rect)
         {
            _loc2_ = battleFsm.board.abilityManager;
            _loc3_ = _loc2_.getFactory.fetch("abl_rest") as BattleAbilityDef;
            _loc4_ = new BattleAbility(this.aiModule.caster,_loc3_,_loc2_);
            cmdSeq.addCmd(new BattleTurnCmdAction(this,0,true,_loc4_,true));
            return;
         }
         var _loc1_:Number = AiGlobalConfig.FAST ? 0 : 0.5;
         TweenMax.delayedCall(_loc1_,this.aiModule.performMove);
      }
      
      override protected function handleCleanup() : void
      {
         battleFsm.removeEventListener(BattleFsmEvent.TURN_COMPLETE,this.turnCompleteHandler);
         battleFsm.removeEventListener(BattleFsmEvent.TURN_MOVE_EXECUTED,this.moveExecutedHandler);
         battleFsm.removeEventListener(BattleFsmEvent.TURN_MOVE_INTERRUPTED,this.moveInterruptedHandler);
         super.handleCleanup();
         TweenMax.killDelayedCallsTo(this.aiModule.performMove);
         TweenMax.killDelayedCallsTo(this.aiModule.performAction);
         this.aiModule.cleanup();
      }
      
      private function moveExecutedHandler(param1:BattleFsmEvent) : void
      {
         var _loc3_:IBattleMove = null;
         var _loc4_:Number = NaN;
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateTurnAI.moveExecutedHandler");
         }
         var _loc2_:IBattleTurn = battleFsm.turn;
         if(_loc2_.suspended)
         {
            return;
         }
         if(!_loc2_.complete)
         {
            _loc3_ = _loc2_.move;
            if(_loc3_.committed)
            {
               if(_loc2_.numAbilities == 0)
               {
                  _loc4_ = AiGlobalConfig.FAST ? 0 : 0.5;
                  TweenMax.delayedCall(_loc4_,this.aiModule.performAction);
               }
               else
               {
                  this.skip(false,"BattleStateTurnAi.moveExecutedHandler",false);
               }
            }
         }
      }
      
      private function moveInterruptedHandler(param1:BattleFsmEvent) : void
      {
         if(turn.suspended)
         {
            return;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateTurnAi.moveInterruptedHandler");
         }
         this.skip(false,"BattleStateTurnAi.moveInterruptedHandler",false);
      }
      
      private function turnCompleteHandler(param1:BattleFsmEvent) : void
      {
         var _loc3_:IBattleMove = null;
         var _loc4_:int = 0;
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateTurnAI.turnCompleteHandler");
         }
         var _loc2_:IBattleTurn = battleFsm.turn;
         if(_loc2_.suspended)
         {
            return;
         }
         if(!_loc2_.complete)
         {
            _loc3_ = _loc2_.move;
            if(!_loc3_.committed)
            {
               _loc4_ = 3;
               this.aiModule.runAway(_loc4_);
            }
         }
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this._willskip)
         {
            this.skip(false,this._skipReason,false);
            return;
         }
      }
   }
}
