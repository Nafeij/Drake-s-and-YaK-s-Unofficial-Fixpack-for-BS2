package passets
{
   import flash.display.MovieClip;
   import game.gui.ButtonWithIndex;
   
   public dynamic class deployment_frame extends ButtonWithIndex
   {
       
      
      public var deployment_inner:MovieClip;
      
      public var deployment_outer:MovieClip;
      
      public function deployment_frame()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.deployment_outer.mouseEnabled = false;
         this.deployment_inner.mouseEnabled = true;
      }
   }
}
