package engine.saga.action
{
   import engine.battle.fsm.BattleFsmConfig;
   import engine.saga.Saga;
   
   public class Action_BattleGuiEnable extends Action
   {
       
      
      public function Action_BattleGuiEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.param;
         var _loc2_:* = def.varvalue != 0;
         if(!_loc1_ || _loc1_.indexOf("hud") >= 0)
         {
            BattleFsmConfig.guiHudEnabled = _loc2_;
         }
         if(!_loc1_ || _loc1_.indexOf("tiles") >= 0)
         {
            BattleFsmConfig.guiTilesEnabled = _loc2_;
         }
         if(!_loc1_ || _loc1_.indexOf("flytext") >= 0)
         {
            BattleFsmConfig.guiFlytextEnabled = _loc2_;
         }
         if(!_loc1_ || _loc1_.indexOf("waves") >= 0)
         {
            BattleFsmConfig.guiWaveDeployEnabled = _loc2_;
         }
         end();
      }
   }
}
