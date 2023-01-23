package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   
   public class Op_RemovePassive extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_RemovePassive",
         "properties":{
            "ability":{"type":"string"},
            "responseTarget":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var ablDef:BattleAbilityDef;
      
      public var responseTarget:BattleAbilityResponseTargetType;
      
      public var rt:IBattleEntity;
      
      public function Op_RemovePassive(param1:EffectDefOp, param2:Effect)
      {
         this.responseTarget = BattleAbilityResponseTargetType.TARGET;
         super(param1,param2);
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         if(param1.params.responseTarget)
         {
            this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTarget) as BattleAbilityResponseTargetType;
         }
         this.rt = this.getResponseTarget();
      }
      
      private function getResponseTarget() : IBattleEntity
      {
         switch(this.responseTarget)
         {
            case BattleAbilityResponseTargetType.CASTER:
            case BattleAbilityResponseTargetType.SELF:
               return caster;
            case BattleAbilityResponseTargetType.TARGET:
               return target;
            default:
               throw new ArgumentError("Invalid responseTarget " + this.responseTarget + " for " + this);
         }
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:Vector.<IBattleAbility> = null;
         if(this.rt.effects)
         {
            _loc1_ = this.rt.effects.getBattleAbilitiesByDef(this.ablDef);
            if(Boolean(_loc1_) && Boolean(_loc1_.length))
            {
               return EffectResult.OK;
            }
         }
         return EffectResult.FAIL;
      }
      
      override public function apply() : void
      {
         var _loc1_:Vector.<IBattleAbility> = null;
         var _loc2_:IBattleAbility = null;
         if(this.rt.effects)
         {
            _loc1_ = this.rt.effects.getBattleAbilitiesByDef(this.ablDef);
            if(_loc1_)
            {
               for each(_loc2_ in _loc1_)
               {
                  _loc2_.removeAllEffects(EffectRemoveReason.FORCED_EXPIRATION);
               }
            }
         }
      }
   }
}
