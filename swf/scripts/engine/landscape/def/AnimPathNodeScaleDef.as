package engine.landscape.def
{
   public class AnimPathNodeScaleDef extends AnimPathNodeDef
   {
       
      
      public var scaleX:Number = 1;
      
      public var scaleY:Number = 1;
      
      public function AnimPathNodeScaleDef()
      {
         super();
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": SCALE";
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeScaleDef = new AnimPathNodeScaleDef();
         _loc1_.copyFromBase(this);
         return _loc1_;
      }
   }
}
