package game.gui.battle
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.ability.IAbilityDef;
   import engine.ability.def.AbilityDef;
   import engine.gui.StickWangler;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiSelfPopupAbility extends GuiBase
   {
       
      
      public var _button_ability1:GuiPopupAbilityButton;
      
      public var _button_ability2:GuiPopupAbilityButton;
      
      public var _button_ability3:GuiPopupAbilityButton;
      
      public var _cancel_button:ButtonWithIndex;
      
      private var popup:GuiSelfPopup;
      
      private var _abilityDefs:Vector.<AbilityDef>;
      
      private var wangler:StickWangler;
      
      private var _maxStars:int;
      
      public function GuiSelfPopupAbility()
      {
         super();
         this.wangler = new StickWangler(this);
         this._button_ability1 = getChildByName("button_ability1") as GuiPopupAbilityButton;
         this._button_ability2 = getChildByName("button_ability2") as GuiPopupAbilityButton;
         this._button_ability3 = getChildByName("button_ability3") as GuiPopupAbilityButton;
         this._cancel_button = getChildByName("cancel_button") as ButtonWithIndex;
      }
      
      public function get abilityDefs() : Vector.<AbilityDef>
      {
         return this._abilityDefs;
      }
      
      public function set abilityDefs(param1:Vector.<AbilityDef>) : void
      {
         this._abilityDefs = param1;
         this.setupButtonAbility(this._button_ability1,0);
         this._button_ability1.ttAlign = "right";
         this.setupButtonAbility(this._button_ability2,1);
         this._button_ability2.ttAlign = "center";
         this.setupButtonAbility(this._button_ability3,2);
         this._button_ability3.ttAlign = "left";
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "SELFPOPUP visible=" + visible + "\n";
         _loc1_ += "SELFPOPUP _abilityDefs=" + (!!this._abilityDefs ? this._abilityDefs.join(",") : "NONE") + "\n";
         _loc1_ += this._button_ability1.getDebugString();
         _loc1_ += this._button_ability2.getDebugString();
         return _loc1_ + this._button_ability3.getDebugString();
      }
      
      private function setupButtonAbility(param1:GuiPopupAbilityButton, param2:int) : void
      {
         param1.visible = Boolean(this._abilityDefs) && this._abilityDefs.length > param2;
         param1.abilityDef = param1.visible ? this._abilityDefs[param2] : null;
      }
      
      public function init(param1:IGuiContext, param2:GuiSelfPopup) : void
      {
         stop();
         initGuiBase(param1);
         this.popup = param2;
         this._button_ability1.init(param1,param2);
         this._button_ability1.setDownFunction(this.buttonAbilityHandler);
         this._button_ability2.init(param1,param2);
         this._button_ability2.setDownFunction(this.buttonAbilityHandler);
         this._button_ability3.init(param1,param2);
         this._button_ability3.setDownFunction(this.buttonAbilityHandler);
         this._cancel_button.guiButtonContext = param1;
         this._cancel_button.setDownFunction(this.buttonCancelHandler);
         this.wangler.addButton(this._button_ability1);
         this.wangler.addButton(this._button_ability2);
         this.wangler.addButton(this._button_ability3);
         if(PlatformInput.hasClicker)
         {
            this.wangler.addButton(this._cancel_button);
         }
         else
         {
            this._cancel_button.visible = false;
         }
         this.stop();
      }
      
      public function cleanup() : void
      {
         this.popup = null;
         this.wangler.cleanup();
         this._button_ability1.cleanup();
         this._button_ability2.cleanup();
         this._button_ability3.cleanup();
         this._cancel_button.cleanup();
         this.stop();
         super.cleanupGuiBase();
      }
      
      private function buttonCancelHandler(param1:ButtonWithIndex) : void
      {
         this.popup.handleAbilityCancel();
      }
      
      private function buttonAbilityHandler(param1:GuiPopupAbilityButton) : void
      {
         if(!param1.blockedReason)
         {
            this.popup.handleAbilityClick(param1.abilityDef);
         }
      }
      
      public function handleGpButton() : Boolean
      {
         if(this.wangler.visible)
         {
            return this.wangler.handleGpButton();
         }
         return false;
      }
      
      public function updatePopup(param1:int) : void
      {
         if(!visible)
         {
            return;
         }
         this.wangler.update(param1);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         this.wangler.visible = param1;
      }
      
      public function updateWillpower(param1:int) : void
      {
         this._maxStars = param1;
         if(this._button_ability1)
         {
            this._button_ability1.updateWillpower(param1);
         }
         if(this._button_ability2)
         {
            this._button_ability2.updateWillpower(param1);
         }
         if(this._button_ability3)
         {
            this._button_ability3.updateWillpower(param1);
         }
      }
   }
}
