package engine.battle.fsm.state.turn.cmd
{
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.battle.fsm.txn.BattleTxnActionSend;
   
   public class BattleTurnCmdAction extends BattleTurnCmd
   {
      
      public static var SUPPRESS_TURN_END:Boolean;
       
      
      public var action:BattleAbility;
      
      public var terminator:Boolean;
      
      public var extra_move:Boolean;
      
      public function BattleTurnCmdAction(param1:BattleStateTurnBase, param2:int, param3:Boolean, param4:BattleAbility, param5:Boolean)
      {
         super(param1,param2,param3);
         this.action = param4;
         this.terminator = param5;
         var _loc6_:IPersistedEffects = !!entity ? entity.effects : null;
         this.extra_move = Boolean(_loc6_) && Boolean(_loc6_.hasTag(EffectTag.EXTRA_MOVE)) && !entity.isDisabledMove;
         if(turn.entity.playerControlled)
         {
            turn.entity.mobility.fastForwardMove();
         }
      }
      
      public function toString() : String
      {
         return "BattleTurnCmdAction [" + this.action + "] term=" + this.terminator;
      }
      
      override protected function handleBattleExecute() : void
      {
         var _loc1_:BattleTxnActionSend = null;
         if(turn.entity.playerControlled)
         {
            if(!this.action.checkCosts(true))
            {
               logger.error("Action cannot be completed due to checkCosts: " + this.action);
               battleComplete();
               return;
            }
            if(battleFsm.isOnline)
            {
               _loc1_ = new BattleTxnActionSend(battleFsm.battleId,turn.number,this.action,ordinal,this.terminator,battleFsm.session.credentials,null,battleFsm,logger);
               _loc1_.send(battleFsm.session.communicator);
            }
         }
         if(this.terminator)
         {
            if(Boolean(turn.ability) && (turn.ability.executed || turn.ability.executing))
            {
               logger.error("Attempting to re-terminate with: " + this.action);
               battleComplete();
               return;
            }
            turn.ability = this.action;
            turn.committed = true;
         }
         if(this.action == turn._ability)
         {
            ++turn._numAbilities;
         }
         this.action.execute(null);
         battleComplete();
      }
      
      override protected function handleBattleCompleting() : void
      {
         var _loc1_:BattleStateTurnBase = null;
         var _loc2_:Boolean = false;
         var _loc3_:BattleAbility = null;
         if(BattleTurnCmdAction.SUPPRESS_TURN_END)
         {
            return;
         }
         if(this.extra_move && turn._numAbilities < 2)
         {
            _loc1_ = battleFsm.current as BattleStateTurnBase;
            _loc2_ = !!_loc1_ ? _loc1_.readyToFinishBattle : false;
            if(!_loc2_)
            {
               _loc3_ = turn._ability;
               if(!_loc3_ || _loc3_.def.tag != BattleAbilityTag.END)
               {
                  return;
               }
            }
         }
         if(this.terminator)
         {
            state.turnCompleting();
         }
      }
      
      override protected function handleBattleCompleted() : void
      {
         var _loc1_:BattleStateTurnBase = null;
         var _loc2_:Boolean = false;
         if(!turn)
         {
            logger.error("BattleTurnCmdAction.handleBattleCompleted with no turn, skipping");
            return;
         }
         if(turn._entity != entity)
         {
            logger.info("BattleTurnCmdAction.handleBattleCompleted mismatched entities, skipping.  Expected " + entity + " found " + turn._entity);
            return;
         }
         if(this.extra_move)
         {
            _loc1_ = battleFsm.current as BattleStateTurnBase;
            _loc2_ = !!_loc1_ ? _loc1_.readyToFinishBattle : false;
            if(!_loc2_)
            {
               if(turn._ability && turn._ability == this.action && turn._ability.def.tag != BattleAbilityTag.END)
               {
                  if(turn._numAbilities < 2)
                  {
                     turn.ability = null;
                     if(turn.move)
                     {
                        turn.move.uncommitMove();
                        board.triggers.clearEntitiesHitThisTurn();
                     }
                     turn.complete = false;
                     turn.committed = false;
                     battleFsm.interact = null;
                     turn.attackMode = false;
                     return;
                  }
               }
            }
         }
         if(BattleTurnCmdAction.SUPPRESS_TURN_END)
         {
            turn.ability = null;
            return;
         }
         if(this.terminator)
         {
            state.turnCompleted();
         }
      }
   }
}
