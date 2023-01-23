package game.gui
{
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.talent.Talent;
   import engine.talent.Talents;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class GuiPgStatDisplay extends GuiBase
   {
       
      
      private const statTextChangedColor:uint = 16777215;
      
      private const statTextChangedRedColor:uint = 16723245;
      
      private const statTextChangedGlowColor:uint = 16743936;
      
      private const statTextDefaultColor:uint = 16767921;
      
      private const statTextDefaultGlowColor:uint = 0;
      
      private var _placeholder_talent:MovieClip;
      
      private var _numbers:MovieClip;
      
      private var _numerator:TextField;
      
      private var _denominator:TextField;
      
      public var _buttonStat:GuiStatButton;
      
      public var _buttonMinus:ButtonWithIndex;
      
      public var _buttonPlus:ButtonWithIndex;
      
      private var _modifyCallback:Function;
      
      private var _statCallback:Function;
      
      private var _statDisplayButtonVisibilityHandler:Function;
      
      public var statType:StatType;
      
      public var _pointsAvailable:int;
      
      public var _originalPointsAvailable:int;
      
      private var _value:int;
      
      private var _original:int;
      
      private var _max:int;
      
      private var _talents:Talents;
      
      private var _talentIcon:GuiIcon;
      
      private var gp_dpad_left:GuiGpBitmap;
      
      private var gp_dpad_right:GuiGpBitmap;
      
      private var _lastTalent:Talent;
      
      public function GuiPgStatDisplay()
      {
         super();
         this._numbers = getChildByName("numbers") as MovieClip;
         this._numerator = this._numbers.getChildByName("numerator") as TextField;
         this._denominator = this._numbers.getChildByName("denominator") as TextField;
         this._buttonStat = getChildByName("buttonStat") as GuiStatButton;
         this._buttonMinus = getChildByName("buttonMinus") as ButtonWithIndex;
         this._buttonPlus = getChildByName("buttonPlus") as ButtonWithIndex;
         this._placeholder_talent = getChildByName("placeholder_talent") as MovieClip;
         this._placeholder_talent.visible = false;
      }
      
      private function updateButtonState() : void
      {
         var _loc1_:Boolean = this._buttonPlus.visible;
         var _loc2_:Boolean = this._buttonMinus.visible;
         if(this._originalPointsAvailable == 0 || !Stats.isUserChangedStat(this.statType))
         {
            this._buttonPlus.visible = false;
            this._buttonMinus.visible = false;
         }
         else
         {
            if(this._original == this._max)
            {
               this._buttonPlus.visible = false;
            }
            else
            {
               this._buttonPlus.visible = true;
               this._buttonPlus.enabled = this._value < this._max && Boolean(this._pointsAvailable);
               this._buttonPlus.alpha = this._buttonPlus.enabled ? 1 : 0.7;
            }
            this._buttonMinus.visible = this._value > this._original;
         }
         if(this.gp_dpad_left)
         {
            this.gp_dpad_left.visible = this._buttonMinus.visible;
         }
         if(this.gp_dpad_right)
         {
            this.gp_dpad_right.visible = this._buttonPlus.visible;
         }
         if(_loc1_ != this._buttonPlus.visible || _loc2_ != this._buttonMinus.visible)
         {
            if(this._statDisplayButtonVisibilityHandler != null)
            {
               this._statDisplayButtonVisibilityHandler(this);
            }
         }
      }
      
      public function init(param1:IGuiContext, param2:StatType, param3:Talents, param4:Function, param5:Function, param6:Function) : void
      {
         super.initGuiBase(param1);
         this.statType = param2;
         this._modifyCallback = param4;
         this._statCallback = param5;
         this._statDisplayButtonVisibilityHandler = param6;
         this._buttonMinus.guiButtonContext = param1;
         this._buttonPlus.guiButtonContext = param1;
         this._buttonMinus.clickSound = this._buttonPlus.clickSound = null;
         this._buttonStat.init(param1,param2);
         this._buttonStat.setDownFunction(this.buttonStatPressHandler);
         this._buttonMinus.setDownFunction(this.buttonMinusPressHandler);
         this._buttonPlus.setDownFunction(this.buttonPlusPressHandler);
      }
      
      public function cleanup() : void
      {
         this._buttonStat.cleanup();
         this._buttonMinus.cleanup();
         this._buttonPlus.cleanup();
         this._modifyCallback = null;
         this._statCallback = null;
         this._statDisplayButtonVisibilityHandler = null;
         GuiGp.releasePrimaryBitmap(this.gp_dpad_left);
         GuiGp.releasePrimaryBitmap(this.gp_dpad_right);
         this._modifyCallback = null;
         super.cleanupGuiBase();
      }
      
      private function buttonStatPressHandler(param1:ButtonWithIndex) : void
      {
         this._statCallback(this);
      }
      
      private function buttonMinusPressHandler(param1:ButtonWithIndex) : void
      {
         this._modifyCallback(this,-1);
      }
      
      private function buttonPlusPressHandler(param1:ButtonWithIndex) : void
      {
         this._modifyCallback(this,1);
      }
      
      public function get modified() : Boolean
      {
         return this._value != this._original;
      }
      
      public function setStatValue(param1:int, param2:int, param3:int, param4:int, param5:int) : void
      {
         this._pointsAvailable = param4;
         this._originalPointsAvailable = param5;
         this._value = param1;
         this._original = param2;
         this._max = param3;
         if(this.statType == null)
         {
            this._numerator.visible = false;
            this._denominator.visible = false;
         }
         else
         {
            this._numerator.visible = true;
            this._denominator.visible = true;
            this._numerator.text = param1.toString();
            this._denominator.text = "/" + param3;
         }
         this._buttonStat.setStatValue(this._value,this._original,this._max,param4,param5);
         this.updateTextColorsAndGlows();
         this.updateButtonState();
      }
      
      private function setTextColorsAndGlows(param1:uint, param2:uint) : void
      {
         var _loc3_:GlowFilter = this._numerator.filters[0] as GlowFilter;
         _loc3_.color = param2;
         this._numerator.filters = [_loc3_];
         var _loc4_:GlowFilter = this._numerator.filters[0] as GlowFilter;
         this._numerator.textColor = param1;
      }
      
      private function updateTextColorsAndGlows() : void
      {
         if(this._original == this._value)
         {
            this.setTextColorsAndGlows(this.statTextDefaultColor,this.statTextDefaultGlowColor);
         }
         else
         {
            this.setTextColorsAndGlows(this.statTextChangedColor,this.statTextChangedGlowColor);
         }
      }
      
      public function activateGp(param1:GuiGpBitmap, param2:GuiGpBitmap) : void
      {
         this.gp_dpad_left = param1;
         this.gp_dpad_right = param2;
         param1.visible = this._buttonMinus.visible;
         param2.visible = this._buttonPlus.visible;
         GuiGp.placeIconBottom(this._buttonMinus,param1,GuiGpAlignV.S_DOWN);
         GuiGp.placeIconBottom(this._buttonPlus,param2,GuiGpAlignV.S_DOWN);
      }
      
      public function deactivateGp() : void
      {
         this.gp_dpad_left = null;
         this.gp_dpad_right = null;
      }
      
      public function set availablePoints(param1:int) : void
      {
         this._buttonStat.availablePoints = param1;
         var _loc2_:Talent = this._talents.getTalentByParentStatType(this.statType);
         this.checkTalentIcon();
      }
      
      public function get talents() : Talents
      {
         return this._talents;
      }
      
      public function set talents(param1:Talents) : void
      {
         this._lastTalent = null;
         this._talents = param1;
         this._buttonStat.talents = param1;
         this.checkTalentIcon();
      }
      
      private function checkTalentIcon() : void
      {
         if(!this.statType)
         {
            return;
         }
         var _loc1_:Talent = this._talents.getTalentByParentStatType(this.statType);
         if(this._original == this._max && _loc1_ && _loc1_.rank > 0)
         {
            if(this._lastTalent != _loc1_ || this._talentIcon == null)
            {
               this.talentIcon = _context.getIcon(_loc1_.def.getIconPath());
            }
         }
         else
         {
            this.talentIcon = null;
         }
         this._lastTalent = _loc1_;
      }
      
      public function set talentIcon(param1:GuiIcon) : void
      {
         if(this._talentIcon == param1)
         {
            return;
         }
         if(this._talentIcon)
         {
            if(this._talentIcon.parent)
            {
               this._talentIcon.parent.removeChild(this._talentIcon);
            }
            this._talentIcon.release();
         }
         this._talentIcon = param1;
         if(this._talentIcon)
         {
            this._talentIcon.setTargetSize(this._placeholder_talent.width,this._placeholder_talent.height);
            this._talentIcon.layout = GuiIconLayoutType.CENTER_FIT;
            this._talentIcon.x = this._placeholder_talent.x;
            this._talentIcon.y = this._placeholder_talent.y;
            addChild(this._talentIcon);
         }
      }
   }
}
