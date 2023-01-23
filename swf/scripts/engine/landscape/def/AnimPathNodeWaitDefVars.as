package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodeWaitDefVars
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeWaitDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "duration_secs":{"type":"number"},
            "start_secs":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function AnimPathNodeWaitDefVars()
      {
         super();
      }
      
      public static function constructNode(param1:Object, param2:ILogger) : AnimPathNodeWaitDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         var _loc3_:AnimPathNodeWaitDef = new AnimPathNodeWaitDef();
         AnimPathNodeDef.constructBase(_loc3_,param1);
         _loc3_.durationSecs = param1.duration_secs;
         return _loc3_;
      }
      
      public static function save(param1:AnimPathNodeWaitDef) : Object
      {
         return {
            "type":AnimPathType.WAIT.name,
            "duration_secs":param1.durationSecs,
            "start_secs":(isNaN(param1.startTimeSecs) ? -1 : param1.startTimeSecs)
         };
      }
   }
}
