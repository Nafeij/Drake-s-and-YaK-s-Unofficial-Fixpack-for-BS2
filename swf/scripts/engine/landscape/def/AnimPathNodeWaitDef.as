package engine.landscape.def
{
   public class AnimPathNodeWaitDef extends AnimPathNodeDef
   {
       
      
      public function AnimPathNodeWaitDef()
      {
         super();
      }
      
      override public function get labelString() : String
      {
         return "WAIT " + durationSecs;
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeWaitDef = new AnimPathNodeWaitDef();
         _loc1_.copyFromBase(this);
         _loc1_.durationSecs = durationSecs;
         _loc1_.startTimeSecs = startTimeSecs;
         return _loc1_;
      }
   }
}
