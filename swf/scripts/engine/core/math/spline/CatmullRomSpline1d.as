package engine.core.math.spline
{
   public class CatmullRomSpline1d
   {
       
      
      private var points:Vector.<Number>;
      
      private var parameters:Vector.<Number>;
      
      public var totalLength:Number = 0;
      
      public function CatmullRomSpline1d(param1:Vector.<Number>, param2:Vector.<Number>)
      {
         this.points = new Vector.<Number>();
         super();
         if(param1.length < 4)
         {
            throw new ArgumentError("4 or more points are required for a catmull-rom spline");
         }
         this.points = param1;
         if(param2)
         {
            this.createParameters(param2);
         }
      }
      
      private function createParameters(param1:Vector.<Number>) : void
      {
         var _loc2_:int = 0;
         if(param1.length != this.points.length - 1)
         {
            throw new ArgumentError("There must be one fewer lengths than points. found " + param1.length + " expected " + (this.points.length - 1));
         }
         this.totalLength = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            if(param1[_loc2_] <= 0)
            {
               throw new ArgumentError("lengths must be positive, hombre");
            }
            _loc2_++;
         }
         this.parameters = new Vector.<Number>();
         this.parameters.push(-1);
         _loc2_ = 1;
         while(_loc2_ < param1.length - 1)
         {
            this.parameters.push(this.totalLength);
            this.totalLength += param1[_loc2_];
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.parameters.length)
         {
            this.parameters[_loc2_] /= this.totalLength;
            _loc2_++;
         }
         this.parameters.push(1);
         this.parameters[0] = -param1[0] / this.totalLength;
         this.parameters.push(1 + param1[param1.length - 1] / this.totalLength);
      }
      
      private function uniformSegment(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         return this.segment(param1,1,1,param2,param3,param4,param5);
      }
      
      private function segment(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : Number
      {
         var _loc8_:Number = param1 * param1;
         var _loc9_:Number = param1 * _loc8_;
         var _loc10_:Number = 2 * _loc9_ - 3 * _loc8_ + 1;
         var _loc11_:Number = -2 * _loc9_ + 3 * _loc8_;
         var _loc12_:Number = _loc9_ - 2 * _loc8_ + param1;
         var _loc13_:Number = _loc9_ - _loc8_;
         var _loc14_:Number = 0.5;
         var _loc15_:Number = param2 * 0.5 * (param6 - param4);
         var _loc16_:Number = param3 * 0.5 * (param7 - param5);
         return _loc15_ * _loc12_ + param5 * _loc10_ + param6 * _loc11_ + _loc16_ * _loc13_;
      }
      
      private function nonUniformSegment(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number) : Number
      {
         var _loc10_:Number = param4 - param3;
         var _loc11_:Number = param3 - param2;
         var _loc12_:Number = param5 - param4;
         var _loc13_:Number = 2 * _loc10_ / (_loc11_ + _loc10_);
         var _loc14_:Number = 2 * _loc10_ / (_loc10_ + _loc12_);
         return this.segment(param1,_loc13_,_loc14_,param6,param7,param8,param9);
      }
      
      private function findPointIndex(param1:Number) : int
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
      
      private function getPointParameter(param1:int) : Number
      {
         if(!this.parameters)
         {
            return Number(param1 - 1) / (this.points.length - 3);
         }
         return this.parameters[param1];
      }
      
      public function sample(param1:Number) : Number
      {
         if(param1 <= 0)
         {
            return this.points[1];
         }
         if(param1 >= 1)
         {
            return this.points[this.points.length - 2];
         }
         var _loc2_:int = this.findPointIndex(param1);
         if(_loc2_ >= this.points.length - 2)
         {
            return this.points[_loc2_];
         }
         var _loc3_:Number = this.points[_loc2_ - 1];
         var _loc4_:Number = this.points[_loc2_ + 0];
         var _loc5_:Number = this.points[_loc2_ + 1];
         var _loc6_:Number = this.points[_loc2_ + 2];
         var _loc7_:Number = this.getPointParameter(_loc2_ + 0);
         var _loc8_:Number = this.getPointParameter(_loc2_ + 1);
         var _loc9_:Number = (param1 - _loc7_) / (_loc8_ - _loc7_);
         if(!this.parameters)
         {
            return this.uniformSegment(_loc9_,_loc3_,_loc4_,_loc5_,_loc6_);
         }
         var _loc10_:Number = this.getPointParameter(_loc2_ - 1);
         var _loc11_:Number = this.getPointParameter(_loc2_ + 2);
         return this.nonUniformSegment(_loc9_,_loc10_,_loc7_,_loc8_,_loc11_,_loc3_,_loc4_,_loc5_,_loc6_);
      }
   }
}
