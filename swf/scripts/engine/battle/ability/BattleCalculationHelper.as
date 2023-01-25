package engine.battle.ability
{
   import engine.entity.model.IEntity;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class BattleCalculationHelper
   {
       
      
      public function BattleCalculationHelper()
      {
         super();
      }
      
      public static function strengthNormalDamage(param1:IEntity, param2:IEntity, param3:int = 0) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.stats.getBase(StatType.STRENGTH));
         var _loc6_:int = int(param1.stats.getBase(StatType.STRENGTH_ATTACK));
         var _loc7_:int = int(param2.stats.getBase(StatType.ARMOR));
         _loc4_ = _loc5_ + _loc6_ - _loc7_;
         _loc4_ = Math.max(1,_loc4_);
         return _loc4_ + param3;
      }
      
      public static function strengthDamage(param1:IEntity, param2:IEntity, param3:int = 0) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.stats.getValue(StatType.STRENGTH));
         var _loc6_:int = int(param1.stats.getValue(StatType.STRENGTH_ATTACK));
         var _loc7_:int = int(param2.stats.getValue(StatType.ARMOR));
         _loc4_ = _loc5_ + _loc6_ - _loc7_;
         _loc4_ = Math.max(1,_loc4_);
         return _loc4_ + param3;
      }
      
      public static function calculatePunctureBonus(param1:IEntity, param2:IEntity) : int
      {
         var _loc3_:Stat = null;
         var _loc4_:int = 0;
         if(!param1.stats.hasStat(StatType.PUNCTURE_ATTACK_BONUS))
         {
            return 0;
         }
         _loc3_ = param2.stats.getStat(StatType.ARMOR);
         _loc4_ = _loc3_.original - _loc3_.value;
         return int(_loc4_ / 2);
      }
      
      public static function strengthNormalMiss(param1:IEntity, param2:IEntity) : int
      {
         var _loc3_:int = int(param1.stats.getBase(StatType.STRENGTH));
         var _loc4_:int = int(param2.stats.getBase(StatType.ARMOR));
         var _loc5_:int = 1 + _loc4_ - _loc3_;
         return int(Math.max(0,_loc5_));
      }
      
      public static function armorNormalDamage(param1:IEntity, param2:IEntity, param3:int = 0) : int
      {
         var _loc4_:int = 0;
         _loc4_ = param1.stats.getBase(StatType.ARMOR_BREAK) + param3;
         _loc4_ = Math.max(0,_loc4_);
         return int(Math.min(param2.stats.getBase(StatType.ARMOR),_loc4_));
      }
      
      public static function strengthMiss(param1:IEntity, param2:IEntity) : int
      {
         var _loc3_:int = int(param1.stats.getValue(StatType.STRENGTH));
         var _loc4_:int = int(param2.stats.getValue(StatType.ARMOR));
         var _loc5_:int = 1 + _loc4_ - _loc3_;
         return int(Math.max(0,_loc5_));
      }
      
      public static function armorDamage(param1:IEntity, param2:IEntity, param3:int = 0) : int
      {
         var _loc4_:int = 0;
         _loc4_ = param1.stats.getValue(StatType.ARMOR_BREAK) + param3;
         _loc4_ = Math.max(0,_loc4_);
         return int(Math.min(param2.stats.getValue(StatType.ARMOR),_loc4_));
      }
   }
}
