package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiConvo;
   import passets.cnv_button_end;
   import passets.cnv_choice_convo;
   import passets.cnv_poppable_button;
   
   public dynamic class cnv_convo extends GuiConvo
   {
       
      
      public var bannerName:MovieClip;
      
      public var buttonEnd:cnv_button_end;
      
      public var buttonNext:cnv_poppable_button;
      
      public var choice1:cnv_choice_convo;
      
      public var choice2:cnv_choice_convo;
      
      public var choice3:cnv_choice_convo;
      
      public var choice4:cnv_choice_convo;
      
      public var choice5:cnv_choice_convo;
      
      public var choice6:cnv_choice_convo;
      
      public var text:TextField;
      
      public var textName:TextField;
      
      public function cnv_convo()
      {
         super();
      }
   }
}
