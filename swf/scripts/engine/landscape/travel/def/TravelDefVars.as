package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   import engine.core.math.spline.CatmullRomSpline2d;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.NumberVars;
   import engine.def.PointVars;
   import engine.landscape.def.LandscapeDef;
   import flash.geom.Point;
   
   public class TravelDefVars extends TravelDef
   {
      
      public static const schema:Object = {
         "name":"TravelDefVars",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "optional":true
            },
            "spline":{
               "type":"array",
               "items":PointVars.schema,
               "optional":true
            },
            "splinex":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "locations":{
               "type":"array",
               "items":TravelLocationDefVars.schema,
               "optional":true
            },
            "reactors":{
               "type":"array",
               "items":TravelReactorDef.schema,
               "optional":true
            },
            "close":{
               "type":"boolean",
               "optional":true
            },
            "yoxen":{
               "type":"boolean",
               "optional":true
            },
            "ships":{
               "type":"boolean",
               "optional":true
            },
            "speed":{
               "type":"number",
               "optional":true
            },
            "paramControls":{
               "type":"array",
               "items":TravelParamControlDef.schema,
               "optional":true
            },
            "showYoxen":{
               "type":"boolean",
               "optional":true
            },
            "showCartFront":{
               "type":"boolean",
               "optional":true
            },
            "showBanner":{
               "type":"boolean",
               "optional":true
            },
            "showGlow":{
               "type":"boolean",
               "optional":true
            },
            "showMinCaravan":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function TravelDefVars(param1:LandscapeDef, param2:Object, param3:ILogger)
      {
         var _loc4_:Object = null;
         var _loc5_:TravelParamControlDef = null;
         var _loc6_:Object = null;
         var _loc7_:Point = null;
         var _loc8_:String = null;
         var _loc9_:Point = null;
         var _loc10_:Object = null;
         var _loc11_:TravelReactorDef = null;
         var _loc12_:Object = null;
         var _loc13_:TravelLocationDefVars = null;
         super(param1);
         EngineJsonDef.validateThrow(param2,schema,param3);
         this.id = param2.id;
         if(param2.paramControls)
         {
            this.paramControls = new Vector.<TravelParamControlDef>();
            for each(_loc4_ in param2.paramControls)
            {
               _loc5_ = new TravelParamControlDef().fromJson(_loc4_,param3);
               this.paramControls.push(_loc5_);
            }
         }
         if(param2.spline)
         {
            for each(_loc6_ in param2.spline)
            {
               _loc7_ = PointVars.parse(_loc6_,param3,null);
               points.push(_loc7_);
            }
         }
         else if(param2.splinex)
         {
            for each(_loc8_ in param2.splinex)
            {
               _loc9_ = PointVars.parseString(_loc8_,null);
               _loc9_.x = Math.round(_loc9_.x);
               _loc9_.y = Math.round(_loc9_.y);
               points.push(_loc9_);
            }
         }
         if(param2.reactors)
         {
            for each(_loc10_ in param2.reactors)
            {
               _loc11_ = new TravelReactorDef().fromJson(_loc10_,param3);
               if(!this.reactors)
               {
                  this.reactors = new Vector.<TravelReactorDef>();
               }
               this.reactors.push(_loc11_);
            }
         }
         spline = new CatmullRomSpline2d(points);
         if(param2.locations)
         {
            for each(_loc12_ in param2.locations)
            {
               _loc13_ = new TravelLocationDefVars(this);
               _loc13_.fromJson(_loc12_,param3,spline);
               locations.push(_loc13_);
            }
         }
         close = BooleanVars.parse(param2.close,close);
         ships = BooleanVars.parse(param2.ships,ships);
         speed = NumberVars.parse(param2.speed,speed);
         showYoxen = BooleanVars.parse(param2.showYoxen,showYoxen);
         showCartFront = BooleanVars.parse(param2.showCartFront,showCartFront);
         showBanner = BooleanVars.parse(param2.showBanner,showBanner);
         showGlow = BooleanVars.parse(param2.showGlow,showGlow);
         showMinCaravan = BooleanVars.parse(param2.showMinCaravan,showMinCaravan);
         cacheLimits();
         sortLocations();
         cacheMapKeyLocations();
         cacheLoadBarrierLocations();
      }
      
      public static function save(param1:TravelDef) : Object
      {
         var _loc4_:Point = null;
         var _loc5_:String = null;
         var _loc6_:TravelLocationDef = null;
         var _loc7_:Object = null;
         var _loc8_:TravelReactorDef = null;
         var _loc9_:Object = null;
         var _loc10_:TravelParamControlDef = null;
         var _loc2_:Object = {"splinex":[]};
         var _loc3_:int = 0;
         while(_loc3_ < param1.spline.points.length)
         {
            _loc4_ = param1.spline.points[_loc3_];
            _loc5_ = PointVars.saveString(_loc4_);
            _loc2_.splinex.push(_loc5_);
            _loc3_++;
         }
         if(Boolean(param1.locations) && param1.locations.length > 0)
         {
            _loc2_.locations = [];
            for each(_loc6_ in param1.locations)
            {
               _loc7_ = TravelLocationDefVars.save(_loc6_);
               _loc2_.locations.push(_loc7_);
            }
         }
         if(param1.close)
         {
            _loc2_.close = true;
         }
         if(!param1.showYoxen)
         {
            _loc2_.showYoxen = false;
         }
         if(!param1.showCartFront)
         {
            _loc2_.showCartFront = false;
         }
         if(!param1.showBanner)
         {
            _loc2_.showBanner = false;
         }
         if(param1.showGlow)
         {
            _loc2_.showGlow = param1.showGlow;
         }
         if(param1.showMinCaravan)
         {
            _loc2_.showMinCaravan = param1.showMinCaravan;
         }
         if(param1.ships)
         {
            _loc2_.ships = true;
         }
         if(param1.speed > 0)
         {
            _loc2_.speed = param1.speed;
         }
         if(Boolean(param1.reactors) && Boolean(param1.reactors.length))
         {
            _loc2_.reactors = [];
            for each(_loc8_ in param1.reactors)
            {
               _loc9_ = _loc8_.toJson();
               _loc2_.reactors.push(_loc9_);
            }
         }
         if(Boolean(param1.paramControls) && Boolean(param1.paramControls.length))
         {
            _loc2_.paramControls = [];
            for each(_loc10_ in param1.paramControls)
            {
               _loc2_.paramControls.push(_loc10_.toJson());
            }
         }
         return _loc2_;
      }
   }
}
