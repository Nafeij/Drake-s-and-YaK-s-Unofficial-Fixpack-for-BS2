package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class ss_back extends ButtonWithIndex
   {
       
      
      public function ss_back()
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
