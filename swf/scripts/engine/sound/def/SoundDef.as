package engine.sound.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class SoundDef implements ISoundDef
   {
      
      public static const schema:Object = {
         "name":"SoundDef",
         "type":"object",
         "properties":{
            "sku":{
               "type":"string",
               "optional":true
            },
            "soundName":{"type":"string"},
            "eventName":{"type":"string"},
            "groupName":{
               "type":"string",
               "optional":true
            },
            "isStream":{
               "type":"boolean",
               "optional":true
            },
            "parameters":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "parameter_values":{
               "type":"array",
               "optional":true,
               "items":{"properties":{
                  "parameter":{"type":"string"},
                  "value":{"type":"number"}
               }}
            }
         }
      };
       
      
      protected var _soundName:String;
      
      protected var _eventName:String;
      
      protected var _isStream:Boolean;
      
      protected var _sku:String;
      
      protected var _allowDuplicateSounds:Boolean;
      
      private var parameters:Vector.<String>;
      
      private var parameterSet:Dictionary;
      
      public var parameter_values:Dictionary;
      
      public function SoundDef()
      {
         this.parameter_values = new Dictionary();
         super();
      }
      
      public static function save(param1:SoundDef) : Object
      {
         var _loc2_:Object = {};
         _loc2_.soundName = param1.soundName;
         _loc2_.eventName = param1.eventName;
         if(param1.isStream)
         {
            _loc2_.isStream = param1.isStream;
         }
         return _loc2_;
      }
      
      public function setup(param1:String, param2:String, param3:String, param4:Boolean = false) : SoundDef
      {
         this._soundName = param2;
         this._sku = param1;
         this._eventName = param3;
         this._allowDuplicateSounds = param4;
         return this;
      }
      
      public function fromJson(param1:String, param2:Object, param3:ILogger) : SoundDef
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         this._sku = param1;
         EngineJsonDef.validateThrow(param2,schema,param3);
         this._soundName = param2.soundName;
         this._eventName = param2.eventName;
         this._isStream = !!param2.isStream ? true : false;
         if(param2.sku)
         {
            this._sku = param1;
         }
         if(param2.parameters != undefined)
         {
            this.parameters = new Vector.<String>();
            this.parameterSet = new Dictionary();
            for each(_loc4_ in param2.parameters)
            {
               this.parameters.push(_loc4_);
               this.parameterSet[_loc4_] = _loc4_;
            }
         }
         if(param2.parameter_values != undefined)
         {
            for each(_loc5_ in param2.parameter_values)
            {
               this.parameter_values[_loc5_.parameter] = _loc5_.value;
            }
         }
         return this;
      }
      
      public function toString() : String
      {
         return "[" + this._sku + "]" + this._soundName + ":(" + this._eventName + ")";
      }
      
      public function get soundName() : String
      {
         return this._soundName;
      }
      
      public function get sku() : String
      {
         return this._sku;
      }
      
      public function get eventName() : String
      {
         return this._eventName;
      }
      
      public function get isStream() : Boolean
      {
         return this._isStream;
      }
      
      public function get debugString() : String
      {
         return this.soundName + ":" + this.eventName;
      }
      
      public function get allowDuplicateSounds() : Boolean
      {
         return this._allowDuplicateSounds;
      }
      
      public function hasParameter(param1:String) : Boolean
      {
         return Boolean(this.parameterSet) && param1 in this.parameterSet;
      }
      
      public function hasParameterValue(param1:String) : Boolean
      {
         return param1 in this.parameter_values;
      }
      
      public function getParameterValue(param1:String) : Number
      {
         return this.parameter_values[param1];
      }
      
      public function get parameterValues() : Dictionary
      {
         return this.parameter_values;
      }
      
      public function updateSku(param1:String) : void
      {
         if(this._sku)
         {
            throw new IllegalOperationError("do not change sku");
         }
         this._sku = param1;
      }
   }
}
