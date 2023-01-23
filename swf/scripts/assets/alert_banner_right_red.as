package assets
{
   import flash.text.TextField;
   import game.gui.GuiAlert;
   import passets.alert_button_cancel;
   import passets.alert_button_ok_small;
   import passets.alert_button_plus;
   
   public dynamic class alert_banner_right_red extends GuiAlert
   {
       
      
      public var buttonCancel:alert_button_cancel;
      
      public var buttonCross:alert_button_plus;
      
      public var buttonOkSmall:alert_button_ok_small;
      
      public var textMsg:TextField;
      
      public var textName:TextField;
      
      public function alert_banner_right_red()
      {
         super();
      }
   }
}
