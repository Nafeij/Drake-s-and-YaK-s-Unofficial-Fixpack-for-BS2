package assets
{
   import flash.display.MovieClip;
   import game.gui.battle.GuiMovePopup;
   import passets.move_popup_icon;
   import passets.starsContainer;
   
   public dynamic class move_popup extends GuiMovePopup
   {
       
      
      public var checkmark:MovieClip;
      
      public var move_icon:move_popup_icon;
      
      public var starsContainer:starsContainer;
      
      public function move_popup()
      {
         super();
         addFrameScript(29,this.frame30);
      }
      
      internal function frame30() : *
      {
         gotoAndPlay(5);
      }
   }
}
