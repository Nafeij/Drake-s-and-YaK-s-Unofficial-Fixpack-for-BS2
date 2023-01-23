package engine.landscape.def
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class AnimPathNodeMoveDef extends AnimPathNodeDef_MotionBase
   {
       
      
      public var start:Point;
      
      public var target:Point;
      
      public var tailpos:Number = 1;
      
      public function AnimPathNodeMoveDef()
      {
         this.start = new Point();
         this.target = new Point();
         super();
      }
      
      public function computeSplineT(param1:Number) : Number
      {
         return LandscapeSplineDef.staticComputeSplineT(param1,this.tailpos);
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": MOVE " + this.start + " -> " + this.target + " in " + durationSecs;
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeMoveDef = new AnimPathNodeMoveDef();
         _loc1_.start.copyFrom(this.start);
         _loc1_.target.copyFrom(this.target);
         _loc1_.copyFromMotionBase(this);
         return _loc1_;
      }
      
      override public function getBounds(param1:Rectangle) : Rectangle
      {
         var _loc2_:Rectangle = new Rectangle(Math.min(this.start.x,this.target.x),Math.min(this.start.y,this.target.y),Math.abs(this.start.x - this.target.x),Math.abs(this.start.y - this.target.y));
         if(!param1)
         {
            return _loc2_;
         }
         return param1.union(_loc2_);
      }
      
      public function get velocity() : Number
      {
         var _loc1_:Number = Point.distance(this.start,this.target);
         return _loc1_ / durationSecs;
      }
      
      public function set velocity(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(param1 != 0)
         {
            _loc2_ = Point.distance(this.start,this.target);
            this.durationSecs = _loc2_ / param1;
         }
      }
   }
}
