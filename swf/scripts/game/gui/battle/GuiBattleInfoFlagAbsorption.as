package game.gui.battle
{
   import engine.stat.def.StatType;
   
   public class GuiBattleInfoFlagAbsorption extends GuiBattleInfoFlag
   {
       
      
      public function GuiBattleInfoFlagAbsorption()
      {
         super();
      }
      
      override protected function handleCacheStats(param1:Boolean) : void
      {
         _statStr = cacheStat(_statStr,_stats.getStat(StatType.DAMAGE_ABSORPTION_SHIELD,param1));
         _statArm = cacheStat(_statArm,_stats.getStat(StatType.ARMOR,false));
         _statWil = cacheStat(_statWil,_stats.getStat(StatType.WILLPOWER,false));
      }
   }
}
