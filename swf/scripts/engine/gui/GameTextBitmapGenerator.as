package engine.gui
{
   import engine.core.locale.ILocaleProvider;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleFont;
   import engine.core.locale.LocaleInfo;
   import engine.core.logging.ILogger;
   import engine.core.util.BitmapUtil;
   import engine.core.util.ColorUtil;
   import engine.scene.ITextBitmapGenerator;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class GameTextBitmapGenerator implements ITextBitmapGenerator
   {
      
      public static var mcTextField:Class;
       
      
      private var _mcKernel:MovieClip;
      
      private var text_vinque:TextField;
      
      private var text_minion:TextField;
      
      public var logger:ILogger;
      
      public var localeProvider:ILocaleProvider;
      
      private var matrix:Matrix;
      
      public function GameTextBitmapGenerator(param1:ILogger, param2:ILocaleProvider)
      {
         this.matrix = new Matrix();
         super();
         this.logger = param1;
         this.localeProvider = param2;
         if(!param2)
         {
            throw new ArgumentError("null localeProvider");
         }
         this.setupMovieClip();
      }
      
      public function cleanup() : void
      {
      }
      
      private function setupMovieClip() : void
      {
         if(!mcTextField)
         {
            this.logger.error("GameTextBitmapGenerator.setupMovieClip no mcTextField set");
            return;
         }
         this._mcKernel = new mcTextField() as MovieClip;
         if(this._mcKernel)
         {
            this.text_vinque = this._mcKernel.getChildByName("text_vinque") as TextField;
            this.text_minion = this._mcKernel.getChildByName("text_minion") as TextField;
            if(this.text_minion)
            {
               this.text_minion.x = 0;
               this.text_minion.y = 0;
            }
            else
            {
               this.logger.error("GameTextBitmapGenerator No text_minion found");
            }
            if(this.text_vinque)
            {
               this.text_vinque.x = 0;
               this.text_vinque.y = 0;
            }
            else
            {
               this.logger.error("GameTextBitmapGenerator No text_vinque found");
            }
         }
      }
      
      public function generateTextBitmap(param1:String, param2:int, param3:uint, param4:*, param5:String, param6:int) : BitmapData
      {
         var _loc10_:int = 0;
         var _loc17_:LocaleInfo = null;
         var _loc18_:LocaleFont = null;
         var _loc19_:LocaleFont = null;
         if(!this._mcKernel)
         {
            return null;
         }
         var _loc7_:TextField = param1 == "minion" ? this.text_minion : this.text_vinque;
         var _loc8_:TextField = _loc7_ == this.text_minion ? this.text_vinque : this.text_minion;
         if(!_loc7_ || !_loc8_)
         {
            this.logger.error("GameTextBitmapGenerator invalid texts");
            return null;
         }
         _loc7_.visible = true;
         _loc8_.visible = false;
         _loc8_.htmlText = "";
         _loc8_.width = 0;
         _loc8_.height = 0;
         var _loc9_:String = _loc7_.defaultTextFormat.font;
         param1 = _loc9_;
         var _loc11_:Locale = !!this.localeProvider ? this.localeProvider.locale : null;
         if(_loc11_)
         {
            _loc17_ = _loc11_.info;
            _loc18_ = _loc17_.font_v;
            _loc19_ = _loc17_.font_m;
            if(_loc7_ == this.text_vinque && Boolean(_loc18_))
            {
               param1 = _loc18_.face;
               param2 += _loc18_.sizeMod;
               _loc10_ += _loc18_.offsetY / 2;
            }
            else if(_loc7_ == this.text_minion && Boolean(_loc19_))
            {
               param1 = _loc19_.face;
            }
         }
         _loc7_.width = 2000;
         _loc7_.htmlText = "";
         _loc7_.textColor = param3;
         _loc7_.defaultTextFormat = new TextFormat(param1,param2,param3);
         _loc7_.setTextFormat(_loc7_.defaultTextFormat);
         var _loc12_:* = "";
         if(param1 != _loc9_)
         {
            _loc12_ = " face=\'" + param1 + "\' ";
         }
         param5 = "<font size=\'" + param2 + "\' " + _loc12_ + " color=\'" + ColorUtil.colorStr(param3) + "\'>" + param5 + "</font>";
         _loc7_.htmlText = param5;
         _loc7_.width = _loc7_.textWidth + 10;
         if(param6 > 0)
         {
            _loc7_.width = Math.min(param6,_loc7_.width);
         }
         _loc7_.height = 1000;
         _loc7_.height = _loc7_.textHeight + 8;
         var _loc13_:int = 0;
         if(param4 == null || param4 == undefined)
         {
            if(Boolean(_loc7_.filters) && _loc7_.filters.length > 0)
            {
               _loc7_.filters = [];
            }
         }
         else
         {
            _loc13_ = 6;
            _loc7_.filters = [new GlowFilter(param4,1,_loc13_,_loc13_,2)];
         }
         var _loc14_:int = _loc7_.width + _loc13_ * 3;
         var _loc15_:int = _loc7_.height + _loc13_ * 3;
         var _loc16_:BitmapData = new BitmapData(_loc14_,_loc15_,true,0);
         this.matrix.identity();
         this.matrix.translate(_loc7_.x + _loc13_ - _loc10_,_loc7_.y + _loc13_ + _loc10_);
         BitmapUtil.drawWithQuality(_loc16_,this._mcKernel,this.matrix,null,null,_loc16_.rect,true,StageQuality.HIGH);
         return _loc16_;
      }
   }
}
