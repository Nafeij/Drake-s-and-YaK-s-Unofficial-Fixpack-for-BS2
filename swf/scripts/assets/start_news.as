package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiSagaNews;
   import passets.news_chits_group_h;
   import passets.snews_common_arrow_button;
   
   public dynamic class start_news extends GuiSagaNews
   {
       
      
      public var buttonNext:snews_common_arrow_button;
      
      public var buttonPrev:snews_common_arrow_button;
      
      public var chits:news_chits_group_h;
      
      public var hover:MovieClip;
      
      public var placeholder:MovieClip;
      
      public var text:TextField;
      
      public function start_news()
      {
         super();
      }
   }
}
