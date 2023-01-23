package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiCartPicker;
   import passets.cart_picker_arrow;
   import passets.cart_picker_banner;
   import passets.cart_picker_chitGroup;
   import passets.cart_picker_close;
   import passets.cart_picker_confirm;
   
   public dynamic class cart_picker extends GuiCartPicker
   {
       
      
      public var background_matte:MovieClip;
      
      public var banner:cart_picker_banner;
      
      public var button$close:cart_picker_close;
      
      public var button$confirm:cart_picker_confirm;
      
      public var button$left:cart_picker_arrow;
      
      public var button$right:cart_picker_arrow;
      
      public var caravan_peeps:MovieClip;
      
      public var cart_mask:MovieClip;
      
      public var cart_position:MovieClip;
      
      public var chits:cart_picker_chitGroup;
      
      public var text$ks_cart_thanks:TextField;
      
      public var text_cart_title:TextField;
      
      public var yox:MovieClip;
      
      public function cart_picker()
      {
         super();
      }
   }
}
