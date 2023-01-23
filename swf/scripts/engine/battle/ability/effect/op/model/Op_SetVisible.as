package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.def.BooleanVars;
   
   public class Op_SetVisible extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetVisible",
         "properties":{
            "visible":{"type":"boolean"},
            "fadeMs":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      private var visible:Boolean;
      
      private var fadeMs:int;
      
      public function Op_SetVisible(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.visible = BooleanVars.parse(param1.params.visible,this.visible);
         this.fadeMs = param1.params.fadeMs;
      }
      
      override public function execute() : EffectResult
      {
         if(target.visible == this.visible)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(effect.ability.fake || manager.faking)
         {
            return;
         }
         logger.info("Op_SetVisible.apply " + target + " " + this.visible + " in " + this.fadeMs);
         target.setVisible(this.visible,this.fadeMs);
      }
   }
}
