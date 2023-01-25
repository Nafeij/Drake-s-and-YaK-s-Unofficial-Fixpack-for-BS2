package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import flash.events.Event;
   
   public class Op_NoneAdjacent extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_NoneAdjacent",
         "properties":{
            "ability":{"type":"string"},
            "range_max":{
               "type":"number",
               "optional":true
            },
            "rank":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      private var abilityDef:BattleAbilityDef;
      
      private var range_max:int;
      
      private var rankOverride:int = 0;
      
      private var _appliedAbility:IBattleAbility = null;
      
      public function Op_NoneAdjacent(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.range_max = param1.params.range_max;
         this.rankOverride = param1.params.rank;
         this.abilityDef = manager.factory.fetch(param1.params.ability,true) as BattleAbilityDef;
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(board)
         {
            board.addEventListener(BattleBoardEvent.BOARDSETUP,this.checkAdjacency);
            board.addEventListener(BattleEntityEvent.MOVE_FINISHING,this.checkAdjacency);
            board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.checkAdjacency);
            board.addEventListener(BattleEntityEvent.REMOVE_AURAS,this.handleRemoveAuras);
            this.checkAdjacency(null);
         }
      }
      
      override public function remove() : void
      {
         if(board)
         {
            board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.checkAdjacency);
            board.removeEventListener(BattleEntityEvent.MOVE_FINISHING,this.checkAdjacency);
            board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.checkAdjacency);
            board.removeEventListener(BattleEntityEvent.REMOVE_AURAS,this.handleRemoveAuras);
         }
      }
      
      private function checkAdjacency(param1:Event) : void
      {
         var _loc4_:IBattleEntity = null;
         if(!caster)
         {
            logger.error("ERROR: Op_NoneAdjacent attempting to check adjacency without a valid caster!");
            return;
         }
         if(!board)
         {
            logger.error("ERROR: Op_NoneAdjacent attempting to check adjacency without a valid board!");
         }
         var _loc2_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         _loc2_ = board.findAllAdjacentEntities(caster,caster.rect,_loc2_,false);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            if(_loc4_ && _loc4_.party && _loc4_.party.team == caster.party.team)
            {
               this.removeAbility(_loc4_);
               return;
            }
            _loc3_++;
         }
         this.applyAbility();
      }
      
      private function handleRemoveAuras(param1:Event) : void
      {
         this.removeAbility(null);
      }
      
      private function applyAbility() : void
      {
         if(this._appliedAbility)
         {
            return;
         }
         var _loc1_:int = this.rankOverride;
         if(_loc1_ < 1 || _loc1_ > this.abilityDef.maxLevel)
         {
            _loc1_ = 1;
         }
         var _loc2_:IBattleAbilityDef = this.abilityDef.getIBattleAbilityDefLevel(_loc1_);
         this._appliedAbility = new BattleAbility(caster,_loc2_,manager);
         ability.addChildAbility(this._appliedAbility);
      }
      
      private function removeAbility(param1:IBattleEntity) : void
      {
         if(!this._appliedAbility)
         {
            return;
         }
         logger.debug(!!("Op_NoneAdjacent removing applied ability " + this._appliedAbility.def.name + " because of adjacent unit: " + param1) ? String(param1.id) : null);
         this._appliedAbility.removeAllEffects(EffectRemoveReason.DEFAULT);
         this._appliedAbility = null;
      }
   }
}
