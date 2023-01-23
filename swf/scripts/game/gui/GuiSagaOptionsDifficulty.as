package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class GuiSagaOptionsDifficulty extends GuiBase implements IGuiSagaOptionsDifficulty
   {
       
      
      private var _button$easy:ButtonWithIndex;
      
      private var _button$hard:ButtonWithIndex;
      
      private var _button$normal:ButtonWithIndex;
      
      private var _button_close:ButtonWithIndex;
      
      public var color_easy:uint = 8693854;
      
      public var color_normal:uint = 6333635;
      
      public var color_hard:uint = 11624794;
      
      private var listener:IGuiSagaOptionsDifficultyListener;
      
      private var _tooltip:MovieClip;
      
      private var tooltip_text:TextField;
      
      private var nav:GuiGpNav;
      
      private var _iconClose:GuiGpBitmap;
      
      private var _hovering:ButtonWithIndex;
      
      private var gplayer:int;
      
      public function GuiSagaOptionsDifficulty()
      {
         this._iconClose = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         super();
         name = "GuiSagaOptionsDifficulty";
         this.visible = false;
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaOptionsDifficultyListener) : void
      {
         initGuiBase(param1);
         this.nav = new GuiGpNav(param1,"diff",this);
         this._button$easy = requireGuiChild("button$easy") as ButtonWithIndex;
         this._button$hard = requireGuiChild("button$hard") as ButtonWithIndex;
         this._button$normal = requireGuiChild("button$normal") as ButtonWithIndex;
         this._button_close = requireGuiChild("button_close") as ButtonWithIndex;
         this._tooltip = requireGuiChild("tooltip") as MovieClip;
         this.nav.add(this._button$easy);
         this.nav.add(this._button$normal);
         this.nav.add(this._button$hard);
         addChild(this._iconClose);
         this._iconClose.visible = true;
         GuiGp.placeIconCenter(this._button_close,this._iconClose);
         this.tooltip_text = this._tooltip.getChildByName("text") as TextField;
         this.tooltip_text.htmlText = "";
         this._tooltip.visible = false;
         var _loc3_:TextField = requireGuiChild("$difficulty") as TextField;
         registerScalableTextfield(_loc3_);
         this.listener = param2;
         this.setupButton(this._button$easy,this.buttonEasyHandler,1);
         this.setupButton(this._button$normal,this.buttonNormalHandler,2);
         this.setupButton(this._button$hard,this.buttonHardHandler,3);
         this._button_close.guiButtonContext = param1;
         this._button_close.setDownFunction(this.buttonCloseHandler);
         this.onOperationModeChange(null);
         mouseEnabled = false;
         mouseChildren = true;
         this.visible = false;
      }
      
      public function cleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this._iconClose);
         this.nav.cleanup();
         this._button$easy.cleanup();
         this._button$normal.cleanup();
         this._button$hard.cleanup();
         this._button_close.cleanup();
         this._button$easy.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
         this._button$hard.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
         this._button$normal.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
         cleanupGuiBase();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         scaleTextfields();
      }
      
      public function get hovering() : ButtonWithIndex
      {
         return this._hovering;
      }
      
      private function getToggledButton() : ButtonWithIndex
      {
         if(this._button$easy.toggled)
         {
            return this._button$easy;
         }
         if(this._button$normal.toggled)
         {
            return this._button$normal;
         }
         if(this._button$hard.toggled)
         {
            return this._button$hard;
         }
         return null;
      }
      
      public function set hovering(param1:ButtonWithIndex) : void
      {
         var _loc2_:ButtonWithIndex = null;
         this._hovering = param1;
         if(_context.saga.isSurvival)
         {
            return;
         }
         if(!this._hovering)
         {
            _loc2_ = this.getToggledButton();
            this.tooltip_text.htmlText = !!_loc2_ ? _loc2_.buttonTooltipText : "";
            this._tooltip.visible = false;
         }
         else
         {
            this.tooltip_text.htmlText = this._hovering.buttonTooltipText;
            _context.locale.fixTextFieldFormat(this.tooltip_text,null,null,true);
            this._tooltip.visible = true;
         }
      }
      
      private function setupButton(param1:ButtonWithIndex, param2:Function, param3:int) : void
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc5_:int = param1.name.indexOf("$");
         if(_loc5_ > 0)
         {
            _loc4_ = param1.name.substr(_loc5_ + 1);
         }
         param1.index = param3;
         param1.setDownFunction(param2);
         if(_loc4_)
         {
            _loc6_ = "color_" + _loc4_;
            if(_loc6_ in this)
            {
               param1.textColor = this[_loc6_];
            }
            param1.buttonTooltipText = _context.translate(_loc4_ + "_tooltip");
         }
         param1.guiButtonContext = context;
         param1.isToggle = true;
         param1.canToggleUp = false;
         param1.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
      }
      
      private function buttonStateHandler(param1:Event) : void
      {
         var _loc2_:ButtonWithIndex = param1.target as ButtonWithIndex;
         if(_loc2_.isHovering || _loc2_.toggled && PlatformInput.isTouch)
         {
            this.hovering = _loc2_;
         }
         else if(this._hovering == _loc2_)
         {
            this.hovering = null;
         }
      }
      
      private function buttonEasyHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsDifficultySet(param1.index);
         this.showSagaOptionsDifficulty(param1.index);
      }
      
      private function buttonNormalHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsDifficultySet(param1.index);
         this.showSagaOptionsDifficulty(param1.index);
      }
      
      private function buttonHardHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsDifficultySet(param1.index);
         this.showSagaOptionsDifficulty(param1.index);
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsDifficultyClose();
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         x = param1 / 2;
         y = param2 / 2;
      }
      
      public function closeOptionsDifficulty() : Boolean
      {
         if(visible)
         {
            context.playSound("ui_generic");
            this.visible = false;
            return true;
         }
         return false;
      }
      
      private function getButtonForDifficulty(param1:int) : ButtonWithIndex
      {
         switch(param1)
         {
            case 1:
               return this._button$easy;
            case 2:
               return this._button$normal;
            case 3:
               return this._button$hard;
            default:
               return null;
         }
      }
      
      private function toggleOneButton(param1:ButtonWithIndex, param2:ButtonWithIndex) : void
      {
         param1.toggled = param2 == param1;
      }
      
      public function showSagaOptionsDifficulty(param1:int) : void
      {
         this._iconClose.gplayer = GpBinder.gpbinder.topLayer;
         this.visible = true;
         _context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this,_context.logger);
         this.setupButton(this._button$easy,this.buttonEasyHandler,1);
         this.setupButton(this._button$normal,this.buttonNormalHandler,2);
         this.setupButton(this._button$hard,this.buttonHardHandler,3);
         var _loc2_:ButtonWithIndex = this.getButtonForDifficulty(param1);
         this.toggleOneButton(this._button$easy,_loc2_);
         this.toggleOneButton(this._button$normal,_loc2_);
         this.toggleOneButton(this._button$hard,_loc2_);
         this.nav.selected = _loc2_;
         if(_context.saga.isSurvival)
         {
            this._button$easy.enabled = false;
            this._button$normal.enabled = false;
            this._button$hard.enabled = false;
            this.tooltip_text.htmlText = _context.translate("survival_difficulty_locked");
            this._tooltip.visible = true;
         }
         else
         {
            this._button$easy.enabled = true;
            this._button$normal.enabled = true;
            this._button$hard.enabled = true;
            this._tooltip.visible = false;
         }
         _context.currentLocale.fixTextFieldFormat(this.tooltip_text);
         this.handleLocaleChange();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(this.nav)
         {
            if(super.visible)
            {
               this.nav.activate();
            }
            else
            {
               this.nav.deactivate();
            }
         }
         if(super.visible)
         {
            PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.onOperationModeChange(null);
         }
         else
         {
            PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
         }
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button_close.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
      }
      
      public function ensureTopGp() : void
      {
         if(this.nav)
         {
            this.nav.reactivate();
         }
      }
   }
}
