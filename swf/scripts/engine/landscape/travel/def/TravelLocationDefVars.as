package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   import engine.core.math.spline.CatmullRomSpline2d;
   import engine.def.EngineJsonDef;
   import engine.math.MathUtil;
   import flash.geom.Point;
   
   public class TravelLocationDefVars extends TravelLocationDef
   {
      
      public static const schema:Object = {
         "name":"TravelLocationDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "position":{"type":"number"},
            "mapkey":{
               "type":"boolean",
               "optional":true
            },
            "loadBarrier":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var _scratch:Point;
      
      public function TravelLocationDefVars(param1:TravelDef)
      {
         this._scratch = new Point();
         super(param1);
      }
      
      public static function save(param1:TravelLocationDef) : Object
      {
         var _loc2_:Object = {
            "id":param1.id,
            "position":param1.position
         };
         if(param1.mapkey)
         {
            _loc2_.mapkey = true;
         }
         if(param1.loadBarrier)
         {
            _loc2_.loadBarrier = true;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:CatmullRomSpline2d) : void
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         _id = param1.id;
         if(!id || id.indexOf(" ") >= 0)
         {
            throw new ArgumentError("invalid travel location id [" + id + "]");
         }
         _position = param1.position;
         this._position = MathUtil.stripDecimalPrecision(_position,TravelLocationDef.DECIMAL_PRECISION);
         var _loc4_:Number = _position / param3.totalLength;
         param3.sample(_loc4_,this._scratch);
         mapx = this._scratch.x;
         mapkey = param1.mapkey;
         loadBarrier = param1.loadBarrier;
      }
   }
}
