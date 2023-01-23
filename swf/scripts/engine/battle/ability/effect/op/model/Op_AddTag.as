package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.core.util.Enum;
   
   public class Op_AddTag extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_AddTag",
         "properties":{"tag":{"type":"string"}}
      };
       
      
      private var tag:EffectTag;
      
      public function Op_AddTag(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.tag = Enum.parse(EffectTag,param1.params.tag) as EffectTag;
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake)
         {
            return;
         }
         if(this.tag)
         {
            if(target.effects)
            {
               target.effects.addTag(this.tag);
            }
         }
      }
   }
}
