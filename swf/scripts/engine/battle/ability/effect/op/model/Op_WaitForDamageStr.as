package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   
   public class Op_WaitForDamageStr extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForDamageStr",
         "properties":{"ability":{"type":"string"}}
      };
       
      
      private var oldWatchValue:int;
      
      private var ablDef:BattleAbilityDef;
      
      public var stat_target_watch:Stat;
      
      public function Op_WaitForDamageStr(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         this.stat_target_watch = requireStat(target,StatType.STRENGTH);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         this.oldWatchValue = this.stat_target_watch.value;
         this.stat_target_watch.addEventListener(StatEvent.CHANGE,this.strengthChangedHandler);
      }
      
      override public function remove() : void
      {
         this.stat_target_watch.removeEventListener(StatEvent.CHANGE,this.strengthChangedHandler);
      }
      
      private function strengthChangedHandler(param1:StatEvent) : void
      {
         var _loc2_:BattleAbility = null;
         if(this.stat_target_watch.value < this.oldWatchValue)
         {
            this.stat_target_watch.removeEventListener(StatEvent.CHANGE,this.strengthChangedHandler);
            _loc2_ = new BattleAbility(target,this.ablDef,manager);
            _loc2_.targetSet.setTarget(target);
            _loc2_.execute(null);
         }
         this.oldWatchValue = this.stat_target_watch.value;
      }
   }
}
