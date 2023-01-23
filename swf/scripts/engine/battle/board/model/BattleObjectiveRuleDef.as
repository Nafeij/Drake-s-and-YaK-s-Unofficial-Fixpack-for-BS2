package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class BattleObjectiveRuleDef
   {
      
      public static const schema:Object = {
         "name":"BattleObjectiveRuleDef",
         "type":"object",
         "properties":{
            "count":{
               "type":"number",
               "optional":true
            },
            "disabled":{
               "type":"boolean",
               "optional":true
            },
            "negate":{
               "type":"boolean",
               "optional":true
            },
            "type":{"type":"string"},
            "params":{
               "type":{},
               "optional":true,
               "skip":true
            }
         }
      };
       
      
      public var negate:Boolean;
      
      public var type:BattleObjectiveRuleType;
      
      public var subdef:Object;
      
      public var count:int;
      
      public var disabled:Boolean;
      
      public function BattleObjectiveRuleDef()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.type.name;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleObjectiveRuleDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.count = param1.count;
         this.type = Enum.parse(BattleObjectiveRuleType,param1.type) as BattleObjectiveRuleType;
         this.negate = BooleanVars.parse(param1.negate,this.negate);
         this.disabled = param1.disabled;
         var _loc3_:Function = this.type.clazz["fromJson"];
         if(_loc3_ != null)
         {
            this.subdef = _loc3_(param1.params,param2);
         }
         return this;
      }
      
      public function createObjectiveRule(param1:BattleObjective) : BattleObjectiveRule
      {
         if(this.disabled)
         {
            return null;
         }
         return this.type.ctor(param1,this);
      }
   }
}
