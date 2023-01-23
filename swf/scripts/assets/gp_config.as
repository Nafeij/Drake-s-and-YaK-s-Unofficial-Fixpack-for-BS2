package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiGpConfig;
   import passets.gpc_button_close;
   import passets.gpc_button_confirm;
   
   public dynamic class gp_config extends GuiGpConfig
   {
       
      
      public var $gp_cfg_title:TextField;
      
      public var bmpholder_common__gui__gp_map__backdrop:MovieClip;
      
      public var button$cancel:gpc_button_confirm;
      
      public var button$confirm:gpc_button_confirm;
      
      public var button$gp_cfg_reset:gpc_button_confirm;
      
      public var button_close:gpc_button_close;
      
      public var divider:MovieClip;
      
      public var error_text:TextField;
      
      public var gp_chooser:MovieClip;
      
      public function gp_config()
      {
         super();
      }
   }
}
