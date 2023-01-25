package game.gui.battle
{
   import engine.ability.IAbilityDef;
   import engine.ability.def.AbilityDef;
   import engine.gui.PopupAbilityValidity;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiIcon;
   import game.gui.GuiToolTip;
   import game.gui.IGuiContext;
   
   public class GuiPopupAbilityButton extends ButtonWithIndex
   {
       
      
      public var _placeholder:MovieClip;
      
      private var _abilityGuiIcon:GuiIcon;
      
      private var _abilityDef:IAbilityDef;
      
      private var _iconIndex:int = 0;
      
      private var _abilityCount:int = -1;
      
      private var _popup:GuiSelfPopup;
      
      private var _blocker:MovieClip;
      
      private var _ability_hover:MovieClip;
      
      private var _tt_whynot:GuiToolTip;
      
      private var _blockedReason:String;
      
      private var _maxStars:int;
      
      private var validity:PopupAbilityValidity;
      
      public function GuiPopupAbilityButton()
      {
         this.validity = new PopupAbilityValidity();
         super();
         this._placeholder = getChildByName("placeholder") as MovieClip;
         this._blocker = getChildByName("blocker") as MovieClip;
         this._ability_hover = getChildByName("ability_hover") as MovieClip;
         this._tt_whynot = getChildByName("tt_whynot") as GuiToolTip;
         if(this._tt_whynot)
         {
            this._tt_whynot.margin = 16;
         }
         if(_tt)
         {
            _tt.margin = 16;
         }
         this._updateHoveringState();
      }
      
      public function get blockedReason() : String
      {
         return this._blockedReason;
      }
      
      public function get abilityCount() : int
      {
         return this._abilityCount;
      }
      
      public function set abilityCount(param1:int) : void
      {
         if(this._abilityCount == param1)
         {
            return;
         }
         this._abilityCount = param1;
         if(this._abilityCount > 1)
         {
            this.abilityGuiIcon = null;
            this.buttonTooltipText = _context.translate("abilities");
            this._blockedReason = null;
            this._tt_whynot.setContent(null,null);
         }
         this.updateWillpower(this._maxStars);
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         var _loc2_:* = "ABILITYBUTTON (" + name + ") ";
         _loc1_ += _loc2_ + "visible=" + visible + "\n";
         _loc1_ += _loc2_ + "_abilityDef=" + this._abilityDef + "\n";
         _loc1_ += _loc2_ + "_iconIndex=" + this._iconIndex + "\n";
         return _loc1_ + (_loc2_ + "_abilityCount=" + this._abilityCount + "\n");
      }
      
      public function init(param1:IGuiContext, param2:GuiSelfPopup) : void
      {
         super.guiButtonContext = param1;
         this.scaleTextToFit = true;
         this._popup = param2;
         this._iconIndex = getChildIndex(this._placeholder);
         if(this._tt_whynot)
         {
            this._tt_whynot.init(param1);
         }
      }
      
      override public function cleanup() : void
      {
         if(this._tt_whynot)
         {
            this._tt_whynot.cleanup();
            this._tt_whynot = null;
         }
         super.cleanup();
      }
      
      public function get abilityDef() : IAbilityDef
      {
         return this._abilityDef;
      }
      
      public function set abilityDef(param1:IAbilityDef) : void
      {
         if(this._abilityCount > 1)
         {
            this.abilityGuiIcon = null;
            return;
         }
         this._abilityDef = param1;
         this.abilityGuiIcon = _context.getAbilityIcon(param1);
         if(!param1)
         {
            this.buttonTooltipText = _context.translate("abilities_none");
         }
         else
         {
            this.buttonTooltipText = param1.name;
         }
         this.updateWillpower(this._maxStars);
      }
      
      public function get abilityGuiIcon() : GuiIcon
      {
         return this._abilityGuiIcon;
      }
      
      public function set abilityGuiIcon(param1:GuiIcon) : void
      {
         if(this._abilityGuiIcon == param1)
         {
            return;
         }
         if(this._abilityGuiIcon)
         {
            if(this._abilityGuiIcon.parent)
            {
               this._abilityGuiIcon.parent.removeChild(this._abilityGuiIcon);
            }
            this._abilityGuiIcon.release();
         }
         this._abilityGuiIcon = param1;
         if(this._abilityGuiIcon)
         {
            this._abilityGuiIcon.x = this._placeholder.x;
            this._abilityGuiIcon.y = this._placeholder.y;
            addChild(this._abilityGuiIcon);
            setChildIndex(this._abilityGuiIcon,this._iconIndex + 1);
         }
      }
      
      public function updateWillpower(param1:int) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         this._maxStars = param1;
         if(this._abilityCount > 1)
         {
            this._blocker.visible = false;
            this._blockedReason = null;
            return;
         }
         var _loc2_:AbilityDef = this._abilityDef as AbilityDef;
         PopupAbilityValidity.isAbilityInvalid(_loc2_,this._popup.entity,_context.logger,this.validity);
         var _loc3_:int = 1;
         if(Boolean(_loc2_) && Boolean(_loc2_.root))
         {
            _loc3_ = _loc2_.root.costs.getValue(StatType.WILLPOWER);
         }
         if(this.validity.valid && param1 >= _loc3_)
         {
            this._blocker.visible = false;
         }
         else
         {
            this._blocker.visible = true;
         }
         if(!this.validity.valid && Boolean(this.validity.leastReason))
         {
            _loc4_ = "ability_invalid_" + this.validity.leastReason;
            _loc5_ = String(_context.translate(_loc4_.toLowerCase()));
            this._blockedReason = _loc5_;
            if(this._tt_whynot)
            {
               this._tt_whynot.setContent(null,_loc5_);
            }
         }
         else
         {
            this._blockedReason = null;
            if(this._tt_whynot)
            {
               this._tt_whynot.setContent(null,null);
               this._updateHoveringState();
            }
         }
      }
      
      override protected function updateState() : void
      {
         super.updateState();
         this._updateHoveringState();
      }
      
      override public function setHovering(param1:Boolean) : void
      {
         super.setHovering(param1);
         this._updateHoveringState();
      }
      
      private function _updateHoveringState() : void
      {
         var _loc1_:Boolean = isHovering;
         if(this._ability_hover)
         {
            this._ability_hover.visible = _loc1_;
            if(_textField)
            {
               _textField.visible = this._ability_hover.visible;
            }
         }
         if(this._tt_whynot)
         {
            this._tt_whynot.visible = _loc1_ && this._tt_whynot.hasContent;
            this._tt_whynot.performLayout();
         }
      }
   }
}
