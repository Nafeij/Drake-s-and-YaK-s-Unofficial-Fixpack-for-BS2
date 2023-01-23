package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class snews_common_arrow_button extends ButtonWithIndex
   {
       
      
      public function snews_common_arrow_button()
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
