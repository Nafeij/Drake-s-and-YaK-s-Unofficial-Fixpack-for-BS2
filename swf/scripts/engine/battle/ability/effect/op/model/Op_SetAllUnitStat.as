package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.stat.def.StatType;
   
   public class Op_SetAllUnitStat extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetAllUnitStat",
         "properties":{
            "stat":{"type":"string"},
            "value":{"type":"number"}
         }
      };
       
      
      private var type:StatType;
      
      private var value:int = 0;
      
      public function Op_SetAllUnitStat(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.type = Enum.parse(StatType,param1.params.stat) as StatType;
         this.value = param1.params.value;
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:IBattleEntity = null;
         for each(_loc1_ in target.board.entities)
         {
            _loc1_.stats.setBase(this.type,this.value);
         }
      }
   }
}
