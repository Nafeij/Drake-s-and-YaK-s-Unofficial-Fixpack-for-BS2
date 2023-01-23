package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiSagaSurvivalLeaderboards;
   import passets.ss_diff_hard;
   import passets.ss_diff_normal;
   
   public dynamic class saga2_survival_leaderboards extends GuiSagaSurvivalLeaderboards
   {
       
      
      public var $ss_difficulty:TextField;
      
      public var $ss_lb_name:TextField;
      
      public var $ss_lb_rank:TextField;
      
      public var $ss_lb_score:TextField;
      
      public var $ss_lb_title:TextField;
      
      public var $ss_scope:TextField;
      
      public var bmpholder_common__gui__saga2_survival__leaderboards__hall_of_valor_bg:MovieClip;
      
      public var bmpholder_common__gui__saga2_survival__leaderboards__hall_of_valor_top:MovieClip;
      
      public var button_$ss_lb_friends:banner_alltime;
      
      public var button_$ss_lb_global:banner_tournament;
      
      public var button_board_next:common_arrow_button;
      
      public var button_board_prev:common_arrow_button;
      
      public var button_diff$hard:ss_diff_hard;
      
      public var button_diff$normal:ss_diff_normal;
      
      public var chits_group:chits_group;
      
      public var mc_texts_name:MovieClip;
      
      public var mc_texts_rank:MovieClip;
      
      public var mc_texts_score:MovieClip;
      
      public var text_board_filter:TextField;
      
      public var text_board_name:TextField;
      
      public var text_info_desc:TextField;
      
      public function saga2_survival_leaderboards()
      {
         super();
      }
   }
}
