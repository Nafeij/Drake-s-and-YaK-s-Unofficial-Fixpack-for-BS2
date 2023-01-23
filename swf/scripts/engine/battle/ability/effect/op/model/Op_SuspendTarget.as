package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_SuspendTarget extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SuspendTarget",
         "properties":{
            "suspend":{"type":"boolean"},
            "caster":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function Op_SuspendTarget(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function apply() : void
      {
         if(fake)
         {
            return;
         }
         var _loc1_:Boolean = Boolean(def.params.suspend);
         var _loc2_:Boolean = Boolean(def.params.caster);
         if(_loc2_)
         {
            caster.setTurnSuspended(_loc1_);
         }
         else
         {
            target.setTurnSuspended(_loc1_);
         }
      }
   }
}
