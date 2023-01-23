package engine.core.math.spline
{
   import flash.geom.Point;
   
   public class CatmullRomSpline2d
   {
       
      
      public var points:Vector.<Point>;
      
      internal var parameters:Vector.<Number>;
      
      public var totalLength:Number = 0;
      
      public var ooTotalLength:Number = 0;
      
      private var m_tension:Number = 0.5;
      
      private var mp0:Point;
      
      private var mp1:Point;
      
      public var lastSamplePointIndex:int;
      
      public function CatmullRomSpline2d(param1:Vector.<Point>, param2:Number = 0.5)
      {
         this.points = new Vector.<Point>();
         this.mp0 = new Point();
         this.mp1 = new Point();
         super();
         this.m_tension = param2;
         if(param1.length < 4)
         {
            throw new ArgumentError("4 or more points are required for a catmull-rom spline");
         }
         this.points = param1;
         this.parameterize();
      }
      
      public function get tension() : Number
      {
         return this.m_tension;
      }
      
      public function set tension(param1:Number) : void
      {
         if(this.m_tension != param1)
         {
            this.m_tension = param1;
            this.parameterize();
         }
      }
      
      private function measureSegmentArc(param1:int, param2:Number) : Number
      {
         var _loc3_:Point = null;
         var _loc4_:Number = 0;
         var _loc5_:Point = this.points[param1 - 1];
         var _loc6_:Point = this.points[param1 + 0];
         var _loc7_:Point = this.points[param1 + 1];
         var _loc8_:Point = this.points[param1 + 2];
         return Point.distance(_loc6_,_loc7_);
      }
      
      public function parameterize() : void
      {
         var _loc7_:Number = NaN;
         this.parameters = null;
         this.totalLength = 0;
         var _loc1_:Vector.<Number> = new Vector.<Number>();
         var _loc2_:Number = Point.distance(this.points[0],this.points[1]);
         _loc1_.push(-_loc2_);
         _loc1_.push(0);
         var _loc3_:Number = 0;
         var _loc4_:Number = 0.1;
         var _loc5_:int = 1;
         while(_loc5_ < this.points.length - 2)
         {
            _loc7_ = this.measureSegmentArc(_loc5_,_loc4_);
            _loc3_ += _loc7_;
            _loc1_.push(_loc3_);
            _loc5_++;
         }
         var _loc6_:Number = Point.distance(this.points[this.points.length - 2],this.points[this.points.length - 1]);
         _loc1_.push(_loc3_ + _loc6_);
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc1_[_loc5_] /= _loc3_;
            _loc5_++;
         }
         this.totalLength = _loc3_;
         if(this.totalLength > 0)
         {
            this.ooTotalLength = 1 / this.totalLength;
         }
         this.parameters = _loc1_;
      }
      
      private function uniformSegment(param1:Number, param2:Point, param3:Point, param4:Point, param5:Point, param6:Point) : Point
      {
         return this.segment(param1,1,1,param2,param3,param4,param5,param6);
      }
      
      private function segment(param1:Number, param2:Number, param3:Number, param4:Point, param5:Point, param6:Point, param7:Point, param8:Point) : Point
      {
         var _loc9_:Number = param1 * param1;
         var _loc10_:Number = param1 * _loc9_;
         var _loc11_:Number = 2 * _loc10_ - 3 * _loc9_ + 1;
         var _loc12_:Number = -2 * _loc10_ + 3 * _loc9_;
         var _loc13_:Number = _loc10_ - 2 * _loc9_ + param1;
         var _loc14_:Number = _loc10_ - _loc9_;
         var _loc15_:Number = param2 * this.tension * (param6.x - param4.x);
         var _loc16_:Number = param3 * this.tension * (param7.x - param5.x);
         var _loc17_:Number = param2 * this.tension * (param6.y - param4.y);
         var _loc18_:Number = param3 * this.tension * (param7.y - param5.y);
         param8.x = _loc15_ * _loc13_ + param5.x * _loc11_ + param6.x * _loc12_ + _loc16_ * _loc14_;
         param8.y = _loc17_ * _loc13_ + param5.y * _loc11_ + param6.y * _loc12_ + _loc18_ * _loc14_;
         return param8;
      }
      
      private function nonUniformSegment(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Point, param7:Point, param8:Point, param9:Point, param10:Point) : Point
      {
         var _loc11_:Number = param4 - param3;
         var _loc12_:Number = param3 - param2;
         var _loc13_:Number = param5 - param4;
         var _loc14_:Number = 2 * _loc11_ / (_loc12_ + _loc11_);
         var _loc15_:Number = 2 * _loc11_ / (_loc11_ + _loc13_);
         return this.segment(param1,_loc14_,_loc15_,param6,param7,param8,param9,param10);
      }
      
      public function findPointIndex(param1:Number) : int
      {
         if(!this.parameters)
         {
            return Math.max(1,Math.min(this.points.length - 2,int(param1 * (this.points.length - 2))));
         }
         var _loc2_:int = 2;
         while(_loc2_ < this.parameters.length)
         {
            if(this.parameters[_loc2_] > param1)
            {
               return _loc2_ - 1;
            }
            _loc2_++;
         }
         return this.points.length - 3;
      }
      
      public function getPointParameter(param1:int) : Number
      {
         if(!this.parameters)
         {
            return Number(param1 - 1) / (this.points.length - 3);
         }
         return this.parameters[param1];
      }
      
      public function sample(param1:Number, param2:Point) : Point
      {
         if(param1 <= 0)
         {
            this.lastSamplePointIndex = 1;
            param2.copyFrom(this.points[1]);
            return param2;
         }
         if(param1 >= 1)
         {
            this.lastSamplePointIndex = this.points.length - 2;
            param2.copyFrom(this.points[this.points.length - 2]);
            return param2;
         }
         var _loc3_:int = this.findPointIndex(param1);
         this.lastSamplePointIndex = _loc3_;
         if(_loc3_ >= this.points.length - 2)
         {
            param2.copyFrom(this.points[_loc3_]);
            return param2;
         }
         var _loc4_:Point = this.points[_loc3_ - 1];
         var _loc5_:Point = this.points[_loc3_ + 0];
         var _loc6_:Point = this.points[_loc3_ + 1];
         var _loc7_:Point = this.points[_loc3_ + 2];
         var _loc8_:Number = this.getPointParameter(_loc3_ + 0);
         var _loc9_:Number = this.getPointParameter(_loc3_ + 1);
         var _loc10_:Number = (param1 - _loc8_) / (_loc9_ - _loc8_);
         if(!this.parameters)
         {
            return this.uniformSegment(_loc10_,_loc4_,_loc5_,_loc6_,_loc7_,param2);
         }
         var _loc11_:Number = this.getPointParameter(_loc3_ - 1);
         var _loc12_:Number = this.getPointParameter(_loc3_ + 2);
         return this.nonUniformSegment(_loc10_,_loc11_,_loc8_,_loc9_,_loc12_,_loc4_,_loc5_,_loc6_,_loc7_,param2);
      }
      
      public function findClosestPosition(param1:Point) : Number
      {
         var _loc2_:Number = 1 / this.totalLength;
         return this.binarySearchToPoint(0,1,param1,_loc2_);
      }
      
      public function binarySearchToPoint(param1:Number, param2:Number, param3:Point, param4:Number) : Number
      {
         var _loc9_:Number = NaN;
         var _loc5_:Point = new Point();
         var _loc6_:Point = new Point();
         this.sample(param1,_loc5_);
         this.sample(param2,_loc6_);
         var _loc7_:Number = Point.distance(param3,_loc5_);
         var _loc8_:Number = Point.distance(param3,_loc6_);
         while(Math.abs(param1 - param2) > param4)
         {
            _loc9_ = (param1 + param2) / 2;
            if(_loc7_ < _loc8_)
            {
               param2 = _loc9_;
               this.sample(param2,_loc6_);
               _loc8_ = Point.distance(param3,_loc6_);
            }
            else
            {
               param1 = _loc9_;
               this.sample(param1,_loc5_);
               _loc7_ = Point.distance(param3,_loc5_);
            }
         }
         if(_loc7_ < _loc8_)
         {
            return param1;
         }
         return param2;
      }
      
      public function findClosestPositionX(param1:Number) : Number
      {
         var _loc2_:Number = 1 / this.totalLength;
         return this.binarySearchToX(0,1,param1,_loc2_);
      }
      
      public function binarySearchToX(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:Point = new Point();
         var _loc6_:Point = new Point();
         this.sample(param1,_loc5_);
         this.sample(param2,_loc6_);
         var _loc7_:Number = Math.abs(_loc5_.x - param3);
         var _loc8_:Number = Math.abs(_loc6_.x - param3);
         while(true)
         {
            _loc9_ = Math.abs(param1 - param2);
            _loc10_ = Math.abs(_loc7_ + _loc8_);
            if(Math.abs(param1 - param2) <= param4)
            {
               break;
            }
            _loc11_ = (param1 + param2) / 2;
            if(_loc7_ < _loc8_)
            {
               _loc12_ = (_loc7_ + _loc8_ / 2) / _loc10_;
               param2 = _loc12_ * _loc9_ + param1;
               this.sample(param2,_loc6_);
               _loc8_ = Math.abs(param3 - _loc6_.x);
            }
            else
            {
               _loc13_ = _loc7_ / 2 / _loc10_;
               param1 = _loc13_ * _loc9_ + param1;
               this.sample(param1,_loc5_);
               _loc7_ = Math.abs(param3 - _loc5_.x);
            }
         }
         if(_loc7_ < _loc8_)
         {
            return param1;
         }
         return param2;
      }
   }
}
