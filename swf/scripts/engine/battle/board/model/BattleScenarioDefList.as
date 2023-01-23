package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class BattleScenarioDefList
   {
      
      public static const schema:Object = {
         "name":"BattleScenarioDef",
         "type":"object",
         "properties":{"scenarios":{
            "type":"array",
            "items":BattleScenarioDef.schema
         }}
      };
       
      
      private var _defs:Vector.<BattleScenarioDef>;
      
      private var _defsById:Dictionary;
      
      public var url:String;
      
      public function BattleScenarioDefList()
      {
         this._defs = new Vector.<BattleScenarioDef>();
         this._defsById = new Dictionary();
         super();
      }
      
      public function add(param1:BattleScenarioDef) : void
      {
         this._defs.push(param1);
         this._defsById[param1.id] = param1;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleScenarioDefList
      {
         var _loc3_:Object = null;
         var _loc4_:BattleScenarioDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.scenarios)
         {
            _loc4_ = new BattleScenarioDef().fromJson(_loc3_,param2);
            this.add(_loc4_);
         }
         return this;
      }
      
      public function fetch(param1:String) : BattleScenarioDef
      {
         return this._defsById[param1];
      }
   }
}
