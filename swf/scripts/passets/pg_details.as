package passets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiPgDetails;
   import passets.pg_component.character_stats;
   
   public dynamic class pg_details extends GuiPgDetails
   {
       
      
      public var anchor_titleText:MovieClip;
      
      public var arrow_bg:MovieClip;
      
      public var bio:pg_bio_button;
      
      public var bioPopup:pg_bioPopup;
      
      public var bmpholder_common__gui__saga2_survival__heroes__foreground_left:MovieClip;
      
      public var bmpholder_common__gui__saga2_survival__heroes__foreground_right:MovieClip;
      
      public var button$survival_funeral_hero:pg_recruitButton;
      
      public var button$survival_recruit_hero:pg_recruitButton;
      
      public var button_character_left:pg_common_arrow_button;
      
      public var button_character_right:pg_common_arrow_button;
      
      public var characterStats:character_stats;
      
      public var dead:MovieClip;
      
      public var details_item:pg_details_item;
      
      public var heroicTitlesButton:passets_pg_heroicTitles_button;
      
      public var heroicTitlesPopup:passets_pg_titlePopup;
      
      public var heroicTitlesTutorial:heroicTitleTutorial;
      
      public var killCounter:MovieClip;
      
      public var placeholder_portrait:MovieClip;
      
      public var promoteBanner:pg_promote_banner;
      
      public var promotion:pg_promotion_dialog;
      
      public var text_character_name:TextField;
      
      public var text_character_rank:TextField;
      
      public var text_character_title:TextField;
      
      public function pg_details()
      {
         super();
      }
   }
}
