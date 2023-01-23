package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.def.BooleanValueReqs;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.core.util.Enum;
   
   public class Op_WaitForCollision extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForCollision",
         "properties":{
            "ability":{"type":"string"},
            "responseCaster":{
               "type":"string",
               "optional":true
            },
            "responseTarget":{
               "type":"string",
               "optional":true
            },
            "conditionsCollider":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "targetColliderSameTeamReq":{
               "type":BooleanValueReqs.schema,
               "optional":true
            }
         }
      };
       
      
      private var abilityResponseDef:BattleAbilityDef;
      
      private var responseCaster:BattleAbilityResponseTargetType;
      
      private var responseTarget:BattleAbilityResponseTargetType;
      
      private var conditionsCollider:AbilityExecutionEntityConditions;
      
      private var targetColliderSameTeamReq:BooleanValueReqs;
      
      public function Op_WaitForCollision(param1:EffectDefOp, param2:Effect)
      {
         this.responseCaster = BattleAbilityResponseTargetType.CASTER;
         this.responseTarget = BattleAbilityResponseTargetType.TARGET;
         super(param1,param2);
         var _loc3_:String = param1.params.ability;
         this.abilityResponseDef = manager.factory.fetchBattleAbilityDef(_loc3_);
         if(!this.abilityResponseDef)
         {
            manager.logger.error("Op_WaitForMove " + this + " invalid ability [" + _loc3_ + "]");
         }
         if(param1.params.responseCaster)
         {
            this.responseCaster = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseCaster) as BattleAbilityResponseTargetType;
         }
         if(param1.params.responseTarget)
         {
            this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTarget) as BattleAbilityResponseTargetType;
         }
         if(param1.params.conditionsCollider)
         {
            this.conditionsCollider = new AbilityExecutionEntityConditions().fromJson(param1.params.conditionsCollider,logger);
         }
         if(param1.params.targetCasterSameTeam)
         {
            this.targetColliderSameTeamReq = new BooleanValueReqs();
            this.targetColliderSameTeamReq = this.targetColliderSameTeamReq.fromJson(param1.params.targetCasterSameTeam,logger);
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         target.addEventListener(BattleEntityEvent.COLLISION,this.collisionHandler);
      }
      
      override public function remove() : void
      {
         target.removeEventListener(BattleEntityEvent.COLLISION,this.collisionHandler);
      }
      
      private function resolveResponse(param1:BattleAbilityResponseTargetType, param2:IBattleEntity) : IBattleEntity
      {
         switch(param1)
         {
            case BattleAbilityResponseTargetType.CASTER:
               return caster;
            case BattleAbilityResponseTargetType.TARGET:
               return target;
            case BattleAbilityResponseTargetType.OTHER:
               return param2;
            default:
               return null;
         }
      }
      
      private function collisionHandler(param1:BattleEntityEvent) : void
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:BattleAbility = null;
         logger.info("Op_WaitForCollision " + param1.entity + " -> " + param1.other + " in: " + this);
         if(param1.entity == target)
         {
            logger.info("Op_WaitForCollision ignoring self moving collision for " + param1.entity + " -> " + param1.other + " in: " + this);
            return;
         }
         if(param1.other != target)
         {
            logger.info("Op_WaitForCollision ignoring irrelevant collision for " + param1.entity + " -> " + param1.other + " in: " + this);
            return;
         }
         var _loc2_:IBattleEntity = param1.entity;
         if(this.conditionsCollider)
         {
            if(!this.conditionsCollider.checkExecutionConditions(_loc2_,logger,true))
            {
               logger.info("Op_WaitForCollision.collisionHandler skipping other conditions for " + _loc2_);
               return;
            }
         }
         if(this.targetColliderSameTeamReq)
         {
            if(!BooleanValueReqs.check(this.targetColliderSameTeamReq,target.team == _loc2_.team))
            {
               logger.info("Op_WaitForCollision.collisionHandler targetColliderSameTeamReq failed for " + target + " & " + _loc2_);
               return;
            }
         }
         if(this.abilityResponseDef)
         {
            _loc3_ = this.resolveResponse(this.responseCaster,_loc2_);
            if(!this.abilityResponseDef.checkCasterExecutionConditions(_loc3_,logger,true))
            {
               logger.info("Op_WaitForCollision.collisionHandler skipping caster conditions for " + _loc3_ + " on " + this.abilityResponseDef);
               return;
            }
            _loc4_ = this.resolveResponse(this.responseTarget,_loc2_);
            _loc5_ = new BattleAbility(_loc3_,this.abilityResponseDef,manager);
            _loc5_.targetSet.setTarget(_loc4_);
            ability.addChildAbility(_loc5_);
         }
      }
   }
}
