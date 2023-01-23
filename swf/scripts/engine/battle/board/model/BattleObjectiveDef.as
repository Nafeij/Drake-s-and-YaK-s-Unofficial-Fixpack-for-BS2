package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class BattleObjectiveDef
   {
      
      public static const schema:Object = {
         "name":"BattleObjectiveDef",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "optional":true
            },
            "token":{"type":"string"},
            "count":{
               "type":"number",
               "optional":true
            },
            "rules":{
               "type":"array",
               "items":BattleObjectiveRuleDef.schema,
               "optional":true
            },
            "rule":{
               "type":BattleObjectiveRuleDef.schema,
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
            "requiredPlayerUnits":{
               "type":"array",
               "optional":true
            },
            "requiredObjectivesIncomplete":{
               "type":"array",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var token:String;
      
      public var negate:Boolean;
      
      public var requiredPlayerUnits:Array;
      
      public var requiredPlayerUnitsDict:Dictionary;
      
      public var requiredObjectivesIncomplete:Array;
      
      public var requiredObjectivesIncompleteDict:Dictionary;
      
      public var disabled:Boolean;
      
      public var rules:Vector.<BattleObjectiveRuleDef>;
      
      public var count:int;
      
      public var scenarioDef:BattleScenarioDef;
      
      public function BattleObjectiveDef(param1:BattleScenarioDef)
      {
         this.rules = new Vector.<BattleObjectiveRuleDef>();
         super();
         this.scenarioDef = param1;
      }
      
      public function toString() : String
      {
         return "" + this.id + "/" + this.token;
      }
      
      public function createObjective(param1:BattleScenario) : BattleObjective
      {
         if(this.disabled)
         {
            return null;
         }
         return new BattleObjective(param1,this,null,param1.saga);
      }
      
      public function createHint(param1:BattleScenario) : BattleObjective
      {
         if(this.disabled)
         {
            return null;
         }
         var _loc2_:BattleObjective = new BattleObjective(param1,this,null,param1.saga);
         _loc2_.hint = true;
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleObjectiveDef
      {
         var s:String = null;
         var o:Object = null;
         var json:Object = param1;
         var logger:ILogger = param2;
         EngineJsonDef.validateThrow(json,schema,logger);
         this.count = json.count;
         this.id = json.id;
         this.negate = BooleanVars.parse(json.negate,this.negate);
         this.token = json.token;
         this.requiredPlayerUnits = json.requiredPlayerUnits;
         this.requiredObjectivesIncomplete = json.requiredObjectivesIncomplete;
         this.disabled = json.disabled;
         if(this.requiredPlayerUnits)
         {
            this.requiredPlayerUnitsDict = new Dictionary();
            for each(s in this.requiredPlayerUnits)
            {
               this.requiredPlayerUnitsDict[s] = true;
            }
         }
         if(this.requiredObjectivesIncomplete)
         {
            this.requiredObjectivesIncompleteDict = new Dictionary();
            for each(s in this.requiredObjectivesIncomplete)
            {
               this.requiredObjectivesIncompleteDict[s] = true;
            }
         }
         try
         {
            if(json.rule)
            {
               this.rules.push(new BattleObjectiveRuleDef().fromJson(json.rule,logger));
            }
            if(json.rules)
            {
               for each(o in json.rules)
               {
                  this.rules.push(new BattleObjectiveRuleDef().fromJson(o,logger));
               }
            }
         }
         catch(e:Error)
         {
            throw new ArgumentError("Failed to parse objective rule for " + this + ", scenario " + scenarioDef);
         }
         if(this.rules.length == 0)
         {
            throw new ArgumentError("no rules");
         }
         return this;
      }
      
      public function setToken(param1:String) : BattleObjectiveDef
      {
         this.token = param1;
         return this;
      }
   }
}
