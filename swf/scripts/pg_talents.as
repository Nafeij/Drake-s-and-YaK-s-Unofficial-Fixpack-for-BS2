package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiPgTalents;
   import passets.pg_button_item_minus;
   import passets.pg_button_item_plus;
   import passets.pg_common_arrow_button;
   import passets.pg_reset_text_button;
   import passets.pg_stat_button;
   
   public dynamic class pg_talents extends GuiPgTalents
   {
       
      
      public var bmpholder_common__gui__pages__tal_detailing:MovieClip;
      
      public var bmpholder_common__gui__pg_abl_pop2__pg_ability_panel:MovieClip;
      
      public var button$close:pg_reset_text_button;
      
      public var button_abk:pg_stat_button;
      
      public var button_arm:pg_stat_button;
      
      public var button_exe:pg_stat_button;
      
      public var button_left:pg_common_arrow_button;
      
      public var button_minus:pg_button_item_minus;
      
      public var button_plus:pg_button_item_plus;
      
      public var button_right:pg_common_arrow_button;
      
      public var button_str:pg_stat_button;
      
      public var button_wil:pg_stat_button;
      
      public var chits:passets_pg_chits_group_h;
      
      public var numbers:MovieClip;
      
      public var placeholder:MovieClip;
      
      public var text$talent_locked:TextField;
      
      public var text_desc:TextField;
      
      public var text_item:TextField;
      
      public var text_name:TextField;
      
      public var text_ranks:TextField;
      
      public var text_stat:TextField;
      
      public function pg_talents()
      {
         super();
      }
   }
}
