package game.gui
{
   import com.greensock.TweenMax;
   import engine.session.Alert;
   import engine.session.AlertEvent;
   import engine.session.AlertOrientationType;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class GuiAlert extends GuiBase implements IGuiAlert
   {
      
      private static const TWEEN_TIME:Number = 0.3;
      
      private static const OFFSCREEN_X:Number = 300;
       
      
      public var _buttonCross:ButtonWithIndex;
      
      public var _textName:TextField;
      
      public var _textMsg:TextField;
      
      public var _buttonOk:ButtonWithIndex;
      
      public var _buttonOkSmall:ButtonWithIndex;
      
      public var _buttonCancel:ButtonWithIndex;
      
      private var _alert:Alert;
      
      private var maximized:Boolean;
      
      public var textMinWidth:Number;
      
      public var buttonOkStartX:Number;
      
      public var buttonCancelStartX:Number;
      
      public var _leaderWidth:Number;
      
      private var _appeared:Boolean;
      
      private var _listener:IGuiAlertListener;
      
      private var TEXT_BUFFER:int = 10;
      
      private var textNameOriginalPos:Point;
      
      private var textNameOriginalSize:Point;
      
      private var originalOkColor = null;
      
      private var departing:Boolean;
      
      private var departed:Boolean;
      
      public function GuiAlert()
      {
         this.textNameOriginalPos = new Point();
         this.textNameOriginalSize = new Point();
         super();
      }
      
      public function init(param1:IGuiContext, param2:Alert, param3:IGuiAlertListener) : void
      {
         initGuiBase(param1);
         this._buttonCross = requireGuiChild("buttonCross") as ButtonWithIndex;
         this._textName = requireGuiChild("textName") as TextField;
         this._textMsg = requireGuiChild("textMsg") as TextField;
         this._buttonOk = requireGuiChild("buttonOk") as ButtonWithIndex;
         this._buttonOkSmall = requireGuiChild("buttonOkSmall") as ButtonWithIndex;
         this._buttonCancel = requireGuiChild("buttonCancel") as ButtonWithIndex;
         this._alert = param2;
         this._listener = param3;
         if(!this._buttonOk)
         {
            this._buttonOk = this._buttonOkSmall;
         }
         this.textMinWidth = this._textName.width + this.TEXT_BUFFER;
         this.textNameOriginalPos.setTo(this._textName.x,this._textName.y);
         this.textNameOriginalSize.setTo(this._textName.width,this._textName.height);
         this.buttonOkStartX = this._buttonOk.x;
         this.buttonCancelStartX = this._buttonCancel.x;
         this._textName.mouseEnabled = false;
         this._textMsg.mouseEnabled = false;
         this.originalOkColor = this._buttonOk.textColor;
         this._buttonOk.scaleTextToFit = true;
         this._buttonCancel.scaleTextToFit = true;
         this.checkButtonVisibility(false);
         this._buttonCross.setDownFunction(this.buttonCrossHandler);
         this._buttonOk.setDownFunction(this.buttonOkHandler);
         this._buttonCancel.setDownFunction(this.buttonCancelHandler);
         param2.addEventListener(AlertEvent.ALERT_CHANGED,this.alertChangedHandler);
         this.alertChangedHandler(null);
      }
      
      public function cleanup() : void
      {
         if(this.alert)
         {
            this.alert.removeEventListener(AlertEvent.ALERT_CHANGED,this.alertChangedHandler);
         }
      }
      
      private function alertChangedHandler(param1:AlertEvent) : void
      {
         this._textName.htmlText = !!this.alert.sender_display_name ? this.alert.sender_display_name : "";
         this._textMsg.htmlText = !!this.alert.msg ? this.alert.msg : "";
         this._buttonOk.buttonText = !!this.alert.okMsg ? this.alert.okMsg : "";
         if(this.alert.okColor)
         {
            this._buttonOk.textColor = this.alert.okColor;
         }
         else
         {
            this._buttonOk.textColor = this.originalOkColor;
         }
         this._buttonCancel.buttonText = !!this.alert.cancelMsg ? this.alert.cancelMsg : "";
         this._textName.x = this.textNameOriginalPos.x;
         this._textName.y = this.textNameOriginalPos.y;
         this._textName.width = this.textNameOriginalSize.x;
         this._textName.height = this.textNameOriginalSize.y;
         this._textName.width = this._textMsg.width = Math.max(this.textMinWidth,Math.max(this._textName.textWidth,this._textMsg.textWidth) + this.TEXT_BUFFER);
         this._textName.x -= this._textName.width - this.textMinWidth;
         if(this.alert.orientation == AlertOrientationType.LEFT)
         {
            this._leaderWidth = this._textName.x + 30;
            this._buttonOk.x = this.buttonOkStartX + (this._textName.width - this.textMinWidth) / 2;
            this._buttonCancel.x = this.buttonCancelStartX - (this._textName.width - this.textMinWidth) / 2;
         }
         else
         {
            this._leaderWidth = this._textName.x + this._textName.width + 30;
            this._buttonOk.x = this.buttonOkStartX + (this._textName.x + this._textName.width - this.textMinWidth) / 2;
            this._buttonCancel.x = this.buttonCancelStartX + (this._textName.x + this._textName.width - this.textMinWidth) / 2;
         }
      }
      
      private function checkButtonVisibility(param1:Boolean) : void
      {
         if(!param1)
         {
            this._buttonCancel.visible = false;
            this._buttonOk.visible = false;
         }
         else
         {
            this._buttonOk.visible = this._buttonOk.buttonText != null && Boolean(this._buttonOk.buttonText);
            this._buttonCancel.visible = this._buttonCancel.buttonText != null && Boolean(this._buttonCancel.buttonText);
         }
      }
      
      public function get leaderWidth() : Number
      {
         return this._leaderWidth;
      }
      
      public function get alert() : Alert
      {
         return this._alert;
      }
      
      private function checkAppear() : void
      {
         if(!this._appeared)
         {
            this._appeared = true;
            x = OFFSCREEN_X;
         }
      }
      
      public function depart() : void
      {
         if(this.departing || this.departed)
         {
            return;
         }
         this.departing = true;
         this.minimize();
      }
      
      public function minimize() : void
      {
         if(!this.maximized && this._appeared)
         {
            if(this.departing)
            {
               this.tweenMinimizeCompleteHandler();
            }
            return;
         }
         this.checkAppear();
         this.checkButtonVisibility(false);
         var _loc1_:Number = this.departing ? OFFSCREEN_X : 0;
         this.maximized = false;
         if(this.alert.orientation == AlertOrientationType.LEFT)
         {
            TweenMax.to(this,TWEEN_TIME,{
               "x":-_loc1_,
               "onComplete":this.tweenMinimizeCompleteHandler
            });
         }
         else
         {
            TweenMax.to(this,TWEEN_TIME,{
               "x":_loc1_,
               "onComplete":this.tweenMinimizeCompleteHandler
            });
         }
         TweenMax.to(this._buttonCross,TWEEN_TIME,{"rotation":0});
         if(Boolean(this._listener) && !this.departing)
         {
            this._listener.guiAlertMinimized(this);
         }
      }
      
      private function tweenMinimizeCompleteHandler() : void
      {
         if(this.departing)
         {
            if(!this.departed)
            {
               this.departed = true;
               if(this._listener)
               {
                  this._listener.guiAlertDeparted(this);
               }
            }
         }
      }
      
      private function tweenMaximizeCompleteHandler() : void
      {
         this.checkButtonVisibility(true);
      }
      
      public function maximize() : void
      {
         if(this.maximized && this._appeared)
         {
            return;
         }
         this.checkAppear();
         this.maximized = true;
         if(this.alert.orientation == AlertOrientationType.LEFT)
         {
            TweenMax.to(this,TWEEN_TIME,{
               "x":-this.leaderWidth,
               "onComplete":this.tweenMaximizeCompleteHandler
            });
         }
         else
         {
            TweenMax.to(this,TWEEN_TIME,{
               "x":-this.leaderWidth,
               "onComplete":this.tweenMaximizeCompleteHandler
            });
         }
         TweenMax.to(this._buttonCross,TWEEN_TIME,{"rotation":45});
         if(this._listener)
         {
            this._listener.guiAlertMaximized(this);
         }
      }
      
      private function buttonOkHandler(param1:ButtonWithIndex) : void
      {
         this.alert.response = Alert.RESPONSE_OK;
      }
      
      private function buttonCancelHandler(param1:ButtonWithIndex) : void
      {
         this.alert.response = Alert.RESPONSE_CANCEL;
      }
      
      private function buttonCrossHandler(param1:ButtonWithIndex) : void
      {
         if(!this.alert.okMsg && !this.alert.cancelMsg)
         {
            if(this.maximized)
            {
               this.alert.response = Alert.RESPONSE_CANCEL;
            }
            else
            {
               this.maximize();
            }
            return;
         }
         if(this.maximized)
         {
            this.minimize();
         }
         else
         {
            this.maximize();
         }
      }
   }
}
