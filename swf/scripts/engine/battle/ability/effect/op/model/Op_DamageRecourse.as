package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.BoxInt;
   import engine.core.util.Enum;
   import engine.stat.def.StatType;
   
   public class Op_DamageRecourse extends Op implements IOp_DamageRecourse
   {
      
      public static const schema:Object = {
         "name":"Op_DamageRecourse",
         "properties":{
            "stats":{
               "type":"array",
               "items":"string"
            },
            "recourseMult":{"type":"number"},
            "onRecourseAbility":{
               "type":"string",
               "optional":true
            },
            "recoursePercent":{"type":"number"}
         }
      };
       
      
      protected var _recourseMult:Number = 1;
      
      protected var _recoursePercent:Number = 1;
      
      protected var _statsToRecourse:Vector.<StatType>;
      
      protected var _onRecourseAbility:IBattleAbilityDef = null;
      
      public function Op_DamageRecourse(param1:EffectDefOp, param2:Effect)
      {
         var _loc4_:int = 0;
         var _loc5_:StatType = null;
         super(param1,param2);
         this._recourseMult = param1.params.recourseMult;
         this._recoursePercent = param1.params.recoursePercent;
         if(param1.params.onRecourseAbility)
         {
            this._onRecourseAbility = manager.getFactory.fetchIBattleAbilityDef(param1.params.onRecourseAbility,true);
         }
         var _loc3_:Array = param1.params.stats;
         if(_loc3_)
         {
            this._statsToRecourse = new Vector.<StatType>();
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = Enum.parse(StatType,_loc3_[_loc4_]) as StatType;
               if(_loc5_)
               {
                  this._statsToRecourse.push(_loc5_);
               }
               _loc4_++;
            }
         }
      }
      
      public static function processDamageRecourse(param1:IBattleEntity, param2:int, param3:StatType, param4:Effect, param5:Boolean = false) : int
      {
         var _loc7_:IBattleEntity = null;
         var _loc8_:Effect = null;
         var _loc9_:Op = null;
         var _loc10_:IOp_DamageRecourse = null;
         if(param2 >= 0)
         {
            return param2;
         }
         var _loc6_:IBattleBoard = param1.board;
         for each(_loc7_ in _loc6_.entities)
         {
            if(_loc7_ != param1)
            {
               if(_loc7_.effects)
               {
                  for each(_loc8_ in _loc7_.effects.effects)
                  {
                     if(_loc8_.ability.caster == param1)
                     {
                        if(_loc8_.ops)
                        {
                           for each(_loc9_ in _loc8_.ops)
                           {
                              _loc10_ = _loc9_ as IOp_DamageRecourse;
                              if(_loc10_)
                              {
                                 return _loc10_.executeStatRecourse(_loc7_,param1,param2,param3,param4,param5);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         return param2;
      }
      
      public function get statsRecoursed() : Vector.<StatType>
      {
         return this._statsToRecourse.concat();
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      protected function doOnRecourseAbility(param1:IBattleEntity, param2:IBattleEntity) : void
      {
         if(ability.fake || manager.faking || !this._onRecourseAbility)
         {
            return;
         }
         var _loc3_:BattleAbility = new BattleAbility(param2,this._onRecourseAbility,manager);
         _loc3_.targetSet.setTarget(param1);
         _loc3_.execute(null);
      }
      
      public function executeStatRecourse(param1:IBattleEntity, param2:IBattleEntity, param3:int, param4:StatType, param5:Effect, param6:Boolean = false) : int
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(!this._statsToRecourse || !param4 || !this._recoursePercent)
         {
            return param3;
         }
         var _loc7_:int = 0;
         while(_loc7_ < this._statsToRecourse.length)
         {
            if(param4 == this._statsToRecourse[_loc7_])
            {
               _loc8_ = Math.round(param3 * this._recoursePercent * this._recourseMult);
               if(!param6)
               {
                  if(param4 == StatType.STRENGTH)
                  {
                     _loc9_ = _loc8_;
                     _loc8_ = -Op_DamageStr.computeArmorAbsorb(param1,param5,-_loc8_,new BoxInt(0));
                     _loc9_ -= _loc8_;
                     param1.stats.getStat(StatType.ARMOR).base = Math.max(0,param1.stats.getStat(StatType.ARMOR).base + _loc9_);
                  }
                  param1.stats.getStat(param4).base = param1.stats.getStat(param4).base + _loc8_;
                  this.doOnRecourseAbility(param1,param2);
               }
               return Math.round(param3 * (1 - this._recoursePercent));
            }
            _loc7_++;
         }
         return param3;
      }
   }
}
