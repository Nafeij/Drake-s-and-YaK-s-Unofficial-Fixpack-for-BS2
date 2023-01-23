package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.stat.def.StatType;
   
   public class Op_TransferDamage extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_TransferDamage",
         "properties":{"responseAbility":{"type":"string"}}
      };
       
      
      private var responseAbilityDef:BattleAbilityDef;
      
      private var transferees:Vector.<IBattleEntity>;
      
      public function Op_TransferDamage(param1:EffectDefOp, param2:Effect)
      {
         this.transferees = new Vector.<IBattleEntity>();
         super(param1,param2);
         this.responseAbilityDef = manager.factory.fetch(param1.params.responseAbility) as BattleAbilityDef;
      }
      
      private function setupTransferees() : void
      {
         var _loc1_:IBattleEntity = null;
         this.transferees.splice(0,this.transferees.length);
         if(!board)
         {
            return;
         }
         for each(_loc1_ in board.entities)
         {
            if(this._checkTransferee(_loc1_))
            {
               this.transferees.push(_loc1_);
            }
         }
         target.stats.setBase(StatType.TRANSFER_DAMAGE_COUNT,this.transferees.length);
         board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.aliveHandler);
         board.addEventListener(BattleEntityEvent.ADDED,this.addedHandler);
      }
      
      private function _checkTransferee(param1:IBattleEntity) : Boolean
      {
         if(!param1.alive)
         {
            return false;
         }
         if(!this.responseAbilityDef.checkTargetExecutionConditions(param1,logger,true))
         {
            return false;
         }
         return true;
      }
      
      private function aliveHandler(param1:BattleBoardEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:IBattleEntity = param1.entity;
         if(!this._checkTransferee(_loc2_))
         {
            _loc3_ = this.transferees.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               this.transferees.splice(_loc3_,1);
               target.stats.setBase(StatType.TRANSFER_DAMAGE_COUNT,this.transferees.length);
            }
         }
      }
      
      private function addedHandler(param1:BattleEntityEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:IBattleEntity = param1.entity;
         if(this._checkTransferee(_loc2_))
         {
            _loc3_ = this.transferees.indexOf(_loc2_);
            if(_loc3_ < 0)
            {
               this.transferees.push(_loc2_);
               target.stats.setBase(StatType.TRANSFER_DAMAGE_COUNT,this.transferees.length);
            }
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(ability.fake)
         {
            return;
         }
         this.setupTransferees();
      }
      
      override public function handleTransferDamage(param1:IEffect, param2:int) : void
      {
         var _loc6_:IBattleEntity = null;
         var _loc3_:int = int(target.stats.getValue(StatType.TRANSFER_DAMAGE_COUNT));
         logger.info("Op_TransferDamage TRANSFER " + param1 + " amount=" + param2 + " count=" + _loc3_ + "trans" + this.transferees.length);
         if(_loc3_ <= 0 || this.transferees.length <= 0)
         {
            return;
         }
         var _loc4_:BattleAbility = new BattleAbility(param1.ability.caster,this.responseAbilityDef,manager);
         var _loc5_:int = Math.ceil(param2 / _loc3_);
         for each(_loc6_ in this.transferees)
         {
            if(_loc5_ > param2)
            {
               _loc5_ = Math.max(1,param2);
            }
            _loc4_.targetSet.addTarget(_loc6_);
            _loc6_.stats.setBase(StatType.TRANSFER_DAMAGE_AMOUNT,_loc5_);
            param2 -= _loc5_;
         }
         _loc4_.execute(null);
      }
   }
}
