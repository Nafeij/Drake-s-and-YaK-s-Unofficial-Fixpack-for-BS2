package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.board.model.IBattleEntity;
   
   public class Op_SetBattleHudIndicatorVisible extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetBattleHudIndicatorVisible",
         "properties":{
            "visible":{"type":"boolean"},
            "caster":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var _hudIndicatorVisible:Boolean;
      
      private var _affectsCaster:Boolean;
      
      public function Op_SetBattleHudIndicatorVisible(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this._hudIndicatorVisible = param1.params.visible;
         this._affectsCaster = param1.params.caster;
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:IBattleEntity = this._affectsCaster ? caster : target;
         if(Boolean(_loc1_) && _loc1_.battleHudIndicatorVisible == this._hudIndicatorVisible)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:IBattleEntity = this._affectsCaster ? caster : target;
         if(effect.ability.fake || manager.faking || !_loc1_)
         {
            return;
         }
         _loc1_.battleHudIndicatorVisible = this._hudIndicatorVisible;
      }
   }
}
