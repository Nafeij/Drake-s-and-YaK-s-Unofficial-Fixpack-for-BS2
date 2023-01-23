package battle_self_popup_fla
{
   import flash.display.MovieClip;
   
   public dynamic class check_green_16 extends MovieClip
   {
       
      
      public function check_green_16()
      {
         super();
         addFrameScript(0,this.frame1,24,this.frame25);
      }
      
      internal function frame1() : *
      {
         this.mouseChildren = false;
         this.mouseEnabled = false;
      }
      
      internal function frame25() : *
      {
         this.gotoAndPlay(6);
      }
   }
}
