package assets
{
   import flash.accessibility.AccessibilityProperties;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class gui_damage_flag extends MovieClip
   {
       
      
      public var damage_text:TextField;
      
      public function gui_damage_flag()
      {
         super();
         this.__setAcc_damage_text_gui_damage_flag_text_0();
      }
      
      internal function __setAcc_damage_text_gui_damage_flag_text_0() : *
      {
         this.damage_text.accessibilityProperties = new AccessibilityProperties();
         this.damage_text.accessibilityProperties.silent = true;
      }
   }
}
