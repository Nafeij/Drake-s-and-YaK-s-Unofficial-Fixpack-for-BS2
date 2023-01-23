package passets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiStatButton;
   
   public dynamic class pg_stat_button extends GuiStatButton
   {
       
      
      public var AB0:MovieClip;
      
      public var ABK:MovieClip;
      
      public var ARM:MovieClip;
      
      public var EXE:MovieClip;
      
      public var STR:MovieClip;
      
      public var WIL:MovieClip;
      
      public var plus:MovieClip;
      
      public var rankCircle:MovieClip;
      
      public var rankText:TextField;
      
      public var toggler:MovieClip;
      
      public function pg_stat_button()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}
