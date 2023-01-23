package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   
   public class Op_OnTurnChanged extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForStartTurn",
         "properties":{
            "ability":{"type":"string"},
            "responseTurnType":{"type":"string"},
            "responseLevel":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      private var ablDef:BattleAbilityDef;
      
      private var responseTurnType:BattleAbilityResponseTargetType;
      
      private var responseLevel:int;
      
      public function Op_OnTurnChanged(param1:EffectDefOp, param2:Effect)
      {
         var _loc3_:BattleAbilityDef = null;
         super(param1,param2);
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         if(param1.params.responseLevel)
         {
            this.responseLevel = param1.params.responseLevel;
            _loc3_ = this.ablDef.root.getAbilityDefForLevel(this.responseLevel) as BattleAbilityDef;
            if(!_loc3_)
            {
               logger.error("Op_OnTurnChanged invalid level " + this.responseLevel + " for " + this.ablDef);
            }
            else
            {
               this.ablDef = _loc3_;
            }
         }
         this.responseTurnType = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTurnType) as BattleAbilityResponseTargetType;
      }
      
      override public function turnChanged() : Boolean
      {
         var _loc2_:BattleAbility = null;
         var _loc1_:IBattleEntity = board.fsm.activeEntity;
         switch(this.responseTurnType)
         {
            case BattleAbilityResponseTargetType.OTHER:
               if(_loc1_ != caster)
               {
                  _loc2_ = new BattleAbility(target,this.ablDef,manager);
               }
               break;
            case BattleAbilityResponseTargetType.ALL_ALLIES:
               if(_loc1_.team == caster.team)
               {
                  _loc2_ = new BattleAbility(target,this.ablDef,manager);
               }
               break;
            case BattleAbilityResponseTargetType.ALL_ENEMIES:
               if(_loc1_.team != caster.team)
               {
                  _loc2_ = new BattleAbility(target,this.ablDef,manager);
               }
               break;
            case BattleAbilityResponseTargetType.CASTER:
               if(_loc1_ == caster)
               {
                  _loc2_ = new BattleAbility(target,this.ablDef,manager);
               }
               break;
            default:
               return false;
         }
         if(_loc2_)
         {
            _loc2_.execute(null);
            return true;
         }
         return false;
      }
   }
}
