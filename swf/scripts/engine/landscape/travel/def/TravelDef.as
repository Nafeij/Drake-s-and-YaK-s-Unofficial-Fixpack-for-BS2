package engine.landscape.travel.def
{
   import engine.core.math.spline.CatmullRomSpline2d;
   import engine.landscape.def.LandscapeDef;
   import engine.math.MathUtil;
   import engine.saga.SagaTriggerDef;
   import engine.saga.SagaTriggerDefBag;
   import engine.saga.SagaTriggerType;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class TravelDef extends EventDispatcher implements ITravelDef
   {
      
      public static const LOCATION_ID_START:String = "start";
      
      public static const LOCATION_ID_END:String = "end";
      
      public static var POINT_PAD:Number = 50;
       
      
      public var id:String;
      
      public var points:Vector.<Point>;
      
      public var spline:CatmullRomSpline2d;
      
      public var spline_start:Number = 0;
      
      public var spline_end:Number = 0;
      
      public var locations:Vector.<TravelLocationDef>;
      
      public var mapKeyLocations:Vector.<TravelLocationDef>;
      
      public var loadBarrierLocations:Vector.<TravelLocationDef>;
      
      public var close:Boolean;
      
      public var ships:Boolean = false;
      
      public var speed:Number = 0;
      
      public var leftToRight:Boolean;
      
      public var showYoxen:Boolean = true;
      
      public var showCartFront:Boolean = true;
      
      public var showBanner:Boolean = true;
      
      public var showGlow:Boolean = false;
      
      public var showMinCaravan:Boolean = false;
      
      public var landscapeDef:LandscapeDef;
      
      public var reactors:Vector.<TravelReactorDef>;
      
      public var paramControls:Vector.<TravelParamControlDef>;
      
      private var tmp:Point;
      
      private var _scratch:Point;
      
      public function TravelDef(param1:LandscapeDef)
      {
         this.points = new Vector.<Point>();
         this.locations = new Vector.<TravelLocationDef>();
         this.mapKeyLocations = new Vector.<TravelLocationDef>();
         this.loadBarrierLocations = new Vector.<TravelLocationDef>();
         this.tmp = new Point();
         this._scratch = new Point();
         super();
         this.landscapeDef = param1;
      }
      
      public function cacheLimits() : void
      {
         var _loc1_:TravelLocationDef = this.findLocationById(LOCATION_ID_START);
         var _loc2_:TravelLocationDef = this.findLocationById(LOCATION_ID_END);
         this.spline_start = !!_loc1_ ? _loc1_.position : 0;
         this.spline_end = !!_loc2_ ? _loc2_.position : this.spline.totalLength;
         if(this.points.length > 1)
         {
            this.leftToRight = this.points[0].x < this.points[1].x;
         }
      }
      
      public function changePoint(param1:int, param2:Number, param3:Number) : void
      {
         param3 = Math.round(param3);
         var _loc4_:Point = this.spline.points[0];
         var _loc5_:Point = this.spline.points[this.spline.points.length - 1];
         var _loc6_:* = _loc4_.x < _loc5_.x;
         var _loc7_:Point = param1 > 0 ? this.spline.points[param1 - 1] : null;
         var _loc8_:Point = param1 < this.spline.points.length - 1 ? this.spline.points[param1 + 1] : null;
         var _loc9_:Point = _loc6_ ? _loc7_ : _loc8_;
         var _loc10_:Point = _loc6_ ? _loc8_ : _loc7_;
         if(_loc9_)
         {
            param2 = Math.max(_loc9_.x + POINT_PAD,param2);
         }
         if(_loc10_)
         {
            param2 = Math.min(_loc10_.x - POINT_PAD,param2);
         }
         param2 = Math.round(param2);
         this.points[param1].setTo(param2,param3);
         this.spline.points[param1].setTo(param2,param3);
         this.spline.parameterize();
         this._lockLocationsToMapX();
         this.cacheLimits();
         dispatchEvent(new TravelDefPointEvent(param1));
      }
      
      private function _lockLocationsToMapX() : void
      {
         var _loc1_:TravelLocationDef = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         for each(_loc1_ in this.locations)
         {
            _loc2_ = this.spline.findClosestPositionX(_loc1_.mapx);
            _loc3_ = _loc2_;
            _loc2_ *= this.spline.totalLength;
            _loc1_._position = MathUtil.stripDecimalPrecision(_loc2_,TravelLocationDef.DECIMAL_PRECISION);
            this.spline.sample(_loc3_,this.tmp);
            _loc4_ = this.tmp.x - _loc1_.mapx;
            if(Math.abs(_loc4_) > 10)
            {
               this.spline.findClosestPositionX(_loc1_.mapx);
               this.spline.findClosestPositionX(this.tmp.x);
            }
         }
      }
      
      public function changeLocation(param1:int, param2:Number) : int
      {
         var _loc5_:* = false;
         param2 = Math.round(param2);
         var _loc3_:TravelLocationDef = this.locations[param1];
         var _loc4_:Number = param2 / this.spline.totalLength;
         this.spline.sample(_loc4_,this._scratch);
         _loc3_.setPosition(param2,this._scratch.x);
         if(_loc3_.id == LOCATION_ID_END || _loc3_.id == LOCATION_ID_START)
         {
            this.cacheLimits();
         }
         if(param1 > 0)
         {
            _loc5_ = this.locations[param1 - 1].position > _loc3_.position;
         }
         if(param1 < this.locations.length - 1)
         {
            _loc5_ = _loc5_ || this.locations[param1 + 1].position < _loc3_.position;
         }
         if(_loc5_)
         {
            this.sortLocations();
            this.sortMapKeyLocations();
            dispatchEvent(new TravelDefLocationsEvent());
            return this.locations.indexOf(_loc3_);
         }
         dispatchEvent(new TravelDefLocationEvent(param1));
         return param1;
      }
      
      public function setLocationMapKey(param1:int, param2:Boolean) : void
      {
         var _loc3_:TravelLocationDef = this.locations[param1];
         if(_loc3_.mapkey == param2)
         {
            return;
         }
         _loc3_.mapkey = param2;
         if(_loc3_.mapkey)
         {
            this.addToMapKeyLocations(_loc3_);
         }
         else
         {
            this.removeFromMapKeyLocations(_loc3_);
         }
         dispatchEvent(new TravelDefLocationEvent(param1));
      }
      
      public function setLocationLoadBarrier(param1:int, param2:Boolean) : void
      {
         var _loc3_:TravelLocationDef = this.locations[param1];
         if(_loc3_.loadBarrier == param2)
         {
            return;
         }
         _loc3_.loadBarrier = param2;
         if(_loc3_.loadBarrier)
         {
            this.addToLoadBarrierLocations(_loc3_);
         }
         else
         {
            this.removeFromLoadBarrierLocations(_loc3_);
         }
         dispatchEvent(new TravelDefLocationEvent(param1));
      }
      
      public function setLocationId(param1:int, param2:String) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:TravelLocationDef = this.locations[param1];
         if(_loc3_.id == param2)
         {
            return;
         }
         if(_loc3_.id == LOCATION_ID_END || _loc3_.id == LOCATION_ID_START)
         {
            _loc4_ = true;
         }
         _loc3_._id = param2;
         if(_loc4_ || _loc3_.id == LOCATION_ID_END || _loc3_.id == LOCATION_ID_START)
         {
            this.cacheLimits();
         }
         dispatchEvent(new TravelDefLocationEvent(param1));
      }
      
      public function reversePoints() : void
      {
         this.points = this.points.reverse();
         this.spline.points = this.points;
         this.spline.parameterize();
         this.cacheLimits();
         dispatchEvent(new TravelDefLocationsEvent());
      }
      
      private function insertPointLinear(param1:int, param2:Number) : Point
      {
         var _loc3_:Point = this.spline.points[param1];
         var _loc4_:Point = this.spline.points[param1 + 1];
         var _loc5_:Number = _loc3_.x + param2 * (_loc4_.x - _loc3_.x);
         var _loc6_:Number = _loc3_.y + param2 * (_loc4_.y - _loc3_.y);
         return new Point(_loc5_,_loc6_);
      }
      
      public function insertPointAfter(param1:int, param2:Number) : void
      {
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(param1 >= this.points.length - 2)
         {
            _loc3_ = this.insertPointLinear(this.points.length - 2,param2);
         }
         else if(param1 >= 1)
         {
            _loc4_ = this.spline.points[param1];
            _loc5_ = this.spline.points[param1 + 1];
            _loc6_ = this.spline.getPointParameter(param1);
            _loc7_ = this.spline.getPointParameter(param1 + 1);
            _loc3_ = new Point();
            _loc8_ = _loc6_ + (_loc7_ - _loc6_) * param2;
            this.spline.sample(_loc8_,_loc3_);
         }
         else
         {
            _loc3_ = this.insertPointLinear(0,param2);
         }
         if(_loc3_)
         {
            this.points.splice(param1 + 1,0,_loc3_);
            this.spline.points = this.points;
            this.spline.parameterize();
            this._lockLocationsToMapX();
            this.cacheLimits();
            dispatchEvent(new TravelDefSplineEvent());
         }
      }
      
      public function deletePoint(param1:int) : void
      {
         if(param1 < 0 || param1 >= this.points.length)
         {
            return;
         }
         this.points.splice(param1,1);
         this.spline.points = this.points;
         this.spline.parameterize();
         this.cacheLimits();
         dispatchEvent(new TravelDefSplineEvent());
      }
      
      public function insertLocationAfter(param1:int) : TravelLocationDef
      {
         var _loc2_:TravelLocationDef = null;
         var _loc3_:Number = NaN;
         if(param1 >= 0 && param1 < this.locations.length)
         {
            _loc2_ = this.locations[param1];
            _loc3_ = _loc2_.position + 100;
            return this.insertLocation(_loc3_);
         }
         return this.insertLocation(0);
      }
      
      public function insertLocation(param1:Number) : TravelLocationDef
      {
         var _loc2_:TravelLocationDef = new TravelLocationDef(this);
         var _loc3_:Number = param1 / this.spline.totalLength;
         this.spline.sample(_loc3_,this._scratch);
         _loc2_.setPosition(param1,this._scratch.x);
         _loc2_._id = "new_location";
         this.locations.push(_loc2_);
         this.sortLocations();
         this.cacheLimits();
         dispatchEvent(new TravelDefLocationsEvent());
         return _loc2_;
      }
      
      public function deleteLocation(param1:int, param2:Boolean) : void
      {
         if(param1 < 0 || param1 >= this.locations.length)
         {
            return;
         }
         var _loc3_:TravelLocationDef = this.locations[param1];
         this.locations.splice(param1,1);
         this.cacheLimits();
         this.removeFromMapKeyLocations(_loc3_);
         if(param2)
         {
            dispatchEvent(new TravelDefLocationsEvent());
         }
      }
      
      public function notifyTravelDefLocationsChanged() : void
      {
         dispatchEvent(new TravelDefLocationsEvent());
      }
      
      public function addToMapKeyLocations(param1:TravelLocationDef) : void
      {
         var _loc2_:int = this.mapKeyLocations.indexOf(param1);
         if(_loc2_ < 0)
         {
            this.mapKeyLocations.push(param1);
            this.sortMapKeyLocations();
         }
      }
      
      public function removeFromMapKeyLocations(param1:TravelLocationDef) : void
      {
         var _loc2_:int = this.mapKeyLocations.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.mapKeyLocations.splice(_loc2_,1);
         }
      }
      
      public function cacheMapKeyLocations() : void
      {
         var _loc1_:TravelLocationDef = null;
         this.mapKeyLocations.splice(0,this.mapKeyLocations.length);
         for each(_loc1_ in this.locations)
         {
            if(_loc1_.mapkey)
            {
               this.mapKeyLocations.push(_loc1_);
            }
         }
      }
      
      public function addToLoadBarrierLocations(param1:TravelLocationDef) : void
      {
         var _loc2_:int = this.loadBarrierLocations.indexOf(param1);
         if(_loc2_ < 0)
         {
            this.loadBarrierLocations.push(param1);
            this.sortLoadBarrierLocations();
         }
      }
      
      public function removeFromLoadBarrierLocations(param1:TravelLocationDef) : void
      {
         var _loc2_:int = this.loadBarrierLocations.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.loadBarrierLocations.splice(_loc2_,1);
         }
      }
      
      public function cacheLoadBarrierLocations() : void
      {
         var _loc1_:TravelLocationDef = null;
         this.loadBarrierLocations.splice(0,this.loadBarrierLocations.length);
         for each(_loc1_ in this.locations)
         {
            if(_loc1_.loadBarrier)
            {
               this.loadBarrierLocations.push(_loc1_);
            }
         }
      }
      
      public function sortLocations() : void
      {
         this.locations.sort(function(param1:TravelLocationDef, param2:TravelLocationDef):Number
         {
            return param1.position - param2.position;
         });
      }
      
      private function sortMapKeyLocations() : void
      {
         this.mapKeyLocations.sort(function(param1:TravelLocationDef, param2:TravelLocationDef):Number
         {
            return param1.position - param2.position;
         });
      }
      
      private function sortLoadBarrierLocations() : void
      {
         this.loadBarrierLocations.sort(function(param1:TravelLocationDef, param2:TravelLocationDef):Number
         {
            return param1.position - param2.position;
         });
      }
      
      public function findLocationById(param1:String) : TravelLocationDef
      {
         var _loc2_:TravelLocationDef = null;
         for each(_loc2_ in this.locations)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getPointAtLocation(param1:int, param2:Point = null) : Point
      {
         if(param1 < 0 || param1 >= this.locations.length)
         {
            return null;
         }
         var _loc3_:TravelLocationDef = this.locations[param1];
         if(!param2)
         {
            param2 = new Point();
         }
         var _loc4_:Number = _loc3_.position / this.spline.totalLength;
         this.spline.sample(_loc4_,param2);
         return param2;
      }
      
      public function isLocationTriggerInRange(param1:SagaTriggerDefBag, param2:Number, param3:Number) : Boolean
      {
         var _loc5_:SagaTriggerDef = null;
         var _loc6_:TravelLocationDef = null;
         if(!param1 || !param1.list || param1.list.length == 0)
         {
            return true;
         }
         var _loc4_:Boolean = true;
         for each(_loc5_ in param1.list)
         {
            if(_loc5_.type == SagaTriggerType.LOCATION)
            {
               _loc6_ = this.findLocationById(_loc5_.location);
               if(_loc6_)
               {
                  if(_loc6_.position >= param2 && _loc6_.position <= param3)
                  {
                     return true;
                  }
               }
            }
            else
            {
               _loc4_ = false;
            }
         }
         if(_loc4_)
         {
            return false;
         }
         return true;
      }
      
      public function findNextLoadBarrier(param1:Number) : Number
      {
         var _loc2_:TravelLocationDef = null;
         if(this.loadBarrierLocations)
         {
            for each(_loc2_ in this.loadBarrierLocations)
            {
               if(_loc2_.position > param1)
               {
                  return _loc2_.position;
               }
            }
         }
         return this.spline.totalLength;
      }
      
      public function getLocationDefs(param1:String, param2:Vector.<ITravelLocationDef>) : Vector.<ITravelLocationDef>
      {
         var _loc3_:ITravelLocationDef = null;
         for each(_loc3_ in this.locations)
         {
            if(!param1 || _loc3_.id == param1)
            {
               if(!param2)
               {
                  param2 = new Vector.<ITravelLocationDef>();
               }
               param2.push(_loc3_);
            }
         }
         return param2;
      }
      
      public function get numTravelLocations() : int
      {
         return !!this.locations ? int(this.locations.length) : 0;
      }
      
      public function getTravelLocation(param1:int) : ITravelLocationDef
      {
         return this.locations[param1];
      }
      
      public function getId() : String
      {
         return this.id;
      }
   }
}
