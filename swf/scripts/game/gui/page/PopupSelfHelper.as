package game.gui.page
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.ability.def.AbilityDef;
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.IBattleTurn;
   import engine.core.gp.GpControlButton;
   import engine.gui.BattleHudConfig;
   import flash.events.Event;
   import game.gui.battle.IGuiSelfPopup;
   
   public class PopupSelfHelper extends PopupHelper
   {
       
      
      private var selfPopup:IGuiSelfPopup;
      
      private var _ability:IBattleAbility;
      
      private var fsm:BattleFsm;
      
      public function PopupSelfHelper(param1:IGuiSelfPopup, param2:BattleBoardView, param3:BattleHudConfig)
      {
         super(param1,param2,param3);
         this.selfPopup = param1;
         this.fsm = param2.board.sim.fsm;
         this.fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         this.fsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.turnAttackHandler);
      }
      
      override public function cleanup() : void
      {
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.turnAttackHandler);
         this.fsm = null;
         this.ability = null;
         super.cleanup();
      }
      
      private function boardEntitHudIndicatorVisibleHandler(param1:Event) : void
      {
      }
      
      public function handleConfirm() : Boolean
      {
         return Boolean(this.selfPopup) && Boolean(this.selfPopup.handleConfirm());
      }
      
      private function checkPopup(param1:IBattleTurn) : Boolean
      {
         if(!enabled)
         {
            return false;
         }
         if(!param1)
         {
            return false;
         }
         if(param1.move.executing)
         {
            return false;
         }
         if(param1.committed)
         {
            return false;
         }
         if(!param1.entity.playerControlled)
         {
            return false;
         }
         if(!param1.entity.battleHudIndicatorVisible)
         {
            return false;
         }
         if(param1.attackMode)
         {
            return false;
         }
         if(!param1.ability)
         {
            if(param1.turnInteract)
            {
               if(param1.turnInteract != param1.entity)
               {
                  return false;
               }
            }
            else if(!param1.move.committed)
            {
               return false;
            }
         }
         else if(param1.ability.def.tag != BattleAbilityTag.SPECIAL)
         {
            return false;
         }
         var _loc2_:IBattleBoard = param1.entity.board;
         if(!_loc2_ || _loc2_.isUsingEntity)
         {
            return false;
         }
         return true;
      }
      
      public function setupPopup(param1:IBattleTurn) : void
      {
         if(!this.checkPopup(param1))
         {
            popup.entity = null;
            return;
         }
         if(param1.ability)
         {
            popup.entity = null;
         }
         else
         {
            this.selfPopup.entity = param1.entity;
            this.displayPopup(param1,true);
         }
      }
      
      private function displayPopup(param1:IBattleTurn, param2:Boolean) : void
      {
         var _loc7_:AbilityDefLevel = null;
         var _loc8_:* = false;
         var _loc9_:int = 0;
         var _loc10_:BattleBoard = null;
         var _loc3_:IBattleEntity = param1.entity;
         var _loc4_:BattleAbilityDefLevels = _loc3_.def.actives as BattleAbilityDefLevels;
         var _loc5_:Vector.<AbilityDefLevel> = _loc4_.getAbilityDefLevelsByTag(BattleAbilityTag.SPECIAL);
         var _loc6_:Vector.<AbilityDef> = new Vector.<AbilityDef>();
         for each(_loc7_ in _loc5_)
         {
            if(_loc7_.level > 0)
            {
               _loc9_ = _loc7_.level;
               if(_loc9_ > _loc7_.def.maxLevel)
               {
                  logger.info("PopupSelfHelper " + _loc3_ + " believes in a level " + _loc7_.level + " " + _loc7_.def.id + ", but max level is only " + _loc7_.def.maxLevel);
                  _loc9_ = _loc7_.def.maxLevel;
               }
               _loc6_.push(_loc7_.def.getAbilityDefForLevel(_loc9_) as AbilityDef);
            }
         }
         _loc8_ = param1.numAbilities == 0;
         this.selfPopup.setValues(_loc6_,param1.move.committed,param2,_loc8_);
         positionPopup();
         if(PlatformInput.lastInputGp)
         {
            _loc10_ = _loc3_.board as BattleBoard;
            _loc10_.hoverTile = null;
            _loc10_.hoverEntity = null;
         }
      }
      
      public function selectEndTurn(param1:BattleTurn) : void
      {
         this.selfPopup.entity = param1.entity;
         this.displayPopup(param1,false);
         this.selfPopup.hotEndTurn(param1.entity);
      }
      
      public function get ability() : IBattleAbility
      {
         return this._ability;
      }
      
      public function set ability(param1:IBattleAbility) : void
      {
         if(this._ability == param1)
         {
            return;
         }
         if(this._ability)
         {
            this._ability.targetSet.removeEventListener(Event.CHANGE,this.targetSetChangeHandler);
         }
         this._ability = param1;
         if(this._ability)
         {
            this._ability.targetSet.addEventListener(Event.CHANGE,this.targetSetChangeHandler);
         }
      }
      
      public function updateWillpower(param1:int) : void
      {
         this.selfPopup.updateWillpower(param1);
      }
      
      private function turnAttackHandler(param1:BattleFsmEvent) : void
      {
         this.setupPopup(this.fsm.turn);
      }
      
      private function turnAbilityHandler(param1:BattleFsmEvent) : void
      {
         this.ability = !!this.fsm.turn ? this.fsm.turn.ability : null;
         this.setupPopup(this.fsm.turn);
      }
      
      private function targetSetChangeHandler(param1:Event) : void
      {
         this.setupPopup(this.fsm.turn);
      }
      
      override protected function handleEnabled() : void
      {
         this.setupPopup(this.fsm.turn);
      }
      
      public function update(param1:int) : void
      {
         if(popup)
         {
            popup.updatePopup(param1);
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         return Boolean(popup) && popup.handleGpButton(param1);
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "POPUPSELFHELPER _ability=" + this._ability + "\n";
         return _loc1_ + this.selfPopup.getDebugString();
      }
   }
}
