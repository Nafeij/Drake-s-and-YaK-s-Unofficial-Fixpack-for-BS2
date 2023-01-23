package game.gui
{
   import com.greensock.TweenMax;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   
   public class GuiDarknessTransition extends GuiBase implements IGuiTransition
   {
       
      
      private var _buttonContinue:ButtonWithIndex;
      
      private var _continueButtonComplete:Function;
      
      private var _banner:DisplayObject;
      
      private var _textTopLocation:DisplayObject;
      
      private var _textBottomLocation:DisplayObject;
      
      private var _textAboveLocation:DisplayObject;
      
      private var _textSumLocation:DisplayObject;
      
      private var _messageTextField:TextField;
      
      private var _messageTextField_key:String;
      
      private var _gp_a:GuiGpBitmap;
      
      public function GuiDarknessTransition()
      {
         this._gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         super();
         addChild(this._gp_a);
         this._gp_a.visible = false;
         name = "darkness_transition";
      }
      
      public function init(param1:IGuiContext) : void
      {
         initGuiBase(param1,true);
         this._buttonContinue = getChildByName("button$continue") as ButtonWithIndex;
         this._buttonContinue.guiButtonContext = param1;
         this._buttonContinue.visible = false;
         this._banner = getChildByName("_common__gui__darkness_transition__darkness_transition_banner");
         this._textTopLocation = requireGuiChild("text_top");
         this._textBottomLocation = requireGuiChild("text_bottom");
         this._textAboveLocation = requireGuiChild("text_above");
         this._textSumLocation = requireGuiChild("text_sum");
         this._messageTextField = requireGuiChild("message_text_field") as TextField;
         this._messageTextField.visible = false;
         this._gp_a.visible = false;
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         GuiGp.releasePrimaryBitmap(this._gp_a);
         this._gp_a = null;
         this._banner = null;
         super.cleanupGuiBase();
      }
      
      public function get textTopLocation() : DisplayObject
      {
         return this._textTopLocation;
      }
      
      public function get textBottomLocation() : DisplayObject
      {
         return this._textBottomLocation;
      }
      
      public function get textAboveLocation() : DisplayObject
      {
         return this._textAboveLocation;
      }
      
      public function get textSumLocation() : DisplayObject
      {
         return this._textSumLocation;
      }
      
      public function get displayObjectContainer() : DisplayObjectContainer
      {
         return this;
      }
      
      public function get bannerHeight() : Number
      {
         return this._banner.height;
      }
      
      public function displayCompleteButton(param1:Function) : void
      {
         this._continueButtonComplete = param1;
         this._buttonContinue.visible = true;
         this._buttonContinue.setDownFunction(this.completeButtonDown);
         this._gp_a.visible = true;
         GuiGp.placeIconRight(this._buttonContinue,this._gp_a);
      }
      
      private function completeButtonDown(param1:ButtonWithIndex) : void
      {
         param1.visible = false;
         this._continueButtonComplete();
      }
      
      public function displayMessage(param1:String, param2:Function) : void
      {
         if(!this._messageTextField)
         {
            param2();
            return;
         }
         if(param1)
         {
            this._messageTextField_key = param1;
         }
         var _loc3_:Number = this._messageTextField.y;
         this._messageTextField.y = -this._messageTextField.height / 2;
         this._messageTextField.visible = true;
         this._messageTextField.htmlText = context.locale.translateGui(param1);
         if(param2 != null)
         {
            TweenMax.to(this._messageTextField,0.5,{
               "y":_loc3_,
               "onComplete":param2
            });
         }
      }
      
      public function animateOnScreen(param1:Function) : void
      {
         var _loc2_:Number = this.y;
         this.y = 0 - this.height - 50;
         this.visible = true;
         TweenMax.to(this,0.6,{
            "y":_loc2_,
            "onComplete":param1
         });
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         if(this._messageTextField_key)
         {
            this._messageTextField.htmlText = context.locale.translateGui(this._messageTextField_key);
         }
      }
      
      public function killTweens() : void
      {
         var _loc3_:TweenMax = null;
         var _loc4_:Function = null;
         var _loc1_:Array = TweenMax.getTweensOf(this);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            if(_loc3_.vars.hasOwnProperty("onComplete"))
            {
               _loc4_ = _loc3_.vars["onComplete"];
               _loc4_();
            }
            _loc2_++;
         }
         TweenMax.killTweensOf(this);
      }
   }
}
