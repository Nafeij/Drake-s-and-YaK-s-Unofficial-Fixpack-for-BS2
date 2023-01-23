package passets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.battle.GuiDeploymentTimer;
   
   public dynamic class deploymentTimer extends GuiDeploymentTimer
   {
       
      
      public var deployText:TextField;
      
      public var deploymentFrame:deployment_frame;
      
      public var timerRing:MovieClip;
      
      public function deploymentTimer()
      {
         super();
      }
   }
}
