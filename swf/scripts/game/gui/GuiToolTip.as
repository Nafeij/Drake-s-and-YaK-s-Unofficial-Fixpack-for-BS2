package game.gui
{
   import engine.core.locale.Locale;
   import engine.gui.GuiContextEvent;
   import engine.gui.IGuiToolTip;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class GuiToolTip extends GuiBase implements IGuiToolTip
   {
       
      
      private var _bg_left:MovieClip;
      
      private var _bg_right:MovieClip;
      
      private var _bg_center:MovieClip;
      
      private var _textField:TextField;
      
      private var _placeholder:MovieClip;
      
      private var _icon:GuiIcon;
      
      private var _anchor_right:int;
      
      private var _anchor_center:int;
      
      private var _anchor_left:int;
      
      private var _textValue:String;
      
      public var margin:int = 8;
      
      private var _pad:int = 4;
      
      private var _ttAlign:String = "left";
      
      public function GuiToolTip()
      {
         super();
         this._bg_left = requireGuiChild("bg_left") as MovieClip;
         this._bg_right = requireGuiChild("bg_right") as MovieClip;
         this._bg_center = requireGuiChild("bg_center") as MovieClip;
         this._textField = requireGuiChild("text") as TextField;
         this._placeholder = requireGuiChild("placeholder") as MovieClip;
         this._placeholder.visible = false;
         this._textField.autoSize = TextFieldAutoSize.NONE;
         this._textField.htmlText = "";
         this._bg_center.x = this._bg_left.x + this._bg_left.width;
         this._anchor_right = this.x + this.width;
         this._anchor_center = this.x + this.width / 2;
         this._anchor_left = this.x;
         this.setContent(null,null);
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.setContent(this.icon,this._textValue);
      }
      
      public function get hasContent() : Boolean
      {
         return Boolean(this._textField.htmlText) || Boolean(this._icon);
      }
      
      public function cleanup() : void
      {
         this.icon = null;
         super.cleanupGuiBase();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         var _loc2_:* = param1 != super.visible;
         super.visible = param1;
         if(_loc2_ && param1)
         {
            this.performLayout();
         }
      }
      
      public function setText(param1:String) : void
      {
         this.setContent(this._icon,param1);
      }
      
      public function setContent(param1:GuiIcon, param2:String) : void
      {
         if(this._textValue == param2)
         {
            return;
         }
         this._textValue = param2;
         this._textField.autoSize = TextFieldAutoSize.NONE;
         this._textField.width = 1000;
         this._textField.wordWrap = false;
         this._textField.htmlText = !!param2 ? param2 : "";
         if(_context)
         {
            _context.locale.fixTextFieldFormat(this._textField);
         }
         this.icon = param1;
         this.performLayout();
      }
      
      public function performLayout() : void
      {
         var _loc7_:* = undefined;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         if(!this._textField || !this._textField.text || !visible)
         {
            return;
         }
         if(!this._bg_left || !this._bg_right || !this._bg_center)
         {
            return;
         }
         var _loc1_:int = this._pad;
         var _loc2_:Locale = !!_context ? _context.locale : null;
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_.info.font_m)
         {
            _loc1_ += 4;
         }
         var _loc3_:Number = this._textField.textWidth;
         var _loc4_:Rectangle = this._textField.getCharBoundaries(0);
         var _loc5_:Rectangle = this._textField.getCharBoundaries(this._textField.text.length - 1);
         if(Boolean(_loc4_) && Boolean(_loc5_))
         {
            _loc7_ = this._textField.defaultTextFormat.size;
            _loc8_ = !!_loc7_ ? Number(_loc7_) : 12;
            _loc9_ = _loc5_.x - _loc4_.x;
            _loc3_ = Math.max(_loc9_ + _loc8_,_loc3_);
         }
         this._textField.width = _loc3_ + _loc1_;
         var _loc6_:int = _loc1_ + (this._textField.width + this.margin * 2) - this._bg_left.width - this._bg_right.width;
         if(this._icon)
         {
            _loc10_ = this._icon.targetWidth + this._icon.x;
            _loc6_ += _loc10_;
            this._textField.x = _loc1_ + _loc10_ + this.margin;
         }
         else
         {
            this._textField.x = this.margin;
         }
         this._bg_center.width = _loc6_;
         this._bg_right.x = this._bg_center.x + _loc6_;
         this.performAlignment();
      }
      
      public function set ttAlign(param1:String) : void
      {
         this._ttAlign = param1;
         this.performAlignment();
      }
      
      private function performAlignment() : void
      {
         switch(this._ttAlign)
         {
            case "right":
               this.x = this._anchor_right - this.width;
               break;
            case "center":
               this.x = this._anchor_center - this.width / 2;
               break;
            case "left":
               this.x = this._anchor_left;
         }
      }
      
      public function get icon() : GuiIcon
      {
         return this._icon;
      }
      
      public function set icon(param1:GuiIcon) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(param1 == this._icon)
         {
            return;
         }
         if(this._icon)
         {
            if(this._icon.parent == this)
            {
               this.removeChild(this._icon);
            }
            this._icon.release();
            this._icon = null;
         }
         this._icon = param1;
         if(this._icon)
         {
            addChild(this._icon);
            _loc2_ = this._placeholder.width;
            _loc3_ = this._icon.scaleX;
            this._icon.x = this._placeholder.x - (_loc3_ - 1) * _loc2_ / 2;
            this._icon.y = this._placeholder.y - (_loc3_ - 1) * _loc2_ / 2;
            this._icon.setTargetSize(_loc2_,_loc2_);
            this._icon.layout = GuiIconLayoutType.CENTER_FIT;
         }
      }
   }
}
