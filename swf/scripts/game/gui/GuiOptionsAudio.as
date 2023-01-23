package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class GuiOptionsAudio extends GuiBase implements IGuiOptionsAudio
   {
       
      
      private var _button_close:ButtonWithIndex;
      
      private var listener:IGuiOptionsAudioListener;
      
      public var nav:GuiGpNav;
      
      private var _iconClose:GuiGpBitmap;
      
      public var cc_button:ButtonWithIndex;
      
      public var busses:Vector.<Bus>;
      
      private var gplayer:int;
      
      public function GuiOptionsAudio()
      {
         this._iconClose = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.busses = new Vector.<Bus>();
         super();
         name = "GuiSagaOptionsAudio";
         this.visible = false;
      }
      
      public function init(param1:IGuiContext, param2:IGuiOptionsAudioListener) : void
      {
         initGuiBase(param1,true);
         this.nav = new GuiGpNav(param1,"diff",this);
         this._button_close = requireGuiChild("button_close") as ButtonWithIndex;
         addChild(this._iconClose);
         this._iconClose.visible = true;
         GuiGp.placeIconCenter(this._button_close,this._iconClose);
         var _loc3_:TextField = requireGuiChild("$opt_audio") as TextField;
         registerScalableTextfield(_loc3_);
         this.listener = param2;
         this._button_close.guiButtonContext = param1;
         this._button_close.setDownFunction(this.buttonCloseHandler);
         this.onOperationModeChange(null);
         mouseEnabled = false;
         mouseChildren = true;
         this._initBusses();
         this._initCc();
         this.visible = false;
      }
      
      private function _initBusses() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:Bus = null;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as MovieClip;
            if(_loc2_)
            {
               if(StringUtil.startsWith(_loc2_.name,"bus_"))
               {
                  _loc3_ = _loc2_.name.substring(4);
                  _loc4_ = new Bus().init(_loc3_,this,_loc2_);
                  this.busses.push(_loc4_);
               }
            }
            _loc1_++;
         }
      }
      
      private function _initCc() : void
      {
         this.cc_button = getChildByName("button_cc") as ButtonWithIndex;
         this.cc_button.setDownFunction(this.onCcClicked);
         this.cc_button.noMouseEventsOnDisable = false;
         this.cc_button.isToggle = true;
         this.cc_button.toggled = !context.getPref(GuiGamePrefs.PREF_OPTION_CC);
         this.cc_button.guiButtonContext = context;
         this.nav.add(this.cc_button);
      }
      
      public function cleanup() : void
      {
         var _loc1_:Bus = null;
         GuiGp.releasePrimaryBitmap(this._iconClose);
         this.nav.cleanup();
         for each(_loc1_ in this.busses)
         {
            _loc1_.cleanup();
         }
         this.busses = null;
         this._button_close.cleanup();
         cleanupGuiBase();
      }
      
      override public function handleLocaleChange() : void
      {
         var _loc1_:Bus = null;
         super.handleLocaleChange();
         for each(_loc1_ in this.busses)
         {
            _loc1_.handleLocaleChange();
         }
         scaleTextfields();
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsAudioClose();
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         x = param1 / 2;
         y = param2 / 2;
      }
      
      public function closeOptionsAudio() : Boolean
      {
         if(visible)
         {
            context.playSound("ui_generic");
            this.visible = false;
            return true;
         }
         return false;
      }
      
      public function showOptionsAudio() : void
      {
         this._iconClose.gplayer = GpBinder.gpbinder.topLayer;
         this.visible = true;
         _context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this,_context.logger);
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
            this.cc_button.toggled = Boolean(context) && !context.getPref(GuiGamePrefs.PREF_OPTION_CC);
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
      
      private function onCcClicked(param1:Object) : void
      {
         context.setPref(GuiGamePrefs.PREF_OPTION_CC,!this.cc_button.toggled);
      }
   }
}

import com.greensock.TweenMax;
import engine.math.MathUtil;
import engine.sound.config.ISoundMixer;
import flash.display.MovieClip;
import flash.text.TextField;
import game.gui.ButtonWithIndex;
import game.gui.GuiChitsGroup;
import game.gui.GuiOptionsAudio;
import game.gui.IGuiContext;

class Bus
{
    
   
   public var audio:GuiOptionsAudio;
   
   public var name:String;
   
   public var _button_mute:ButtonWithIndex;
   
   public var _button_down:ButtonWithIndex;
   
   public var _button_up:ButtonWithIndex;
   
   public var _chits:GuiChitsGroup;
   
   public var _text_name:TextField;
   
   public var _pulse_mute:MovieClip;
   
   public var context:IGuiContext;
   
