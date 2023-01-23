package passets
{
   import game.gui.ButtonWithIndex;
   
   public dynamic class pg_ap_btn_ability_toggle extends ButtonWithIndex
   {
       
      
      public function pg_ap_btn_ability_toggle()
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
