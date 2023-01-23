package engine.landscape.def
{
   import com.greensock.easing.Cubic;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Quad;
   import com.greensock.easing.Sine;
   import engine.core.math.spline.CatmullRomSpline1d;
   import engine.core.math.spline.CatmullRomSpline2d;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class LandscapeSplineDef
   {
       
      
      public var id:String;
      
      public var ease:String = "Linear";
      
      public var easeIn:Boolean = true;
      
      public var easeOut:Boolean = true;
      
      public var tailpos:Number = 0.8;
      
      public var spline:CatmullRomSpline2d;
      
      public var zoom:CatmullRomSpline1d;
      
      protected var _points:Vector.<LandscapeSplinePoint>;
      
      public var keyPointsById:Dictionary;
      
      public var keyPoints:Vector.<LandscapeSplinePoint>;
      
      public var layer:LandscapeLayerDef;
      
      public function LandscapeSplineDef()
      {
         this._points = new Vector.<LandscapeSplinePoint>();
         this.keyPointsById = new Dictionary();
         this.keyPoints = new Vector.<LandscapeSplinePoint>();
         super();
      }
      
      public static function staticComputeSplineT(param1:Number, param2:Number) : Number
      {
         if(param2 >= 1 || param2 <= 0)
         {
            return param1;
         }
         var _loc3_:Number = param2 + (1 - param2) / 2;
         var _loc4_:Number = param1 / param2 * _loc3_;
         if(param1 <= param2)
         {
            return _loc4_;
         }
         var _loc5_:Number = (param1 - param2) / (1 - param2);
         var _loc6_:Number = (_loc4_ - _loc3_) / (1 - _loc3_);
         var _loc7_:Number = _loc3_ + (1 - _loc3_) * _loc5_;
         var _loc8_:Number = _loc3_ + (1 - _loc3_) * _loc6_;
         var _loc9_:Number = _loc8_ + (_loc7_ - _loc8_) * _loc5_;
         return Math.min(1,_loc9_);
      }
      
      public static function computeEaseFunction(param1:String, param2:Boolean, param3:Boolean) : Function
      {
         var _loc4_:Class = null;
         var _loc6_:String = null;
         var _loc5_:String = param1.toLowerCase();
         switch(_loc5_)
         {
            case "linear":
               _loc4_ = Linear;
               break;
            case "quad":
               _loc4_ = Quad;
               break;
            case "cubic":
               _loc4_ = Cubic;
               break;
            case "quart":
               _loc4_ = Cubic;
               break;
            case "quint":
               _loc4_ = Cubic;
               break;
            case "strong":
               _loc4_ = Cubic;
               break;
            case "sine":
               _loc4_ = Sine;
         }
         if(_loc4_)
         {
            if(param2 && param3)
            {
               _loc6_ = "easeInOut";
            }
            else if(param2)
            {
               _loc6_ = "easeIn";
            }
            else if(param3)
            {
               _loc6_ = "easeOut";
            }
            if(_loc6_)
            {
               return _loc4_[_loc6_];
            }
         }
         return Linear.easeNone;
      }
      
      public function getEaseFunction() : Function
      {
         return LandscapeSplineDef.computeEaseFunction(this.ease,this.easeIn,this.easeOut);
      }
      
      public function computeSplineT(param1:Number) : Number
      {
         if(this.tailpos >= 1 || this.tailpos <= 0)
         {
            return param1;
         }
         return staticComputeSplineT(param1,this.tailpos);
      }
      
      public function regenerateSpline() : void
      {
         var _loc2_:LandscapeSplinePoint = null;
         var _loc1_:Vector.<Point> = new Vector.<Point>();
         for each(_loc2_ in this._points)
         {
            _loc1_.push(_loc2_.pos);
         }
         this.spline = new CatmullRomSpline2d(_loc1_);
         this.regenerateZoom();
      }
      
      public function regenerateZoom() : void
      {
         var _loc3_:LandscapeSplinePoint = null;
         var _loc4_:LandscapeSplinePoint = null;
         var _loc5_:Number = NaN;
         var _loc1_:Vector.<Number> = new Vector.<Number>();
         var _loc2_:Vector.<Number> = new Vector.<Number>();
         for each(_loc4_ in this._points)
         {
            _loc1_.push(_loc4_.zoom);
            if(_loc3_)
            {
               _loc5_ = Point.distance(_loc4_.pos,_loc3_.pos);
               _loc2_.push(_loc5_);
            }
            _loc3_ = _loc4_;
         }
         this.zoom = new CatmullRomSpline1d(_loc1_,_loc2_);
      }
      
      public function getIndexOfPoint(param1:LandscapeSplinePoint) : int
      {
         if(!param1)
         {
            return -1;
         }
         return this._points.indexOf(param1);
      }
      
      public function getPoint(param1:int) : LandscapeSplinePoint
      {
         if(param1 >= 0 && param1 < this._points.length)
         {
            return this._points[param1];
         }
         return null;
      }
      
      public function get numPoints() : int
      {
         return this._points.length;
      }
      
      public function getKeyPointById(param1:String) : LandscapeSplinePoint
      {
         return this.keyPointsById[param1];
      }
      
      public function getAKeyPointByIndex(param1:int) : LandscapeSplinePoint
      {
         if(param1 < 0 || param1 >= this.keyPoints.length)
         {
            return null;
         }
         return this.keyPoints[param1];
      }
      
      private function regnerateKeyPoints() : void
      {
         var _loc1_:LandscapeSplinePoint = null;
         this.keyPoints.splice(0,this.keyPoints.length);
         for each(_loc1_ in this._points)
         {
            if(_loc1_.id)
            {
               _loc1_.keyIndex = this.keyPoints.length;
               this.keyPoints.push(_loc1_);
            }
         }
      }
      
      public function addPoint(param1:LandscapeSplinePoint) : void
      {
         this._points.push(param1);
         if(param1.id)
         {
            this.keyPointsById[param1.id] = param1;
            param1.keyIndex = this.keyPoints.length;
            this.keyPoints.push(param1);
         }
      }
      
      public function insertPoint(param1:LandscapeSplinePoint, param2:int) : void
      {
         this._points.splice(param2,0,param1);
         if(param1.id)
         {
            this.keyPointsById[param1.id] = param1;
            this.regnerateKeyPoints();
         }
      }
      
      public function renameSplinePoint(param1:LandscapeSplinePoint, param2:String) : void
      {
         var _loc3_:int = 0;
         if(!param1 || param1.id == param2)
         {
            return;
         }
         if(this.keyPointsById[param2])
         {
            return;
         }
         if(this.keyPointsById[param1.id] == param1)
         {
            delete this.keyPointsById[param1.id];
         }
         param1.internalSetId(param2);
         if(!param1.id)
         {
            param1.keyIndex = -1;
            _loc3_ = this.keyPoints.indexOf(param1);
            if(_loc3_ >= 0)
            {
               this.keyPoints.splice(_loc3_,1);
            }
         }
         else
         {
            this.keyPointsById[param1.id] = param1;
         }
      }
      
      public function removeSplinePoint(param1:LandscapeSplinePoint) : Boolean
      {
         var _loc3_:int = 0;
         if(!param1)
         {
            return false;
         }
         var _loc2_:int = this._points.indexOf(param1);
         if(_loc2_ < 0 || _loc2_ == 0 || _loc2_ == this._points.length - 1)
         {
            return false;
         }
         if(param1.id)
         {
            delete this.keyPointsById[param1.id];
            param1.keyIndex = -1;
            _loc3_ = this.keyPoints.indexOf(param1);
            if(_loc3_ >= 0)
            {
               this.keyPoints.splice(_loc3_,1);
            }
         }
         this._points.splice(_loc2_,1);
         return true;
      }
      
      public function constructDefaultSpline(param1:Number, param2:Number) : void
      {
         this._points.push(LandscapeSplinePoint.ctor(param1 - 300,param2));
         this._points.push(LandscapeSplinePoint.ctor(param1 - 100,param2));
         this._points.push(LandscapeSplinePoint.ctor(param1 + 100,param2));
         this._points.push(LandscapeSplinePoint.ctor(param1 + 300,param2));
      }
   }
}
