package game.gui
{
   import engine.core.locale.Locale;
   import engine.gui.IEngineGuiContext;
   import engine.gui.IGuiTooltipStatus;
   import flash.errors.IllegalOperationError;
   import flash.text.TextField;
   
   public class GuiTooltipStatus extends GuiBase implements IGuiTooltipStatus
   {
       
      
      private var _left_texts:Vector.<String>;
      
      private var _right_texts:Vector.<String>;
      
      public var _tooltip_text_left:TextField;
      
      public var _tooltip_text_right:TextField;
      
      public var _tooltip_text_title:TextField;
      
      private var _tooltip_text_left_width:int;
      
      private var _tooltip_text_left_x:int;
      
      public function GuiTooltipStatus()
      {
         super();
         this._left_texts = new Vector.<String>(this.maxLines);
         this._right_texts = new Vector.<String>(this.maxLines);
         this._tooltip_text_left = this.getChildByName("text_left") as TextField;
         this._tooltip_text_right = this.getChildByName("text_right") as TextField;
         this._tooltip_text_title = this.getChildByName("text_title") as TextField;
         this._tooltip_text_left_width = this._tooltip_text_left.width;
         this._tooltip_text_left_x = this._tooltip_text_left.x;
         this.visible = false;
         this.mouseEnabled = this.mouseChildren = false;
         registerScalableTextfield(this._tooltip_text_title);
      }
      
      public function get maxLines() : int
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function init(param1:IEngineGuiContext) : void
      {
         super.initGuiBase(param1 as IGuiContext);
      }
      
      public function tooltipSetLeftText(param1:int, param2:String) : void
      {
         this._left_texts[param1] = param2;
      }
      
      public function tooltipSetRightText(param1:int, param2:String) : void
      {
         this._right_texts[param1] = param2;
      }
      
      public function tooltipSetTitle(param1:String) : void
      {
         this._tooltip_text_title.htmlText = !!param1 ? param1 : "";
      }
      
      public function tooltipRender() : void
      {
         var _loc4_:Number = NaN;
         var _loc1_:String = this._composeText(this._left_texts);
         var _loc2_:String = this._composeText(this._right_texts);
         this._tooltip_text_left.htmlText = _loc1_;
         this._tooltip_text_right.htmlText = _loc2_;
         var _loc3_:Locale = _context.locale;
         _loc3_.fixTextFieldFormat(this._tooltip_text_left);
         _loc3_.fixTextFieldFormat(this._tooltip_text_right);
         this._tooltip_text_left.scaleX = 1;
         this._tooltip_text_left.width = 1000;
         this._tooltip_text_left.x = this._tooltip_text_left_x;
         if(this._tooltip_text_left.textWidth > this._tooltip_text_left_width)
         {
            _loc4_ = this._tooltip_text_left_width / this._tooltip_text_left.textWidth;
            this._tooltip_text_left.scaleX = _loc4_;
            this._tooltip_text_left.x = this._tooltip_text_left_x - 20 * (1 - _loc4_);
         }
      }
      
      private function _composeText(param1:Vector.<String>) : String
      {
         var _loc4_:String = null;
         var _loc2_:* = "";
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_)
            {
               _loc2_ += _loc4_;
            }
            if(_loc3_ < param1.length - 1)
            {
               _loc2_ += "\n";
            }
            _loc3_++;
         }
         return _loc2_;
      }
   }
}
