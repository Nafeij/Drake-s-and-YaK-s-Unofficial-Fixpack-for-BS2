package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   
   public class AnimPathNodeMoveDefVars
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeMoveDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "duration_secs":{"type":"number"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "start":{"type":PointVars.schema},
            "target":{"type":PointVars.schema},
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
       
      
      public function AnimPathNodeMoveDefVars()
      {
         super();
      }
      
      public static function constructNode(param1:Object, param2:ILogger) : AnimPathNodeMoveDef
      {
         var _loc3_:AnimPathNodeMoveDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         _loc3_ = new AnimPathNodeMoveDef();
         AnimPathNodeDef.constructBase(_loc3_,param1);
         _loc3_.durationSecs = param1.duration_secs;
         _loc3_.start = PointVars.parse(param1.start,param2,_loc3_.start);
         _loc3_.target = PointVars.parse(param1.target,param2,_loc3_.target);
         if(param1.ease != undefined)
         {
            _loc3_.ease = param1.ease;
         }
         if(param1.tailpos != undefined)
         {
            _loc3_.tailpos = param1.tailpos;
         }
         _loc3_.easeIn = BooleanVars.parse(param1.easeIn,_loc3_.easeIn);
         _loc3_.easeOut = BooleanVars.parse(param1.easeOut,_loc3_.easeOut);
         return _loc3_;
      }
      
      public static function save(param1:AnimPathNodeMoveDef) : Object
      {
         var _loc2_:Object = {
            "type":AnimPathType.MOVE.name,
            "start":PointVars.save(param1.start),
            "start_secs":(isNaN(param1.startTimeSecs) ? -1 : param1.startTimeSecs),
            "target":PointVars.save(param1.target)
         };
         if(param1.durationSecs != 1 && !isNaN(param1.durationSecs))
         {
            _loc2_.duration_secs = param1.durationSecs;
         }
         if(param1.tailpos != 1)
         {
            _loc2_.tailpos = param1.tailpos;
         }
         if(param1.ease != "linear")
         {
            _loc2_.ease = param1.ease;
         }
         if(!param1.easeIn)
         {
            _loc2_.easeIn = param1.easeIn;
         }
         if(!param1.easeOut)
         {
            _loc2_.easeOut = param1.easeIn;
         }
         return _loc2_;
      }
   }
}
