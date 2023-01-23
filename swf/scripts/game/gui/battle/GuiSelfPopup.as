package game.gui.battle
{
   import com.stoicstudio.platform.PlatformDisplay;
   import engine.ability.IAbilityDef;
   import engine.ability.def.AbilityDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.gp.GpControlButton;
   import engine.gui.BattleHudConfig;
   import engine.gui.GuiUtil;
   import flash.display.Sprite;
   import flash.events.Event;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiSelfPopup extends GuiBase implements IGuiSelfPopup
   {
       
      
      public var _basic:GuiSelfPopupBasic;
      
      public var _ability_self_popup:GuiSelfPopupAbility;
      
      public var listener:IGuiPopupListener;
      
      private var abilityDefs:Vector.<AbilityDef>;
      
      private var _entity:IBattleEntity;
      
      public var cancel_button:ButtonWithIndex;
      
      private var moveExecuted:Boolean = false;
      
      private var _showSelfPopup:Boolean = false;
      
      private var startingParent:Sprite;
      
      public function GuiSelfPopup()
      {
         super();
         name = "assets.self_popup";
      }
      
      public function get showSelfPopup() : Boolean
      {
         return this._showSelfPopup;
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "GUISELFPOPUP abilityDefs=" + (!!this.abilityDefs ? this.abilityDefs.join(",") : "NONE") + "\n";
         _loc1_ += "GUISELFPOPUP _entity=" + this._entity + "\n";
         _loc1_ += "GUISELFPOPUP _showSelfPopup=" + this._showSelfPopup + "\n";
         _loc1_ += this._basic.getDebugString();
         return _loc1_ + this._ability_self_popup.getDebugString();
      }
      
      public function set showSelfPopup(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(param1 != this._showSelfPopup)
         {
            _loc2_ = 0;
            _loc2_ = 5;
         }
         this._showSelfPopup = param1;
         this._basic.showSelfPopupBasic();
         this.checkVisibility();
      }
      
      public function init(param1:IGuiContext, param2:IGuiPopupListener) : void
      {
         this._basic = getChildByName("basic") as GuiSelfPopupBasic;
         this._ability_self_popup = getChildByName("ability_self_popup") as GuiSelfPopupAbility;
         stop();
         this.startingParent = this.parent as Sprite;
         initGuiBase(param1);
         this.listener = param2;
         this.mouseEnabled = false;
         this.mouseChildren = true;
         this.showSelfPopup = false;
         this._basic.init(param1,this);
         this._ability_self_popup.init(param1,this);
         param1.battleHudConfig.addEventListener(BattleHudConfig.EVENT_CHANGED,this.configHandler);
         this.configHandler(null);
         PlatformDisplay.disableEdgeAAMode(this);
      }
      
      public function cleanup() : void
      {
         if(this.cancel_button)
         {
            this.cancel_button.cleanup();
         }
         this._basic.cleanup();
         this._ability_self_popup.cleanup();
         context.battleHudConfig.removeEventListener(BattleHudConfig.EVENT_CHANGED,this.configHandler);
         super.cleanupGuiBase();
      }
      
      private function configHandler(param1:Event) : void
      {
         this.checkVisibility();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
         }
         super.visible = param1;
      }
      
      private function checkVisibility() : void
      {
         var _loc1_:Boolean = this._showSelfPopup && context.battleHudConfig.selfPopup;
         if(_loc1_ != this.visible)
         {
            this.visible = _loc1_;
            if(!visible)
            {
               this.hideSelfPopup();
            }
            GuiUtil.updateDisplayList(this,this.startingParent);
         }
         this._basic.checkConfig();
      }
      
      public function hotEndTurn(param1:IBattleEntity) : void
      {
         this.showSelfPopup = true;
         this._basic.hotEndTurn(param1);
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      private function hideSelfPopup() : void
      {
         this._basic.hideSelfPopupBasic();
         this._ability_self_popup.visible = false;
      }
      
      public function updateWillpower(param1:int) : void
      {
         this._basic.updateWillpower(param1);
         this._ability_self_popup.updateWillpower(param1);
      }
      
      private function resetSelfPopup(param1:ButtonWithIndex = null) : void
      {
         this.showSelfPopup = true;
         this._basic.showSelfPopupBasic();
         if(this.cancel_button)
         {
            this.cancel_button.setStateToNormal();
         }
         this._ability_self_popup.visible = false;
         this._basic.showSelfPopupBasic();
      }
      
      public function setValues(param1:Vector.<AbilityDef>, param2:Boolean, param3:Boolean, param4:Boolean) : void
      {
         this.abilityDefs = param1;
         this.moveExecuted = param2 && param4;
         this._basic.setValues(this.abilityDefs,param2,param3,param4);
         if(param3)
         {
            this.resetSelfPopup();
         }
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         if(this._entity == param1)
         {
            if(!this._entity || visible && parent)
            {
               return;
            }
         }
         this._entity = param1;
         this._basic.entity = param1;
         this.resetSelfPopup();
         if(this._entity == null)
         {
            this.hideSelfPopup();
         }
         else
         {
            this.showSelfPopup = true;
         }
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function handleConfirm() : Boolean
      {
         if(!visible)
         {
            return false;
         }
         return this._basic.handleConfirm();
      }
      
      public function handleBasicAbilityClick() : void
      {
         if(Boolean(this.abilityDefs) && this.abilityDefs.length > 1)
         {
            this._basic.visible = false;
            this._ability_self_popup.visible = true;
            this._ability_self_popup.abilityDefs = this.abilityDefs;
         }
      }
      
      public function handleAbilityCancel() : void
      {
         this._basic.visible = true;
         this._ability_self_popup.visible = false;
         this._ability_self_popup.abilityDefs = null;
      }
      
      public function handleAbilityClick(param1:IAbilityDef) : void
      {
         if(param1)
         {
            this.listener.selfAbilitySelect(param1.id);
         }
         this.entity = null;
      }
      
      public function updatePopup(param1:int) : void
      {
         if(Boolean(this._basic) && this._basic.visible)
         {
            this._basic.updatePopup(param1);
         }
         if(Boolean(this._ability_self_popup) && this._ability_self_popup.visible)
         {
            this._ability_self_popup.updatePopup(param1);
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         if(!visible || !parent)
         {
            return false;
         }
         if(param1 == GpControlButton.A)
         {
            if(Boolean(this._basic) && this._basic.visible)
            {
               return this._basic.handleGpButton();
            }
            if(Boolean(this._ability_self_popup) && this._ability_self_popup.visible)
            {
               return this._ability_self_popup.handleGpButton();
            }
         }
         else if(param1 == GpControlButton.B)
         {
            if(Boolean(this._ability_self_popup) && this._ability_self_popup.visible)
            {
               this.handleAbilityCancel();
               return true;
            }
            if(this._basic && this._basic.visible && this.moveExecuted)
            {
            }
         }
         return false;
      }
      
      public function update(param1:int) : void
      {
         if(!visible)
         {
            return;
         }
         if(Boolean(this._basic) && this._basic.visible)
         {
            this._basic.update(param1);
         }
      }
   }
}
