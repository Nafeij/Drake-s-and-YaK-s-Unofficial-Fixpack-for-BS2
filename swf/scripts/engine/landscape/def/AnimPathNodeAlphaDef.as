package engine.landscape.def
{
   public class AnimPathNodeAlphaDef extends AnimPathNodeDef_MotionBase
   {
       
      
      public var start:Number = -1;
      
      public var target:Number = 0;
      
      public var tailpos:Number = 1;
      
      public function AnimPathNodeAlphaDef()
      {
         super();
         _durationSecs = 0;
      }
      
      public function computeSplineT(param1:Number) : Number
      {
         return LandscapeSplineDef.staticComputeSplineT(param1,this.tailpos);
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": ALPHA " + this.start + " -> " + this.target + " in " + durationSecs;
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeAlphaDef = new AnimPathNodeAlphaDef();
         _loc1_.copyFromMotionBase(this);
         _loc1_.start = this.start;
         _loc1_.target = this.target;
         _loc1_.tailpos = this.tailpos;
         return _loc1_;
      }
   }
}
