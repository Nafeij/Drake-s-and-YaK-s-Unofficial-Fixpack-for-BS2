package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.AbilityExecutionConditions;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IEffectTagProvider;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.ability.phantasm.def.ChainPhantasmsDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class EffectDef implements IEffectTagProvider, IEffectDef
   {
       
      
      protected var _phantasms:Vector.<ChainPhantasmsDef>;
      
      protected var _conditions:Vector.<EffectDefConditions>;
      
      protected var _persistent:EffectDefPersistence;
      
      protected var _ops:Vector.<EffectDefOp>;
      
      protected var _name:String;
      
      protected var _tags:Dictionary;
      
      protected var _targetCasterFirst:Boolean;
      
      protected var _targetCasterLast:Boolean;
      
      protected var _logger:ILogger;
      
      public var _executionConditions:AbilityExecutionConditions;
      
      protected var _noValidateAbility:Boolean;
      
      public var tag_vars:Array;
      
      public function EffectDef()
      {
         this._phantasms = new Vector.<ChainPhantasmsDef>();
         this._conditions = new Vector.<EffectDefConditions>();
         this._ops = new Vector.<EffectDefOp>();
         this._tags = new Dictionary();
         super();
      }
      
      public function hasTag(param1:EffectTag) : Boolean
      {
         return this.tags[param1] != null;
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function getChainPhantasmsForResult(param1:EffectResult) : ChainPhantasmsDef
      {
         var _loc2_:ChainPhantasmsDef = null;
         for each(_loc2_ in this.phantasms)
         {
            if(_loc2_.isResultOk(param1))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function link(param1:IBattleAbilityDefFactory) : void
      {
         var _loc2_:EffectDefOp = null;
         for each(_loc2_ in this.ops)
         {
            _loc2_.link(param1);
         }
         if(Boolean(this.persistent) && Boolean(this.persistent.expireAbility))
         {
            param1.fetch(this.persistent.expireAbility);
         }
      }
      
      public function get phantasms() : Vector.<ChainPhantasmsDef>
      {
         return this._phantasms;
      }
      
      public function get conditions() : Vector.<EffectDefConditions>
      {
         return this._conditions;
      }
      
      public function get persistent() : EffectDefPersistence
      {
         return this._persistent;
      }
      
      public function get ops() : Vector.<EffectDefOp>
      {
         return this._ops;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get tags() : Dictionary
      {
         return this._tags;
      }
      
      public function get targetCasterFirst() : Boolean
      {
         return this._targetCasterFirst;
      }
      
      public function get targetCasterLast() : Boolean
      {
         return this._targetCasterLast;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function get executionConditions() : AbilityExecutionConditions
      {
         return this._executionConditions;
      }
      
      public function checkEffectConditionsAbility(param1:IBattleAbility, param2:IBattleEntity, param3:Boolean, param4:AbilityReason) : Boolean
      {
         var _loc5_:IBattleAbilityDef = param1.def;
         var _loc6_:IBattleEntity = param1.caster;
         return this.checkEffectConditions(param1,_loc5_,_loc6_,param2,param3,param4);
      }
      
      public function checkEffectConditionsAbilityDef(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleEntity, param4:Boolean, param5:AbilityReason) : Boolean
      {
         return this.checkEffectConditions(null,param1,param2,param3,param4,param5);
      }
      
      public function checkEffectConditions(param1:IBattleAbility, param2:IBattleAbilityDef, param3:IBattleEntity, param4:IBattleEntity, param5:Boolean, param6:AbilityReason) : Boolean
      {
         var _loc7_:EffectDefConditions = null;
         var _loc8_:IEffect = null;
         var _loc9_:BattleAbilityValidation = null;
         var _loc10_:String = null;
         var _loc11_:TileRect = null;
         var _loc12_:TileRect = null;
         var _loc13_:String = null;
         if(param6)
         {
            param6.clear();
         }
         if(!param2)
         {
            throw new ArgumentError("No ability def");
         }
         if(!param3)
         {
            throw new ArgumentError("No caster");
         }
         if(this.conditions)
         {
            for each(_loc7_ in this.conditions)
            {
               if(_loc7_.other)
               {
                  _loc8_ = !!param1 ? param1.getEffectByName(_loc7_.other) : null;
                  if(!_loc8_)
                  {
                     AbilityReason.setMessage(param6,"effect condition [" + _loc7_ + "] requires other effect [" + _loc7_.other + "] which is missing from ability [" + param1 + "]");
                     return false;
                  }
                  if(!_loc7_.checkEffectConditions(_loc8_,this.logger,param6))
                  {
                     return false;
                  }
               }
               if(_loc7_.minLevel > param2.level)
               {
                  AbilityReason.setMessage(param6,"minlevel " + _loc7_.minLevel + " > " + param2.level);
                  return false;
               }
            }
         }
         if(this._executionConditions)
         {
            _loc9_ = this._executionConditions.checkExecutionConditions(param1,param2,param3,param4,this._logger,param5);
            if(!_loc9_ || !_loc9_.ok)
            {
               AbilityReason.setValid(param6,_loc9_);
               return false;
            }
            if(Boolean(param3) && Boolean(param4))
            {
               if(this._executionConditions.target)
               {
                  _loc10_ = this._executionConditions.target.visualAlignment;
                  if(_loc10_)
                  {
                     _loc11_ = param3.rect;
                     _loc12_ = param4.rect;
                     _loc13_ = this._findVisualAlignment(_loc11_,_loc12_);
                     if(_loc13_ != _loc10_)
                     {
                        AbilityReason.setMessage(param6,"visual_align");
                        return false;
                     }
                  }
                  if(!this._executionConditions.target.checkExecutionConditions(param4,this._logger,true))
                  {
                     AbilityReason.setMessage(param6,"target_cond");
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      private function _findVisualAlignment(param1:TileRect, param2:TileRect) : String
      {
         if(!param1 || !param1.facing || !param2)
         {
            return null;
         }
         switch(param1.facing)
         {
            case BattleFacing.NE:
               return param2.right <= param1.left ? "left" : (param2.left >= param1.right ? "right" : "center");
            case BattleFacing.NW:
               return param2.back <= param1.front ? "left" : (param2.front >= param1.back ? "right" : "center");
            case BattleFacing.SE:
               return param2.back <= param1.front ? "left" : (param2.front >= param1.back ? "right" : "center");
            case BattleFacing.SW:
               return param2.right <= param1.left ? "left" : (param2.left >= param1.right ? "right" : "center");
            default:
               return null;
         }
      }
      
      public function get noValidateAbility() : Boolean
      {
         return this._noValidateAbility;
      }
   }
}
