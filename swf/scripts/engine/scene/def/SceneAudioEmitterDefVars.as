package engine.scene.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.def.RectangleVars;
   
   public class SceneAudioEmitterDefVars extends SceneAudioEmitterDef
   {
      
      public static const schema:Object = {
         "name":"SceneAudioEmitterDefVars",
         "type":"object",
         "properties":{
            "source":{"type":RectangleVars.schema},
            "limit":{
               "type":RectangleVars.schema,
               "optional":true
            },
            "attenuation_left":{
               "type":"number",
               "optional":true
            },
            "attenuation_right":{
               "type":"number",
               "optional":true
            },
            "volume":{
               "type":"number",
               "optional":true
            },
            "event":{"type":"string"},
            "sku":{"type":"string"},
            "layer":{
               "type":"string",
               "optional":true
            },
            "condition_if":{
               "type":"string",
               "optional":true
            },
            "condition_not":{
               "type":"string",
               "optional":true
            },
            "paramNames":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "paramValues":{
               "type":"array",
               "items":"number",
               "optional":true
            }
         }
      };
       
      
      public function SceneAudioEmitterDefVars()
      {
         super();
      }
      
      public static function save(param1:SceneAudioEmitterDef) : Object
      {
         var _loc2_:Object = {
            "source":RectangleVars.save(param1.source),
            "event":(!!param1.event ? param1.event : ""),
            "sku":(!!param1.sku ? param1.sku : "")
         };
         if(param1.limit)
         {
            _loc2_.limit = RectangleVars.save(param1.limit);
         }
         if(param1.volume != 1)
         {
            _loc2_.volume = param1.volume;
         }
         if(param1.attenuation_left != 1)
         {
            _loc2_.attenuation_left = param1.attenuation_left;
         }
         if(param1.attenuation_right != 1)
         {
            _loc2_.attenuation_right = param1.attenuation_right;
         }
         if(param1.paramNames.length > 0 && param1.paramValues.length == param1.paramNames.length)
         {
            _loc2_.paramNames = param1.paramNames;
            _loc2_.paramValues = param1.paramValues;
         }
         if(param1.condition_if)
         {
            _loc2_.condition_if = param1.condition_if;
         }
         if(param1.condition_not)
         {
            _loc2_.condition_not = param1.condition_not;
         }
         if(param1.layer)
         {
            _loc2_.layer = param1.layer;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SceneAudioEmitterDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         source = RectangleVars.parse(param1.source,param2,source);
         _limit = RectangleVars.parse(param1.limit,param2,_limit);
         if(param1.volume != undefined)
         {
            volume = param1.volume;
         }
         if(param1.attenuation_left != undefined)
         {
            attenuation_left = param1.attenuation_left;
         }
         if(param1.attenuation_left != undefined)
         {
            attenuation_left = param1.attenuation_left;
         }
         _event = param1.event;
         _sku = param1.sku;
         if(Boolean(param1.paramNames) && Boolean(param1.paramValues))
         {
            paramNames = param1.paramNames;
            paramValues = param1.paramValues;
         }
         condition_if = param1.condition_if;
         condition_not = param1.condition_not;
         layer = param1.layer;
         return this;
      }
   }
}
