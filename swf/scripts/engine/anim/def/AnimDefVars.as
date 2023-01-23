package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   
   public class AnimDefVars extends AnimDef
   {
      
      public static const schema:Object = {
         "name":"AnimDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "clip":{"type":"string"},
            "flip":{
               "type":"boolean",
               "optional":true
            },
            "speed":{
               "type":"number",
               "optional":true
            },
            "offset":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function AnimDefVars(param1:Object, param2:ILogger, param3:AnimLibrary, param4:String, param5:String)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         _flip = Boolean(param1.flip) && (param1.flip is Boolean || param1.flip == "true");
         _name = param1.name;
         _clipUrl = param1.clip;
         _offset = PointVars.parseString(param1.offset,null);
         if(_offset)
         {
            _offset = _offset;
         }
         if(Boolean(param4) && param5 != null)
         {
            _clipUrl = _clipUrl.replace(param4,param5);
         }
         if(param1.speed)
         {
            _moveSpeed = Number(param1.speed);
         }
      }
      
      public static function save(param1:AnimDef) : Object
      {
         var _loc2_:Object = {
            "name":param1.name,
            "flip":param1.flip,
            "clip":param1.clipUrl,
            "speed":param1.moveSpeed
         };
         if(param1._offset)
         {
            _loc2_.offset = PointVars.saveString(param1._offset);
         }
         return _loc2_;
      }
   }
}
