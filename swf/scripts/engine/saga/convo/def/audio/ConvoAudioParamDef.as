package engine.saga.convo.def.audio
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class ConvoAudioParamDef
   {
      
      public static const schema:Object = {
         "name":"ConvoAudioParamDef",
         "type":"object",
         "properties":{
            "param":{"type":"string"},
            "value":{"type":"number"}
         }
      };
       
      
      public var param:String;
      
      public var value:Number = 0;
      
      public function ConvoAudioParamDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ConvoAudioParamDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.param = param1.param;
         this.value = param1.value;
         return this;
      }
      
      public function save() : Object
      {
         return {
            "param":(!!this.param ? this.param : ""),
            "value":this.value
         };
      }
   }
}
