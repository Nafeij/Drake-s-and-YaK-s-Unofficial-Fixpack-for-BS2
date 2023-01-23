package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.tile.def.TileRect;
   
   public class Op_Needle extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_Needle",
         "properties":{
            "ability":{"type":"string"},
            "entityMustHaveAbility":{
               "type":"boolean",
               "optional":true
            },
            "abilityCaster":{
               "type":"string",
               "optional":true
            },
            "abilityTarget":{
               "type":"string",
               "optional":true
            },
            "aoeTargetOtherRule":{
               "type":"string",
               "optional":true
            },
            "aoeCasterOtherRule":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var distance:Number;
      
      public var entityMustHaveAbility:Boolean;
      
      public var abilityEntityDef:BattleAbilityDef;
      
      public var abilityTileDef:BattleAbilityDef;
      
      public var abilityCaster:BattleAbilityResponseTargetType;
      
      public var abilityTarget:BattleAbilityResponseTargetType;
      
      public var aoeCasterOtherRule:BattleAbilityTargetRule;
      
      public function Op_Needle(param1:EffectDefOp, param2:Effect)
      {
         var _loc4_:BattleAbilityDef = null;
         var _loc5_:BattleAbilityDef = null;
         this.abilityCaster = BattleAbilityResponseTargetType.TARGET;
         this.abilityTarget = BattleAbilityResponseTargetType.TARGET;
         this.aoeCasterOtherRule = BattleAbilityTargetRule.ANY;
         super(param1,param2);
         var _loc3_:BattleAbilityDefFactory = manager.factory;
         if(param1.params.abilityCaster)
         {
            this.abilityCaster = Enum.parse(BattleAbilityResponseTargetType,param1.params.abilityCaster) as BattleAbilityResponseTargetType;
         }
         if(param1.params.abilityTarget != undefined)
         {
            this.abilityTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.abilityTarget) as BattleAbilityResponseTargetType;
         }
         if(param1.params.abilityEntity)
         {
            _loc4_ = _loc3_.fetchBattleAbilityDef(param1.params.abilityEntity);
            this.abilityEntityDef = _loc4_.getAbilityDefForLevel(param2.ability.def.level) as BattleAbilityDef;
         }
         if(param1.params.abilityTile != undefined)
         {
            _loc5_ = _loc3_.fetchBattleAbilityDef(param1.params.abilityTile);
            this.abilityTileDef = _loc5_.getAbilityDefForLevel(param2.ability.def.level) as BattleAbilityDef;
         }
         if(param1.params.aoeCasterOtherRule != undefined)
         {
            this.aoeCasterOtherRule = Enum.parse(BattleAbilityTargetRule,param1.params.aoeCasterOtherRule) as BattleAbilityTargetRule;
         }
         this.entityMustHaveAbility = BooleanVars.parse(param1.params.entityMustHaveAbility,this.entityMustHaveAbility);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      private function applyGlobally() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in caster.board.entities)
         {
            if(target != _loc1_)
            {
               this.applyOnTarget(_loc1_);
            }
         }
      }
      
      override public function apply() : void
      {
         var _loc7_:IBattleEntity = null;
         if(!target)
         {
            return;
         }
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:TileRect = caster.rect;
         var _loc4_:TileRect = target.rect;
         if(_loc4_.back <= _loc3_.front)
         {
            _loc2_ = -1;
         }
         else if(_loc4_.front >= _loc3_.back)
         {
            _loc2_ = 1;
         }
         else if(_loc4_.left >= _loc3_.right)
         {
            _loc1_ = 1;
         }
         else if(_loc4_.right <= _loc3_.left)
         {
            _loc1_ = -1;
         }
         var _loc5_:int = _loc3_.left;
         var _loc6_:int = _loc3_.front;
         var _loc8_:Array = [];
         var _loc9_:int = 0;
         for(; _loc9_ < 100; _loc9_++)
         {
            _loc5_ += _loc1_;
            _loc6_ += _loc2_;
            _loc7_ = caster.board.findEntityOnTile(_loc5_,_loc6_,true,caster);
            if(this.aoeCasterOtherRule.isValid(caster,caster.rect,_loc7_,null,true,this.abilityEntityDef,true))
            {
               if(this.entityMustHaveAbility)
               {
                  if(!_loc7_.def.actives)
                  {
                     continue;
                  }
                  if(!_loc7_.def.actives.hasAbility(this.abilityEntityDef.id) && !_loc7_.def.attacks.hasAbility(this.abilityEntityDef.id))
                  {
                     continue;
                  }
               }
               _loc8_.push(_loc7_);
               if(_loc7_ == target)
               {
                  break;
               }
            }
         }
         for each(_loc7_ in _loc8_)
         {
            this.applyOnTarget(target);
         }
         effect.handleOpUsed(this);
      }
      
      private function computeEntity(param1:BattleAbilityResponseTargetType, param2:IBattleEntity) : IBattleEntity
      {
         switch(param1)
         {
            case BattleAbilityResponseTargetType.SELF:
            case BattleAbilityResponseTargetType.TARGET:
               return target;
            case BattleAbilityResponseTargetType.CASTER:
               return caster;
            case BattleAbilityResponseTargetType.OTHER:
               return param2;
            default:
               throw new ArgumentError("what?");
         }
      }
      
      private function applyOnTarget(param1:IBattleEntity) : void
      {
         if(!this.abilityEntityDef)
         {
            return;
         }
         var _loc2_:IBattleEntity = this.computeEntity(this.abilityCaster,param1);
         var _loc3_:IBattleEntity = this.computeEntity(this.abilityTarget,param1);
         var _loc4_:Boolean = true;
         if(!this.checkPeers(param1,this.abilityEntityDef))
         {
            return;
         }
         var _loc5_:BattleAbility = new BattleAbility(_loc2_,this.abilityEntityDef,manager);
         _loc5_.targetSet.setTarget(_loc3_);
         effect.ability.addChildAbility(_loc5_);
      }
      
      private function checkPeers(param1:IBattleEntity, param2:BattleAbilityDef) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:BattleAbility = null;
         var _loc3_:BattleAbility = effect.ability.root as BattleAbility;
         var _loc4_:Array = [];
         _loc4_.push(_loc3_);
         while(_loc4_.length > 0)
         {
            _loc3_ = _loc4_.pop();
            if(_loc3_ != effect.ability)
            {
               if(_loc3_.def == param2)
               {
                  if(_loc3_.caster == param1 || _loc3_.targetSet.hasTarget(param1))
                  {
                     return false;
                  }
               }
               _loc5_ = 0;
               while(_loc5_ < _loc3_.children.length)
               {
                  _loc6_ = _loc3_.children[_loc5_];
                  _loc4_.push(_loc6_);
                  _loc5_++;
               }
            }
         }
         return true;
      }
   }
}
