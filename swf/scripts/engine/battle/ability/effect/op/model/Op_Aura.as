package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.def.BooleanVars;
   import engine.tile.def.TileRectRange;
   import flash.utils.Dictionary;
   
   public class Op_Aura extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_Aura",
         "properties":{
            "aura":{"type":"string"},
            "self":{"type":"string"},
            "aura_persists":{
               "type":"boolean",
               "optional":true
            },
            "range_max":{
               "type":"number",
               "optional":true
            },
            "rank":{
               "type":"number",
               "optional":true
            },
            "pulseSelf":{
               "type":"boolean",
               "optional":true
            },
            "pulseOthers":{
               "type":"boolean",
               "optional":true
            },
            "removeSelfOnRemoveAuras":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var aura:BattleAbilityDef;
      
      private var self:BattleAbilityDef;
      
      private var others:Dictionary;
      
      private var selfs:Dictionary;
      
      private var _pulseSelf:Boolean;
      
      private var _pulseOthers:Boolean;
      
      private var aura_persists:Boolean;
      
      private var range_max:int;
      
      private var rankOverride:int = 0;
      
      private var _removeSelfOnRemoveAuras:Boolean = false;
      
      public function Op_Aura(param1:EffectDefOp, param2:Effect)
      {
         this.others = new Dictionary();
         this.selfs = new Dictionary();
         super(param1,param2);
         this.range_max = param1.params.range_max;
         this.rankOverride = param1.params.rank;
         this.aura = manager.factory.fetch(param1.params.aura,true) as BattleAbilityDef;
         if(param1.params.self)
         {
            this.self = manager.factory.fetch(param1.params.self,true) as BattleAbilityDef;
         }
         this.aura_persists = BooleanVars.parse(param1.params.aura_persists,this.aura_persists);
         this._pulseSelf = BooleanVars.parse(param1.params.pulseSelf,this._pulseSelf);
         this._pulseOthers = BooleanVars.parse(param1.params.pulseOthers,this._pulseOthers);
         this._removeSelfOnRemoveAuras = BooleanVars.parse(param1.params.removeSelfOnRemoveAuras,this._removeSelfOnRemoveAuras);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(board)
         {
            board.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            board.addEventListener(BattleEntityEvent.MOVE_FINISHING,this.moveFinishingHandler);
            board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
            board.addEventListener(BattleEntityEvent.REMOVE_AURAS,this.handleRemoveAuras);
            board.addEventListener(BattleEntityEvent.TELEPORTING,this.teleportHandler);
            board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.entityEnabledHandler);
            this.boardSetupHandler(null);
         }
      }
      
      override public function casterStartTurn() : Boolean
      {
         var _loc1_:IBattleEntity = null;
         if(!this._pulseOthers && !this._pulseSelf)
         {
            return false;
         }
         for each(_loc1_ in board.entities)
         {
            if(this._pulseOthers)
            {
               this.pulseOther(_loc1_);
            }
            if(this._pulseSelf)
            {
               this.pulseSelf(_loc1_);
            }
         }
         return true;
      }
      
      override public function remove() : void
      {
         if(board)
         {
            board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            board.removeEventListener(BattleEntityEvent.MOVE_FINISHING,this.moveFinishingHandler);
            board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
            board.removeEventListener(BattleEntityEvent.REMOVE_AURAS,this.handleRemoveAuras);
            board.removeEventListener(BattleEntityEvent.TELEPORTING,this.teleportHandler);
            board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.entityEnabledHandler);
         }
      }
      
      private function handleRemoveAuras(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = null;
         if(param1.entity == target)
         {
            for each(_loc2_ in board.entities)
            {
               if(_loc2_ != target)
               {
                  this.checkOther(_loc2_,true);
               }
            }
            if(this._removeSelfOnRemoveAuras)
            {
               ability.removeAllEffects(EffectRemoveReason.DEFAULT);
            }
         }
         else
         {
            this.checkOther(param1.entity,true);
         }
      }
      
      private function boardEntityAliveHandler(param1:BattleBoardEvent) : void
      {
         this._handleUnitChanged(param1.entity);
      }
      
      private function moveFinishingHandler(param1:BattleEntityEvent) : void
      {
         this._handleUnitChanged(param1.entity);
      }
      
      private function teleportHandler(param1:BattleEntityEvent) : void
      {
         this._handleUnitChanged(param1.entity);
      }
      
      private function _handleUnitChanged(param1:IBattleEntity) : void
      {
         if(param1 == target)
         {
            this.boardSetupHandler(null);
         }
         else
         {
            this.checkOther(param1);
         }
      }
      
      private function boardSetupHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = null;
         if(!board.boardSetup)
         {
            return;
         }
         logger.d("AURA","source scan " + this);
         for each(_loc2_ in board.entities)
         {
            if(_loc2_ != target)
            {
               this.checkOther(_loc2_);
            }
         }
      }
      
      private function entityEnabledHandler(param1:BattleBoardEvent) : void
      {
         this._handleUnitChanged(param1.entity);
      }
      
      private function checkParents(param1:IBattleEntity) : Boolean
      {
         var _loc2_:BattleAbilityDef = ability.def.root as BattleAbilityDef;
         var _loc3_:BattleAbility = ability.parent as BattleAbility;
         while(_loc3_)
         {
            if(_loc3_.def.root == _loc2_)
            {
               if(_loc3_.caster == param1)
               {
                  logger.info("Op_Aura.checkParents " + ability + " blocked for other " + param1 + " by parent ability " + _loc3_);
                  return false;
               }
            }
            _loc3_ = _loc3_.parent as BattleAbility;
         }
         return true;
      }
      
      private function checkOther(param1:IBattleEntity, param2:Boolean = false) : void
      {
         var _loc4_:BattleAbilityValidation = null;
         var _loc5_:int = 0;
         if(param1 == target)
         {
            return;
         }
         var _loc3_:Boolean = param1.alive && target.alive && Boolean(param1.enabled) && Boolean(target.enabled) && !param2;
         if(!this.checkParents(param1))
         {
            return;
         }
         if(_loc3_)
         {
            _loc4_ = BattleAbilityValidation.validate(this.aura,target,null,param1,null,false,false,true);
            _loc3_ = Boolean(_loc4_) && _loc4_.ok;
            if(_loc3_)
            {
               if(this.range_max)
               {
                  _loc5_ = TileRectRange.computeRange(target.rect,param1.rect);
                  if(_loc5_ > this.range_max)
                  {
                     _loc3_ = false;
                  }
               }
            }
         }
         if(_loc3_)
         {
            this.auraAdd(param1);
         }
         else
         {
            this.auraRemove(param1);
         }
      }
      
      private function pulseSelf(param1:IBattleEntity) : void
      {
         var _loc2_:IBattleAbility = this.selfs[param1];
         var _loc3_:int = this.rankOverride;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.removeAllEffects(EffectRemoveReason.DEFAULT);
         logger.d("AURA","pulseSelf  " + param1 + " vs " + this);
         if(_loc3_ < 1 || _loc3_ > this.self.maxLevel)
         {
            _loc3_ = 1;
         }
         var _loc4_:IBattleAbilityDef = this.self.getIBattleAbilityDefLevel(_loc3_);
         var _loc5_:BattleAbility = new BattleAbility(target,_loc4_,manager);
         ability.addChildAbility(_loc5_);
         this.selfs[param1] = _loc5_;
      }
      
      private function pulseOther(param1:IBattleEntity) : void
      {
         var _loc2_:IBattleAbility = this.others[param1];
         var _loc3_:int = this.rankOverride;
         if(!_loc2_)
         {
            return;
         }
         logger.d("AURA","pulseOther " + param1 + " vs " + this);
         _loc2_.removeAllEffects(EffectRemoveReason.DEFAULT);
         if(_loc3_ < 1 || _loc3_ > this.aura.maxLevel)
         {
            _loc3_ = 1;
         }
         var _loc4_:IBattleAbilityDef = this.aura.getIBattleAbilityDefLevel(_loc3_);
         var _loc5_:BattleAbility = new BattleAbility(target,_loc4_,manager);
         _loc5_.targetSet.setTarget(param1);
         ability.addChildAbility(_loc5_);
         this.others[param1] = _loc5_;
      }
      
      private function auraAdd(param1:IBattleEntity) : void
      {
         var _loc5_:IBattleAbilityDef = null;
         var _loc6_:BattleAbility = null;
         var _loc7_:IBattleAbilityDef = null;
         var _loc8_:BattleAbility = null;
         var _loc2_:IBattleAbility = this.others[param1];
         var _loc3_:IBattleAbility = this.selfs[param1];
         var _loc4_:int = this.rankOverride;
         if(!_loc2_)
         {
            logger.d("AURA","add OTHER " + param1 + " vs " + this);
            if(_loc4_ < 1 || _loc4_ > this.aura.maxLevel)
            {
               _loc4_ = 1;
            }
            _loc5_ = this.aura.getIBattleAbilityDefLevel(_loc4_);
            _loc6_ = new BattleAbility(target,_loc5_,manager);
            _loc6_.targetSet.setTarget(param1);
            ability.addChildAbility(_loc6_);
            this.others[param1] = _loc6_;
         }
         if(!_loc3_ && Boolean(this.self))
         {
            logger.d("AURA","add SELF  " + param1 + " vs " + this);
            if(_loc4_ < 1 || _loc4_ > this.self.maxLevel)
            {
               _loc4_ = 1;
            }
            _loc7_ = this.self.getIBattleAbilityDefLevel(_loc4_);
            _loc8_ = new BattleAbility(target,_loc7_,manager);
            ability.addChildAbility(_loc8_);
            this.selfs[param1] = _loc8_;
         }
      }
      
      private function auraRemove(param1:IBattleEntity) : void
      {
         var _loc2_:IBattleAbility = this.others[param1];
         var _loc3_:IBattleAbility = this.selfs[param1];
         if(_loc2_)
         {
            logger.d("AURA","rem OTHER " + param1 + " vs " + this);
            if(!this.aura_persists)
            {
               _loc2_.removeAllEffects(EffectRemoveReason.DEFAULT);
            }
            delete this.others[param1];
         }
         if(_loc3_)
         {
            logger.d("AURA","rem SELF  " + param1 + " vs " + this);
            _loc3_.removeAllEffects(EffectRemoveReason.DEFAULT);
            delete this.selfs[param1];
         }
      }
   }
}
