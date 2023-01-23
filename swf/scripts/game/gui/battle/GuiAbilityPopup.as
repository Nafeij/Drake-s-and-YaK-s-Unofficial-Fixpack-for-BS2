package game.gui.battle
{
   import engine.ability.IAbilityDef;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiIcon;
   import game.gui.IGuiContext;
   
   public class GuiAbilityPopup extends GuiBase implements IGuiAbilityPopup
   {
       
      
      private var icon:ButtonWithIndex;
      
      private var listener:IGuiAbilityPopupListener;
      
      public var _starsContainer:GuiStarsContainer;
      
      public var _animButton:MovieClip;
      
      private var _abilityGuiIcon:GuiIcon;
      
      private var _lastAbility:IAbilityDef;
      
      private var displayDamage:Boolean;
      
      private var damageFlag:MovieClip;
      
      private var damageAmount:int;
      
      private var bmp_dpad:GuiGpBitmap;
      
      private var bmp_a:GuiGpBitmap;
      
      private var _callbackNeedsInitialization:Boolean;
      
      private var _displayDirty:Boolean = true;
      
      private var availableTargetCount:int = 0;
      
      public function GuiAbilityPopup()
      {
         this.bmp_dpad = GuiGp.ctorPrimaryBitmap(GpControlButton.D_LR);
         this.bmp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
         super();
         this.name = "gui_ability_popup";
         addChild(this.bmp_dpad);
         addChild(this.bmp_a);
         this.bmp_a.scale = 0.75;
      }
      
      public function init(param1:IGuiContext, param2:IGuiAbilityPopupListener) : void
      {
         this.listener = param2;
         initGuiBase(param1);
         stop();
         visible = false;
         this._starsContainer = getGuiChild("starsContainer") as GuiStarsContainer;
         this._animButton = getGuiChild("animButton") as MovieClip;
         this._animButton.stop();
         this._starsContainer.init(param1,this.onStarSelectedChanged);
         this._callbackNeedsInitialization = true;
      }
      
      public function cleanup() : void
      {
         this.hide();
         GuiGp.releasePrimaryBitmap(this.bmp_a);
         GuiGp.releasePrimaryBitmap(this.bmp_dpad);
         this.abilityGuiIcon = null;
         if(this.icon)
         {
            this.icon.cleanup();
         }
         this._starsContainer.cleanup();
         if(this._animButton)
         {
            this._animButton.removeEventListener(Event.EXIT_FRAME,this.buttonAnimationFrameChanged);
         }
         super.cleanupGuiBase();
      }
      
      public function starsMod(param1:int) : void
      {
         if(!visible)
         {
            return;
         }
         if(!this._starsContainer)
         {
            return;
         }
         this._starsContainer.starsMod(param1);
      }
      
      public function doConfirmClick() : void
      {
         if(!visible || !this._abilityGuiIcon.visible)
         {
            _context.logger.error("GuiAbilityPopup.doConfirmClick with nothing to click on");
            return;
         }
         if(this.listener)
         {
            this.listener.guiAbilityPopupExecute(this._starsContainer.selectedStars());
            this.hide();
         }
      }
      
      private function iconButtonClicked(param1:ButtonWithIndex) : void
      {
         this.doConfirmClick();
      }
      
      private function buttonAnimationFrameChanged(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         this.icon = this._animButton.getChildByName("ability_button") as ButtonWithIndex;
         _loc2_ = this.icon.getChildByName("abilityPopupIcon") as MovieClip;
         this.damageFlag = this._animButton.getChildByName("damageFlag") as MovieClip;
         (this.damageFlag.getChildByName("damage_text") as TextField).text = this.damageAmount.toString();
         this.damageFlag.visible = this.displayDamage;
         _loc2_.addChildAt(this._abilityGuiIcon,_loc2_.numChildren - 1);
         this.icon.setDownFunction(this.iconButtonClicked);
         if(this._animButton.currentFrame >= this._animButton.totalFrames)
         {
            this.mouseEnabled = true;
            this.mouseChildren = true;
            this._animButton.stop();
            this._animButton.removeEventListener(Event.EXIT_FRAME,this.buttonAnimationFrameChanged);
         }
      }
      
      public function show(param1:IAbilityDef, param2:int, param3:int, param4:int, param5:Boolean = true) : void
      {
         var _loc6_:int = 0;
         this.availableTargetCount = param3;
         if(Boolean(this.context) && this._lastAbility != param1)
         {
            this.abilityGuiIcon = this.context.getAbilityIcon(param1);
            this._lastAbility = param1;
         }
         this.damageAmount = param2;
         this.displayDamage = Boolean(param1) && param1.displayDamageUI;
         visible = true;
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this._displayDirty = true;
         if(this._animButton)
         {
            this._animButton.addEventListener(Event.EXIT_FRAME,this.buttonAnimationFrameChanged);
            this._animButton.play();
         }
         if(Boolean(this._starsContainer) && Boolean(param1))
         {
            _loc6_ = param1.optionalStars;
            _loc6_ -= param4 - 1;
            this._starsContainer.showing(param1.level,_loc6_);
            if(this._callbackNeedsInitialization && param5)
            {
               this._starsContainer.triggerCallback();
               this._callbackNeedsInitialization = false;
            }
         }
      }
      
      public function hide() : void
      {
         if(visible)
         {
            gotoAndStop(1);
            this._animButton.gotoAndStop(1);
            this._animButton.removeEventListener(Event.EXIT_FRAME,this.buttonAnimationFrameChanged);
            this._starsContainer.restart();
            visible = false;
            this._callbackNeedsInitialization = true;
         }
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      private function set abilityGuiIcon(param1:GuiIcon) : void
      {
         if(this._abilityGuiIcon == param1)
         {
            return;
         }
         if(this._abilityGuiIcon)
         {
            this._abilityGuiIcon.release();
         }
         this._abilityGuiIcon = param1;
      }
      
      private function onStarSelectedChanged(param1:int) : void
      {
         var stars:int = param1;
         try
         {
            this.listener.guiAbilityPopupChanged(stars);
         }
         catch(e:Error)
         {
            _context.logger.error("Failed to change stars:\n" + e.getStackTrace());
         }
      }
      
      public function handleConfirm() : Boolean
      {
         if(visible && Boolean(this.listener))
         {
            this.listener.guiAbilityPopupExecute(this._starsContainer.selectedStars());
            this.hide();
            return true;
         }
         return false;
      }
      
      public function resetDisplay() : void
      {
         this._displayDirty = false;
         this.bmp_a.visible = true;
         this.bmp_dpad.visible = false;
         if(this.availableTargetCount > 1)
         {
            this.bmp_dpad.visible = true;
            this.bmp_dpad.x = -this.bmp_dpad.width / 2;
            this.bmp_dpad.y = -80 - this.bmp_dpad.height;
         }
         this.bmp_a.visible = true;
         this.bmp_a.x = -this.bmp_a.width / 2;
         this.bmp_a.y = 0;
      }
      
      public function updatePopup(param1:int) : void
      {
         if(!visible || !parent)
         {
            return;
         }
         if(this._displayDirty)
         {
            this.resetDisplay();
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         if(param1 == GpControlButton.A)
         {
            return this.handleConfirm();
         }
         return false;
      }
      
      public function doHighlight(param1:Boolean) : void
      {
         if(this.icon)
         {
            this.icon.setHovering(param1);
         }
      }
   }
}
