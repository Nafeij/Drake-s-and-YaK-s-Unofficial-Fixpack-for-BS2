package passets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiItemSlot;
   
   public dynamic class pg_item_slot extends GuiItemSlot
   {
       
      
      public var enabledBlocker:MovieClip;
      
      public var glow:MovieClip;
      
      public var item_bg:MovieClip;
      
      public var ownerHolder:MovieClip;
      
      public var placeholderIcon:MovieClip;
      
      public var powerCircle:MovieClip;
      
      public var textPower:TextField;
      
      public function pg_item_slot()
      {
         super();
      }
   }
}
