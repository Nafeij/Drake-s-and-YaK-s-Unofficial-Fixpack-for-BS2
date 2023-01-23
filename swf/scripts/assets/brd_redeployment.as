package assets
{
   import flash.display.MovieClip;
   import game.gui.battle.redeployment.GuiRedeployment;
   import passets.brd.infobar;
   import passets.brd.init_order;
   import passets.brd.toggle_roster;
   import passets.redeployment_roster;
   
   public dynamic class brd_redeployment extends GuiRedeployment
   {
       
      
      public var __roster:redeployment_roster;
      
      public var infoBar:infobar;
      
      public var order:init_order;
      
      public var roster_mask_mc:MovieClip;
      
      public var roster_title:btl_roster_title;
      
      public var toggle:toggle_roster;
      
      public function brd_redeployment()
      {
         super();
      }
   }
}
