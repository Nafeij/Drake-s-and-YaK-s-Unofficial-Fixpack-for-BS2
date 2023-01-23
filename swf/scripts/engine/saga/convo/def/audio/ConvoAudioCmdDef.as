package engine.saga.convo.def.audio
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ConvoAudioCmdDef extends EventDispatcher
   {
      
      public static const schema:Object = {
         "name":"ConvoAudioCmdDef",
         "type":"object",
         "properties":{
            "params":{
               "type":"array",
               "items":ConvoAudioParamDef.schema,
               "optional":true
            },
            "type":{"type":"string"},
            "event":{"type":"string"},
            "delay":{
               "type":"number",
               "optional":true
            },
            "sku":{"type":"string"},
            "volume":{
               "type":"number",
               "optional":true
            },
            "music":{
               "type":"boolean",
               "optional":true
            },
            "blockInput":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static var EVENT_LABEL:String = "ConvoAudioCmdDef.EVENT_LABEL";
       
      
      private const EVENT_PATH_PREFIX:String = "event:/";
      
      private var _type:ConvoAudioCmdType;
      
      private var _event:String;
      
      public var sku:String;
      
      public var params:Vector.<ConvoAudioParamDef>;
      
      public var volume:Number = 1;
      
      public var music:Boolean;
      
      public var blockInput:Boolean;
      
      public var delay:int;
      
      public function ConvoAudioCmdDef()
      {
         this._type = ConvoAudioCmdType.START;
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ConvoAudioCmdDef
      {
         var _loc3_:Object = null;
         var _loc4_:ConvoAudioParamDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.type = Enum.parse(ConvoAudioCmdType,param1.type) as ConvoAudioCmdType;
         this.event = this.sanitizeEventString(param1.event);
         this.sku = param1.sku;
         this.music = BooleanVars.parse(param1.music,this.music);
         this.blockInput = BooleanVars.parse(param1.blockInput,this.blockInput);
         this.delay = param1.delay;
         if(param1.volume != undefined)
         {
            this.volume = param1.volume;
         }
         if(param1.params)
         {
            for each(_loc3_ in param1.params)
            {
               _loc4_ = new ConvoAudioParamDef().fromJson(_loc3_,param2);
               this.addParam(_loc4_);
            }
         }
         return this;
      }
      
      public function save() : Object
      {
         var _loc2_:ConvoAudioParamDef = null;
         var _loc1_:Object = {
            "event":(!!this.event ? this.sanitizeEventString(this.event) : ""),
            "sku":(!!this.sku ? this.sku : ""),
            "type":this.type.name
         };
         if(this.volume < 1)
         {
            _loc1_.volume = this.volume;
         }
         if(Boolean(this.params) && this.params.length > 0)
         {
            _loc1_.params = [];
            for each(_loc2_ in this.params)
            {
               _loc1_.params.push(_loc2_.save());
            }
         }
         if(this.music)
         {
            _loc1_.music = this.music;
         }
         if(this.blockInput)
         {
            _loc1_.blockInput = this.blockInput;
         }
         if(this.delay)
         {
            _loc1_.delay = this.delay;
         }
         return _loc1_;
      }
      
      private function sanitizeEventString(param1:String) : String
      {
         if(param1.indexOf(this.EVENT_PATH_PREFIX) > -1)
         {
            return param1.substring(this.EVENT_PATH_PREFIX.length,param1.length - 1);
         }
         return param1;
      }
      
      public function get labelString() : String
      {
         return this.type.name + " " + this.event;
      }
      
      override public function toString() : String
      {
         return this.type.name + " event=[" + this.event + "]";
      }
      
      public function addParam(param1:ConvoAudioParamDef) : void
      {
         if(!this.params)
         {
            this.params = new Vector.<ConvoAudioParamDef>();
         }
         this.params.push(param1);
      }
      
      public function removeParam(param1:int) : void
      {
         this.params.splice(param1,1);
      }
      
      public function setParamName(param1:int, param2:String) : void
      {
         this.params[param1].param = param2;
      }
      
      public function setParamValue(param1:int, param2:Number) : void
      {
         this.params[param1].value = param2;
      }
      
      public function get event() : String
      {
         return this._event;
      }
      
      public function set event(param1:String) : void
      {
         if(this._event == param1)
         {
            return;
         }
         this._event = param1;
         dispatchEvent(new Event(EVENT_LABEL));
      }
      
      public function get type() : ConvoAudioCmdType
      {
         return this._type;
      }
      
      public function set type(param1:ConvoAudioCmdType) : void
      {
         if(this._type == param1)
         {
            return;
         }
         this._type = param1;
         dispatchEvent(new Event(EVENT_LABEL));
      }
   }
}
