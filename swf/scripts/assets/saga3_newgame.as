package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiSagaNewGame;
   import passets.newgame_back;
   import passets.newgame_confirm;
   import passets.newgame_importbutton;
   
   public dynamic class saga3_newgame extends GuiSagaNewGame
   {
       
      
      public var bmpholder_common__gui__saga3_newgame__backdrop:MovieClip;
      
      public var button$confirm:newgame_confirm;
      
      public var button$newgame_choose_alette:passets_button_saga3_alette;
      
      public var button$newgame_choose_rook:passets_button_saga3_rook;
      
      public var button$newgame_import_save:newgame_importbutton;
      
      public var buttonClose:newgame_back;
      
      public var description$newgame3_desc_alette:TextField;
      
      public var description$newgame3_desc_rook:TextField;
      
      public var text$newgame_or_choose:TextField;
      
      public function saga3_newgame()
      {
         super();
      }
   }
}
