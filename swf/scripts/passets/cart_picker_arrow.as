package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class cart_picker_arrow extends ButtonWithIndex
   {
       
      
      public function cart_picker_arrow()
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
