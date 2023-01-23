package assets
{
   import flash.text.TextField;
   import game.gui.GuiDialog;
   import passets.common_text_frame;
   import passets.mi_button_close;
   
   public dynamic class gui_dialog extends GuiDialog
   {
       
      
      public var body:TextField;
      
      public var button1:common_text_frame;
      
      public var button2:common_text_frame;
      
      public var button_close:mi_button_close;
      
      public var title:TextField;
      
      public function gui_dialog()
      {
         super();
      }
   }
}
