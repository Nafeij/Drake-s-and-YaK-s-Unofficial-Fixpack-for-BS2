package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import engine.core.BoxInt;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.utils.getTimer;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.GuiCreditsSectionConfig;
   import game.gui.page.IGuiCredits;
   
   public class GuiCredits extends GuiBase implements IGuiCredits
   {
      
      private static var ALTERNATING_IMAGE_X_MARGIN:int = 200;
       
      
      private var sections:Vector.<GuiCreditsSectionBase>;
      
      private var lastY_sections:Number = 0;
      
      private var lastY_images:Number = 0;
      
      private var endY:Number = 0;
      
      private var screen:InteractiveObject;
      
      private var mouseDown:Boolean;
      
      private var mouseDownStageX:Number = 0;
      
      private var mouseDownStageY:Number = 0;
      
      private var mouseDownThisY:Number = 0;
      
      private var _placeholder_logo:MovieClip;
      
      private var mouseDownTime:int = 0;
      
      private var clickCount:int;
      
      private var screenHeight:Number = 0;
      
      private var screenWidth:Number = 0;
      
      private var PADDING:Number = 20;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var alternatingImagesHolder:Sprite;
      
      private var bgBmpd:BitmapData;
      
      private var gplayer:int;
      
      private var creditsStartY:int = 0;
      
      private var _wasGpSticking:Boolean;
      
      private var _gpStickAccel:Number = 1;
      
      private var _bgMatrix:Matrix;
      
      private var _fast_scroll_y_start:Number = -9000;
      
      private var alternatingImageLeftRight:Boolean;
      
      private var alternatingImageY_left:BoxInt;
      
      private var alternatingImageY_right:BoxInt;
      
      private var alternatingImages:Vector.<Bitmap>;
      
      private var _textColor:uint = 4294967295;
      
      private var _headerColor:uint = 4294967295;
      
      private var _imagespeed:Number = 0.5;
      
      public function GuiCredits()
      {
         this.sections = new Vector.<GuiCreditsSectionBase>();
         this.cmd_l1 = new Cmd("cmd_credits_l1",this.func_cmd_l1);
         this.cmd_r1 = new Cmd("cmd_credits_r1",this.func_cmd_r1);
         this.alternatingImagesHolder = new Sprite();
         this._bgMatrix = new Matrix();
         this.alternatingImageY_left = new BoxInt();
         this.alternatingImageY_right = new BoxInt();
         this.alternatingImages = new Vector.<Bitmap>();
         super();
         super.visible = false;
         this.mouseEnabled = true;
         addChild(this.alternatingImagesHolder);
         this._placeholder_logo = requireGuiChild("placeholder_logo") as MovieClip;
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiCreditsSectionBase = null;
         this.stopCredits();
         for each(_loc1_ in this.sections)
         {
            _loc1_.cleanup();
         }
         this.visible = false;
         this.sections = null;
         this.screen = null;
      }
      
      public function setBackgroundBitmapdata(param1:BitmapData) : void
      {
         this.bgBmpd = param1;
      }
      
      public function init(param1:IGuiContext, param2:DisplayObject, param3:Bitmap) : void
      {
         super.initGuiBase(param1);
         this.screen = param2 as InteractiveObject;
         this.visible = false;
         if(param3)
         {
            addChild(param3);
            param3.x = -param3.width / 2;
            param3.y = this._placeholder_logo.y;
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            this.gplayer = GpBinder.gpbinder.createLayer("credits");
            GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
            GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
            if(this.screen)
            {
               this.screen.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
               this.screen.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
               this.screen.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
               this.screen.addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
            }
         }
         else
         {
            this._wasGpSticking = false;
            this.mouseDown = false;
            GpBinder.gpbinder.unbind(this.cmd_l1);
            GpBinder.gpbinder.unbind(this.cmd_r1);
            GpBinder.gpbinder.removeLayer(this.gplayer);
            this.gplayer = 0;
            if(this.screen)
            {
               this.screen.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
               this.screen.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
               this.screen.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
               this.screen.removeEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.mouseDown = true;
         this.mouseDownTime = getTimer();
         this.mouseDownStageY = param1.stageY;
         this.mouseDownStageX = param1.stageX;
         this.mouseDownThisY = y;
         TweenMax.killTweensOf(this);
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         this.mouseDown = false;
         this.rollCredits();
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         if(this.mouseDown)
         {
            this.stopCredits();
            _loc2_ = param1.stageY - this.mouseDownStageY;
            this.y = Math.min(0,Math.max(this.endY,this.mouseDownThisY + _loc2_));
            this.rollCredits();
         }
      }
      
      private function mouseWheelHandler(param1:MouseEvent) : void
      {
         this.stopCredits();
         var _loc2_:Number = param1.delta * 100;
         this.y = Math.min(0,Math.max(this.endY,y + _loc2_));
         this.rollCredits();
      }
      
      public function addSection1(param1:MovieClip, param2:String, param3:String) : void
      {
         var _loc4_:GuiCreditsSection1 = param1 as GuiCreditsSection1;
         _loc4_.init(context,param2,param3);
         this.addSection(_loc4_);
      }
      
      public function addSectionBitmap(param1:MovieClip, param2:String, param3:String) : void
      {
         var _loc4_:GuiCreditsSectionBitmap = param1 as GuiCreditsSectionBitmap;
         _loc4_.init(_context,param2,param3);
         this.addSection(_loc4_);
      }
      
      public function addSection2(param1:GuiCreditsSectionConfig, param2:MovieClip, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:GuiCreditsSection2 = param2 as GuiCreditsSection2;
         _loc6_.init(param1,context,param3,param4,param5);
         this.addSection(_loc6_);
      }
      
      public function addSection3(param1:MovieClip, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:GuiCreditsSection3 = param1 as GuiCreditsSection3;
         _loc6_.init(context,param2,param3,param4,param5);
         this.addSection(_loc6_);
      }
      
      private function addSection(param1:GuiCreditsSectionBase) : void
      {
         param1.textColor = this._textColor;
         param1.headerColor = this._headerColor;
         this.sections.push(param1);
         addChild(param1);
      }
      
      public function layoutCredits(param1:Number, param2:Number) : void
      {
         var _loc3_:GuiCreditsSectionBase = null;
         var _loc4_:GuiCreditsSectionBase = null;
         var _loc5_:MovieClip = null;
         this.screenWidth = param1;
         this.screenHeight = param2;
         this.lastY_sections = param2 / 2;
         this.creditsStartY = this.lastY_sections;
         for each(_loc4_ in this.sections)
         {
            if(Boolean(_loc3_) && Boolean(_loc4_._header.text))
            {
               this.lastY_sections += this.PADDING;
            }
            _loc3_ = _loc4_;
            _loc5_ = _loc4_ as MovieClip;
            _loc5_.y = this.lastY_sections;
            this.lastY_sections += _loc5_.height;
         }
         this.layoutAlternatingImages();
         this.stopCredits();
         if(!this._wasGpSticking && !this.mouseDown)
         {
            this.rollCredits();
         }
      }
      
      public function resetCredits() : void
      {
         this.stopCredits();
         this.y = 0;
         this.rollCredits();
      }
      
      public function rollCredits() : void
      {
         this.visible = true;
         var _loc1_:Number = Math.max(this.lastY_sections,this.lastY_images / this._imagespeed);
         this.endY = -_loc1_ - this.screenHeight / 2;
         var _loc2_:Number = y - this.endY;
         _loc2_ /= 50;
         var _loc3_:int = getTimer();
         TweenMax.to(this,_loc2_,{
            "y":this.endY,
            "delay":1,
            "ease":Linear.easeNone,
            "onComplete":this.tweenCompleteHandler
         });
      }
      
      private function tweenCompleteHandler() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function stopCredits() : void
      {
         TweenMax.killTweensOf(this);
      }
      
      private function _fillBg() : void
      {
         var _loc1_:Graphics = this.alternatingImagesHolder.graphics;
         _loc1_.clear();
         if(this.bgBmpd)
         {
            this._bgMatrix.tx = -this.screenWidth / 2;
            _loc1_.beginBitmapFill(this.bgBmpd,this._bgMatrix,true,true);
            _loc1_.drawRect(-this.screenWidth / 2,-y - this.alternatingImagesHolder.y - this.screenHeight / 2,this.screenWidth,this.screenHeight);
            _loc1_.endFill();
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:GpDevice = GpSource.primaryDevice;
         if(!_loc2_)
         {
            this.gpUnstick();
            return;
         }
         var _loc3_:Number = _loc2_.getStickValue(GpControlButton.AXIS_RIGHT_V);
         if(!_loc3_)
         {
            _loc3_ = _loc2_.getStickValue(GpControlButton.AXIS_LEFT_V);
         }
         if(!_loc3_)
         {
            _loc3_ = !!_loc2_.getControlValue(GpControlButton.D_U) ? -0.5 : 0;
         }
         if(!_loc3_)
         {
            _loc3_ = !!_loc2_.getControlValue(GpControlButton.D_D) ? 0.5 : 0;
         }
         if(!_loc3_)
         {
            this.gpUnstick();
            return;
         }
         _loc3_ = -_loc3_;
         if(!this._wasGpSticking)
         {
            this._gpStickAccel = 1;
            this.stopCredits();
            this._wasGpSticking = true;
         }
         var _loc4_:Number = _loc3_ * param1 * this._gpStickAccel;
         this.y = Math.min(0,Math.max(this.endY,y + _loc4_));
         if(y < this._fast_scroll_y_start)
         {
            this._gpStickAccel = Math.min(10,this._gpStickAccel + param1 / 500);
         }
      }
      
      private function gpUnstick() : void
      {
         this._gpStickAccel = 1;
         if(this._wasGpSticking)
         {
            this._wasGpSticking = false;
            if(!this.mouseDown)
            {
               this.rollCredits();
            }
         }
      }
      
      private function func_cmd_l1(param1:CmdExec) : void
      {
         this.stopCredits();
         this.y = 0;
         if(!this._wasGpSticking)
         {
            if(!this.mouseDown)
            {
               this.rollCredits();
            }
         }
      }
      
      private function func_cmd_r1(param1:CmdExec) : void
      {
         var _loc2_:int = this.endY + this.screenHeight;
         if(y > _loc2_)
         {
            this.stopCredits();
            this.y = _loc2_;
            if(!this._wasGpSticking)
            {
               if(!this.mouseDown)
               {
                  this.rollCredits();
               }
            }
         }
         else
         {
            this.tweenCompleteHandler();
         }
      }
      
      private function _getAlternatingImageY() : BoxInt
      {
         return this.alternatingImageLeftRight ? this.alternatingImageY_left : this.alternatingImageY_right;
      }
      
      public function addAlternatingImagePad(param1:int) : void
      {
         this._getAlternatingImageY().value = this._getAlternatingImageY().value + param1;
      }
      
      public function addAlternatingImage(param1:BitmapData, param2:uint) : void
      {
         var _loc7_:ColorTransform = null;
         var _loc3_:Bitmap = new Bitmap(param1);
         _loc3_.smoothing = true;
         _loc3_.pixelSnapping = PixelSnapping.NEVER;
         _loc3_.scaleX = _loc3_.scaleY = 0.99;
         this.alternatingImagesHolder.addChild(_loc3_);
         var _loc4_:BoxInt = this._getAlternatingImageY();
         _loc3_.y = _loc4_.value;
         var _loc5_:BoxInt = _loc4_ == this.alternatingImageY_left ? this.alternatingImageY_right : this.alternatingImageY_left;
         if(this.alternatingImageLeftRight)
         {
            _loc3_.x = -ALTERNATING_IMAGE_X_MARGIN - _loc3_.width;
         }
         else
         {
            _loc3_.x = ALTERNATING_IMAGE_X_MARGIN;
         }
         this.lastY_images = Math.max(_loc4_.value + param1.height,this.lastY_images);
         var _loc6_:Number = 0.5;
         _loc5_.value = Math.max(_loc5_.value,_loc4_.value + param1.height * _loc6_);
         _loc4_.value += param1.height * (1 + _loc6_);
         this.scaleAlternatingImage(_loc3_);
         this.alternatingImages.push(_loc3_);
         if(param2 != 4294967295)
         {
            _loc7_ = new ColorTransform(param2 >> 16 & 255 / 255,param2 >> 8 & 255 / 255,param2 >> 0 & 255 / 255,param2 >> 24 & 255 / 255);
            _loc3_.transform.colorTransform = _loc7_;
         }
         this.alternatingImageLeftRight = !this.alternatingImageLeftRight;
      }
      
      private function layoutAlternatingImages() : void
      {
         var _loc1_:Bitmap = null;
         for each(_loc1_ in this.alternatingImages)
         {
            this.scaleAlternatingImage(_loc1_);
         }
         this.updateAlternatingImagesScrollPosition();
      }
      
      private function scaleAlternatingImage(param1:Bitmap) : void
      {
         var _loc2_:int = this.screenWidth / 2;
         var _loc3_:int = param1.width / param1.scaleX;
         var _loc4_:Number = Math.min(0.99,(_loc2_ - ALTERNATING_IMAGE_X_MARGIN) / _loc3_);
         param1.scaleX = param1.scaleY = _loc4_;
         if(param1.x <= 0)
         {
            param1.x = -ALTERNATING_IMAGE_X_MARGIN - param1.width;
         }
      }
      
      public function set textColor(param1:uint) : void
      {
         var _loc2_:GuiCreditsSectionBase = null;
         this._textColor = param1;
         for each(_loc2_ in this.sections)
         {
            _loc2_.textColor = param1;
         }
      }
      
      public function set headerColor(param1:uint) : void
      {
         var _loc2_:GuiCreditsSectionBase = null;
         this._headerColor = param1;
         for each(_loc2_ in this.sections)
         {
            _loc2_.headerColor = param1;
         }
      }
      
      public function set imageSpeed(param1:Number) : void
      {
         this._imagespeed = param1;
         this.updateAlternatingImagesScrollPosition();
      }
      
      private function updateAlternatingImagesScrollPosition() : void
      {
         this.alternatingImagesHolder.y = this.creditsStartY - y * (1 - this._imagespeed);
         this._fillBg();
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         this.updateAlternatingImagesScrollPosition();
      }
   }
}
