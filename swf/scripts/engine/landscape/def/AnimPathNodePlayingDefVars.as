package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodePlayingDefVars
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodePlayingDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "playing":{"type":"boolean"}
         }
      };
       
      
      public function AnimPathNodePlayingDefVars()
      {
         super();
      }
      
      public static function constructNode(param1:Object, param2:ILogger) : AnimPathNodePlayingDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         var _loc3_:AnimPathNodePlayingDef = new AnimPathNodePlayingDef();
         AnimPathNodeDef.constructBase(_loc3_,param1);
         return _loc3_;
      }
      
      public static function save(param1:AnimPathNodePlayingDef) : Object
      {
         return {
            "type":AnimPathType.SCALE.name,
            "playing":param1.playing,
            "start_secs":(isNaN(param1.startTimeSecs) ? -1 : param1.startTimeSecs)
         };
      }
   }
}
