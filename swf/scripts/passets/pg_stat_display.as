package passets
{
   import flash.display.MovieClip;
   import game.gui.GuiPgStatDisplay;
   
   public dynamic class pg_stat_display extends GuiPgStatDisplay
   {
       
      
      public var buttonMinus:pg_button_item_minus;
      
      public var buttonPlus:pg_button_item_plus;
      
      public var buttonStat:pg_stat_button;
      
      public var numbers:MovieClip;
      
      public var placeholder_talent:MovieClip;
      
      public function pg_stat_display()
      {
         super();
      }
   }
}
