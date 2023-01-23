package passets
{
   import assets.promote_overlay_ability;
   import flash.display.MovieClip;
   import game.gui.GuiPromotion;
   
   public dynamic class pg_promotion_dialog extends GuiPromotion
   {
       
      
      public var bmpholder_common__gui__pages__promote_background:MovieClip;
      
      public var button$cancel:pg_reset_text_button;
      
      public var button$confirm:pg_confirm_text_button;
      
      public var chits:passets_pg_chits_group_h;
      
      public var left_arrow:pg_common_arrow_button;
      
      public var overlay_ability:promote_overlay_ability;
      
      public var overlay_class:MovieClip;
      
      public var overlay_info:pg_promote_info;
      
      public var overlay_naming:MovieClip;
      
      public var overlay_variation:pg_promote_variation;
      
      public var renown_total:MovieClip;
      
      public var right_arrow:pg_common_arrow_button;
      
      public var stat_values:MovieClip;
      
      public function pg_promotion_dialog()
      {
         super();
      }
   }
}
