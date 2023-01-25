package engine.landscape.def
{
   import engine.ability.def.StringNumberPair;
   import engine.core.logging.ILogger;
   import engine.core.util.UtilFunctions;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodeSoundDef extends AnimPathNodeDef
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeSoundDef",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "sound_url":{"type":"string"},
            "transcendent":{
               "type":"boolean",
               "optional":true
            },
            "params":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var soundUrl:String;
      
      public var transcendent:Boolean;
      
      public var params:Vector.<StringNumberPair>;
      
      public function AnimPathNodeSoundDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : AnimPathNodeSoundDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.startTimeSecs = param1.start_secs;
         this.soundUrl = param1.sound_url;
         this.transcendent = param1.transcendent;
         this._parseJsonParams(param1.params);
         return this;
      }
      
      private function _parseJsonParams(param1:Object) : void
      {
         var _loc5_:String = null;
         var _loc6_:StringNumberPair = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:String = param1 as String;
         var _loc3_:Array = _loc2_.split(",");
         if(!_loc3_ || _loc3_.length == 0)
         {
            return;
         }
         this.params = new Vector.<StringNumberPair>(_loc3_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = String(_loc3_[_loc4_]);
            _loc6_ = new StringNumberPair().parseString(_loc5_,0,"=");
            this.params[_loc4_] = _loc6_;
            _loc4_++;
         }
      }
      
      public function save() : Object
      {
         var _loc1_:Object = {
            "type":AnimPathType.SOUND.name,
            "start_secs":UtilFunctions.safety(this.startTimeSecs),
            "sound_url":this.soundUrl,
            "transcendent":this.transcendent
         };
         if(Boolean(this.params) && Boolean(this.params.length))
         {
            _loc1_.params = this.params.join(",");
         }
         return _loc1_;
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": SOUND " + this.soundUrl;
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeSoundDef = new AnimPathNodeSoundDef();
         _loc1_.copyFromBase(this);
         _loc1_.soundUrl = this.soundUrl;
         _loc1_.transcendent = this.transcendent;
         return _loc1_;
      }
   }
}
