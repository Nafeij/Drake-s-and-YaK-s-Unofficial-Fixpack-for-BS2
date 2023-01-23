package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiSagaOptions;
   import passets.tooltip_survival_options;
   
   public dynamic class saga_options extends GuiSagaOptions
   {
       
      
      public var backdrop:MovieClip;
      
      public var button$credits:button_options_resume;
      
      public var button$difficulty:button_options_resume;
      
      public var button$fullscreen:button_options_resume;
      
      public var button$ga_optstate:button_options_ga_optstate;
      
      public var button$gp_cfg:button_options_gp_cfg;
      
      public var button$language:button_options_resume;
      
      public var button$load:button_options_resume;
      
      public var button$news:button_options_resume;
      
      public var button$opt_audio:button_options_resume;
      
      public var button$quit:button_options_resume;
      
      public var button$resume:button_options_resume;
      
      public var button$survival_reload:btn_opt_survival_reload;
      
      public var button$training_exit:button_options_training_exit;
      
      public var button$training_objectives:button_options_training_exit;
      
      public var button$tutorial_exit:button_options_training_exit;
      
      public var google_play_holder:MovieClip;
      
      public var share:assets_saga_options_share;
      
      public var text$options:TextField;
      
      public var tooltip_survival:tooltip_survival_options;
      
      public var version:TextField;
      
      public function saga_options()
      {
         super();
      }
   }
}
