package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_TargetForwardArc extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_TargetForwardArc",
         "properties":{
            "ability":{"type":"string"},
            "abilityRank":{
               "type":"number",
               "optional":true
            },
            "primaryTargetLast":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static var DEBUG_TARGET_FORWARD_ARC:Boolean;
       
      
      protected var hits:Dictionary;
      
      protected var abilityDef:BattleAbilityDef;
      
      protected var primaryTargetLast:Boolean = false;
      
      public function Op_TargetForwardArc(param1:EffectDefOp, param2:Effect)
      {
         this.hits = new Dictionary();
         super(param1,param2);
         var _loc3_:int = 1;
         if(param1.params.abilityEntityRank != undefined)
         {
            _loc3_ = int(param1.params.abilityEntityRank);
         }
         if(param1.params.primaryTargetLast != undefined)
         {
            this.primaryTargetLast = param1.params.primaryTargetLast;
         }
         var _loc4_:BattleAbilityDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         this.abilityDef = _loc4_.getAbilityDefForLevel(_loc3_) as BattleAbilityDef;
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      private function applyGlobally() : void
      {
         var be:BattleEntity = null;
         for each(be in caster.board.entities)
         {
            if(target != be)
            {
               try
               {
                  this.applyOnTarget(be);
               }
               catch(e:Error)
               {
                  logger.error("Op_TargetAoe.applyGlobally failed to apply to " + be);
                  logger.error(e.getStackTrace());
               }
            }
         }
      }
      
      override public function apply() : void
      {
         var _loc11_:Tile = null;
         var _loc13_:IBattleEntity = null;
         var _loc14_:int = 0;
         var _loc15_:IBattleEntity = null;
         if(!target)
         {
            return;
         }
         var _loc1_:TileRect = target.rect;
         var _loc2_:Tiles = target.board.tiles;
         var _loc3_:TileRect = caster.rect;
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:int = caster.rect.front - 1;
         var _loc8_:int = caster.rect.front - 1;
         var _loc9_:int = int(caster.rect.left);
         var _loc10_:int = int(caster.rect.left);
         if(caster.facing == BattleFacing.NW)
         {
            _loc7_ = caster.rect.left - 1;
            _loc8_ = caster.rect.left - 1;
            _loc9_ = int(caster.rect.back);
            _loc10_ = caster.rect.front - 1;
         }
         else if(caster.facing == BattleFacing.SE)
         {
            _loc7_ = int(caster.rect.right);
            _loc8_ = int(caster.rect.right);
            _loc9_ = int(caster.rect.back);
            _loc10_ = caster.rect.front - 1;
         }
         else if(caster.facing == BattleFacing.NE)
         {
            _loc7_ = caster.rect.left - 1;
            _loc8_ = int(caster.rect.right);
            _loc9_ = caster.rect.front - 1;
            _loc10_ = caster.rect.front - 1;
         }
         else if(caster.facing == BattleFacing.SW)
         {
            _loc7_ = caster.rect.left - 1;
            _loc8_ = int(caster.rect.right);
            _loc9_ = int(caster.rect.back);
            _loc10_ = int(caster.rect.back);
         }
         if(!this.primaryTargetLast)
         {
            _loc5_.push(target);
         }
         var _loc12_:int = _loc7_;
         while(_loc12_ <= _loc8_)
         {
            _loc14_ = _loc9_;
            while(_loc14_ <= _loc10_)
            {
               _loc15_ = caster.board.findEntityOnTile(_loc12_,_loc14_,true,target);
               if(Boolean(_loc15_) && Boolean(_loc15_.attackable))
               {
                  if(!_loc4_[_loc15_])
                  {
                     _loc4_[_loc15_] = _loc15_;
                     _loc5_.push(_loc15_);
                  }
               }
               _loc14_++;
            }
            _loc12_++;
         }
         if(this.primaryTargetLast)
         {
            _loc5_.push(target);
         }
         for each(_loc13_ in _loc5_)
         {
            this.applyOnTarget(_loc13_);
         }
         effect.handleOpUsed(this);
      }
      
      private function applyOnTarget(param1:IBattleEntity) : void
      {
         if(DEBUG_TARGET_FORWARD_ARC)
         {
            logger.debug("Op_TargetForwardArc.applyOnTarget caster=" + caster + " target=" + target + " other=" + param1);
         }
         var _loc2_:Boolean = true;
         if(this.hits[param1])
         {
            if(DEBUG_TARGET_FORWARD_ARC)
            {
               logger.debug("Op_TargetAoe.applyOnTarget SKIP already hit");
            }
            return;
         }
         this.hits[param1] = param1;
         if(!this.checkPeers(param1,this.abilityDef))
         {
            if(DEBUG_TARGET_FORWARD_ARC)
            {
               logger.debug("Op_TargetForwardArc.applyOnTarget SKIP checkPeers");
            }
            return;
         }
         if(!this.abilityDef.checkCasterExecutionConditions(caster,logger,true))
         {
            if(DEBUG_TARGET_FORWARD_ARC)
            {
               logger.debug("Op_TargetForwardArc.applyOnTarget caster execution conditions failed for [" + caster + "]");
            }
            return;
         }
         var _loc3_:BattleAbility = new BattleAbility(caster,this.abilityDef,manager);
         _loc3_.targetSet.setTarget(param1);
         effect.ability.addChildAbility(_loc3_);
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
