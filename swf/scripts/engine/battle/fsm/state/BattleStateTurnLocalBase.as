package engine.battle.fsm.state
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class BattleStateTurnLocalBase extends BattleStateTurnBase
   {
       
      
      public var skipped:Boolean;
      
      public function BattleStateTurnLocalBase(param1:StateData, param2:BattleFsm, param3:ILogger, param4:Boolean)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function skip(param1:Boolean, param2:String, param3:Boolean) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateTurnLocalBase.skip " + turn + " force=" + param1 + " reason=" + param2 + " immediately=" + param3);
         }
         if(!turn)
         {
            return;
         }
         if(cmdSeq._completing)
         {
            logger.info("BattleStateTurnLocalBase.skip already completing");
            return;
         }
         if(Boolean(turn.ability) && (turn.ability.executing || turn.ability.executed))
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("BattleStateTurnLocalBase.skip IGNORE, already ability executing/ed");
            }
            return;
         }
         if(this.skipped)
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("BattleStateTurnLocalBase.skip already skipped");
            }
            if(!param1)
            {
               return;
            }
         }
         this.skipped = true;
         if(!turn.entity)
         {
            advanceToNextState();
            return;
         }
         var _loc4_:IBattleAbilityDef = turn.entity.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_end");
         var _loc5_:BattleAbility = new BattleAbility(turn.entity,_loc4_,turn.entity.board.abilityManager);
         var _loc6_:BattleTurnCmdAction = new BattleTurnCmdAction(this,0,true,_loc5_,true);
         cmdSeq.addCmd(_loc6_,param3);
      }
      
      override protected function handleSelfDied() : void
      {
         if(!BattleTurnCmdAction.SUPPRESS_TURN_END)
         {
            this.skip(true,"BattleStateTurnLocalbase.handleSelfDied",false);
         }
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(entity)
         {
            if(!entity.mobility || !entity.mobility.moving)
            {
               if(!turn.committed)
               {
                  advanceTimer(param1);
               }
            }
         }
      }
   }
}
