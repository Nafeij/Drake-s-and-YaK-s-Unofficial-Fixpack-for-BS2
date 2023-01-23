package com.google.analytics.debug
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   
   public class Label extends UISprite
   {
      
      public static var count:uint = 0;
       
      
      private var _background:Shape;
      
      private var _textField:TextField;
      
      private var _text:String;
      
      private var _tag:String;
      
      private var _color:uint;
      
      protected var selectable:Boolean;
      
      public var stickToEdge:Boolean;
      
      public function Label(param1:String = "", param2:String = "uiLabel", param3:uint = 0, param4:Align = null, param5:Boolean = false)
      {
         super();
         this.name = "Label" + count++;
         this.selectable = false;
         this._background = new Shape();
         this._textField = new TextField();
         this._text = param1;
         this._tag = param2;
         if(param4 == null)
         {
            param4 = Align.none;
         }
         this.alignement = param4;
         this.stickToEdge = param5;
         if(param3 == 0)
         {
            param3 = uint(Style.backgroundColor);
         }
         this._color = param3;
         this._textField.addEventListener(TextEvent.LINK,this.onLink);
      }
      
      override protected function layout() : void
      {
         this._textField.type = TextFieldType.DYNAMIC;
         this._textField.autoSize = TextFieldAutoSize.LEFT;
         this._textField.background = false;
         this._textField.selectable = this.selectable;
         this._textField.multiline = true;
         this._textField.styleSheet = Style.sheet;
         this.text = this._text;
         addChild(this._background);
         addChild(this._textField);
      }
      
      override protected function dispose() : void
      {
         this._textField.removeEventListener(TextEvent.LINK,this.onLink);
         super.dispose();
      }
      
      private function _draw() : void
      {
         var _loc1_:Graphics = this._background.graphics;
         _loc1_.clear();
         _loc1_.beginFill(this._color);
         var _loc2_:uint = this._textField.width;
         var _loc3_:uint = this._textField.height;
         if(forcedWidth > 0)
         {
            _loc2_ = forcedWidth;
         }
         Background.drawRounded(this,_loc1_,_loc2_,_loc3_);
         _loc1_.endFill();
      }
      
      public function get tag() : String
      {
         return this._tag;
      }
      
      public function set tag(param1:String) : void
      {
         this._tag = param1;
         this.text = "";
      }
      
      public function get text() : String
      {
         return this._textField.text;
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == "")
         {
            param1 = this._text;
         }
         this._textField.htmlText = "<span class=\"" + this.tag + "\">" + param1 + "</span>";
         this._text = param1;
         this._draw();
         resize();
      }
      
      public function appendText(param1:String, param2:String = "") : void
      {
         if(param1 == "")
         {
            return;
         }
         if(param2 == "")
         {
            param2 = this.tag;
         }
         this._textField.htmlText += "<span class=\"" + param2 + "\">" + param1 + "</span>";
         this._text += param1;
         this._draw();
         resize();
      }
      
      public function onLink(param1:TextEvent) : void
      {
      }
   }
}
