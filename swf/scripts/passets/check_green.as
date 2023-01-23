package passets
{
   import flash.display.MovieClip;
   
   public dynamic class check_green extends MovieClip
   {
       
      
      public function check_green()
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
