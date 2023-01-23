package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiPromotionAbility;
   import passets.pg_promote_cancel_button;
   import passets.pg_promote_continue_button;
   
   public dynamic class promote_overlay_ability extends GuiPromotionAbility
   {
       
      
      public var button$cancel:pg_promote_cancel_button;
      
      public var button$choose_ability:pg_promote_continue_button;
      
      public var classIconHolder:MovieClip;
      
      public var iconAbl:MovieClip;
      
      public var placeholder_clip:MovieClip;
      
      public var textAblDesc:TextField;
      
      public var textAblName:TextField;
      
      public function promote_overlay_ability()
      {
         super();
      }
   }
}
