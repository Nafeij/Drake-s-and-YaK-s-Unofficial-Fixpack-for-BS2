package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class pg_common_arrow_button extends ButtonWithIndex
   {
       
      
      public function pg_common_arrow_button()
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
