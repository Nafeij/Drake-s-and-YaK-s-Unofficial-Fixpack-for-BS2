package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_FreeTurn extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_FreeTurn",
         "properties":{}
      };
       
      
      public function Op_FreeTurn(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function apply() : void
      {
         if(!ability.fake && !manager.faking)
         {
            board.fsm.order.freeTurn = target;
         }
      }
   }
}
