package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.board.model.IBattleEntity;
   import engine.stat.def.StatType;
   
   public interface IOp_DamageRecourse extends IOp
   {
       
      
      function executeStatRecourse(param1:IBattleEntity, param2:IBattleEntity, param3:int, param4:StatType, param5:Effect, param6:Boolean = false) : int;
      
      function get statsRecoursed() : Vector.<StatType>;
   }
}
