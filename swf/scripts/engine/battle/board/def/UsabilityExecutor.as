package engine.battle.board.def
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   
   public class UsabilityExecutor
   {
       
      
      private var using:IBattleEntity;
      
      private var logger:ILogger;
      
      private var user:IBattleEntity;
      
      public function UsabilityExecutor(param1:IBattleEntity, param2:ILogger)
      {
         super();
         this.using = param1;
         this.logger = param2;
      }
      
      public function execute(param1:IBattleEntity) : void
      {
         this.user = null;
         var _loc2_:Usability = this.using.usability;
         if(!_loc2_)
         {
            return;
         }
         this.logger.info("handleUsed " + this.using);
         if(!_loc2_.handleUsing(param1))
         {
            this.logger.info("using not allowed");
            return;
         }
         var _loc3_:ISaga = SagaInstance.instance;
         if(_loc2_.def.happening)
         {
            _loc3_.executeHappeningById(_loc2_.def.happening,null,this.using);
         }
         var _loc4_:BattleAbilityDef = _loc2_.abilityDef as BattleAbilityDef;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:BattleBoard = this.using.board as BattleBoard;
         var _loc6_:IBattleEntity = this._determineResponse(_loc2_.def.responseCasterRule,param1);
         var _loc7_:IBattleEntity = this._determineResponse(_loc2_.def.responseTargetRule,param1);
         if(!_loc6_)
         {
            this.logger.error("UsabilityExecutor unable to determine caster " + _loc2_);
            return;
         }
         this.user = param1;
         var _loc8_:BattleAbility = new BattleAbility(_loc6_,_loc4_,_loc5_.abilityManager);
         if(_loc7_)
         {
            _loc8_.targetSet.addTarget(_loc7_);
         }
         _loc5_.handleEntityUsingStart(param1,this.using,_loc8_);
         _loc8_.execute(this.handleUsedAbilityComplete);
      }
      
      private function handleUsedAbilityComplete(param1:BattleAbility) : void
      {
         var _loc3_:Usability = null;
         this.logger.info("handleUsedAbilityComplete " + this + " " + param1);
         var _loc2_:BattleBoard = this.using.board as BattleBoard;
         _loc2_.handleEntityUsingEnd(this.using,param1);
         if(Boolean(this.user) && Boolean(this.using))
         {
            _loc3_ = this.using.usability;
            if(_loc3_.def.isAction)
            {
               this.user.endTurn(true,"usability executor",false);
            }
         }
      }
      
      private function _determineResponse(param1:BattleAbilityResponseTargetType, param2:IBattleEntity) : IBattleEntity
      {
         switch(param1)
         {
            case BattleAbilityResponseTargetType.SELF:
               return this.using;
            case BattleAbilityResponseTargetType.OTHER:
               return param2;
            default:
               return null;
         }
      }
   }
}
