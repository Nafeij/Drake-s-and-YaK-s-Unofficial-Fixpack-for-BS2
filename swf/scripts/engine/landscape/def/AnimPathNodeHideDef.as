package engine.landscape.def
{
   public class AnimPathNodeHideDef extends AnimPathNodeDef
   {
       
      
      public function AnimPathNodeHideDef()
      {
         super();
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": HIDE";
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeHideDef = new AnimPathNodeHideDef();
         _loc1_.copyFromBase(this);
         return _loc1_;
      }
   }
}
