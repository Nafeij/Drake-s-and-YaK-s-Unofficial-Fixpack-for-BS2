package assets
{
   import game.gui.battle.GuiBattleHud;
   import passets.deploymentTimer;
   import passets.waveRedeployTop;
   
   public dynamic class battle_hud extends GuiBattleHud
   {
       
      
      public var deploymentTimer:deploymentTimer;
      
      public var waveRedeployTop:waveRedeployTop;
      
      public function battle_hud()
      {
         super();
      }
   }
}
