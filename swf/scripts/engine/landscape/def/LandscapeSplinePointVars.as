package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   
   public class LandscapeSplinePointVars extends LandscapeSplinePoint
   {
      
      public static const schema:Object = {
         "name":"LandscapeSplinePointVars",
         "type":"object",
         "properties":{
            "pos":{"type":"string"},
            "id":{
               "type":"string",
               "optional":true
            },
            "zoom":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function LandscapeSplinePointVars()
      {
         super();
      }
      
      public static function save(param1:LandscapeSplinePoint) : Object
      {
         var _loc2_:Object = {"pos":PointVars.saveString(param1.pos)};
         if(param1.id)
         {
            _loc2_.id = param1.id;
         }
         if(param1.zoom != 1)
         {
            _loc2_.zoom = param1.zoom;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : LandscapeSplinePoint
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         _id = param1.id;
         pos = PointVars.parseString(param1.pos,pos);
         if(param1.zoom != undefined)
         {
            zoom = param1.zoom;
         }
         return this;
      }
   }
}
