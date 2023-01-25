package engine.gui
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.RunMode;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.cmd.KeyBinder;
   import engine.core.cmd.ShellCmdHistory;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.core.logging.targets.DebugLogTarget;
   import engine.core.logging.targets.IDebugLogTarget;
   import engine.core.pref.PrefBag;
   import engine.core.render.BoundedCamera;
   import engine.core.util.ColorUtil;
   import engine.core.util.INativeText;
   import engine.core.util.StringUtil;
   import engine.gui.core.DebugGuiButtonState;
   import engine.gui.core.GuiButton;
   import engine.gui.core.GuiButtonEvent;
   import engine.gui.core.GuiButtonSkin;
   import engine.gui.core.GuiLabel;
   import engine.gui.core.GuiSprite;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.text.Font;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.utils.setTimeout;
   
   public class ConsoleGui extends GuiSprite implements IDebugLogTarget
   {
      
      public static const BUTTON_SKIN:GuiButtonSkin = new GuiButtonSkin({"states":[{
         "name":DebugGuiButtonState.NORMAL.name,
         "skin":{
            "textColor":16777215,
            "bitmap":null
         }
      },{
         "name":DebugGuiButtonState.HOVER.name,
         "skin":{
            "textColor":16776960,
            "bitmap":null
         }
      },{
         "name":DebugGuiButtonState.PRESSED.name,
         "skin":{
            "textColor":65280,
            "bitmap":null
         }
      },{
         "name":DebugGuiButtonState.DISABLED.name,
         "skin":{
            "textColor":11184810,
            "bitmap":null
         }
      }]});
      
      private static const PREF_WIDTH:String = "ConsoleGui.PREF_WIDTH";
      
      private static const PREF_HEIGHT:String = "ConsoleGui.PREF_HEIGHT";
       
      
      public var output:GuiSprite;
      
      public var buttonUp:GuiButton;
      
      public var buttonDown:GuiButton;
      
      private var _scrollToLine:int = -1;
      
      public var FONT:String;
      
      public var ROW_HEIGHT:Number = 12;
      
      public var input:INativeText;
      
      public var slider:GuiSprite;
      
      public var toggle:GuiButton;
      
      private var _out:Boolean = false;
      
      private var dlt:DebugLogTarget;
      
      private var logger:ILogger;
      
      private var _flashing:Boolean;
      
      private var infoTf:TextFormat;
      
      private var errorTf:TextFormat;
      
      public var sizer:GuiSprite;
      
      private var wasFocused:InteractiveObject;
      
      private var _shell:ShellCmdManager;
      
      private var _runMode:RunMode;
      
      private var _prefs:PrefBag;
      
      private var gestures:ConsoleGestureAdapter;
      
      private var INPUT_SCALE:Number = 1;
      
      private var inputHeight:Number = 0;
      
      private var _numRenderableRows:int = 0;
      
      private var regexpTfs:Array;
      
      public var keybinder:KeyBinder;
      
      private var nativeTextClazz:Class;
      
      private var sizerDownPt:Point;
      
      private var sizerDownSliderSize:Point;
      
      private var justToggled:Boolean;
      
      private var logs:Vector.<Object>;
      
      private var numRowsDisplayed:int = 0;
      
      private var limit_soft:int = 500;
      
      private var limit_hard:int = 1000;
      
      private var _outputDragging:Boolean;
      
      private var startDragMousePoint:Point;
      
      private var startDragOutputPos:Point;
      
      private var startDragScrollToLine:int;
      
      private var startDragLogsLength:int;
      
      public function ConsoleGui(param1:ILogger, param2:DebugLogTarget, param3:Class)
      {
         this.output = new GuiSprite();
         this.buttonUp = new GuiButton(BUTTON_SKIN);
         this.buttonDown = new GuiButton(BUTTON_SKIN);
         this.FONT = MonoFont.FONT;
         this.slider = new GuiSprite();
         this.toggle = new GuiButton(BUTTON_SKIN);
         this.sizer = new GuiSprite();
         this.regexpTfs = [{
            "match":"(SAGA)    *>  HAPPENING START",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,8969727,false)
         },{
            "match":"(SAGA)    <*  happening end",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,ColorUtil.greyen(8969727,0.5),false)
         },{
            "match":"(SAGA)     ->    ACTION START",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,8978312,false)
         },{
            "match":"(SAGA)     <-    action end",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,ColorUtil.greyen(8978312,0.5),false)
         },{
            "match":"(SAGA)    TRIGGER ",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,16751103,false)
         },{
            "match":"(SAGA)    VAR ",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,16777113,false)
         },{
            "match":"(SAGA) ",
            "tf":new TextFormat(this.FONT,this.ROW_HEIGHT,12303291,false)
         }];
         this.logs = new Vector.<Object>();
         super();
         var _loc4_:String = Capabilities.os;
         var _loc5_:Number = 1;
         if(StringUtil.startsWith(_loc4_,"iP"))
         {
            _loc5_ = BoundedCamera.dpiFingerScale;
         }
         this.gestures = new ConsoleGestureAdapter(this);
         _loc5_ = Math.max(1,_loc5_);
         this.ROW_HEIGHT *= _loc5_;
         this.ROW_HEIGHT = Math.round(this.ROW_HEIGHT);
         if(param3 != null)
         {
            this.input = new param3() as INativeText;
            this.input.addEventListener(Event.CHANGE,this.textChangeHandler);
            this.input.addEventListener(KeyboardEvent.KEY_DOWN,this.textKeyDownHandler);
            this.input.fontFamily = this.FONT;
            this.input.fontSize = this.ROW_HEIGHT * this.INPUT_SCALE;
            this.input.height = this.ROW_HEIGHT * this.INPUT_SCALE + 8;
            this.input.color = 16777215;
            this.input.name = "input";
            this.input.text = "";
            this.input.borderColor = 65280;
            this.input.borderThickness = 2;
            this.input.height = this.ROW_HEIGHT + 12;
            this.input.restrict = "^`~";
            this.inputHeight = this.ROW_HEIGHT + 12;
         }
         name = "console";
         this.shell = new ShellCmdManager(param1);
         this.logger = param1;
         this.dlt = param2;
         this.slider.debugRender = 3422552064;
         var _loc6_:Array = Font.enumerateFonts();
         var _loc7_:Array = Font.enumerateFonts(true);
         this.infoTf = new TextFormat(this.FONT,this.ROW_HEIGHT,4293853166,false);
         this.errorTf = new TextFormat(this.FONT,this.ROW_HEIGHT,4294945450,false);
         this.slider.name = "slider";
         this.output.name = "output";
         this.buttonUp.name = "buttonUp";
         this.buttonDown.name = "buttonDown";
         this.toggle.name = "toggle";
         this.slider.addChild(this.output);
         if(this.input != null)
         {
            this.slider.addChild(this.input.display);
         }
         this.slider.addChild(this.buttonUp);
         this.slider.addChild(this.buttonDown);
         this.setupSizer();
         addChild(this.toggle);
         this.toggle.visible = false;
         this.toggle.setSize(20,20);
         this.toggle.label.text = ".";
         this.toggle.anchor.right = 0;
         this.toggle.addEventListener(GuiButtonEvent.CLICKED,this.toggleClickedHandler);
         this.mouseEnabled = true;
         this.buttonUp.label.text = "^";
         this.buttonDown.label.text = "v";
         this.buttonUp.setSize(20,20);
         this.buttonDown.setSize(20,20);
         this.buttonUp.anchor.right = 0;
         this.buttonDown.anchor.right = 0;
         this.buttonUp.anchor.bottom = this.inputHeight + this.sizer.height + this.buttonDown.height;
         this.buttonDown.anchor.bottom = this.inputHeight + this.sizer.height;
         this.buttonUp.addEventListener(GuiButtonEvent.CLICKED,this.buttonUpClickedHandler);
         this.buttonDown.addEventListener(GuiButtonEvent.CLICKED,this.buttonDownClickedHandler);
         this.output.mouseEnabled = true;
         this.output.addEventListener(MouseEvent.CLICK,this.outputClickHandler);
         this.slider.addEventListener(MouseEvent.MOUSE_DOWN,this.sliderMouseDownHandler);
         this.slider.addEventListener(MouseEvent.MOUSE_WHEEL,this.sliderMouseWheelHandler);
         this.checkUserSliderSize();
         anchor.left = 0;
         anchor.right = 0;
         anchor.top = 0;
         anchor.bottom = 0;
         param2.listener = this;
         this.updateOut(true);
         this.updateOutput();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.consoleMouseDownHandler);
         this.addedToStageHandler(null);
         this.resizeHandler();
      }
      
      private function textChangeHandler(param1:Event) : void
      {
      }
      
      private function setupSizer() : void
      {
         this.slider.addChild(this.sizer);
         this.sizer.anchor.right = 0;
         this.sizer.anchor.bottom = this.inputHeight;
         var _loc1_:Graphics = this.sizer.graphics;
         this.sizer.width = this.sizer.height = 40;
         _loc1_.lineStyle(2,16777215);
         _loc1_.beginFill(16777215,0.8);
         _loc1_.moveTo(40,0);
         _loc1_.lineTo(40,20);
         _loc1_.lineTo(20,40);
         _loc1_.lineTo(0,40);
         _loc1_.lineTo(40,0);
         _loc1_.endFill();
         this.sizer.addEventListener(MouseEvent.MOUSE_DOWN,this.sizerMouseDownHandler);
         this.sizer.addEventListener(MouseEvent.ROLL_OVER,this.sizerMouseRollOverHandler);
         this.sizer.addEventListener(MouseEvent.ROLL_OUT,this.sizerMouseRollOutHandler);
      }
      
      private function sizerMouseDownHandler(param1:MouseEvent) : void
      {
         this.sizerDownPt = new Point(param1.stageX,param1.stageY);
         this.sizerDownSliderSize = new Point(this.slider.width,this.slider.height);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.sizerMouseUpHandler);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.sizerMouseMoveHandler,true);
      }
      
      private function sizerMouseUpHandler(param1:MouseEvent) : void
      {
         this.sizerDownPt = null;
         this.sizerDownSliderSize = null;
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.sizerMouseUpHandler);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.sizerMouseMoveHandler,true);
      }
      
      private function setUserSliderSize(param1:Number, param2:Number) : void
      {
         var _loc5_:Boolean = false;
         if(width == 0 || height == 0)
         {
            return;
         }
         var _loc3_:Number = Math.min(width,Math.max(200,param1));
         var _loc4_:Number = Math.min(height,Math.max(100,param2));
         if(!_loc3_ || isNaN(_loc3_) || _loc3_ == width)
         {
            this.prefs.setPref(PREF_WIDTH,null);
            this.slider.anchor.percentWidth = 100;
         }
         else
         {
            this.slider.anchor.percentWidth = null;
            this.slider.width = _loc3_;
            this.prefs.setPref(PREF_WIDTH,_loc3_);
         }
         if(!_loc4_ || isNaN(_loc4_) || _loc4_ == height)
         {
            this.prefs.setPref(PREF_HEIGHT,null);
            this.slider.anchor.percentHeight = 100;
         }
         else
         {
            this.slider.anchor.percentHeight = null;
            this.slider.height = _loc4_;
            this.prefs.setPref(PREF_HEIGHT,_loc4_);
         }
         this.setSizesFromResizeHandler(_loc3_,_loc4_);
      }
      
      private function checkUserSliderSize() : void
      {
         if(!this._prefs)
         {
            return;
         }
         var _loc1_:Number = this.prefs.getPref(PREF_WIDTH);
         var _loc2_:Number = this.prefs.getPref(PREF_HEIGHT);
         this.setUserSliderSize(!!_loc1_ ? _loc1_ : width,!!_loc2_ ? _loc2_ : height);
      }
      
      private function sizerMouseMoveHandler(param1:MouseEvent) : void
      {
         if(!this.sizerDownPt)
         {
            return;
         }
         var _loc2_:Point = new Point(param1.stageX - this.sizerDownPt.x,param1.stageY - this.sizerDownPt.y);
         this.setUserSliderSize(this.sizerDownSliderSize.x + _loc2_.x,this.sizerDownSliderSize.y + _loc2_.y);
      }
      
      private function sizerMouseRollOverHandler(param1:MouseEvent) : void
      {
         this.sizer.alpha = 1;
      }
      
      private function sizerMouseRollOutHandler(param1:MouseEvent) : void
      {
         this.sizer.alpha = 0.7;
      }
      
      private function consoleMouseDownHandler(param1:MouseEvent) : void
      {
      }
      
      protected function textInputHandler(param1:TextEvent) : void
      {
      }
      
      private function inputMouseDownHandler(param1:MouseEvent) : void
      {
      }
      
      protected function buttonUpClickedHandler(param1:GuiButtonEvent) : void
      {
         var _loc2_:int = this.numRowsDisplayed / 2;
         if(this.scrollToLine < 0)
         {
            this.scrollToLine = Math.max(0,this.logs.length - 1 - _loc2_);
         }
         else
         {
            this.scrollToLine = Math.max(0,this.scrollToLine - _loc2_);
         }
      }
      
      protected function buttonDownClickedHandler(param1:GuiButtonEvent) : void
      {
         var _loc2_:int = 0;
         if(this.scrollToLine >= 0)
         {
            _loc2_ = this.numRowsDisplayed / 2;
            this.scrollToLine += _loc2_;
            if(this.scrollToLine >= this.logs.length)
            {
               this.scrollToLine = -1;
            }
         }
      }
      
      protected function addedToStageHandler(param1:Event) : void
      {
         if(stage)
         {
            stage.addEventListener(KeyboardEvent.KEY_DOWN,this.stageKeyDownHandler);
            this.gestures.checkGestureAdapter();
         }
      }
      
      protected function stageKeyDownHandler(param1:KeyboardEvent) : void
      {
         var event:KeyboardEvent = param1;
         if(event.shiftKey && event.ctrlKey && event.keyCode == Keyboard.BACKQUOTE && !this.justToggled)
         {
            event.preventDefault();
            this.out = !this.out;
            this.justToggled = true;
            setTimeout(function():void
            {
               justToggled = false;
            },10);
            return;
         }
         if(!this.out)
         {
            return;
         }
         if(this.input)
         {
            if(event.keyCode == Keyboard.UP)
            {
               event.preventDefault();
               this.input.text = this.shell.shellCmdHistory.backward();
               this.input.selectRange(this.input.text.length,this.input.text.length);
               this.input.stage = stage;
            }
            else if(event.keyCode == Keyboard.DOWN)
            {
               event.preventDefault();
               this.input.text = this.shell.shellCmdHistory.forward();
               this.input.selectRange(this.input.text.length,this.input.text.length);
               this.input.stage = stage;
            }
            else if(event.keyCode == Keyboard.PAGE_UP)
            {
               event.preventDefault();
               this.buttonUpClickedHandler(null);
            }
            else if(event.keyCode == Keyboard.PAGE_DOWN)
            {
               event.preventDefault();
               this.buttonDownClickedHandler(null);
            }
         }
      }
      
      private function textKeyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:String = null;
         if(param1.keyCode == Keyboard.ENTER || param1.keyCode == Keyboard.SEARCH || param1.keyCode == Keyboard.NEXT)
         {
            param1.preventDefault();
            if(this.input != null)
            {
               _loc2_ = this.input.text;
               if(_loc2_)
               {
                  this.input.text = "";
                  if(!this.shell.exec(_loc2_))
                  {
                     this.logger.info("ConsoleGui: Command Not Found: " + _loc2_);
                  }
               }
               this.scrollToLine = -1;
            }
            return;
         }
         this.stageKeyDownHandler(param1);
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this._numRenderableRows = this.slider.height / this.ROW_HEIGHT;
         this.checkUserSliderSize();
      }
      
      private function setSizesFromResizeHandler(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = !!this.infoTf.size ? this.infoTf.size as Number : 12;
         if(this.input != null)
         {
            this.input.y = param2 - this.input.height;
            this.input.width = param1;
            this.output.height = this.input.y - 2;
         }
         else
         {
            this.output.height = height;
         }
         this.updateOutput();
         this.updateOut(true);
      }
      
      protected function toggleClickedHandler(param1:GuiButtonEvent) : void
      {
         this.out = !this.out;
      }
      
      private function getOutputLabel(param1:int) : GuiLabel
      {
         var _loc2_:GuiLabel = null;
         while(param1 >= this.output.numChildren)
         {
            _loc2_ = new GuiLabel(this.FONT,this.infoTf.size as Number,16777215,false);
            _loc2_.name = "row" + param1;
            _loc2_.anchor.percentWidth = 100;
            this.output.addChild(_loc2_);
         }
         return this.output.getChildAt(param1) as GuiLabel;
      }
      
      private function updateOutput() : void
      {
         var _loc6_:int = 0;
         var _loc7_:GuiLabel = null;
         var _loc8_:Object = null;
         var _loc9_:TextFormat = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc12_:RegExp = null;
         var _loc13_:String = null;
         if(!this.out)
         {
            return;
         }
         var _loc1_:int = this.scrollToLine >= 0 ? this.scrollToLine : int(this.logs.length - 1);
         var _loc2_:int = 2;
         var _loc3_:int = this.output.height - _loc2_;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc4_ < this.logs.length)
         {
            if(_loc3_ <= 0)
            {
               break;
            }
            _loc6_ = _loc1_ - _loc4_;
            if(_loc6_ < 0 || _loc6_ >= this.logs.length)
            {
               break;
            }
            _loc7_ = this.getOutputLabel(_loc4_);
            _loc8_ = this.logs[_loc6_];
            _loc9_ = this.infoTf;
            _loc10_ = String(_loc8_.txt);
            if(_loc8_.error)
            {
               _loc9_ = this.errorTf;
            }
            else
            {
               for each(_loc11_ in this.regexpTfs)
               {
                  _loc12_ = _loc11_.regexp;
                  _loc13_ = String(_loc11_.match);
                  if(_loc13_)
                  {
                     if(_loc10_.indexOf(_loc13_) >= 0)
                     {
                        _loc9_ = _loc11_.tf;
                        break;
                     }
                  }
                  else if(_loc12_ != null)
                  {
                     if(_loc10_.search(_loc12_) >= 0)
                     {
                        _loc9_ = _loc11_.tf;
                        break;
                     }
                  }
               }
            }
            _loc7_.label.defaultTextFormat = _loc9_;
            _loc7_.label.setTextFormat(_loc9_);
            _loc7_.label.text = _loc10_;
            _loc7_.height = _loc7_.label.textHeight;
            _loc3_ -= _loc7_.height;
            _loc7_.y = _loc3_;
            _loc7_.visible = true;
            _loc5_ = Math.max(_loc5_,_loc7_.label.textWidth + 10);
            _loc4_++;
         }
         this.numRowsDisplayed = _loc4_;
         while(_loc4_ < this.output.numChildren)
         {
            this.getOutputLabel(_loc4_).visible = false;
            _loc4_++;
         }
         this.output.width = _loc5_;
      }
      
      private function addLog(param1:Object, param2:Boolean = true) : void
      {
         var _loc4_:String = null;
         var _loc3_:Array = param1.txt.split("\n");
         if(_loc3_.length > 1)
         {
            for each(_loc4_ in _loc3_)
            {
               this.addLog({
                  "txt":_loc4_,
                  "error":param1.error
               },false);
            }
         }
         else
         {
            this.logs.push(param1);
            if(!this.out)
            {
               this.checkLimits();
            }
         }
         if(this.out && param2)
         {
            this.updateOutput();
         }
      }
      
      private function checkLimits() : Boolean
      {
         if(this.logs.length > this.limit_hard)
         {
            this.logs.splice(0,this.logs.length - this.limit_soft);
            return true;
         }
         return false;
      }
      
      public function debugLogTarget_debug(param1:ILogger, param2:String) : void
      {
         var _loc3_:String = !!param1.name ? "(" + param1.name + ") " : "";
         var _loc4_:String = "[DEBUG] " + _loc3_ + param2;
         var _loc5_:Object = {
            "txt":_loc4_,
            "error":false
         };
         this.addLog(_loc5_);
      }
      
      public function debugLogTarget_info(param1:ILogger, param2:String) : void
      {
         var _loc3_:String = !!param1.name ? "(" + param1.name + ") " : "";
         var _loc4_:String = "[INFO]  " + _loc3_ + param2;
         var _loc5_:Object = {
            "txt":_loc4_,
            "error":false
         };
         this.addLog(_loc5_);
      }
      
      public function debugLogTarget_error(param1:ILogger, param2:String) : void
      {
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc3_:String = !!param1.name ? "(" + param1.name + ") " : "";
         var _loc4_:String = "[ERROR] " + _loc3_;
         var _loc5_:int = param2.indexOf("\n");
         if(_loc5_ < 0)
         {
            _loc6_ = _loc4_ + param2;
            _loc7_ = {
               "txt":_loc6_,
               "error":true
            };
            this.addLog(_loc7_);
         }
         else
         {
            _loc8_ = param2.split("\n");
            for each(_loc9_ in _loc8_)
            {
               _loc6_ = _loc4_ + _loc9_;
               _loc7_ = {
                  "txt":_loc6_,
                  "error":true
               };
               this.addLog(_loc7_,false);
            }
            if(this.out)
            {
               this.updateOutput();
            }
         }
         this.flashing = !this.out;
      }
      
      public function get out() : Boolean
      {
         return this._out;
      }
      
      public function set out(param1:Boolean) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         if(this._out == param1)
         {
            return;
         }
         if(param1)
         {
            PlatformStarling.fullscreenIncrement("consoleGui.out=" + param1,this.logger);
         }
         else
         {
            PlatformStarling.fullscreenDecrement("consoleGui.out=" + param1,this.logger);
         }
         this._out = param1;
         if(this._out)
         {
            this.checkLimits();
            this.updateOutput();
            if(this.keybinder)
            {
               this.keybinder.disableBindsFromGroup(KeyBindGroup.COMBAT);
               this.keybinder.disableBindsFromGroup(KeyBindGroup.CONVO);
               this.keybinder.disableBindsFromGroup(KeyBindGroup.CHAT);
               this.keybinder.disableBindsFromGroup(KeyBindGroup.TOWN);
               this.keybinder.disableBindsFromGroup(KeyBindGroup.VIDEO);
               this.keybinder.disableBindsFromGroup(KeyBindGroup.TRAVEL);
               this.keybinder.disableBindsFromGroup(KeyBindGroup.SCENE);
               this.keybinder.disableBindsFromGroup("match_resolution");
               this.keybinder.disableBindsFromGroup("");
            }
            if(this.parent.getChildIndex(this) != this.parent.numChildren - 1)
            {
               _loc2_ = this.parent;
               _loc2_.setChildIndex(this,this.parent.numChildren - 1);
            }
         }
         else if(this.keybinder)
         {
            this.keybinder.enableBindsFromGroup(KeyBindGroup.COMBAT);
            this.keybinder.enableBindsFromGroup(KeyBindGroup.CONVO);
            this.keybinder.enableBindsFromGroup(KeyBindGroup.CHAT);
            this.keybinder.enableBindsFromGroup(KeyBindGroup.TOWN);
            this.keybinder.enableBindsFromGroup(KeyBindGroup.VIDEO);
            this.keybinder.enableBindsFromGroup(KeyBindGroup.TRAVEL);
            this.keybinder.enableBindsFromGroup(KeyBindGroup.SCENE);
            this.keybinder.enableBindsFromGroup("match_resolution");
            this.keybinder.enableBindsFromGroup("");
         }
         this.updateOut();
      }
      
      private function updateOut(param1:Boolean = false) : void
      {
         var _loc3_:int = 0;
         this.flashing = this.flashing && !this.out;
         var _loc2_:Number = 0.2;
         TweenMax.killTweensOf(this.slider);
         TweenMax.killTweensOf(this.toggle);
         if(this._out)
         {
            if(!this.slider.parent)
            {
               addChildAt(this.slider,0);
               this.resizeHandler();
            }
            if(this.input != null)
            {
               this.input.stage = stage;
            }
            if(param1)
            {
               this.toggle.y = 0;
               this.slider.y = 0;
            }
            else
            {
               TweenMax.to(this.toggle,_loc2_,{"y":0});
               TweenMax.to(this.slider,_loc2_,{"y":0});
            }
         }
         else
         {
            if(this.input != null)
            {
               this.input.stage = null;
            }
            _loc3_ = 11;
            if(param1)
            {
               this.toggle.y = -this.toggle.height + _loc3_;
               this.slider.y = -this.slider.height - 1;
            }
            else
            {
               TweenMax.to(this.toggle,_loc2_,{"y":-this.toggle.height + _loc3_});
               TweenMax.to(this.slider,_loc2_,{
                  "y":-this.slider.height - 1,
                  "onComplete":this.sliderInComplete
               });
            }
         }
      }
      
      private function sliderInComplete() : void
      {
         if(this.slider.parent)
         {
            removeChild(this.slider);
            this.restoreFocus();
         }
      }
      
      private function restoreFocus() : void
      {
         if(Boolean(this.wasFocused) && Boolean(this.wasFocused.stage))
         {
            stage.focus = this.wasFocused;
         }
         else
         {
            stage.focus = parent;
         }
      }
      
      public function get flashing() : Boolean
      {
         return this._flashing;
      }
      
      public function set flashing(param1:Boolean) : void
      {
         this._flashing = param1;
         TweenMax.killTweensOf(this.toggle);
         this.toggle.alpha = 1;
         if(this._flashing)
         {
            TweenMax.to(this.toggle,0.2,{
               "alpha":0.5,
               "yoyo":true,
               "repeat":-1
            });
            this.toggle.filters = [new GlowFilter(16711680,1)];
         }
         else
         {
            this.toggle.filters = [];
         }
      }
      
      public function get outputDragging() : Boolean
      {
         return this._outputDragging;
      }
      
      public function set outputDragging(param1:Boolean) : void
      {
         if(this._outputDragging == param1)
         {
            return;
         }
         this._outputDragging = param1;
         if(this._outputDragging)
         {
            this.startDragMousePoint = new Point(stage.mouseX,stage.mouseY);
            this.startDragOutputPos = new Point(this.output.x,this.output.y);
            this.startDragScrollToLine = this.scrollToLine;
            this.startDragLogsLength = this.logs.length;
            stage.addEventListener(MouseEvent.MOUSE_UP,this.stageMouseUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,this.stageMouseMoveHandler);
            TweenMax.killTweensOf(this.output);
         }
         else
         {
            this.startDragMousePoint = null;
            this.startDragOutputPos = null;
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.stageMouseUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.stageMouseMoveHandler);
            if(this.output.x != 0)
            {
               TweenMax.to(this.output,0.2,{"x":0});
            }
            if(this.scrollToLine == this.logs.length - 1)
            {
               this.scrollToLine = -1;
            }
         }
      }
      
      protected function stageMouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = stage.mouseX - this.startDragMousePoint.x;
         var _loc3_:Number = stage.mouseY - this.startDragMousePoint.y;
         var _loc4_:Number = this.startDragOutputPos.x + _loc2_;
         var _loc5_:Number = this.width / 4;
         var _loc6_:Number = this.width * 3 / 4 - Math.max(this.width,this.output.width);
         _loc4_ = Math.max(Math.min(_loc5_,_loc4_),_loc6_);
         this.output.x = _loc4_;
         var _loc7_:int = _loc3_ / this.ROW_HEIGHT;
         if(this.startDragScrollToLine < 0)
         {
            this.scrollToLine = this.startDragLogsLength - _loc7_;
         }
         else
         {
            this.scrollToLine = Math.max(0,this.startDragScrollToLine - _loc7_);
         }
      }
      
      protected function sliderMouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         param1.stopImmediatePropagation();
         if(this._outputDragging)
         {
            return;
         }
         if(this.input != null && this.slider.mouseY >= this.input.y)
         {
            return;
         }
         var _loc2_:int = -param1.delta;
         if(param1.shiftKey)
         {
            _loc2_ *= 2;
         }
         if(_loc2_ < 0)
         {
            if(this._scrollToLine < 0)
            {
               this._scrollToLine = this.logs.length - 1;
            }
            _loc3_ = Math.max(this._scrollToLine + _loc2_,this._numRenderableRows / 2);
            this.scrollToLine = _loc3_;
         }
         else if(_loc2_ > 0)
         {
            if(this.scrollToLine < 0)
            {
               this.scrollToLine = this.logs.length - 1;
            }
            else
            {
               this.scrollToLine += _loc2_;
            }
         }
         if(this.scrollToLine == this.logs.length - 1)
         {
            this.scrollToLine = -1;
         }
      }
      
      protected function stageMouseUpHandler(param1:MouseEvent) : void
      {
         this.outputDragging = false;
      }
      
      protected function sliderMouseDownHandler(param1:MouseEvent) : void
      {
         if(this.input != null && this.slider.mouseY < this.input.y)
         {
            this.outputDragging = true;
         }
      }
      
      protected function outputClickHandler(param1:MouseEvent) : void
      {
      }
      
      public function get scrollToLine() : int
      {
         return this._scrollToLine;
      }
      
      public function set scrollToLine(param1:int) : void
      {
         var _loc2_:int = param1;
         param1 = Math.min(this.logs.length - 1,param1);
         if(param1 < -1)
         {
            param1 = this.logs.length + param1;
         }
         if(this._scrollToLine == param1)
         {
            return;
         }
         this._scrollToLine = param1;
         this.updateOutput();
      }
      
      public function get shell() : ShellCmdManager
      {
         return this._shell;
      }
      
      public function set shell(param1:ShellCmdManager) : void
      {
         this._shell = param1;
         if(this._shell)
         {
            this._shell.shellCmdHistory = new ShellCmdHistory();
         }
      }
      
      public function get runMode() : RunMode
      {
         return this._runMode;
      }
      
      public function set runMode(param1:RunMode) : void
      {
         this._runMode = param1;
         this.toggle.visible = this._runMode.developer;
      }
      
      public function get prefs() : PrefBag
      {
         return this._prefs;
      }
      
      public function set prefs(param1:PrefBag) : void
      {
         this._prefs = param1;
         this.checkUserSliderSize();
      }
   }
}
