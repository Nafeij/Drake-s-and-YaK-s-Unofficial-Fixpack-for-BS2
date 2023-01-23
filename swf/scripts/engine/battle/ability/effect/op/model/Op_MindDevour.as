package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.stat.def.StatType;
   
   public class Op_MindDevour extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_MindDevour",
         "properties":{}
      };
       
      
      public function Op_MindDevour(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:int = int(caster.stats.getValue(StatType.WILLPOWER,0));
         if(!ability.fake)
         {
            _loc1_ += ability.def.costs.getValue(StatType.WILLPOWER,0);
         }
         var _loc2_:int = int(target.stats.getValue(StatType.WILLPOWER,0));
         var _loc3_:int = Math.max(0,_loc1_ - _loc2_);
         var _loc4_:int = Math.max(1,Math.ceil(_loc3_ / 2));
         var _loc5_:int = Math.max(0,_loc3_ - _loc4_);
         var _loc6_:int = int(target.stats.getValue(StatType.STRENGTH,0));
         _loc4_ = Math.min(_loc4_,_loc6_);
         if(_loc4_)
         {
            caster.stats.changeBase(StatType.STRENGTH,_loc4_,0);
            target.stats.changeBase(StatType.STRENGTH,-_loc4_,0);
            effect.annotateStatChange(StatType.STRENGTH,-_loc4_);
            effect.addTag(EffectTag.DAMAGED_STR);
         }
         _loc5_ = Math.min(_loc5_,_loc2_);
         if(_loc5_)
         {
            caster.stats.changeBase(StatType.WILLPOWER,_loc5_,0);
            target.stats.changeBase(StatType.WILLPOWER,-_loc5_,0);
            effect.annotateStatChange(StatType.WILLPOWER,-_loc5_);
         }
      }
   }
}
