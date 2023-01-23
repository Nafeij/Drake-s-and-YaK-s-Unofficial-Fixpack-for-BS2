package passets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.battle.GuiWaveRedeploymentTop;
   
   public dynamic class waveRedeployTop extends GuiWaveRedeploymentTop
   {
       
      
      public var button$wave_fight:buttonRedeployFight;
      
      public var button$wave_flee:buttonRedeployFlee;
      
      public var deployment_inner:MovieClip;
      
      public var deployment_outer:MovieClip;
      
      public var text$wave_fight:TextField;
      
      public var text$wave_flee:TextField;
      
      public function waveRedeployTop()
      {
         super();
      }
   }
}
