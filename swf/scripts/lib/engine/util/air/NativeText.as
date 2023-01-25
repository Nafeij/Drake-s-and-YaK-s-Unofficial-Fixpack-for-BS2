package lib.engine.util.air
{
   import engine.core.util.INativeText;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.SoftKeyboardEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.ReturnKeyLabel;
   import flash.text.SoftKeyboardType;
   import flash.text.StageText;
   import flash.text.StageTextInitOptions;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextLineMetrics;
   import flash.text.engine.FontPosture;
   import flash.text.engine.FontWeight;
   import starling.events.KeyboardEvent;
   
   [Event(name="softKeyboardDeactivate",type="flash.events.SoftKeyboardEvent")]
   [Event(name="softKeyboardActivating",type="flash.events.SoftKeyboardEvent")]
   [Event(name="softKeyboardActivate",type="flash.events.SoftKeyboardEvent")]
   [Event(name="keyUp",type="flash.events.KeyboardEvent")]
   [Event(name="keyDown",type="flash.events.KeyboardEvent")]
   [Event(name="focusOut",type="flash.events.FocusEvent")]
   [Event(name="focusIn",type="flash.events.FocusEvent")]
   [Event(name="change",type="flash.events.Event")]
   public class NativeText extends Sprite implements INativeText
   {
      
      public static var defaultReturnKeyLabel:String = ReturnKeyLabel.DEFAULT;
       
      
      private var st:StageText;
      
      private var numberOfLines:uint;
      
      private var _width:uint;
      
      private var _height:uint;
      
      private var snapshot:Bitmap;
      
      private var _borderThickness:uint = 0;
      
      private var _borderColor:uint = 0;
      
      private var _borderCornerSize:uint = 0;
      
      private var lineMetric:TextLineMetrics;
      
      public function NativeText(param1:uint = 1)
      {
         super();
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStage);
         this.numberOfLines = param1;
         var _loc2_:StageTextInitOptions = new StageTextInitOptions(this.numberOfLines > 1);
         this.st = new StageText(_loc2_);
         this.st.softKeyboardType = SoftKeyboardType.DEFAULT;
         this.st.returnKeyLabel = defaultReturnKeyLabel;
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(this.isEventTypeStageTextSpecific(param1))
         {
            this.st.addEventListener(param1,param2,param3,param4,param5);
         }
         else
         {
            super.addEventListener(param1,param2,param3,param4,param5);
         }
      }
      
      override public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         if(this.isEventTypeStageTextSpecific(param1))
         {
            this.st.removeEventListener(param1,param2,param3);
         }
         else
         {
            super.removeEventListener(param1,param2,param3);
         }
      }
      
      private function isEventTypeStageTextSpecific(param1:String) : Boolean
      {
         return param1 == Event.CHANGE || param1 == FocusEvent.FOCUS_IN || param1 == FocusEvent.FOCUS_OUT || param1 == KeyboardEvent.KEY_DOWN || param1 == KeyboardEvent.KEY_UP || param1 == SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE || param1 == SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING || param1 == SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.st.stage = this.stage;
         this.render();
      }
      
      private function onRemoveFromStage(param1:Event) : void
      {
         this.st.stage = null;
      }
      
      public function set borderThickness(param1:uint) : void
      {
         this._borderThickness = param1;
         this.render();
      }
      
      public function get borderThickness() : uint
      {
         return this._borderThickness;
      }
      
      public function set borderColor(param1:uint) : void
      {
         this._borderColor = param1;
         this.render();
      }
      
      public function get borderColor() : uint
      {
         return this._borderColor;
      }
      
      public function set borderCornerSize(param1:uint) : void
      {
         this._borderCornerSize = param1;
         this.render();
      }
      
      public function get borderCornerSize() : uint
      {
         return this._borderCornerSize;
      }
      
      public function set autoCapitalize(param1:String) : void
      {
         this.st.autoCapitalize = param1;
      }
      
      public function set autoCorrect(param1:Boolean) : void
      {
         this.st.autoCorrect = param1;
      }
      
      public function set color(param1:uint) : void
      {
         this.st.color = param1;
      }
      
      public function set displayAsPassword(param1:Boolean) : void
      {
         this.st.displayAsPassword = param1;
      }
      
      public function set editable(param1:Boolean) : void
      {
         this.st.editable = param1;
      }
      
      public function set fontFamily(param1:String) : void
      {
         this.st.fontFamily = param1;
      }
      
      public function set fontPosture(param1:String) : void
      {
         this.st.fontPosture = param1;
      }
      
      public function set fontSize(param1:uint) : void
      {
         this.st.fontSize = param1;
         this.render();
      }
      
      public function set fontWeight(param1:String) : void
      {
         this.st.fontWeight = param1;
      }
      
      public function set locale(param1:String) : void
      {
         this.st.locale = param1;
      }
      
      public function set maxChars(param1:int) : void
      {
         this.st.maxChars = param1;
      }
      
      public function set restrict(param1:String) : void
      {
         this.st.restrict = param1;
      }
      
      public function set returnKeyLabel(param1:String) : void
      {
         this.st.returnKeyLabel = param1;
      }
      
      public function get selectionActiveIndex() : int
      {
         return this.st.selectionActiveIndex;
      }
      
      public function get selectionAnchorIndex() : int
      {
         return this.st.selectionAnchorIndex;
      }
      
      public function set softKeyboardType(param1:String) : void
      {
         this.st.softKeyboardType = param1;
      }
      
      public function get text() : String
      {
         return this.st.text;
      }
      
      public function set text(param1:String) : void
      {
         this.st.text = param1;
      }
      
      public function set textAlign(param1:String) : void
      {
         this.st.textAlign = param1;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         this.visible = param1;
         this.st.visible = param1;
      }
      
      public function get multiline() : Boolean
      {
         return this.st.multiline;
      }
      
      public function assignFocus() : void
      {
         this.st.assignFocus();
      }
      
      public function selectRange(param1:int, param2:int) : void
      {
         this.st.selectRange(param1,param2);
      }
      
      public function freeze() : void
      {
         var _loc1_:Rectangle = this.getViewPortRectangle();
         var _loc2_:Sprite = new Sprite();
         this.drawBorder(_loc2_);
         var _loc3_:BitmapData = new BitmapData(this.st.viewPort.width,this.st.viewPort.height);
         this.st.drawViewPortToBitmapData(_loc3_);
         _loc3_.draw(_loc2_,new Matrix(1,0,0,1,this.x - _loc1_.x,this.y - _loc1_.y));
         this.snapshot = new Bitmap(_loc3_);
         this.snapshot.x = _loc1_.x - this.x;
         this.snapshot.y = _loc1_.y - this.y;
         this.addChild(this.snapshot);
         this.st.visible = false;
      }
      
      public function unfreeze() : void
      {
         if(this.snapshot != null && this.contains(this.snapshot))
         {
            this.removeChild(this.snapshot);
            this.snapshot = null;
            this.st.visible = true;
         }
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.render();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
         this.render();
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         this.render();
      }
      
      private function render() : void
      {
         if(this.stage == null || !this.stage.contains(this))
         {
            return;
         }
         this.lineMetric = null;
         this.calculateHeight();
         var _loc1_:Rectangle = this.getViewPortRectangle();
         this.st.viewPort = _loc1_;
         this.drawBorder(this);
      }
      
      private function getViewPortRectangle() : Rectangle
      {
         var _loc1_:Number = this.getTotalFontHeight();
         var _loc2_:Number = Math.max(0,Math.round(this._width - this.borderThickness * 2.5));
         var _loc3_:Number = Math.max(0,Math.round((_loc1_ + (_loc1_ - this.st.fontSize)) * this.numberOfLines));
         return new Rectangle(this.x + this.borderThickness,this.y + this.borderThickness,_loc2_,_loc3_ + 8);
      }
      
      private function drawBorder(param1:Sprite) : void
      {
         if(this.borderThickness == 0)
         {
            return;
         }
         param1.graphics.clear();
         param1.graphics.lineStyle(this.borderThickness,this.borderColor);
         param1.graphics.drawRoundRect(0,0,this._width - this.borderThickness,this._height,this.borderCornerSize,this.borderCornerSize);
         param1.graphics.endFill();
      }
      
      private function calculateHeight() : void
      {
         var _loc1_:Number = this.getTotalFontHeight();
         this._height = _loc1_ * this.numberOfLines + this.borderThickness * 2 + 8;
      }
      
      private function getTotalFontHeight() : Number
      {
         if(this.lineMetric != null)
         {
            return this.lineMetric.ascent + this.lineMetric.descent;
         }
         var _loc1_:TextField = new TextField();
         var _loc2_:TextFormat = new TextFormat(this.st.fontFamily,this.st.fontSize,null,this.st.fontWeight == FontWeight.BOLD,this.st.fontPosture == FontPosture.ITALIC);
         _loc1_.defaultTextFormat = _loc2_;
         _loc1_.text = "QQQ";
         this.lineMetric = _loc1_.getLineMetrics(0);
         return this.lineMetric.ascent + this.lineMetric.descent;
      }
      
      public function get display() : DisplayObject
      {
         return this;
      }
      
      public function set stage(param1:Stage) : void
      {
         this.st.stage = param1;
         this.render();
         if(param1)
         {
            this.st.assignFocus();
         }
      }
   }
}
