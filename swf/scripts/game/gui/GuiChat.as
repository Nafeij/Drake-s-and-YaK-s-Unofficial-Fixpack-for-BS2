package game.gui
{
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.gui.battle.IGuiBattleChatListener;
   
   public class GuiChat extends GuiBase
   {
       
      
      private var DIM_BACKGROUD_MSG_DELAY_MS:int = 500;
      
      private var DIM_BACKGROUD_UNFOCUS_DELAY_MS:int = 200;
      
      private var listener:IGuiBattleChatListener;
      
      public var _textOutput:TextField;
      
      public var _textInput:TextField;
      
      public var _background:MovieClip;
      
      public var _inputFrame:MovieClip;
      
      public var _upArrow:ButtonWithIndex;
      
      public var _downArrow:ButtonWithIndex;
      
      public var _chatButton:MovieClip;
      
      public var _chatButtonWithIndex:ButtonWithIndex;
      
      public var _chatBubbleGlow:MovieClip;
      
      private var _chatVisible:Boolean = true;
      
      private var _focused:Boolean;
      
      private var timerGlowBlink:Timer;
      
      private var ateIt:MouseEvent;
      
      private var _showChatButton:Boolean = true;
      
      private var _showWhenUnfocused:Boolean = true;
      
      private var _chatWidth:Number = 0;
      
      private var dimStart:int;
      
      private var dimDelay:int;
      
      public function GuiChat()
      {
         this.timerGlowBlink = new Timer(1000,0);
         super();
         this.timerGlowBlink.addEventListener(TimerEvent.TIMER,this.timerCountDownHandler);
      }
      
      public function get chatVisible() : Boolean
      {
         return this._chatVisible;
      }
      
      public function set chatVisible(param1:Boolean) : void
      {
         this._chatVisible = param1;
         this.checkVisible();
      }
      
      public function init(param1:IGuiContext, param2:IGuiBattleChatListener) : void
      {
         super.initGuiBase(param1);
         this.listener = param2;
         this._textOutput = requireGuiChild("textOutput") as TextField;
         this._textInput = requireGuiChild("textInput") as TextField;
         this._background = requireGuiChild("background") as MovieClip;
         this._inputFrame = requireGuiChild("inputFrame") as MovieClip;
         this._upArrow = requireGuiChild("upArrow") as ButtonWithIndex;
         this._downArrow = requireGuiChild("downArrow") as ButtonWithIndex;
         this._chatButton = requireGuiChild("chatButton") as MovieClip;
         this._upArrow.setDownFunction(this.onUpArrowClicked);
         this._downArrow.setDownFunction(this.onDownArrowClicked);
         this._chatButton.mouseEnabled = false;
         this._chatBubbleGlow = this._chatButton.getChildByName("chat_bubble_glow") as MovieClip;
         this._chatBubbleGlow.mouseEnabled = false;
         this.showObject(this._chatBubbleGlow,this._chatButton,false);
         this._chatButtonWithIndex = this._chatButton.getChildByName("chat_button_with_index") as ButtonWithIndex;
         this._chatButtonWithIndex.setDownFunction(this.chatButtonClicked);
         mouseEnabled = false;
         this._textOutput.mouseEnabled = false;
         this._inputFrame.mouseEnabled = false;
         this._background.mouseEnabled = false;
         this._focused = true;
         this.unfocusChat();
         this._textInput.text = "";
         this._textInput.htmlText = "";
         this._textOutput.htmlText = "";
         this._chatWidth = width;
         this.chatVisible = param1.getPref(GuiGamePrefs.PREF_OPTION_CHAT);
      }
      
      public function showObject(param1:DisplayObject, param2:DisplayObjectContainer, param3:Boolean) : void
      {
         if(param3 && !param1.parent)
         {
            param2.addChild(param1);
         }
         else if(!param3 && Boolean(param1.parent))
         {
            param1.parent.removeChild(param1);
         }
      }
      
      public function appendText(param1:String) : void
      {
         this._textOutput.htmlText += param1;
      }
      
      public function appendMessage(param1:String, param2:GuiChatColor, param3:String, param4:Boolean) : void
      {
         if(!this.chatVisible)
         {
            this.showObject(this._chatBubbleGlow,this._chatButton,true);
            this.timerGlowBlink.start();
         }
         var _loc5_:String = "";
         if(param2)
         {
            _loc5_ += "<font color=\"" + param2.color + "\">" + param1 + ":</font> ";
         }
         else
         {
            _loc5_ += param1 + ": ";
         }
         if(param3.indexOf("<") >= 0)
         {
            param3 = param3.replace("<","&lt;");
         }
         if(param3.indexOf(">") >= 0)
         {
            param3 = param3.replace(">","&gt;");
         }
         _loc5_ += param3;
         this._textOutput.htmlText += _loc5_;
         this._textOutput.scrollV = this._textOutput.maxScrollV;
         this.showBackground();
         if(!this._focused)
         {
            this.dimBackground(this.DIM_BACKGROUD_MSG_DELAY_MS);
         }
         if(param4)
         {
            context.playSound("ui_chat_send");
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.ateIt = param1;
         this.focusChat();
      }
      
      public function onUpArrowClicked(param1:ButtonWithIndex) : void
      {
         if(this._textOutput.scrollV <= 0)
         {
            return;
         }
         --this._textOutput.scrollV;
      }
      
      public function onDownArrowClicked(param1:ButtonWithIndex) : void
      {
         if(this._textOutput.scrollV >= this._textOutput.maxScrollV)
         {
            return;
         }
         this._textOutput.scrollV += 1;
      }
      
      public function focusChat() : void
      {
         if(!this.chatVisible)
         {
            return;
         }
         this._focused = true;
         this.showObject(this._inputFrame,this,true);
         this.showObject(this._textInput,this,true);
         this.showBackground();
         this._textInput.mouseEnabled = true;
         this._textInput.type = TextFieldType.INPUT;
         this.checkVisible();
         if(stage)
         {
            stage.focus = this._textInput;
            stage.addEventListener(MouseEvent.MOUSE_DOWN,this.stageMouseDownHandler);
         }
         this.listener.guiBattleChatFocusChanged();
      }
      
      private function stageMouseDownHandler(param1:MouseEvent) : void
      {
         if(param1 == this.ateIt)
         {
            return;
         }
         if(!this._focused)
         {
            return;
         }
         this.unfocusChat();
      }
      
      public function unfocusChat() : void
      {
         if(this._focused)
         {
            this.dimBackground(this.DIM_BACKGROUD_UNFOCUS_DELAY_MS);
            this.showObject(this._inputFrame,this,false);
            this._focused = false;
            this._textInput.type = TextFieldType.DYNAMIC;
            this._textInput.mouseEnabled = false;
            this.showObject(this._textInput,this,false);
            if(stage)
            {
               stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.stageMouseDownHandler);
            }
            this.listener.guiBattleChatFocusChanged();
            this.checkVisible();
         }
      }
      
      private function showBackground() : void
      {
         TweenMax.killTweensOf(this._background);
         this._background.alpha = 1;
      }
      
      private function dimBackground(param1:int) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = getTimer() - this.dimStart;
         var _loc4_:int = this.dimDelay - _loc3_;
         if(param1 > _loc4_)
         {
            TweenMax.killTweensOf(this._background);
            TweenMax.to(this._background,0.5,{
               "alpha":0.5,
               "delay":param1 * 0.001
            });
            this.dimStart = _loc2_;
            this.dimDelay = param1;
         }
      }
      
      public function sendMessage() : void
      {
         context.playSound("ui_dismiss");
         var _loc1_:String = this._textInput.text;
         this._textInput.text = "";
         this.listener.guiBattleChatTextEntered(_loc1_);
      }
      
      private function checkVisible() : void
      {
         var _loc1_:Boolean = this.chatVisible && (this._focused || this._showWhenUnfocused);
         this.showObject(this._background,this,_loc1_);
         this.showObject(this._textOutput,this,_loc1_);
         this.showObject(this._upArrow,this,_loc1_);
         this.showObject(this._downArrow,this,_loc1_);
         this.showObject(this._chatButton,this,this._showChatButton && (this._focused || this._showWhenUnfocused));
      }
      
      private function chatButtonClicked(param1:ButtonWithIndex) : void
      {
         this.timerGlowBlink.stop();
         this.showObject(this._chatBubbleGlow,this._chatButton,false);
         this.chatVisible = !this.chatVisible;
         context.setPref(GuiGamePrefs.PREF_OPTION_CHAT,this.chatVisible);
         this.checkVisible();
         if(!this.chatVisible)
         {
            this.unfocusChat();
         }
      }
      
      public function get focused() : Boolean
      {
         return this._focused;
      }
      
      protected function timerCountDownHandler(param1:TimerEvent) : void
      {
         this._chatBubbleGlow.visible = !this._chatBubbleGlow.visible;
         this.timerGlowBlink.reset();
         this.timerGlowBlink.start();
      }
      
      public function setEnabledAvailable(param1:Boolean) : void
      {
         this.visible = param1;
         this.mouseEnabled = param1;
      }
      
      public function set showWhenUnfocused(param1:Boolean) : void
      {
         this._showWhenUnfocused = param1;
         this.checkVisible();
      }
      
      public function set showChatButton(param1:Boolean) : void
      {
         this._showChatButton = param1;
         this.checkVisible();
      }
      
      public function get showChatButton() : Boolean
      {
         return this._showChatButton;
      }
      
      public function get chatWidth() : Number
      {
         return this._chatWidth;
      }
   }
}
