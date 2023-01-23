package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   
   public class PhantasmDefSound extends PhantasmDef
   {
      
      public static const schema:Object = {
         "name":"PhantasmDefSound",
         "type":"object",
         "properties":{
            "sound":{"type":"string"},
            "params":{
               "type":"array",
               "items":SoundParamInfo.schema,
               "optional":true
            },
            "base":{"type":PhantasmDefVars.schema}
         }
      };
       
      
      public var sound:String;
      
      public var isVocalizeGetHit:Boolean;
      
      public var params:Vector.<SoundParamInfo>;
      
      public function PhantasmDefSound(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         PhantasmDefVars.parse(this,param1.base,param2);
         this.sound = param1.sound;
         if(this.sound)
         {
            this.isVocalizeGetHit = StringUtil.startsWith(this.sound,"vocalize_gethit_");
         }
         this.params = ArrayUtil.arrayToDefVector(param1.params,SoundParamInfo,param2,null) as Vector.<SoundParamInfo>;
      }
      
      override public function toJson() : Object
      {
         var _loc1_:Object = {
            "sound":this.sound,
            "base":PhantasmDefVars.save(this)
         };
         if(Boolean(this.params) && Boolean(this.params.length))
         {
            _loc1_.params = ArrayUtil.defVectorToArray(this.params,true);
         }
         return _loc1_;
      }
      
      override public function toString() : String
      {
         return "PDSound " + super.toString() + " sound=" + this.sound;
      }
   }
}
