package game.gui.battle
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.board.def.Usability;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleFsm;
   import engine.core.gp.GpControlButton;
   import flash.display.MovieClip;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiToolTip;
   import game.gui.IGuiContext;
   
   public class GuiPropPopup extends GuiBase implements IGuiPropPopup
   {
       
      
      private var _entity:IBattleEntity;
      
      private var _showing:Boolean = true;
      
      private var _checkmark:MovieClip;
      
      private var _button:ButtonWithIndex;
      
      private var _tooltip:GuiToolTip;
      
      private var _tooltip_error:GuiToolTip;
      
      private var listener:IGuiPropPopupListener;
      
      private var _fsm:IBattleFsm;
      
      public function GuiPropPopup()
      {
         super();
         this._checkmark = requireGuiChild("checkmark") as MovieClip;
         this._button = requireGuiChild("button") as ButtonWithIndex;
         this._tooltip = requireGuiChild("tooltip") as GuiToolTip;
         this._tooltip_error = requireGuiChild("tooltip_error") as GuiToolTip;
      }
      
      public function init(param1:IGuiContext, param2:IGuiPropPopupListener) : void
      {
         super.initGuiBase(param1);
         this.listener = param2;
         this._button.guiButtonContext = param1;
         this._button.setDownFunction(this.buttonPressed);
         this._tooltip.init(param1);
         this._tooltip_error.init(param1);
         visible = false;
      }
      
      public function set fsm(param1:IBattleFsm) : void
      {
         this._fsm = param1;
      }
      
      private function buttonPressed(param1:*) : void
      {
         this.listener.guiPropPopupUsed();
      }
      
      public function show() : void
      {
         this._showing = true;
         visible = this._showing && Boolean(this._entity);
      }
      
      public function hide() : void
      {
         this._showing = false;
         visible = this._showing && Boolean(this._entity);
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function handleConfirm() : Boolean
      {
         return false;
      }
      
      public function cleanup() : void
      {
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         var _loc5_:* = null;
         if(this._entity == param1)
         {
            return;
         }
         this._entity = param1;
         var _loc2_:Usability = !!this._entity ? this._entity.usability : null;
         visible = this._showing && Boolean(this._entity) && Boolean(_loc2_);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:String = this._entity.name;
         this._tooltip.setText(_loc3_);
         var _loc4_:IBattleAbilityDef = _loc2_.abilityDef;
         _loc5_ = !!_loc4_ ? _loc4_.name : "";
         if(_loc2_.def.limit)
         {
            _loc5_ += " Uses: " + _loc2_.useCount + "/" + _loc2_.def.limit;
         }
         var _loc6_:IBattleEntity = !!this._fsm ? this._fsm.activeEntity : null;
         if(_loc6_)
         {
            if(!_loc2_.isInRange(_loc6_))
            {
               _loc5_ += " ... Get Closer";
            }
         }
         this._tooltip_error.visible = false;
         if(_loc5_ != "")
         {
            this._tooltip_error.visible = true;
            this._tooltip_error.setText(_loc5_);
         }
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function updatePopup(param1:int) : void
      {
         if(this._showing && this._entity && !this._entity.usable)
         {
            this.hide();
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         if(this._entity && this._entity.usable && param1 == GpControlButton.A)
         {
            this.listener.guiPropPopupUsed();
            return true;
         }
         return false;
      }
   }
}
