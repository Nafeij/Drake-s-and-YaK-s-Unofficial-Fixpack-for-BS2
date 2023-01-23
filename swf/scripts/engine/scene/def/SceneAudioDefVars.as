package engine.scene.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SceneAudioDefVars extends SceneAudioDef
   {
      
      public static const schema:Object = {
         "name":"SceneAudioDefVars",
         "type":"object",
         "properties":{"emitters":{
            "type":"array",
            "items":SceneAudioEmitterDefVars.schema
         }}
      };
       
      
      public function SceneAudioDefVars(param1:SceneDef)
      {
         super(param1);
      }
      
      public static function save(param1:SceneAudioDef) : Object
      {
         var _loc3_:SceneAudioEmitterDef = null;
         var _loc2_:Object = {"emitters":[]};
         for each(_loc3_ in param1.emitters)
         {
            _loc2_.emitters.push(SceneAudioEmitterDefVars.save(_loc3_));
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SceneAudioDef
      {
         var _loc3_:Object = null;
         var _loc4_:SceneAudioEmitterDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.emitters)
         {
            _loc4_ = new SceneAudioEmitterDefVars().fromJson(_loc3_,param2);
            emitters.push(_loc4_);
         }
         return this;
      }
   }
}
