package passets
{
   import flash.text.TextField;
   import game.gui.GuiItemSlots;
   
   public dynamic class pg_item_list extends GuiItemSlots
   {
       
      
      public var $items:TextField;
      
      public var button_item_left:pg_common_arrow_button;
      
      public var button_item_right:pg_common_arrow_button;
      
      public var info:pg_item_info;
      
      public var item_slot_0:pg_item_slot;
      
      public var item_slot_1:pg_item_slot;
      
      public var item_slot_2:pg_item_slot;
      
      public var item_slot_3:pg_item_slot;
      
      public var item_slot_4:pg_item_slot;
      
      public function pg_item_list()
      {
         super();
      }
   }
}
