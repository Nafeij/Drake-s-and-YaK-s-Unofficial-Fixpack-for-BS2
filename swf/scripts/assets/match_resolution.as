package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.battle.GuiMatchResolution;
   import passets.mr_button_blue;
   import passets.mr_matchKillsAndBonuses;
   import passets.mr_match_button;
   import passets.mr_objectives;
   import passets.mr_warOutcome;
   
   public dynamic class match_resolution extends GuiMatchResolution
   {
       
      
      public var backdrop_banner:MovieClip;
      
      public var backdrop_banner_torn:MovieClip;
      
      public var background_defeat:MovieClip;
      
      public var background_defeat_torn:MovieClip;
      
      public var background_victory:MovieClip;
      
      public var background_victory_torn:MovieClip;
      
      public var button$continue:mr_button_blue;
      
      public var button_survival$continue:mr_match_button;
      
      public var button_survival$survival_reload:mr_match_button;
      
      public var consequencesTitle:MovieClip;
      
      public var defeat:MovieClip;
      
      public var gameover:MovieClip;
      
      public var guiObjectiveResults:mr_objectives;
      
      public var guiWarOutcome:mr_warOutcome;
      
      public var injury:MovieClip;
      
      public var items:MovieClip;
      
      public var killsAndBonuses:mr_matchKillsAndBonuses;
      
      public var obj_complete:MovieClip;
      
      public var obj_failed:MovieClip;
      
      public var promotion:MovieClip;
      
      public var renownGrows:TextField;
      
      public var renownTotal:MovieClip;
      
      public var retreat:MovieClip;
      
      public var rewards:MovieClip;
      
      public var rewardsTitle:MovieClip;
      
      public var text_gameover_desc:TextField;
      
      public var victory:MovieClip;
      
      public var warRenownClansmen:MovieClip;
      
      public function match_resolution()
      {
         super();
      }
   }
}
