package engine.battle.board.def
{
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.NumberVars;
   import flash.errors.IllegalOperationError;
   
   public class UsabilityDef
   {
      
      public static const schema:Object = {
         "name":"BattleSpawnerDefVars",
         "properties":{
            "ability":{
               "type":"string",
               "optional":true
            },
            "happening":{
               "type":"string",
               "optional":true
            },
            "responseCaster":{
               "type":"string",
               "optional":true
            },
            "responseTarget":{
               "type":"string",
               "optional":true
            },
            "range":{
               "type":"number",
               "optional":true
            },
            "isAction":{
               "type":"boolean",
               "optional":true
            },
            "limit":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var happening:String;
      
      public var abilityId:String;
      
      public var responseCasterRule:BattleAbilityResponseTargetType;
      
      public var responseTargetRule:BattleAbilityResponseTargetType;
      
      public var range:int = 1;
      
      public var isAction:Boolean;
      
      public var limit:int = 0;
      
      public function UsabilityDef()
      {
         this.responseCasterRule = BattleAbilityResponseTargetType.SELF;
         this.responseTargetRule = BattleAbilityResponseTargetType.OTHER;
         super();
      }
      
      public function toString() : String
      {
         return this.abilityId + " " + this.responseCasterRule + " " + this.responseTargetRule + " " + this.range + " " + this.isAction + " " + this.limit;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : UsabilityDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.abilityId = param1.ability;
         this.happening = param1.happening;
         if(!this.abilityId && !this.happening)
         {
            throw new IllegalOperationError("UsabilityDef must contain either an abilityId or a happening (or both), otherwise what\'s it for");
         }
         if(param1.responseCaster)
         {
            this.responseCasterRule = Enum.parse(BattleAbilityResponseTargetType,param1.responseCaster) as BattleAbilityResponseTargetType;
         }
         if(param1.responseTarget)
         {
            this.responseTargetRule = Enum.parse(BattleAbilityResponseTargetType,param1.responseTarget) as BattleAbilityResponseTargetType;
         }
         this.range = NumberVars.parse(param1.range,this.range);
         this.limit = NumberVars.parse(param1.limit,this.limit);
         this.isAction = BooleanVars.parse(param1.isAction,this.isAction);
         return this;
      }
      
      public function save() : Object
      {
         var _loc1_:Object = {};
         if(this.abilityId)
         {
            _loc1_.ability = this.abilityId;
         }
         if(this.happening)
         {
            _loc1_.happening = this.happening;
         }
         if(this.responseCasterRule != BattleAbilityResponseTargetType.SELF)
         {
            _loc1_.responseCaster = this.responseCasterRule.name;
         }
         if(this.responseTargetRule != BattleAbilityResponseTargetType.OTHER)
         {
            _loc1_.responseTarget = this.responseTargetRule.name;
         }
         if(this.range != 1)
         {
            _loc1_.range = this.range;
         }
         if(this.isAction)
         {
            _loc1_.isAction = this.isAction;
         }
         if(this.limit)
         {
            _loc1_.limit = this.limit;
         }
         return _loc1_;
      }
      
      public function clone() : UsabilityDef
      {
         var _loc1_:UsabilityDef = new UsabilityDef();
         _loc1_.abilityId = this.abilityId;
         _loc1_.happening = this.happening;
         _loc1_.responseCasterRule = this.responseCasterRule;
         _loc1_.responseTargetRule = this.responseTargetRule;
         _loc1_.range = this.range;
         _loc1_.isAction = this.isAction;
         _loc1_.limit = this.limit;
         return _loc1_;
      }
   }
}
