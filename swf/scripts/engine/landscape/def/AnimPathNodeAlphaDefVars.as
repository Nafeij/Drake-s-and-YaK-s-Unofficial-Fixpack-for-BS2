package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodeAlphaDefVars
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeAlphaDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "duration_secs":{"type":"number"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "start":{
               "type":"number",
               "optional":true
            },
            "target":{"type":"number"},
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
       
      
      public function AnimPathNodeAlphaDefVars()
      {
         super();
      }
      
      public static function constructNode(param1:Object, param2:ILogger) : AnimPathNodeAlphaDef
      {
         var _loc3_:AnimPathNodeAlphaDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         _loc3_ = new AnimPathNodeAlphaDef();
         AnimPathNodeDef.constructBase(_loc3_,param1);
         _loc3_.durationSecs = param1.duration_secs;
         if(param1.start != undefined)
         {
            _loc3_.start = param1.start;
         }
         _loc3_.target = param1.target;
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
      
      public static function save(param1:AnimPathNodeAlphaDef) : Object
      {
         return {
            "type":AnimPathType.ALPHA.name,
            "start":param1.start,
            "start_secs":(isNaN(param1.startTimeSecs) ? -1 : param1.startTimeSecs),
            "target":param1.target,
            "duration_secs":(isNaN(param1.durationSecs) ? 0 : param1.durationSecs),
            "ease":(!!param1.ease ? param1.ease : ""),
            "tailpos":param1.tailpos,
            "easeIn":param1.easeIn,
            "easeOut":param1.easeOut
         };
      }
   }
}
