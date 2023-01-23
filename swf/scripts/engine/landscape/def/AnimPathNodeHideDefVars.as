package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodeHideDefVars
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeHideDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "start_secs":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function AnimPathNodeHideDefVars()
      {
         super();
      }
      
      public static function constructNode(param1:Object, param2:ILogger) : AnimPathNodeHideDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         var _loc3_:AnimPathNodeHideDef = new AnimPathNodeHideDef();
         AnimPathNodeDef.constructBase(_loc3_,param1);
         return _loc3_;
      }
      
      public static function save(param1:AnimPathNodeHideDef) : Object
      {
         return {
            "type":AnimPathType.HIDE.name,
            "start_secs":(isNaN(param1.startTimeSecs) ? -1 : param1.startTimeSecs)
         };
      }
   }
}
