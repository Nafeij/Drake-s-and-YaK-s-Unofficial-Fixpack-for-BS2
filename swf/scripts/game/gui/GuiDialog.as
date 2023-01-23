package game.gui
{
   import com.stoicstudio.platform.Platform;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.locale.Locale;
   import engine.core.render.BoundedCamera;
   import engine.core.render.FitConstraints;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class GuiDialog extends MovieClip implements IGuiDialog
   {
       
      
      private var ui_author_width:int = 2731;
      
      private var ui_author_height:int = 1536;
      
      private var _button:ButtonWithIndex;
      
      private var _button2:ButtonWithIndex;
      
      private var _title:TextField;
      
      private var _body:TextField;
      
      private var _button_close:ButtonWithIndex;
      
      private var context:IGuiContext;
      
      private var dialogCloseCallback:Function;
      
      private var button1Color:uint = 8759646;
      
      private var button2Color:uint = 11624794;
      
      private var fitConstraints:FitConstraints;
      
      private var bodySize:Point;
      
      private var bodyPos:Point;
      
      private var titleWidth:Number = 0;
      
      private var _disableEscape:Boolean;
      
      private var _iconOk:GuiGpBitmap;
      
      private var _iconCancel:GuiGpBitmap;
      
      private var _iconClose:GuiGpBitmap;
      
      public function GuiDialog()
      {
         this.bodySize = new Point();
         this.bodyPos = new Point();
         this._iconOk = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this._iconCancel = GuiGp.ctorPrimaryBitmap(GpControlButton.B,true);
         this._iconClose = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         super();
         GuiUtil.attemptStopAllMovieClips(this);
         this.visible = false;
      }
      
      override public function toString() : String
      {
         return "[" + this._body.text.substr(0,40) + "...]";
      }
      
      public function init(param1:IGuiContext) : void
      {
         this.context = param1;
         this._button = getChildByName("button1") as ButtonWithIndex;
         this._button.setDownFunction(this.button1DownHandler);
         this._button.scaleTextToFit = true;
         this._button.centerTextVertically = true;
         this._button.guiButtonContext = param1;
         this._button2 = getChildByName("button2") as ButtonWithIndex;
         this._button2.scaleTextToFit = true;
         this._button2.centerTextVertically = true;
         this._button2.setDownFunction(this.button2DownHandler);
         this._button2.guiButtonContext = param1;
         this._title = getChildByName("title") as TextField;
         this._body = getChildByName("body") as TextField;
         this._button_close = getChildByName("button_close") as ButtonWithIndex;
         if(this._button_close)
         {
            this._button_close.setDownFunction(this.buttonCloseDownHandler);
            this._button_close.guiButtonContext = param1;
            this._button_close.visible = false;
         }
         this.bodyPos.x = this._body.x;
         this.bodyPos.y = this._body.y;
         this.bodySize.x = this._body.width;
         this.bodySize.y = this._body.height;
         this.titleWidth = this._title.width;
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
      }
      
      public function cleanup() : void
      {
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         GuiGp.releasePrimaryBitmap(this._iconCancel);
         GuiGp.releasePrimaryBitmap(this._iconClose);
         GuiGp.releasePrimaryBitmap(this._iconOk);
         this._button.cleanup();
         this._button = null;
         this._button2.cleanup();
         this._button2 = null;
         if(this._button_close)
         {
            this._button_close.cleanup();
            this._button_close = null;
         }
      }
      
      public function setCloseButtonVisible(param1:Boolean) : void
      {
         if(this._button_close)
         {
            this._button_close.visible = param1;
         }
      }
      
      private function setOpenDialog(param1:String, param2:String, param3:String, param4:String, param5:Function = null) : void
      {
         this._iconCancel.gplayer = GpBinder.gpbinder.topLayer;
         this._iconClose.gplayer = GpBinder.gpbinder.topLayer;
         this._iconOk.gplayer = GpBinder.gpbinder.topLayer;
         this._title.htmlText = param1;
         this.context.currentLocale.fixTextFieldFormat(this._title);
         GuiUtil.scaleTextToFit(this._title,this.titleWidth);
         this._body.scaleX = this._body.scaleY = 1;
         this._body.x = this.bodyPos.x;
         this._body.y = this.bodyPos.y;
         this._body.width = this.bodySize.x;
         this._body.height = this.bodySize.y;
         this.context.locale.updateDisplayObjectTranslation(this._body,param2,null,0);
         GuiUtil.scaleTextToFit2d(this._body,this.bodySize.x,this.bodySize.y);
         this._body.y = this.bodyPos.y + this.bodySize.y / 2 - this._body.height / 2;
         this._body.x = this.bodyPos.x + this.bodySize.x / 2 - this._body.width / 2;
         Locale.updateTextFieldGuiGpTextHelper(this._body);
         this._button.buttonText = param3;
         this._button2.buttonText = param4;
         this._button.visible = Boolean(param3) && Boolean(param3);
         this._button2.visible = Boolean(param4) && Boolean(param4);
         this.dialogCloseCallback = param5;
         this.scaleToScreen();
         this.visible = true;
         this.context.logger.info("GuiDialog.setOpenDialog [" + param1 + "]");
      }
      
      public function scaleToScreen() : void
      {
         if(!parent)
         {
            return;
         }
         this.scaleX = this.scaleY = 1;
         BoundedCamera.computeDpiFingerScale();
         var _loc1_:Number = Math.min(2,BoundedCamera.dpiFingerScale * Platform.textScale);
         var _loc2_:Number = parent.height / this.height;
         var _loc3_:Number = parent.width / this.width;
         _loc1_ = Math.min(_loc2_,Math.min(_loc3_,_loc1_));
         _loc1_ = Math.min(2,_loc1_);
         this.scaleX = this.scaleY = _loc1_;
      }
      
      public function openDialog(param1:String, param2:String, param3:String, param4:Function = null) : void
      {
         this.setOpenDialog(param1,param2,param3,"",param4);
         this._button2.visible = false;
         this.updateIconPlacement();
      }
      
      public function openTwoBtnDialog(param1:String, param2:String, param3:String, param4:String, param5:Function = null) : void
      {
         this.setOpenDialog(param1,param2,param3,param4,param5);
         var _loc6_:int = 230;
         this._button.x -= _loc6_;
         this._button.textColor = this.button1Color;
         this._button2.x += _loc6_;
         this._button2.textColor = this.button2Color;
         this.updateIconPlacement();
      }
      
      public function openNoButtonDialog(param1:String, param2:String, param3:Function = null) : void
      {
         this.setOpenDialog(param1,param2,"","",param3);
         this._button.visible = false;
         this._button2.visible = false;
         this.updateIconPlacement();
      }
      
      public function closeDialog(param1:String) : void
      {
         this.visible = false;
         this.notifyClosed(param1);
         this.context.removeDialog(this);
      }
      
      public function notifyClosed(param1:String) : void
      {
         var _loc2_:Function = this.dialogCloseCallback;
         this.dialogCloseCallback = null;
         if(_loc2_ != null)
         {
            _loc2_(param1);
         }
      }
      
      protected function button1DownHandler(param1:*) : void
      {
         this.closeDialog(this._button.buttonText);
      }
      
      protected function button2DownHandler(param1:*) : void
      {
         this.closeDialog(this._button2.buttonText);
      }
      
      protected function buttonCloseDownHandler(param1:*) : void
      {
         this.closeDialog("close");
      }
      
      public function setColors(param1:uint, param2:uint) : void
      {
         this.button1Color = param1;
         this.button2Color = param2;
      }
      
      public function setSounds(param1:String, param2:String) : void
      {
         if(param1)
         {
            this._button.clickSound = param1;
         }
         if(param2)
         {
            this._button2.clickSound = param2;
         }
      }
      
      public function get buttonOne() : String
      {
         if(Boolean(this._button) && this._button.visible)
         {
            return this._button.buttonText;
         }
         return null;
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.updateIconPlacement();
      }
      
      private function updateIconPlacement() : void
      {
         this.placeIconOnButton(this._button,this._iconOk);
         this.placeIconOnButton(this._button2,this._iconCancel);
         this.placeIconOnButton(this._button_close,this._iconClose);
      }
      
      private function placeIconOnButton(param1:ButtonWithIndex, param2:DisplayObject) : void
      {
         param2.visible = Boolean(param1) && param1.visible;
         if(Boolean(param1) && param1.visible)
         {
            if(param2.visible && !param2.parent)
            {
               this.addChild(param2);
            }
            var _loc3_:Rectangle = param1.getBounds(this);
            param2.x = _loc3_.right - param2.width / 2;
            param2.y = (_loc3_.top + _loc3_.bottom - param2.height) / 2;
            return;
         }
      }
      
      public function pressOk() : void
      {
         if(Boolean(this._button) && this._button.visible)
         {
            this._button.press();
         }
         else if(Boolean(this._button_close) && this._button_close.visible)
         {
            this._button.press();
         }
      }
      
      public function pressEscape() : void
      {
         if(this._disableEscape)
         {
            return;
         }
         this.pressCancel();
      }
      
      public function pressCancel() : void
      {
         if(Boolean(this._button_close) && this._button_close.visible)
         {
            this._button_close.press();
         }
         else if(Boolean(this._button2) && this._button2.visible)
         {
            this._button2.press();
         }
         else if(Boolean(this._button) && this._button.visible)
         {
            this._button.press();
         }
      }
      
      public function set disableEscape(param1:Boolean) : void
      {
         this._disableEscape = param1;
      }
   }
}
