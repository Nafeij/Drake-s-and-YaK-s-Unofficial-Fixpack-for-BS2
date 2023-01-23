package assets
{
   import flash.display.MovieClip;
   import game.gui.pages.GuiProvingGrounds;
   import passets.pg_common_back_btn;
   import passets.pg_component.roster;
   import passets.pg_corner_help_se;
   import passets.pg_details;
   import passets.pg_options_button;
   import passets.pg_top_banner;
   
   public dynamic class proving_grounds extends GuiProvingGrounds
   {
       
      
      public var bg_normal:MovieClip;
      
      public var bg_survival:MovieClip;
      
      public var button_options:pg_options_button;
      
      public var button_town:pg_common_back_btn;
      
      public var details:pg_details;
      
      public var pg_particle_back:MovieClip;
      
      public var pg_particle_front:MovieClip;
      
      public var pg_top_banner:pg_top_banner;
      
      public var question_button:pg_corner_help_se;
      
      public var question_pages:MovieClip;
      
      public var readyPanel:MovieClip;
      
      public var roster:roster;
      
      public function proving_grounds()
      {
         super();
      }
   }
}
