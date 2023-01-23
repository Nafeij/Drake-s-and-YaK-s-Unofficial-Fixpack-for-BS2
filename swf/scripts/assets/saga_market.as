package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.saga_market.GuiSagaMarket;
   import passets.smkt_button_confirm;
   import passets.smkt_button_item_minus;
   import passets.smkt_button_item_plus;
   import passets.smkt_button_market_close;
   import passets.smkt_item_tabs;
   
   public dynamic class saga_market extends GuiSagaMarket
   {
       
      
      public var $items:TextField;
      
      public var $mkt_1_renown_gets_pfx:TextField;
      
      public var $mkt_days_worth_pfx:TextField;
      
      public var $mkt_renown_pfx:TextField;
      
      public var $mkt_supplies_pfx:TextField;
      
      public var $mkt_total_available_pfx:TextField;
      
      public var $supplies:TextField;
      
      public var bmpholder_common__gui__saga_market__market_backdrop:MovieClip;
      
      public var button_close:smkt_button_market_close;
      
      public var button_confirm:smkt_button_confirm;
      
      public var button_minus:smkt_button_item_minus;
      
      public var button_plus:smkt_button_item_plus;
      
      public var item_tabs:smkt_item_tabs;
      
      public var textSuppliesAdd:TextField;
      
      public var textSuppliesAvailable:TextField;
      
      public var textSuppliesPerRenown:TextField;
      
      public var textTotalDays:TextField;
      
      public var textTotalRenown:TextField;
      
      public var textTotalSupplies:TextField;
      
      public function saga_market()
      {
         super();
      }
   }
}
