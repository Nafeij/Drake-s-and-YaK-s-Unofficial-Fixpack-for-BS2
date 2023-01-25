package game.gui
{
   import engine.entity.model.IEntity;
   import engine.stat.def.StatType;
   
   public class BattleHudDamageHelper
   {
       
      
      public function BattleHudDamageHelper()
      {
         super();
      }
      
      public static function strengthNormalDamage(param1:IEntity, param2:IEntity, param3:int = 0) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.stats.getValue(StatType.STRENGTH));
         var _loc6_:int = int(param2.stats.getValue(StatType.ARMOR));
         _loc4_ = _loc5_ - _loc6_;
         _loc4_ = Math.max(1,_loc4_);
         return _loc4_ + param3;
      }
      
      public static function strengthNormalMiss(param1:IEntity, param2:IEntity) : int
      {
         var _loc3_:int = int(param1.stats.getValue(StatType.STRENGTH));
         var _loc4_:int = int(param2.stats.getValue(StatType.ARMOR));
         var _loc5_:int = 1 + _loc4_ - _loc3_;
         return int(Math.max(0,_loc5_));
      }
      
      public static function armorNormalDamage(param1:IEntity, param2:IEntity, param3:int = 0) : int
      {
         var _loc4_:int = 0;
         _loc4_ = param1.stats.getValue(StatType.ARMOR_BREAK) + param3;
         _loc4_ = Math.max(0,_loc4_);
         return int(Math.min(param2.stats.getValue(StatType.ARMOR),_loc4_));
      }
   }
}
