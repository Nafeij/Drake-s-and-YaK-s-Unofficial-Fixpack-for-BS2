package
{
   import flash.text.TextField;
   import game.gui.pages.GuiTitleRankChanger;
   import passets.pg_button_item_minus;
   import passets.pg_button_item_plus;
   
   public dynamic class passets_pg_title_rank extends GuiTitleRankChanger
   {
       
      
      public var curRank:TextField;
      
      public var maxRank:TextField;
      
      public var rankDown:pg_button_item_minus;
      
      public var rankUp:pg_button_item_plus;
      
      public function passets_pg_title_rank()
      {
         super();
      }
   }
}
