package engine.vfx
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   
   public class OrientedOffsetVars extends OrientedOffset
   {
      
      public static const schema:Object = {
         "name":"OrientedOffsetVars",
         "type":"object",
         "properties":{
            "ne":{
               "type":PointVars.schema,
               "optional":true
            },
            "se":{
               "type":PointVars.schema,
               "optional":true
            },
            "nw":{
               "type":PointVars.schema,
               "optional":true
            },
            "sw":{
               "type":PointVars.schema,
               "optional":true
            }
         }
      };
       
      
      public function OrientedOffsetVars()
      {
         super();
      }
      
      public static function save(param1:OrientedOffset) : Object
      {
         return {
            "ne":param1.ne,
            "se":param1.se,
            "nw":param1.nw,
            "sw":param1.sw
         };
      }
      
      public function fromJson(param1:Object, param2:ILogger) : OrientedOffset
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.ne)
         {
            ne = PointVars.parse(param1.ne,param2,ne);
         }
         if(param1.se)
         {
            se = PointVars.parse(param1.se,param2,se);
         }
         if(param1.nw)
         {
            nw = PointVars.parse(param1.nw,param2,nw);
         }
         if(param1.sw)
         {
            sw = PointVars.parse(param1.sw,param2,sw);
         }
         return this;
      }
   }
}
