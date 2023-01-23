package assets
{
   import flash.display.MovieClip;
   
   public dynamic class gpc_check_green extends MovieClip
   {
       
      
      public function gpc_check_green()
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
         stop();
      }
   }
}
