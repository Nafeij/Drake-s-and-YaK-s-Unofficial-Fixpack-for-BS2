package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class pg_common_back_btn extends ButtonWithIndex
   {
       
      
      public function pg_common_back_btn()
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
