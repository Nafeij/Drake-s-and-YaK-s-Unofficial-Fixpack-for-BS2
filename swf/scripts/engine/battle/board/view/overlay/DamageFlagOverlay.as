package engine.battle.board.view.overlay
{
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.StatChangeData;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.stat.def.StatType;
   
   public class DamageFlagOverlay
   {
       
      
      private var _turn:BattleTurn;
      
      private var view:BattleBoardView;
      
      private var _renderDirty:Boolean;
      
      private var fsm:BattleFsm;
      
      private var _board:BattleBoard;
      
      public function DamageFlagOverlay(param1:BattleBoardView)
      {
         super();
         this.view = param1;
         this._board = this.view.board;
         this.fsm = this.view.board.sim.fsm;
         this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_DAMAGED,this.entityDamagedHander);
         this.fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN_IN_RANGE,this.turnInRangeHandler);
         this.fsm.addEventListener(BattleFsmEvent.INTERACT,this.interactHandler);
      }
      
      public function cleanup() : void
      {
         this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_DAMAGED,this.entityDamagedHander);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_IN_RANGE,this.turnInRangeHandler);
         this.fsm.removeEventListener(BattleFsmEvent.INTERACT,this.interactHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
      }
      
      private function entityDamagedHander(param1:BattleBoardEvent) : void
      {
         if(!this._turn || param1.entity != this._turn.entity)
         {
            return;
         }
         this.setRenderDirty();
      }
      
      public function render() : void
      {
         var _loc4_:BattleEntity = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:BattleAbilityDefLevels = null;
         var _loc8_:StatChangeData = null;
         var _loc9_:Vector.<AbilityDefLevel> = null;
         var _loc10_:BattleEntity = null;
         var _loc11_:IBattleMove = null;
         var _loc12_:AbilityDefLevel = null;
         var _loc13_:BattleAbilityDef = null;
         if(!this._renderDirty)
         {
            return;
         }
         if(!this.fsm || !this._turn)
         {
            return;
         }
         this._renderDirty = false;
         var _loc1_:BattleEntity = this._turn.entity as BattleEntity;
         var _loc2_:Boolean = Boolean(this._turn.ability) && this.fsm.turn.ability.targetSet.hasTarget(_loc1_);
         var _loc3_:Boolean = !this._turn.ability && _loc1_.playerControlled && this.fsm.interact == _loc1_ && Boolean(this._turn._inRange[_loc1_]);
         for each(_loc4_ in this._turn._inRange)
         {
            if(!_loc4_.alive || this._turn.committed || this._turn.ability || _loc2_ || _loc3_ || _loc4_ == this._turn.turnInteract)
            {
               _loc4_.setBattleDamageFlagVisible(false,0);
            }
            else
            {
               _loc5_ = _loc4_.centerX * this.view.units;
               _loc6_ = _loc4_.centerY * this.view.units;
               _loc7_ = _loc1_.def.attacks as BattleAbilityDefLevels;
               _loc8_ = new StatChangeData();
               _loc9_ = _loc7_.getAbilityDefLevelsByTag(BattleAbilityTag.ATTACK_STR);
               _loc10_ = _loc1_ as BattleEntity;
               _loc11_ = this._turn.move;
               for each(_loc12_ in _loc9_)
               {
                  _loc13_ = _loc12_._def as BattleAbilityDef;
                  if(BattleAbility.getStatChange(_loc13_,_loc10_,StatType.STRENGTH,_loc8_,_loc4_,_loc11_))
                  {
                     break;
                  }
               }
               _loc4_.setBattleDamageFlagVisible(true,_loc8_.amount);
            }
         }
         for each(_loc4_ in this.fsm.board.entities)
         {
            if(!this._turn._inRange[_loc4_])
            {
               _loc4_.setBattleDamageFlagVisible(false,0);
            }
         }
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
         this._turn = this.view.board.sim.fsm.turn as BattleTurn;
         this.setRenderDirty();
      }
      
      private function setRenderDirty() : void
      {
         this._renderDirty = true;
      }
      
      private function interactHandler(param1:BattleFsmEvent) : void
      {
         this.setRenderDirty();
      }
      
      private function turnInRangeHandler(param1:BattleFsmEvent) : void
      {
         this.setRenderDirty();
      }
   }
}
