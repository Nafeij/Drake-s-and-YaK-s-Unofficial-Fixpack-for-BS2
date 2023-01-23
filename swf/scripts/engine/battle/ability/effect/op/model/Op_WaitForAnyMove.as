package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.tile.Tile;
   
   public class Op_WaitForAnyMove extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForAnyMove",
         "properties":{
            "ability":{"type":"string"},
            "level":{"type":"number"},
            "maxPerTurn":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      private var abilityDef:BattleAbilityDef;
      
      private var abilityLevel:int;
      
      private var maxPerTurn:int = 1;
      
      private var _lastTurnNumber:int;
      
      private var _countThisTurn:int;
      
      public function Op_WaitForAnyMove(param1:EffectDefOp, param2:Effect)
      {
         var _loc4_:BattleAbilityDef = null;
         super(param1,param2);
         var _loc3_:String = param1.params.ability;
         this.abilityDef = manager.factory.fetchBattleAbilityDef(_loc3_);
         this.abilityLevel = param1.params.level;
         this.maxPerTurn = param1.params.maxPerTurn != undefined ? int(param1.params.maxPerTurn) : this.maxPerTurn;
         if(!this.abilityDef)
         {
            manager.logger.error("Op_WaitForAnyMove " + this + " invalid ability [" + _loc3_ + "]");
         }
         else
         {
            _loc4_ = this.abilityDef.getAbilityDefForLevel(this.abilityLevel) as BattleAbilityDef;
            if(!_loc4_)
            {
               manager.logger.error("Op_WaitForAnyMove " + this + " invalid ability level " + this.abilityLevel + " for " + _loc3_);
            }
            else
            {
               this.abilityDef = _loc4_;
            }
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(!fake)
         {
            board.addEventListener(BattleBoardEvent.BOARD_ENTITY_TILE_TRIGGER,this.boardEntityTileChangedHandler);
         }
      }
      
      override public function remove() : void
      {
         if(!fake)
         {
            board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_TILE_TRIGGER,this.boardEntityTileChangedHandler);
         }
      }
      
      private function boardEntityTileChangedHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:Tile = null;
         var _loc4_:BattleAbilityValidation = null;
         var _loc5_:BattleAbility = null;
         if(!board || !board.fsm.turn)
         {
            return;
         }
         if(this._lastTurnNumber == board.fsm.turn.number)
         {
            if(this.maxPerTurn > 0 && this._countThisTurn >= this.maxPerTurn)
            {
               return;
            }
         }
         if(this.abilityDef && target.alive && !effect.removed)
         {
            _loc2_ = param1.entity;
            if(_loc2_.alive)
            {
               if(target.awareOf(_loc2_))
               {
                  _loc3_ = _loc2_.tile;
                  if(Boolean(_loc3_) && _loc3_.numResidents > 1)
                  {
                     return;
                  }
                  if(!_loc2_.collidable)
                  {
                     return;
                  }
                  _loc4_ = BattleAbilityValidation.validate(this.abilityDef,target,null,_loc2_,null,false,false,true);
                  if(BattleAbilityValidation.OK == _loc4_)
                  {
                     if(this._lastTurnNumber != board.fsm.turn.number)
                     {
                        this._lastTurnNumber = board.fsm.turn.number;
                        this._countThisTurn = 0;
                     }
                     ++this._countThisTurn;
                     _loc5_ = new BattleAbility(target,this.abilityDef,manager);
                     _loc5_.targetSet.setTarget(_loc2_);
                     effect.handleOpUsed(this);
                     _loc5_.execute(null);
                  }
               }
            }
         }
      }
   }
}
