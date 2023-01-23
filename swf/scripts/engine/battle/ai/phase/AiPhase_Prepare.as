package engine.battle.ai.phase
{
   import engine.battle.ai.Ai;
   import engine.battle.ai.IAiEntity;
   import flash.utils.Dictionary;
   
   public class AiPhase_Prepare extends AiPhase
   {
       
      
      public var cachedDamageByAi:Dictionary;
      
      public var cachedDamageToAi:Dictionary;
      
      public function AiPhase_Prepare(param1:Ai)
      {
         super(param1);
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         complete = true;
      }
      
      private function cacheEnemyDamages() : void
      {
         var _loc3_:IAiEntity = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:int = ai.entity.getAttackStrengthRangeMin();
         var _loc2_:int = ai.entity.getAttackStrengthRangeMax();
         for each(_loc3_ in ai.enemies)
         {
            _loc4_ = ai.entity.getAttackStrengthNormalDamage(_loc3_,false);
            _loc5_ = ai.entity.getPunctureDamage(_loc3_);
            _loc6_ = _loc3_.getAttackStrengthNormalDamage(ai.entity,true);
         }
      }
   }
}
