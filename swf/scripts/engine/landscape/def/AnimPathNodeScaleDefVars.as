package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodeScaleDefVars
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeScaleDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "scaleX":{"type":"number"},
            "scaleY":{"type":"number"}
         }
      };
       
      
      public function AnimPathNodeScaleDefVars()
      {
         super();
      }
      
      public static function constructNode(param1:Object, param2:ILogger) : AnimPathNodeScaleDef
      {
         var _loc3_:AnimPathNodeScaleDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         _loc3_ = new AnimPathNodeScaleDef();
         AnimPathNodeDef.constructBase(_loc3_,param1);
         _loc3_.scaleX = param1.scaleX;
         _loc3_.scaleY = param1.scaleY;
         return _loc3_;
      }
      
      public static function save(param1:AnimPathNodeScaleDef) : Object
      {
         return {
            "type":AnimPathType.SCALE.name,
            "start_secs":(isNaN(param1.startTimeSecs) ? -1 : param1.startTimeSecs),
            "scaleX":param1.scaleX,
            "scaleY":param1.scaleY
         };
      }
   }
}
