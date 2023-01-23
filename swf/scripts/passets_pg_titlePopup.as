package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiHeroicTitles;
   import passets.pg_common_arrow_button;
   import passets.pg_ht_continue_button;
   
   public dynamic class passets_pg_titlePopup extends GuiHeroicTitles
   {
       
      
      public var bmpholder_common__gui__pages__ht_detailing:MovieClip;
      
      public var bmpholder_common__gui__pages__promote_background:MovieClip;
      
      public var button$continue:pg_ht_continue_button;
      
      public var rankFrame:MovieClip;
      
      public var rankGui:passets_pg_title_rank;
      
      public var renownCostFrame:MovieClip;
      
      public var text_desc:TextField;
      
      public var text_ranks:TextField;
      
      public var titleLeft:pg_common_arrow_button;
      
      public var titleRight:pg_common_arrow_button;
      
      public var titleText:TextField;
      
      public var titlesChits:passets_pg_chits_group_h_20;
      
      public function passets_pg_titlePopup()
      {
         super();
      }
   }
}
