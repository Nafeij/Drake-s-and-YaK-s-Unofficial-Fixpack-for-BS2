package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class LandscapeSplineDefVars extends LandscapeSplineDef
   {
      
      public static const schema:Object = {
         "name":"LandscapeSplineDefVars",
         "type":"object",
         "properties":{
            "points":{
               "type":"array",
               "items":LandscapeSplinePointVars.schema
            },
            "id":{"type":"string"},
            "ease":{
               "type":"string",
               "optional":true
            },
            "easeIn":{
               "type":"boolean",
               "optional":true
            },
            "easeOut":{
               "type":"boolean",
               "optional":true
            },
            "tailpos":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function LandscapeSplineDefVars()
      {
         super();
      }
      
      public static function save(param1:LandscapeSplineDef) : Object
      {
         var _loc4_:LandscapeSplinePoint = null;
         var _loc2_:Object = {
            "id":param1.id,
            "ease":(!!param1.ease ? param1.ease : ""),
            "easeIn":param1.easeIn,
            "easeOut":param1.easeOut,
            "tailpos":param1.tailpos,
            "points":[]
         };
         var _loc3_:int = 0;
         while(_loc3_ < param1.numPoints)
         {
            _loc4_ = param1.getPoint(_loc3_);
            _loc2_.points.push(LandscapeSplinePointVars.save(_loc4_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : LandscapeSplineDefVars
      {
         var _loc3_:Object = null;
         var _loc4_:LandscapeSplinePoint = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         id = param1.id;
         for each(_loc3_ in param1.points)
         {
            _loc4_ = new LandscapeSplinePointVars().fromJson(_loc3_,param2);
            addPoint(_loc4_);
         }
         if(param1.ease != undefined)
         {
            ease = param1.ease;
         }
         this.easeIn = BooleanVars.parse(param1.easeIn,easeIn);
         this.easeOut = BooleanVars.parse(param1.easeOut,easeOut);
         if(param1.tailpos != undefined)
         {
            tailpos = param1.tailpos;
         }
         regenerateSpline();
         return this;
      }
   }
}
