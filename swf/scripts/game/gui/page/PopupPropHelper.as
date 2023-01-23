package game.gui.page
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.IBattleFsm;
   import engine.core.gp.GpControlButton;
   import engine.gui.BattleHudConfig;
   import game.gui.battle.IGuiPropPopup;
   
   public class PopupPropHelper extends PopupHelper
   {
       
      
      private var popupProp:IGuiPropPopup;
      
      public function PopupPropHelper(param1:IGuiPropPopup, param2:BattleBoardView, param3:BattleHudConfig)
      {
         super(param1,param2,param3);
         this.popupProp = param1;
      }
      
      public function set fsm(param1:IBattleFsm) : void
      {
         if(this.popupProp)
         {
            this.popupProp.fsm = param1;
         }
      }
      
      public function handleConfirm() : Boolean
      {
         return Boolean(this.popupProp) && Boolean(this.popupProp.handleConfirm());
      }
      
      private function checkPopup(param1:BattleTurn) : Boolean
      {
         if(!enabled)
         {
            return false;
         }
         if(!param1)
         {
            return false;
         }
         if(param1.committed)
         {
            return false;
         }
         if(param1.move.executing)
         {
            return false;
         }
         var _loc2_:* = param1._numAbilities == 0;
         if(!_loc2_)
         {
            return false;
         }
         if(!param1.turnInteract || !param1.turnInteract.usable)
         {
            return false;
         }
         if(!param1.entity.playerControlled)
         {
            return false;
         }
         if(param1.ability)
         {
            return false;
         }
         var _loc3_:IBattleBoard = param1.entity.board;
         if(!_loc3_ || _loc3_.isUsingEntity)
         {
            return false;
         }
         return true;
      }
      
      public function setupPopup(param1:BattleTurn) : void
      {
         if(!this.checkPopup(param1) || !battleHudConfig.propPopup)
         {
            this.popupProp.entity = null;
            return;
         }
         this.popupProp.entity = param1.turnInteract;
         positionPopup();
      }
      
      override protected function handleEnabled() : void
      {
         this.setupPopup(null);
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
   }
}
