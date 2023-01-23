package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_AdjacentArmorBonus extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_AdjacentArmorBonus",
         "properties":{}
      };
       
      
      public function Op_AdjacentArmorBonus(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
      }
   }
}
