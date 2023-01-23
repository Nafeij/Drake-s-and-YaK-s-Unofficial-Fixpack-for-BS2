package engine.battle.ability.effect.op.model
{
   import engine.anim.event.AnimControllerEvent;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_SpecialBorurMaw extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SpecialBorurMaw",
         "properties":{"digAnim":{"type":"string"}}
      };
       
      
      private var _digAnimName:String;
      
      public function Op_SpecialBorurMaw(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this._digAnimName = param1.params.digAnim;
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         effect.blockComplete();
         caster.animController.addEventListener(AnimControllerEvent.FINISHING,this.onDigAnimComplete);
         caster.animController.playAnim(this._digAnimName,1);
      }
      
      private function onDigAnimComplete(param1:AnimControllerEvent) : void
      {
         caster.animController.removeEventListener(AnimControllerEvent.FINISHING,this.onDigAnimComplete);
         caster.setVisible(false,0);
         caster.isSubmerged = true;
         caster.setPos(target.rect.loc.x,target.rect.loc.y);
         effect.unblockComplete();
      }
   }
}
