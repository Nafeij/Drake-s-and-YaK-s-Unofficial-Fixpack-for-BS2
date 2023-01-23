package
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class common_arrow_button extends ButtonWithIndex
   {
       
      
      public function common_arrow_button()
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
