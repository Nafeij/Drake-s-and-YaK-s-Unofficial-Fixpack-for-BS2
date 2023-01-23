package game.gui
{
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class GuiNineSliceToolTip extends GuiBase
   {
      
      public static const LEFT:String = "left";
      
      public static const RIGHT:String = "right";
      
      public static const CENTER:String = "center";
      
      public static const TOP:String = "top";
      
      public static const BOTTOM:String = "bottom";
       
      
      private var _xMargin:int = 10;
      
      private var _yMargin:int = 10;
      
      private var _textField:TextField;
      
      private var _background:MovieClip;
      
      private var _verticalAlignment:String;
      
      private var _horizontalAlignment:String;
      
      private var _text:String;
      
      public function GuiNineSliceToolTip()
      {
         super();
      }
      
      public function get xMargin() : int
      {
         return this._xMargin;
      }
      
      public function set xMargin(param1:int) : void
      {
         this._xMargin = param1;
         this.updateTextField();
      }
      
      public function get yMargin() : int
      {
         return this._yMargin;
      }
      
      public function set yMargin(param1:int) : void
      {
         this._yMargin = param1;
         this.updateTextField();
      }
      
      public function init(param1:IGuiContext, param2:String, param3:String) : void
      {
         initGuiBase(param1);
         this._textField = requireGuiChild("textField") as TextField;
         this._background = requireGuiChild("background") as MovieClip;
         this._verticalAlignment = param3;
         this._horizontalAlignment = param2;
         _context.currentLocale.fixTextFieldFormat(this._textField);
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
      }
      
      public function setText(param1:String) : void
      {
         this._text = !!param1 ? param1 : "";
         if(!this._textField)
         {
            return;
         }
         this.updateTextField();
      }
      
      private function updateTextField() : void
      {
         this._textField.autoSize = TextFieldAutoSize.CENTER;
         this._textField.htmlText = this._text;
         _context.currentLocale.fixTextFieldFormat(this._textField);
         var _loc1_:Rectangle = this._textField.getCharBoundaries(0);
         var _loc2_:Rectangle = this._textField.getCharBoundaries(this._textField.text.length - 1);
         if(!_loc2_)
         {
            _loc2_ = _loc1_;
         }
         if(!_loc2_ || !_loc1_)
         {
            logger.error("GuiNineSliceToolTip cannot slice null rectangle.  Perhaps the font is wrong for the language?:\n" + this._textField.htmlText);
            return;
         }
         var _loc3_:Number = _loc2_.y + _loc2_.height - _loc1_.y;
         var _loc4_:Number = _loc2_.x + _loc2_.width - _loc1_.x;
         this._background.height = _loc3_ + this._yMargin + this._yMargin;
         this._background.width = _loc4_ + this._xMargin + this._xMargin;
         this._background.x = this.horiPositionMult * this._background.width;
         this._background.y = this.vertPositionMult * this._background.height;
         this._textField.y = this._background.y + this._yMargin;
         this._textField.x = this._background.x + this._xMargin - 2;
      }
      
      public function get vertPositionMult() : Number
      {
         switch(this._verticalAlignment)
         {
            case TOP:
               return 0;
            case BOTTOM:
               return -1;
            case CENTER:
               return -0.5;
            default:
               return 1;
         }
      }
      
      public function get horiPositionMult() : Number
      {
         switch(this._horizontalAlignment)
         {
            case LEFT:
               return 0;
            case RIGHT:
               return -1;
            case CENTER:
               return -0.5;
            default:
               return 1;
         }
      }
   }
}