   public var container:MovieClip;
   
   public function Bus()
   {
      super();
   }
   
   public function init(param1:String, param2:GuiOptionsAudio, param3:MovieClip) : Bus
   {
      this.name = param1;
      this.audio = param2;
      this.context = param2.context;
      this.container = param3;
      this._button_mute = param3.getChildByName("button_mute") as ButtonWithIndex;
      this._button_mute.setDownFunction(this.onMuteClicked);
      this._button_mute.noMouseEventsOnDisable = false;
      this._button_mute.guiButtonContext = this.context;
      this._button_mute.isToggle = true;
      this._button_down = param3.getChildByName("button_down") as ButtonWithIndex;
      this._button_down.setDownFunction(this.onButtonDownClicked);
      this._button_down.guiButtonContext = this.context;
      this._button_up = param3.getChildByName("button_up") as ButtonWithIndex;
      this._button_up.setDownFunction(this.onButtonUpClicked);
      this._button_up.guiButtonContext = this.context;
      this._pulse_mute = param3.getChildByName("pulse_mute") as MovieClip;
      this._pulse_mute.mouseEnabled = this._pulse_mute.mouseChildren = false;
      this._pulse_mute.alpha = 0;
      this._chits = param3.getChildByName("chits") as GuiChitsGroup;
      this._chits.init(this.context);
      this._chits.showLeadingChits = true;
      this._chits.numVisibleChits = 11;
      this._text_name = param3.getChildByName("text_name") as TextField;
      var _loc4_:ISoundMixer = this.context.soundDriver.system.mixer;
      this._button_mute.toggled = _loc4_.getMute(param1);
      this._updateChits();
      param2.registerScalableTextfield(this._text_name,false);
      param2.nav.add(this._button_mute);
      param2.nav.add(this._button_down);
      param2.nav.add(this._button_up);
      this.handleLocaleChange();
      return this;
   }
   
   public function cleanup() : void
   {
      if(this._button_mute)
      {
         this._button_mute.cleanup();
      }
      if(this._button_down)
      {
         this._button_down.cleanup();
      }
      if(this._button_up)
      {
         this._button_up.cleanup();
      }
      if(this._chits)
      {
         this._chits.cleanupGuiBase();
         this._chits = null;
      }
      if(this._pulse_mute)
      {
         TweenMax.killTweensOf(this._pulse_mute);
         this._pulse_mute = null;
      }
      this._text_name = null;
   }
   
   private function _updateChits() : void
   {
      var _loc1_:ISoundMixer = this.context.soundDriver.system.mixer;
      var _loc2_:Number = _loc1_.getVolume(this.name);
      var _loc3_:int = MathUtil.clampValue(_loc2_ * 10,0,10);
      this._chits.activeChitIndex = _loc3_;
   }
   
   private function onButtonDownClicked(param1:Object) : void
   {
      var _loc2_:ISoundMixer = this.context.soundDriver.system.mixer;
      var _loc3_:Number = _loc2_.getVolume(this.name);
      var _loc4_:int = Math.floor(_loc3_ * 10);
      _loc4_ = Math.max(0,_loc4_ - 1);
      _loc3_ = _loc4_ / 10;
      _loc2_.setVolume(this.name,_loc3_);
      this._updateChits();
      if(this._button_mute.toggled)
      {
         this.showPulseMute();
      }
   }
   
   private function showPulseMute() : void
   {
      this._pulse_mute.alpha = 0;
      TweenMax.killTweensOf(this._pulse_mute);
      TweenMax.to(this._pulse_mute,0.1,{
         "alpha":1,
         "repeat":1,
         "yoyo":1
      });
   }
   
   private function onButtonUpClicked(param1:Object) : void
   {
      var _loc2_:ISoundMixer = this.context.soundDriver.system.mixer;
      var _loc3_:Number = _loc2_.getVolume(this.name);
      var _loc4_:int = Math.ceil(_loc3_ * 10);
      _loc4_ = Math.min(10,_loc4_ + 1);
      _loc3_ = _loc4_ / 10;
      _loc2_.setVolume(this.name,_loc3_);
      this._updateChits();
      if(this._button_mute.toggled)
      {
         this.showPulseMute();
      }
   }
   
   private function onMuteClicked(param1:Object) : void
   {
      var _loc2_:ISoundMixer = this.context.soundDriver.system.mixer;
      _loc2_.setMute(this.name,this._button_mute.toggled);
   }
   
   public function handleLocaleChange() : void
   {
      this._text_name.htmlText = this.context.translate("opt_mixer_bus_" + this.name);
      this.context.locale.fixTextFieldFormat(this._text_name);
   }
}
