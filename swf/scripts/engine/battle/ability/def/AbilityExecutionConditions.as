package engine.battle.ability.def
{
   import engine.battle.ability.effect.def.AbilityReason;
   import engine.battle.ability.effect.def.EffectDefConditions;
   import engine.battle.ability.effect.def.EffectDefConditionsVars;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   
   public class AbilityExecutionConditions
   {
      
      public static const schema:Object = {
         "name":"AbilityExecutionConditions",
         "properties":{
            "caster":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "target":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "prereq":{
               "type":"string",
               "optional":true
            },
            "effects":{
               "type":"array",
               "items":EffectDefConditionsVars.schema,
               "optional":true
            },
            "levelMin":{
               "type":"number",
               "optional":true
            },
            "levelMax":{
               "type":"number",
               "optional":true
            },
            "minimumEnemies":{
               "type":"number",
               "optional":true
            },
            "maximumEnemies":{
               "type":"number",
               "optional":true
            },
            "requireUnpillaged":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static const empty:AbilityExecutionConditions = new AbilityExecutionConditions();
      
      public static const emptyJsonEverything:Object = empty.save(true);
       
      
      public var caster:AbilityExecutionEntityConditions;
      
      public var target:AbilityExecutionEntityConditions;
      
      public var effects:Vector.<EffectDefConditions>;
      
      public var levelMin:int;
      
      public var levelMax:int;
      
      public var minimumEnemies:int;
      
      public var maximumEnemies:int;
      
      public var requireUnpillaged:Boolean;
      
      public var prereq:String;
      
      public function AbilityExecutionConditions()
      {
         super();
      }
      
      public function checkExecutionConditions(param1:IBattleAbility, param2:IBattleAbilityDef, param3:IBattleEntity, param4:IBattleEntity, param5:ILogger, param6:Boolean) : BattleAbilityValidation
      {
         var _loc7_:BattleAbilityValidation = null;
         var _loc8_:ISaga = null;
         if(!param2 && Boolean(param1))
         {
            param2 = param1.def;
         }
         if(!param2)
         {
            throw new ArgumentError("no ability def");
         }
         if(this.prereq)
         {
            _loc8_ = SagaInstance.instance;
            if(_loc8_)
            {
               if(!_loc8_.expression.evaluate(this.prereq,false))
               {
                  return BattleAbilityValidation.SAGA_PREREQS;
               }
            }
         }
         if(!param3 && Boolean(param1))
         {
            param3 = param1.caster;
         }
         if(this.levelMin > 0 && param2.level < this.levelMin)
         {
            return BattleAbilityValidation.ABILITY_LEVEL_LOW;
         }
         if(this.levelMax > 0 && param2.level > this.levelMax)
         {
            return BattleAbilityValidation.ABILITY_LEVEL_HIGH;
         }
         if(Boolean(this.caster) && Boolean(param3))
         {
            if(!this.caster.checkExecutionConditions(param3,param5,param6))
            {
               return BattleAbilityValidation.INCORRECT_CASTER;
            }
         }
         if(Boolean(this.target) && Boolean(param4))
         {
            if(!this.target.checkExecutionConditions(param4,param5,param6))
            {
               return BattleAbilityValidation.INCORRECT_TARGET;
            }
         }
         if(!this.checkEffectConditions(param1,param5,null))
         {
            this.checkEffectConditions(param1,param5,null);
            return BattleAbilityValidation.INCORRECT_EFFECTS;
         }
         _loc7_ = this.checkPillage(param3);
         if(Boolean(_loc7_) && !_loc7_.ok)
         {
            return _loc7_;
         }
         if(param3)
         {
            _loc7_ = this.checkEnemyCountConditions(param3);
            if(Boolean(_loc7_) && !_loc7_.ok)
            {
               return _loc7_;
            }
         }
         return BattleAbilityValidation.OK;
      }
      
      public function checkPillage(param1:IBattleEntity) : BattleAbilityValidation
      {
         var _loc2_:IBattleBoard = null;
         var _loc3_:IBattleFsm = null;
         if(this.requireUnpillaged)
         {
            _loc2_ = param1.board;
            if(_loc2_)
            {
               _loc3_ = _loc2_.fsm;
               if(_loc3_)
               {
                  if(_loc3_.order.pillage)
                  {
                     return BattleAbilityValidation.PILLAGED;
                  }
               }
            }
         }
         return null;
      }
      
      public function checkEnemyCountConditions(param1:IBattleEntity) : BattleAbilityValidation
      {
         var _loc4_:int = 0;
         var _loc5_:IBattleParty = null;
         if(!this.minimumEnemies && !this.maximumEnemies)
         {
            return BattleAbilityValidation.OK;
         }
         var _loc2_:IBattleBoard = param1.board;
         var _loc3_:int = 0;
         if(_loc2_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.numParties)
            {
               _loc5_ = _loc2_.getParty(_loc4_);
               if(_loc5_.id != "prop")
               {
                  if(_loc5_ != param1.party)
                  {
                     _loc3_ += _loc5_.numAlive;
                     if(Boolean(this.maximumEnemies) && _loc3_ > this.maximumEnemies)
                     {
                        return BattleAbilityValidation.TOO_MANY_ENEMIES;
                     }
                  }
               }
               _loc4_++;
            }
         }
         if(this.minimumEnemies)
         {
            if(_loc3_ < this.minimumEnemies)
            {
               return BattleAbilityValidation.TOO_FEW_ENEMIES;
            }
         }
         return BattleAbilityValidation.OK;
      }
      
      private function checkEffectConditions(param1:IBattleAbility, param2:ILogger, param3:AbilityReason) : Boolean
      {
         var _loc4_:EffectDefConditions = null;
         var _loc5_:IEffect = null;
         if(this.effects)
         {
            if(!param1)
            {
               return true;
            }
            for each(_loc4_ in this.effects)
            {
               if(_loc4_.other)
               {
                  _loc5_ = param1.getEffectByName(_loc4_.other);
                  if(!_loc5_)
                  {
                     return false;
                  }
                  if(!_loc4_.checkEffectConditions(_loc5_,param2,param3))
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : AbilityExecutionConditions
      {
         var _loc3_:Object = null;
         var _loc4_:EffectDefConditions = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.caster)
         {
            this.caster = new AbilityExecutionEntityConditions().fromJson(param1.caster,param2);
         }
         if(param1.target)
         {
            this.target = new AbilityExecutionEntityConditions().fromJson(param1.target,param2);
         }
         if(param1.effects)
         {
            this.effects = new Vector.<EffectDefConditions>();
            for each(_loc3_ in param1.effects)
            {
               _loc4_ = new EffectDefConditionsVars(_loc3_,param2);
               this.effects.push(_loc4_);
            }
         }
         this.levelMin = param1.levelMin;
         this.levelMax = param1.levelMax;
         this.prereq = param1.prereq;
         this.minimumEnemies = param1.minimumEnemies;
         this.maximumEnemies = param1.maximumEnemies;
         this.requireUnpillaged = BooleanVars.parse(param1.requireUnpillaged,this.requireUnpillaged);
         return this;
      }
      
      public function save(param1:Boolean = false) : Object
      {
         var _loc2_:Object = {};
         if(this.requireUnpillaged || param1)
         {
            _loc2_.requireUnpillaged = this.requireUnpillaged;
         }
         if(Boolean(this.prereq) || param1)
         {
            _loc2_.prereq = !!this.prereq ? this.prereq : "";
         }
         if(this.caster)
         {
            _loc2_.caster = this.caster.save(param1);
         }
         else if(param1)
         {
            _loc2_.caster = AbilityExecutionEntityConditions.emptyJsonEverything;
         }
         if(this.target)
         {
            _loc2_.target = this.target.save(param1);
         }
         else if(param1)
         {
            _loc2_.target = AbilityExecutionEntityConditions.emptyJsonEverything;
         }
         if(Boolean(this.minimumEnemies) || param1)
         {
            _loc2_.minimumEnemies = this.minimumEnemies;
         }
         if(Boolean(this.maximumEnemies) || param1)
         {
            _loc2_.maximumEnemies = this.maximumEnemies;
         }
         return _loc2_;
      }
   }
}
