package assets
{
   import game.gui.GuiDevPanel;
   import passets.button_devpanel;
   import passets.devmove;
   import passets.mi_button_close;
   
   public dynamic class devpanel extends GuiDevPanel
   {
       
      
      public var button_close:mi_button_close;
      
      public var button_console:button_devpanel;
      
      public var button_ff:button_devpanel;
      
      public var button_kill:button_devpanel;
      
      public var button_perf:button_devpanel;
      
      public var button_quicksave:button_devpanel;
      
      public var move:devmove;
      
      public function devpanel()
      {
         super();
      }
   }
}
