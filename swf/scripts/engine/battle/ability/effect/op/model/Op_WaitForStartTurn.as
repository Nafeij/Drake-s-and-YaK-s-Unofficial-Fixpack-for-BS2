package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityAiTargetRuleType;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.BattleBoard_SpatialUtil;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.entity.def.IAbilityAssetBundle;
   import flash.utils.Dictionary;
   
   public class Op_WaitForStartTurn extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForStartTurn",
         "properties":{
            "ability":{"type":"string"},
            "abort":{
               "type":"string",
               "optional":true
            },
            "responseTarget":{"type":"string"},
            "responseCaster":{
               "type":"string",
               "optional":true
            },
            "responseLevel":{
               "type":"number",
               "optional":true
            },
            "mustOwnAbility":{"type":"boolean"}
         }
      };
       
      
      private var ablDef:BattleAbilityDef;
      
      private var abort:BattleAbilityDef;
      
      private var responseTarget:BattleAbilityResponseTargetType;
      
      private var _responseCaster:BattleAbilityResponseTargetType;
      
      private var mustOwnAbility:Boolean;
      
      private var responseLevel:int;
      
      public function Op_WaitForStartTurn(param1:EffectDefOp, param2:Effect)
      {
         var _loc3_:BattleAbilityDef = null;
         super(param1,param2);
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         if(param1.params.abort)
         {
            this.abort = manager.factory.fetchBattleAbilityDef(param1.params.abort);
            if(this.abort.targetRule != BattleAbilityTargetRule.NONE)
            {
               logger.error("Op_WaitForStartTurn abort target rule must be NONE");
               this.abort = null;
            }
         }
         if(param1.params.responseCaster)
         {
            this._responseCaster = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseCaster) as BattleAbilityResponseTargetType;
         }
         else
         {
            this._responseCaster = BattleAbilityResponseTargetType.TARGET;
         }
         if(param1.params.responseLevel)
         {
            this.responseLevel = param1.params.responseLevel;
            _loc3_ = this.ablDef.root.getAbilityDefForLevel(this.responseLevel) as BattleAbilityDef;
            if(!_loc3_)
            {
               logger.error("Op_WaitforStartTurn invalid level " + this.responseLevel + " for " + this.ablDef);
            }
            else
            {
               this.ablDef = _loc3_;
            }
         }
         this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTarget) as BattleAbilityResponseTargetType;
         this.mustOwnAbility = param1.params.mustOwnAbility;
      }
      
      public static function preloadAssets(param1:EffectDefOp, param2:IAbilityAssetBundle) : void
      {
         var _loc3_:String = param1.params.ability;
         if(!_loc3_)
         {
            param2.logger.error("No id on spawn op? " + param1);
         }
         else
         {
            param2.preloadAbilityDefById(_loc3_);
         }
      }
      
      override public function targetStartTurn() : Boolean
      {
         if(this.mustOwnAbility)
         {
            if(!target.def.actives || !target.def.actives.hasAbility(this.ablDef.id) && !target.def.attacks.hasAbility(this.ablDef.id))
            {
               manager.logger.info("Target " + target + " does not have ability " + this.ablDef + ", skipping");
               return true;
            }
         }
         var _loc1_:IBattleEntity = target;
         switch(this._responseCaster)
         {
            case BattleAbilityResponseTargetType.TARGET:
               _loc1_ = target;
               break;
            case BattleAbilityResponseTargetType.CASTER:
               _loc1_ = caster;
         }
         var _loc2_:BattleAbility = new BattleAbility(_loc1_,this.ablDef,manager);
         if(this.responseTarget == BattleAbilityResponseTargetType.SELF || this.responseTarget == BattleAbilityResponseTargetType.TARGET)
         {
            if(this.ablDef.targetRule == BattleAbilityTargetRule.ALL_ALLIES)
            {
               this._collectAllAlliesOf(_loc2_,target);
            }
            else
            {
               _loc2_.targetSet.setTarget(target);
            }
         }
         else if(this.responseTarget == BattleAbilityResponseTargetType.CASTER)
         {
            if(this.ablDef.targetRule == BattleAbilityTargetRule.ALL_ALLIES)
            {
               this._collectAllAlliesOf(_loc2_,caster);
            }
            else
            {
               _loc2_.targetSet.setTarget(caster);
            }
         }
         if(this.ablDef.targetRule == BattleAbilityTargetRule.ALL_ALLIES)
         {
            if(_loc2_.targetSet.targets.length == 0)
            {
               if(this.abort)
               {
                  _loc2_ = new BattleAbility(caster,this.abort,manager);
                  _loc2_.execute(null);
                  return true;
               }
               return false;
            }
         }
         _loc2_.execute(null);
         return true;
      }
      
      private function _collectAllAlliesOf(param1:IBattleAbility, param2:IBattleEntity) : void
      {
         var _loc5_:IBattleEntity = null;
         var _loc3_:Dictionary = caster.board.entities;
         var _loc4_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         for each(_loc5_ in _loc3_)
         {
            if(_loc5_ != param2 && _loc5_.team == param2.team && _loc5_.alive)
            {
               if(this.ablDef.checkTargetStatRanges(_loc5_.stats))
               {
                  if(this.ablDef.aiTargetRule == BattleAbilityAiTargetRuleType.TILE_MAX_ADJACENT_ENEMY)
                  {
                     if(!BattleBoard_SpatialUtil.checkAdjacentEnemies(_loc5_,_loc4_,true))
                     {
                        continue;
                     }
                  }
                  param1.targetSet.addTarget(_loc5_);
               }
            }
         }
      }
   }
}
