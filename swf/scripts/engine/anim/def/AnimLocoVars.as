package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimLocoVars extends AnimLoco
   {
      
      public static const schema:Object = {
         "name":"AnimLocoVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "start":{"type":"string"},
            "loop":{"type":"string"},
            "stop":{"type":"string"}
         }
      };
       
      
      public function AnimLocoVars(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.start = param1.start;
         this.loop = param1.loop;
         this.stop = param1.end;
      }
      
      public static function save(param1:AnimLoco) : Object
      {
         var _loc2_:Object = {
            "id":param1.id,
            "loop":param1.loop
         };
         if(param1.start != null)
         {
            _loc2_.start = param1.start;
         }
         if(param1.stop != null)
         {
            _loc2_.stop = param1.stop;
         }
         return _loc2_;
      }
   }
}
