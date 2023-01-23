package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.battle.redeployment.GuiRedeploymentLoadingOverlay;
   
   public dynamic class battle_redeploy_loading_popup extends GuiRedeploymentLoadingOverlay
   {
       
      
      public var gray_overlay:MovieClip;
      
      public var lits:MovieClip;
      
      public var text$loading:TextField;
      
      public function battle_redeploy_loading_popup()
      {
         super();
      }
   }
}
