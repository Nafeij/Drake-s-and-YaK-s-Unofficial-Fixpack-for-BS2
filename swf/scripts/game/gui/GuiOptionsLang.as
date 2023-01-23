package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuiOptionsLang extends GuiBase implements IGuiOptionsLang
   {
       
      
      private var _button_close:ButtonWithIndex;
      
      private var listener:IGuiOptionsLangListener;
      
      private var buttons:Vector.<ButtonWithIndex>;
      
      private var langs:Vector.<String>;
      
      private var nav:GuiGpNav;
      
      private var _chits:GuiChitsGroup;
      
      private var _button_prev:ButtonWithIndex;
      
      private var _button_next:ButtonWithIndex;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      public function GuiOptionsLang()
      {
         this.buttons = new Vector.<ButtonWithIndex>();
         this.langs = new Vector.<String>();
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.cmd_l1 = new Cmd("cmd_lang_l1",this.func_cmd_l1);
         this.cmd_r1 = new Cmd("cmd_lang_r1",this.func_cmd_r1);
         super();
         name = "GuiOptionsLang";
         super.visible = false;
         this.gp_b.visible = true;
         addChild(this.gp_b);
         addChild(this.gp_l1);
         addChild(this.gp_r1);
      }
      
      public function init(param1:IGuiContext, param2:IGuiOptionsLangListener) : void
      {
         var _loc6_:ButtonWithIndex = null;
         initGuiBase(param1);
         this.nav = new GuiGpNav(param1,"optlang",this);
         this.nav.setCallbackNavigate(this.navNavigateHandler);
         this._chits = requireGuiChild("chits") as GuiChitsGroup;
         this._button_prev = requireGuiChild("button_prev") as ButtonWithIndex;
         this._button_next = requireGuiChild("button_next") as ButtonWithIndex;
         this._button_close = requireGuiChild("button_close") as ButtonWithIndex;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numLocales)
         {
            this.langs.push(param1.getLocale(_loc3_));
            _loc3_++;
         }
         var _loc4_:MovieClip = requireGuiChild("button_holder") as MovieClip;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.numChildren)
         {
            _loc6_ = _loc4_.getChildAt(_loc5_) as ButtonWithIndex;
            if(Boolean(_loc6_) && _loc6_ != this._button_close)
            {
               this.setupButton(_loc6_,this.buttonHandler);
               this.nav.add(_loc6_);
            }
            _loc5_++;
         }
         this.onOperationModeChange(null);
         this.listener = param2;
         this._chits.init(param1);
         this._chits.numVisibleChits = 1 + Math.max(0,this.langs.length - this.buttons.length);
         this._chits.activeChitIndex = 0;
         this._chits.visible = this._chits.numVisibleChits > 1;
         this._button_next.visible = this.gp_r1.visible = this._chits.visible;
         this._button_prev.visible = this.gp_l1.visible = this._chits.visible;
         this._button_close.guiButtonContext = param1;
         this._button_close.setDownFunction(this.buttonCloseHandler);
         this._button_next.guiButtonContext = param1;
         this._button_next.setDownFunction(this.buttonNextHandler);
         this._button_prev.guiButtonContext = param1;
         this._button_prev.setDownFunction(this.buttonPrevHandler);
         mouseEnabled = false;
         mouseChildren = true;
         this.visible = false;
         this.setupButtonsForLang();
      }
      
      public function cleanup() : void
      {
         var _loc1_:ButtonWithIndex = null;
         GuiGp.releasePrimaryBitmap(this.gp_b);
         this.nav.cleanup();
         this._button_close.cleanup();
         for each(_loc1_ in this.buttons)
         {
            _loc1_.cleanup();
         }
         cleanupGuiBase();
      }
      
      private function setupButtonsForLang() : void
      {
         var _loc2_:ButtonWithIndex = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.buttons.length)
         {
            _loc2_ = this.buttons[_loc1_];
            _loc3_ = _loc1_ + this._chits.activeChitIndex;
            if(_loc3_ >= this.langs.length)
            {
               _loc2_.visible = false;
            }
            else
            {
               _loc2_.visible = true;
               _loc4_ = this.langs[_loc3_];
               this.setupButtonForLang(_loc2_,_loc4_);
            }
            _loc1_++;
         }
         if(Boolean(context) && Boolean(context.currentLocale))
         {
            this.showOptionsLang(context.currentLocale.id.id);
         }
      }
      
      private function setupButtonForLang(param1:ButtonWithIndex, param2:String) : void
      {
         param1.buttonText = context.translate("lang_" + param2);
         param1.forceLocale = param2;
         param1.disableUnicodeFontFace = false;
      }
      
      private function setupButton(param1:ButtonWithIndex, param2:Function) : void
      {
         param1.index = this.buttons.length;
         this.buttons.push(param1);
         param1.setDownFunction(param2);
         param1.guiButtonContext = context;
         param1.isToggle = true;
         param1.canToggleUp = false;
      }
      
      private function buttonHandler(param1:ButtonWithIndex) : void
      {
         var _loc2_:int = param1.index + this._chits.activeChitIndex;
         var _loc3_:String = context.getLocale(_loc2_);
         this.listener.guiOptionsLangSet(_loc3_);
         this.showOptionsLang(_loc3_);
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsLangClose();
      }
      
      private function buttonNextHandler(param1:ButtonWithIndex) : Boolean
      {
         if(this._chits.activeChitIndex >= this._chits.numVisibleChits - 1)
         {
            return false;
         }
         ++this._chits.activeChitIndex;
         this.setupButtonsForLang();
         return true;
      }
      
      private function buttonPrevHandler(param1:ButtonWithIndex) : Boolean
      {
         if(this._chits.activeChitIndex <= 0)
         {
            return false;
         }
         --this._chits.activeChitIndex;
         this.setupButtonsForLang();
         return true;
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         x = param1 / 2;
         y = param2 / 2;
      }
      
      public function closeOptionsLang() : Boolean
      {
         if(visible)
         {
            context.playSound("ui_generic");
            this.visible = false;
            return true;
         }
         return false;
      }
      
      private function getButtonForLang(param1:String) : ButtonWithIndex
      {
         var _loc3_:ButtonWithIndex = null;
         var _loc4_:int = 0;
         var _loc2_:int = this.langs.indexOf(param1);
         for each(_loc3_ in this.buttons)
         {
            _loc4_ = _loc3_.index + this._chits.activeChitIndex;
            if(_loc4_ == _loc2_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      private function toggleOneButton(param1:ButtonWithIndex, param2:ButtonWithIndex) : void
      {
         param1.toggled = param2 == param1;
      }
      
      private function showOptionsLang(param1:String) : void
      {
         var _loc3_:ButtonWithIndex = null;
         var _loc2_:ButtonWithIndex = this.getButtonForLang(param1);
         for each(_loc3_ in this.buttons)
         {
            this.toggleOneButton(_loc3_,_loc2_);
         }
         this.nav.selected = _loc2_;
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
            this.gp_l1.gplayer = this.gp_r1.gplayer = this.gp_b.gplayer = GpBinder.gpbinder.lastCmdId;
            GuiGp.placeIconLeft(this._button_close,this.gp_b);
            GuiGp.placeIconRight(this._button_prev,this.gp_l1);
            GuiGp.placeIconRight(this._button_next,this.gp_r1);
            if(Boolean(context) && Boolean(context.currentLocale))
            {
               this.showOptionsLang(context.currentLocale.id.id);
            }
            GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
            GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
            PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.onOperationModeChange(null);
         }
         else
         {
            PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            GpBinder.gpbinder.unbind(this.cmd_l1);
            GpBinder.gpbinder.unbind(this.cmd_r1);
         }
      }
      
      public function func_cmd_l1(param1:CmdExec) : void
      {
         this._button_prev.press();
      }
      
      public function func_cmd_r1(param1:CmdExec) : void
      {
         this._button_next.press();
      }
      
      private function navNavigateHandler(param1:int, param2:int, param3:Boolean) : Boolean
      {
         if(param1 == 0 && param2 == 0)
         {
            if(this.buttonPrevHandler(null))
            {
               this.nav.forceSelected = this.buttons[0];
               return true;
            }
         }
         else if(param1 == 2 && param2 == this.buttons.length - 1)
         {
            if(this.buttonNextHandler(null))
            {
               this.nav.forceSelected = this.buttons[this.buttons.length - 1];
               return true;
            }
         }
         return false;
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
