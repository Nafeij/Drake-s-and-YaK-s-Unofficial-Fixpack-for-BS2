package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiCharacterIconSlot;
   import passets.brd.pg_injuryRoster;
   
   public dynamic class brd_order_frame extends GuiCharacterIconSlot
   {
       
      
      public var dead:MovieClip;
      
      public var enabledBlocker:MovieClip;
      
      public var glow:MovieClip;
      
      public var injury:pg_injuryRoster;
      
      public var item:MovieClip;
      
      public var placeholderIcon:MovieClip;
      
      public var powerCircle:MovieClip;
      
      public var rim:MovieClip;
      
      public var textPower:TextField;
      
      public function brd_order_frame()
      {
         super();
      }
   }
}
