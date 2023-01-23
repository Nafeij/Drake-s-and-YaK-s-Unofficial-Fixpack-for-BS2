package
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class button_delete extends ButtonWithIndex
   {
       
      
      public function button_delete()
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
