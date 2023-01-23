package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleTurn;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class Op_DamageStrHelper
   {
       
      
      public function Op_DamageStrHelper()
      {
         super();
      }
      
      public static function computePunctureBonus(param1:IBattleEntity, param2:IBattleEntity, param3:Boolean) : int
      {
         var _loc4_:* = false;
         var _loc5_:IBattleTurn = null;
         var _loc6_:Stat = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(!param2)
         {
            return 0;
         }
         if(param1.stats.hasStat(StatType.PUNCTURE_ATTACK_BONUS))
         {
            _loc5_ = param1.board.fsm.turn;
            if(_loc5_)
            {
               if(param1 == _loc5_.entity)
               {
                  _loc4_ = _loc5_.move.numSteps > 1;
               }
            }
            if(!_loc4_ && param1.mobility.moved == false)
            {
               _loc6_ = param2.stats.getStat(StatType.ARMOR,false);
               if(_loc6_)
               {
                  _loc7_ = _loc6_.original - _loc6_.value;
                  _loc8_ = _loc7_ / 2;
                  if(_loc8_ > 0)
                  {
                     if(!param3)
                     {
                        param1.effects.addTag(EffectTag.SPECIAL_PUNCTURE_BONUS);
                     }
                     return _loc8_;
                  }
               }
            }
         }
         return 0;
      }
   }
}
