package engine.landscape.def
{
   public class AnimPathNodePlayingDef extends AnimPathNodeDef
   {
       
      
      public var playing:Boolean = true;
      
      public function AnimPathNodePlayingDef()
      {
         super();
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": PLAYING";
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodePlayingDef = new AnimPathNodePlayingDef();
         _loc1_.copyFromBase(this);
         return _loc1_;
      }
   }
}
