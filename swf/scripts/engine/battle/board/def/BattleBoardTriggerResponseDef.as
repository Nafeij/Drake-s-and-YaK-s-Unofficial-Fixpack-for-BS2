package engine.battle.board.def
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleBoardTriggerResponseDef extends EventDispatcher
   {
      
      public static var WITH_EVENTS:Boolean;
      
      public static const EVENT_PULSE:String = "BattleBoardTriggerResponseDef.EVENT_PULSE";
      
      public static const schema:Object = {
         "name":"BattleBoardTriggerResponseDef",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "optional":true
            },
            "ability":{
               "type":"string",
               "optional":true
            },
            "happening":{
               "type":"string",
               "optional":true
            },
            "pulse":{
               "type":"boolean",
               "optional":true
            },
            "triggeringEntityConditions":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "abilityId":{
               "type":"string",
               "optional":true
            },
            "hazard":{
               "type":"boolean",
               "optional":true
            },
            "useTileForAbility":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var ability:String;
      
      public var happening:String;
      
      private var _pulse:Boolean;
      
      public var triggeringEntityConditions:AbilityExecutionEntityConditions;
      
      public var abilityStringId:String;
      
      public var hazard:Boolean;
      
      public var useTileForAbility:Boolean;
      
      public var callback:Function;
      
      private var _lastAutoId:int = 0;
      
      public function BattleBoardTriggerResponseDef()
      {
         super();
      }
      
      public static function vctor() : *
      {
         return new Vector.<BattleBoardTriggerResponseDef>();
      }
      
      public function get pulse() : Boolean
      {
         return this._pulse;
      }
      
      public function set pulse(param1:Boolean) : void
      {
         if(this._pulse == param1)
         {
            return;
         }
         this._pulse = param1;
         if(WITH_EVENTS)
         {
            dispatchEvent(new Event(EVENT_PULSE));
         }
      }
      
      override public function toString() : String
      {
         var _loc1_:String = "";
         if(this.ability)
         {
            _loc1_ += " abl=" + this.ability;
         }
         if(this.happening)
         {
            _loc1_ += " hap=" + this.happening;
         }
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTriggerResponseDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.triggeringEntityConditions)
         {
            this.triggeringEntityConditions = new AbilityExecutionEntityConditions().fromJson(param1.triggeringEntityConditions,param2);
         }
         this.id = param1.id;
         this.hazard = param1.hazard;
         this.ability = param1.ability;
         this.pulse = param1.pulse;
         this.happening = param1.happening;
         this.abilityStringId = param1.abilityId;
         this.useTileForAbility = param1.useTileForAbility;
         if(!this.happening && !this.ability)
         {
            throw new ArgumentError("BattleBoardTriggerDef response with no ability or happening!");
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {"id":(!!this.id ? this.id : "")};
         if(this.ability)
         {
            _loc1_.ability = this.ability;
         }
         if(this.happening)
         {
            _loc1_.happening = this.happening;
         }
         if(this.pulse)
         {
            _loc1_.pulse = this.pulse;
         }
         if(this.triggeringEntityConditions)
         {
            _loc1_.triggeringEntityConditions = this.triggeringEntityConditions.save();
         }
         if(this.abilityStringId)
         {
            _loc1_.abilityId = this.abilityStringId;
         }
         if(this.hazard)
         {
            _loc1_.hazard = this.hazard;
         }
         if(this.useTileForAbility)
         {
            _loc1_.useTileForAbility = this.useTileForAbility;
         }
         return _loc1_;
      }
   }
}
