package assets
{
   import flash.text.TextField;
   import game.gui.pages.GuiSaveProfile;
   import passets.prof_load_file;
   import passets.profile_help;
   import passets.tooltip_survival_profile;
   import passets.xsave_button_end;
   
   public dynamic class save_profile extends GuiSaveProfile
   {
       
      
      public var button$load_file:prof_load_file;
      
      public var button_close_profile:xsave_button_end;
      
      public var delete1:button_delete;
      
      public var delete2:button_delete;
      
      public var delete3:button_delete;
      
      public var delete4:button_delete;
      
      public var delete5:button_delete;
      
      public var help1:profile_help;
      
      public var help2:profile_help;
      
      public var help3:profile_help;
      
      public var help4:profile_help;
      
      public var help5:profile_help;
      
      public var text_title:TextField;
      
      public var tooltip_survival:tooltip_survival_profile;
      
      public function save_profile()
      {
         super();
      }
   }
}
