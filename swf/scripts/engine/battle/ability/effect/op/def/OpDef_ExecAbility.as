package engine.battle.ability.effect.op.def
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.entity.def.IAbilityAssetBundle;
   
   public class OpDef_ExecAbility extends EffectDefOp
   {
      
      public static const schema:Object = {
         "name":"OpDef_ExecAbility",
         "properties":{
            "ability":{"type":"string"},
            "responseTarget":{
               "type":"string",
               "optional":true
            },
            "responseTargetConditions":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "responseCaster":{
               "type":"string",
               "optional":true
            },
            "level":{
               "type":"number",
               "optional":true
            },
            "random":{
               "type":"array",
               "optional":true,
               "items":{"properties":{
                  "ability":{"type":"string"},
                  "weight":{"type":"number"},
                  "level":{
                     "type":"number",
                     "optional":true
                  },
                  "entityMustHaveAbility":{
                     "type":"boolean",
                     "optional":true
                  }
               }}
            },
            "execChild":{
               "type":"boolean",
               "optional":true
            },
            "excludeTargetFromRandom":{
               "type":"boolean",
               "optional":true
            },
            "mustHaveValidTargetToExecute":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var _ablDef:BattleAbilityDef;
      
      public var ablLevel:int = 1;
      
      public var randoms:Vector.<BattleAbilityDef>;
      
      public var weights:Vector.<Number>;
      
      public var mustHaveAbility:Vector.<Boolean>;
      
      public var totalWeight:Number = 0;
      
      public var responseTarget:BattleAbilityResponseTargetType;
      
      public var responseCaster:BattleAbilityResponseTargetType;
      
      public var execChild:Boolean = true;
      
      public var excludeTargetFromRandom:Boolean;
      
      public var mustHaveValidTargetToExecute:Boolean;
      
      public function OpDef_ExecAbility(param1:Object, param2:ILogger)
      {
         this.responseTarget = BattleAbilityResponseTargetType.TARGET;
         this.responseCaster = BattleAbilityResponseTargetType.CASTER;
         super();
         EffectDefOpVars.parse(this,param1,param2,schema);
         var _loc3_:String = param1.params.responseTarget;
         if(_loc3_)
         {
            this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,_loc3_) as BattleAbilityResponseTargetType;
         }
         var _loc4_:String = param1.params.responseCaster;
         if(_loc4_)
         {
            this.responseCaster = Enum.parse(BattleAbilityResponseTargetType,_loc4_) as BattleAbilityResponseTargetType;
         }
         if(param1.params.level != undefined)
         {
            this.ablLevel = param1.params.level;
         }
         this.execChild = BooleanVars.parse(param1.params.execChild,this.execChild);
         this.excludeTargetFromRandom = param1.params.excludeTargetFromRandom;
         this.mustHaveValidTargetToExecute = param1.params.mustHaveValidTargetToExecute;
      }
      
      override public function link(param1:IBattleAbilityDefFactory) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc6_:BattleAbilityDef = null;
         if(params.random != undefined)
         {
            this.randoms = new Vector.<BattleAbilityDef>();
            this.weights = new Vector.<Number>();
            this.mustHaveAbility = new Vector.<Boolean>();
            for each(_loc2_ in params.random)
            {
               _loc3_ = _loc2_.ability;
               _loc4_ = Number(_loc2_.weight);
               _loc5_ = Boolean(_loc2_.entityMustHaveAbility);
               _loc6_ = param1.fetchIBattleAbilityDef(_loc3_) as BattleAbilityDef;
               this.randoms.push(_loc6_);
               this.weights.push(_loc4_);
               this.mustHaveAbility.push(_loc5_);
               this.totalWeight += _loc4_;
            }
         }
         else
         {
            this._ablDef = param1.fetchIBattleAbilityDef(params.ability).getBattleAbilityDefLevel(this.ablLevel) as BattleAbilityDef;
         }
      }
      
      public function getAbility(param1:BattleAbilityManager, param2:IBattleEntity) : BattleAbilityDef
      {
         var _loc3_:Vector.<BattleAbilityDef> = null;
         var _loc4_:Vector.<Number> = null;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         if(this.randoms != null)
         {
            _loc3_ = new Vector.<BattleAbilityDef>();
            _loc4_ = new Vector.<Number>();
            _loc5_ = 0;
            _loc6_ = 0;
            while(_loc6_ < this.randoms.length)
            {
               if(!this.mustHaveAbility[_loc6_] || Boolean(param2.def.actives.hasAbility(this.randoms[_loc6_].id)) || Boolean(param2.def.attacks.hasAbility(this.randoms[_loc6_].id)))
               {
                  _loc3_.push(this.randoms[_loc6_]);
                  _loc4_.push(this.weights[_loc6_]);
                  _loc5_ += this.weights[_loc6_];
               }
               _loc6_++;
            }
            _loc7_ = param1.rng.nextNumber() * _loc5_;
            _loc8_ = 0;
            _loc9_ = 0;
            while(_loc9_ < _loc3_.length)
            {
               _loc8_ += _loc4_[_loc9_];
               if(_loc7_ <= _loc8_)
               {
                  return _loc3_[_loc9_];
               }
               _loc9_++;
            }
            return null;
         }
         return this._ablDef;
      }
      
      public function preloadAssets(param1:IAbilityAssetBundle) : void
      {
         var _loc2_:BattleAbilityDef = null;
         if(this._ablDef)
         {
            param1.preloadAbilityDef(this._ablDef);
         }
         if(this.randoms)
         {
            for each(_loc2_ in this.randoms)
            {
               param1.preloadAbilityDef(_loc2_);
            }
         }
      }
   }
}
