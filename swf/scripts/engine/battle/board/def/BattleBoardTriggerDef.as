package engine.battle.board.def
{
   import engine.battle.ability.phantasm.def.VfxSequenceDef;
   import engine.battle.ability.phantasm.def.VfxSequenceDefs;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.vfx.VfxLibrary;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleBoardTriggerDef extends EventDispatcher implements ITileTriggerDef
   {
      
      public static var WITH_EVENTS:Boolean;
      
      public static const EVENT_PULSE:String = "BattleBoardTriggerDef.EVENT_PULSE";
      
      public static const schema:Object = {
         "name":"BattleBoardTriggerDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "tileIconUrl":{
               "type":"string",
               "optional":true
            },
            "stringId":{
               "type":"string",
               "optional":true
            },
            "vfxds":{
               "type":"array",
               "items":VfxSequenceDef.schema,
               "optional":true
            },
            "disabled":{
               "type":"boolean",
               "optional":true
            },
            "responses":{
               "type":"array",
               "items":BattleBoardTriggerResponseDef.schema,
               "optional":true
            },
            "limit":{
               "type":"number",
               "optional":true
            },
            "incorporeal":{
               "type":"boolean",
               "optional":true
            },
            "incorporealFadeAlpha":{
               "type":"number",
               "optional":true
            },
            "ignoreIncorporealOnFadeIn":{
               "type":"boolean",
               "optional":true
            },
            "duration":{
               "type":"number",
               "optional":true
            },
            "checkTriggerOnEnable":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static var DEFAULT_INCORPOREAL_FADE_ALPHA:Number = 0.3;
       
      
      public var _id:String;
      
      public var tileIconUrl:String;
      
      public var stringId:String;
      
      public var visible:Boolean = true;
      
      public var vfxds:VfxSequenceDefs;
      
      public var responses:BattleBoardTriggerResponseDefs;
      
      public var limit:int = 0;
      
      public var incorporeal:Boolean;
      
      public var incorporealFadeAlpha:Number;
      
      public var ignoreIncorporealOnFadeIn:Boolean = false;
      
      public var duration:int = 0;
      
      private var _checkTriggerOnEnable:Boolean = false;
      
      public var vfxLibrary:VfxLibrary;
      
      public var triggerDefs:BattleBoardTriggerDefList;
      
      public function BattleBoardTriggerDef()
      {
         this.incorporealFadeAlpha = DEFAULT_INCORPOREAL_FADE_ALPHA;
         super();
      }
      
      public static function vctor() : *
      {
         return new Vector.<BattleBoardTriggerDef>();
      }
      
      public function get checkTriggerOnEnable() : Boolean
      {
         return this._checkTriggerOnEnable;
      }
      
      public function set checkTriggerOnEnable(param1:Boolean) : void
      {
         if(this._checkTriggerOnEnable && !param1)
         {
            this.duration = this.duration;
         }
         this._checkTriggerOnEnable = param1;
      }
      
      public function copyFromShallow(param1:BattleBoardTriggerDef) : BattleBoardTriggerDef
      {
         this.id = param1.id;
         this.visible = param1.visible;
         this.stringId = param1.stringId;
         this.tileIconUrl = param1.tileIconUrl;
         this.limit = param1.limit;
         this.duration = param1.duration;
         this.checkTriggerOnEnable = param1.checkTriggerOnEnable;
         return this;
      }
      
      public function clone() : BattleBoardTriggerDef
      {
         return new BattleBoardTriggerDef().fromJson(this.toJson(),null);
      }
      
      public function ensureVfxSequenceDefs() : void
      {
         if(!this.vfxds)
         {
            this.vfxds = new VfxSequenceDefs();
         }
      }
      
      public function ensureResponseDefs() : void
      {
         if(!this.responses)
         {
            this.responses = new BattleBoardTriggerResponseDefs();
            if(WITH_EVENTS)
            {
               this.responses.addEventListener(BattleBoardTriggerResponseDefs.EVENT_PULSE,this.pulseHandler);
            }
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      override public function toString() : String
      {
         var _loc1_:String = "";
         _loc1_ += this._id + " ";
         return _loc1_ + this.responses;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTriggerDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this._id = param1.id;
         if(param1.responses)
         {
            this.responses = new BattleBoardTriggerResponseDefs().fromJson(param1.responses,param2);
            if(WITH_EVENTS)
            {
               this.responses.addEventListener(BattleBoardTriggerResponseDefs.EVENT_PULSE,this.pulseHandler);
            }
         }
         this.incorporeal = param1.incorporeal;
         this.tileIconUrl = param1.tileIconUrl;
         this.stringId = param1.stringId;
         if(param1.hasOwnProperty("duration"))
         {
            this.duration = param1.duration;
         }
         if(param1.incorporealFadeAlpha != undefined)
         {
            this.incorporealFadeAlpha = param1.incorporealFadeAlpha;
         }
         if(param1.ignoreIncorporealOnFadeIn != undefined)
         {
            this.ignoreIncorporealOnFadeIn = param1.incorporealOnFadeIn;
         }
         if(param1.checkTriggerOnEnable != undefined)
         {
            this.checkTriggerOnEnable = param1.checkTriggerOnEnable;
         }
         if(param1.vfxds)
         {
            this.vfxds = new VfxSequenceDefs().fromJson(param1.vfxds,param2);
         }
         if(param1.limit)
         {
            this.limit = param1.limit;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {"id":this.id};
         if(this.incorporealFadeAlpha != DEFAULT_INCORPOREAL_FADE_ALPHA)
         {
            _loc1_.incorporealFadeAlpha = this.incorporealFadeAlpha;
         }
         if(this.incorporeal)
         {
            _loc1_.incorporeal = this.incorporeal;
         }
         if(this.tileIconUrl)
         {
            _loc1_.tileIconUrl = this.tileIconUrl;
         }
         if(this.stringId)
         {
            _loc1_.stringId = this.stringId;
         }
         if(Boolean(this.vfxds) && this.vfxds.hasVfxds)
         {
            _loc1_.vfxds = this.vfxds.toJson();
         }
         if(Boolean(this.responses) && this.responses.hasResponseDefs)
         {
            _loc1_.responses = this.responses.toJson();
         }
         if(Boolean(this.limit) && this.limit != 0)
         {
            _loc1_.limit = this.limit;
         }
         if(this.duration > 0)
         {
            _loc1_.duration = this.duration;
         }
         if(this.ignoreIncorporealOnFadeIn)
         {
            _loc1_.ignoreIncorporealOnFadeIn = this.ignoreIncorporealOnFadeIn;
         }
         if(this.checkTriggerOnEnable)
         {
            _loc1_.checkTriggerOnEnable = this.checkTriggerOnEnable;
         }
         return _loc1_;
      }
      
      public function get pulse() : Boolean
      {
         return Boolean(this.responses) && this.responses.pulse;
      }
      
      public function addResponse(param1:BattleBoardTriggerResponseDef) : void
      {
         this.ensureResponseDefs();
         this.responses.addResponse(param1);
      }
      
      public function removeResponse(param1:BattleBoardTriggerResponseDef) : void
      {
         this.responses.removeResponse(param1);
      }
      
      private function pulseHandler(param1:Event) : void
      {
         dispatchEvent(new Event(EVENT_PULSE));
      }
   }
}
