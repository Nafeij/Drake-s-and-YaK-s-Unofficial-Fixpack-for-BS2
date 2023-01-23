package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SoundParamInfo
   {
      
      public static const schema:Object = {
         "name":"SoundParamInfo",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "value":{"type":"number"},
            "timeMs":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var value:Number;
      
      public var timeMs:int;
      
      public function SoundParamInfo()
      {
         super();
      }
      
      public static function vctor() : Vector.<SoundParamInfo>
      {
         return new Vector.<SoundParamInfo>();
      }
      
      public function clone() : SoundParamInfo
      {
         var _loc1_:SoundParamInfo = new SoundParamInfo();
         _loc1_.id = this.id;
         _loc1_.value = this.value;
         _loc1_.timeMs = this.timeMs;
         return _loc1_;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "id":this.id,
            "value":this.value
         };
         if(this.timeMs)
         {
            _loc1_.timeMs = this.timeMs;
         }
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SoundParamInfo
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.value = param1.value;
         this.timeMs = param1.timeMs;
         return this;
      }
   }
}
