package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class newgame_back extends ButtonWithIndex
   {
       
      
      public function newgame_back()
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
