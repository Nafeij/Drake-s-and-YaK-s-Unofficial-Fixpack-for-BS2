package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.TextEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class GraphingPanel extends ConsolePanel
   {
       
      
      private var _group:GraphGroup;
      
      private var _interest:GraphInterest;
      
      private var _menuString:String;
      
      protected var _bm:Bitmap;
      
      protected var _bmd:BitmapData;
      
      protected var lowestValue:Number;
      
      protected var highestValue:Number;
      
      protected var lastValues:Object;
      
      private var lowTxt:TextField;
      
      private var highTxt:TextField;
      
      private var lineRect:Rectangle;
      
      public function GraphingPanel(param1:Console, param2:GraphGroup)
      {
         var _loc3_:TextFormat = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:MainPanel = null;
         this.lastValues = new Object();
         this.lineRect = new Rectangle(0,0,1);
         super(param1);
         this._group = param2;
         name = param2.name;
         registerDragger(bg);
         minWidth = 32;
         minHeight = 26;
         _loc3_ = new TextFormat();
         var _loc4_:Object = style.styleSheet.getStyle("low");
         _loc3_.font = _loc4_.fontFamily;
         _loc3_.size = _loc4_.fontSize;
         _loc3_.color = style.lowColor;
         this._bm = new Bitmap();
         this._bm.name = "graph";
         this._bm.y = style.menuFontSize - 2;
         addChild(this._bm);
         this.lowTxt = new TextField();
         this.lowTxt.name = "lowestField";
         this.lowTxt.defaultTextFormat = _loc3_;
         this.lowTxt.mouseEnabled = false;
         this.lowTxt.height = style.menuFontSize + 2;
         addChild(this.lowTxt);
         this.highTxt = new TextField();
         this.highTxt.name = "highestField";
         this.highTxt.defaultTextFormat = _loc3_;
         this.highTxt.mouseEnabled = false;
         this.highTxt.height = style.menuFontSize + 2;
         this.highTxt.y = style.menuFontSize - 4;
         addChild(this.highTxt);
         txtField = makeTF("menuField");
         txtField.height = style.menuFontSize + 4;
         txtField.y = -3;
         registerTFRoller(txtField,this.onMenuRollOver,this.linkHandler);
         registerDragger(txtField);
         addChild(txtField);
         this.setMenuString();
         this._group.onUpdate.add(this.onGroupUpdate);
         var _loc5_:Rectangle = param2.rect;
         _loc6_ = Math.max(minWidth,_loc5_.width);
         _loc7_ = Math.max(minHeight,_loc5_.height);
         _loc8_ = console.panels.mainPanel;
         x = _loc8_.x + _loc5_.x;
         y = _loc8_.y + _loc5_.y;
         if(param2.alignRight)
         {
            x = _loc8_.x + _loc8_.width - x;
         }
         init(_loc6_,_loc7_,true);
      }
      
      public function get group() : GraphGroup
      {
         return this._group;
      }
      
      public function reset() : void
      {
         this.lowestValue = this.highestValue = NaN;
         this.lastValues = new Object();
      }
      
      protected function setMenuString() : void
      {
         var _loc2_:String = null;
         this._menuString = "<menu>";
         var _loc1_:Array = this._group.menus.concat("R","X");
         for each(_loc2_ in _loc1_)
         {
            this._menuString += " <a href=\"event:" + _loc2_ + "\">" + _loc2_ + "</a>";
         }
         this._menuString += "</menu></low></r>";
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.lowTxt.y = param1 - style.menuFontSize;
         this.resizeBMD();
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.lowTxt.width = param1;
         this.highTxt.width = param1;
         txtField.width = param1;
         txtField.scrollH = txtField.maxScrollH;
         this.resizeBMD();
      }
      
      private function resizeBMD() : void
      {
         var _loc4_:Matrix = null;
         var _loc1_:Number = width;
         var _loc2_:Number = height - style.menuFontSize + 2;
         if(this._bmd != null && this._bmd.width == _loc1_ && this._bmd.height == _loc2_)
         {
            return;
         }
         var _loc3_:BitmapData = this._bmd;
         this._bmd = new BitmapData(_loc1_,_loc2_,true,0);
         if(_loc3_ != null)
         {
            _loc4_ = new Matrix(1,0,0,this._bmd.height / _loc3_.height);
            _loc4_.tx = this._bmd.width - _loc3_.width;
            this._bmd.draw(_loc3_,_loc4_,null,null,null,true);
            _loc3_.dispose();
         }
         this._bm.bitmapData = this._bmd;
      }
      
      protected function onGroupUpdate(param1:Array) : void
      {
         var _loc4_:GraphInterest = null;
         var _loc9_:Number = NaN;
         var _loc2_:Array = this._group.interests;
         var _loc3_:Boolean = false;
         var _loc5_:Number = isNaN(this._group.fixedMin) ? this.lowestValue : this._group.fixedMin;
         var _loc6_:Number = isNaN(this._group.fixedMax) ? this.highestValue : this._group.fixedMax;
         var _loc7_:uint = _loc2_.length;
         var _loc8_:uint = 0;
         while(_loc8_ < _loc7_)
         {
            _loc4_ = _loc2_[_loc8_];
            _loc9_ = Number(param1[_loc8_]);
            if(isNaN(this._group.fixedMin) && (isNaN(_loc5_) || _loc9_ < _loc5_))
            {
               _loc5_ = _loc9_;
            }
            if(isNaN(this._group.fixedMax) && (isNaN(_loc6_) || _loc9_ > _loc6_))
            {
               _loc6_ = _loc9_;
            }
            _loc8_++;
         }
         this.updateKeyText(param1);
         if(this.lowestValue != _loc5_ || this.highestValue != _loc6_)
         {
            this.scaleBitmapData(_loc5_,_loc6_);
            if(this.group.inverted)
            {
               this.highTxt.text = this.makeValueString(_loc5_);
               this.lowTxt.text = this.makeValueString(_loc6_);
            }
            else
            {
               this.lowTxt.text = this.makeValueString(_loc5_);
               this.highTxt.text = this.makeValueString(_loc6_);
            }
         }
         this.pushBMD(param1);
      }
      
      protected function pushBMD(param1:Array) : void
      {
         var _loc7_:GraphInterest = null;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:uint = 0;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc2_:Number = this.highestValue - this.lowestValue;
         var _loc3_:uint = uint(this._bmd.width - 1);
         var _loc4_:int = this._bmd.height;
         this._bmd.lock();
         this._bmd.scroll(-1,0);
         this._bmd.fillRect(new Rectangle(_loc3_,0,1,this._bmd.height),0);
         var _loc5_:Array = this._group.interests;
         var _loc6_:int = int(_loc5_.length - 1);
         while(_loc6_ >= 0)
         {
            _loc7_ = _loc5_[_loc6_];
            _loc8_ = Number(param1[_loc6_]);
            _loc9_ = this.getPixelValue(_loc8_);
            _loc10_ = Number(this.lastValues[_loc6_]);
            _loc11_ = _loc7_.col + 4278190080;
            if(isNaN(_loc10_) == false)
            {
               this.lineRect.x = _loc3_;
               _loc12_ = this.getPixelValue(_loc10_);
               if(_loc9_ < _loc12_)
               {
                  _loc13_ = (_loc12_ - _loc9_) * 0.5;
                  this.lineRect.y = _loc9_;
                  this.lineRect.height = _loc13_;
                  this._bmd.fillRect(this.lineRect,_loc11_);
                  --this.lineRect.x;
                  this.lineRect.y = _loc9_ + _loc13_;
                  this._bmd.fillRect(this.lineRect,_loc11_);
               }
               else
               {
                  _loc9_ > _loc12_;
               }
               _loc13_ = (_loc9_ - _loc12_) * 0.5;
               this.lineRect.y = _loc12_ + _loc13_;
               this.lineRect.height = _loc13_;
               this._bmd.fillRect(this.lineRect,_loc11_);
               --this.lineRect.x;
               this.lineRect.y = _loc12_;
               this._bmd.fillRect(this.lineRect,_loc11_);
            }
            this._bmd.setPixel32(_loc3_,_loc9_,_loc11_);
            this.lastValues[_loc6_] = _loc8_;
            _loc6_--;
         }
         this._bmd.unlock();
      }
      
      protected function getPixelValue(param1:Number) : Number
      {
         if(this.highestValue == this.lowestValue)
         {
            return this._bmd.height * 0.5;
         }
         param1 = (param1 - this.lowestValue) / (this.highestValue - this.lowestValue) * this._bmd.height;
         if(!this._group.inverted)
         {
            param1 = this._bmd.height - param1;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 >= this._bmd.height)
         {
            param1 = this._bmd.height - 1;
         }
         return param1;
      }
      
      protected function scaleBitmapData(param1:Number, param2:Number) : void
      {
         var _loc3_:BitmapData = this._bmd.clone();
         this._bmd.fillRect(this._bmd.rect,0);
         var _loc4_:Number = param2 - param1;
         if(_loc4_ == 0)
         {
            this.lowestValue = param1;
            this.highestValue = param2;
            return;
         }
         var _loc5_:Number = _loc4_ / this._bmd.height;
         var _loc6_:Number = _loc5_ * 0.5;
         param2 += _loc5_;
         param1 -= _loc5_;
         if(!isNaN(this._group.fixedMax) && param2 > this._group.fixedMax)
         {
            param2 = this._group.fixedMax;
         }
         if(!isNaN(this._group.fixedMin) && param1 < this._group.fixedMin)
         {
            param1 = this._group.fixedMin;
         }
         _loc4_ = param2 - param1;
         var _loc7_:Number = this.highestValue - this.lowestValue;
         var _loc8_:Matrix = new Matrix();
         if(this._group.inverted)
         {
            _loc8_.ty = (this.lowestValue - param1) / _loc7_ * this._bmd.height;
         }
         else
         {
            _loc8_.ty = (param2 - this.highestValue) / _loc7_ * this._bmd.height;
         }
         _loc8_.scale(1,_loc7_ / _loc4_);
         this._bmd.draw(_loc3_,_loc8_,null,null,null,true);
         _loc3_.dispose();
         this.lowestValue = param1;
         this.highestValue = param2;
      }
      
      public function updateKeyText(param1:Array) : void
      {
         var _loc5_:GraphInterest = null;
         var _loc2_:String = "<r><low>";
         var _loc3_:uint = this._group.interests.length;
         var _loc4_:uint = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this._group.interests[_loc4_];
            _loc2_ += "<font color=\'#" + _loc5_.col.toString(16) + "\'>" + this.makeValueString(param1[_loc4_]) + _loc5_.key + "</font> ";
            _loc4_++;
         }
         txtField.htmlText = _loc2_ + this._menuString;
         txtField.scrollH = txtField.maxScrollH;
      }
      
      private function makeValueString(param1:Number) : String
      {
         var _loc2_:uint = this._group.numberDisplayPrecision;
         if(_loc2_ == 0 || param1 == 0)
         {
            return String(param1);
         }
         return param1.toPrecision(_loc2_);
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         if(param1.text == "R")
         {
            this.reset();
         }
         else if(param1.text == "X")
         {
            this._group.close();
         }
         this._group.onMenu.apply(param1.text);
         param1.stopPropagation();
      }
      
      protected function onMenuRollOver(param1:TextEvent) : void
      {
         var _loc2_:String = !!param1.text ? param1.text.replace("event:","") : null;
         if(_loc2_ == "G")
         {
            _loc2_ = "Garbage collect::Requires debugger version of flash player";
         }
         else
         {
            _loc2_ = null;
         }
         console.panels.tooltip(_loc2_,this);
      }
   }
}
