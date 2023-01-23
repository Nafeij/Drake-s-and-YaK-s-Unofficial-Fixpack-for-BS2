package engine.gui
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextLineMetrics;
   
   public class GuiGpTextHelper implements IGuiGpTextHelper
   {
      
      public static const DEBUG_VERBOSE:Boolean = false;
      
      public static const DEBUG_RENDER:Boolean = false;
      
      public static const DISABLE_ICONS:Boolean = false;
      
      private static const tokstart:String = "<<GP.";
      
      private static const tokend:String = ">>";
      
      private static const GP_MARKER:String = "     ";
      
      public static const gp_scalefactor:Number = 50;
       
      
      private var gp_infos:Vector.<GuiGpBitmap>;
      
      private var iconsSprite:Sprite;
      
      public var _locale:Locale;
      
      private var logger:ILogger;
      
      public function GuiGpTextHelper(param1:Locale, param2:ILogger)
      {
         this.iconsSprite = new Sprite();
         super();
         this._locale = param1;
         this.logger = param2;
      }
      
      public static function hasGpTokens(param1:String) : Boolean
      {
         return Boolean(param1) && param1.indexOf(tokstart) >= 0;
      }
      
      public function get locale() : Locale
      {
         return this._locale;
      }
      
      public function set locale(param1:Locale) : void
      {
         this._locale = param1;
      }
      
      public function cleanup() : void
      {
         this.reset();
      }
      
      private function reset() : void
      {
         var _loc1_:GuiGpBitmap = null;
         TweenMax.killDelayedCallsTo(this.doLayout);
         if(this.gp_infos)
         {
            for each(_loc1_ in this.gp_infos)
            {
               if(_loc1_)
               {
                  if(_loc1_.parent)
                  {
                     _loc1_.parent.removeChild(_loc1_);
                  }
                  GuiGp.releasePrimaryBitmap(_loc1_);
               }
            }
            this.gp_infos.splice(0,this.gp_infos.length);
         }
         this.resetSprite();
      }
      
      public function preProcessText(param1:String, param2:ILogger) : String
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:GpControlButton = null;
         var _loc9_:GuiGpBitmap = null;
         this.reset();
         this.gp_infos = new Vector.<GuiGpBitmap>();
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.indexOf(tokstart,_loc3_);
            if(_loc4_ < 0)
            {
               break;
            }
            _loc5_ = _loc4_ + tokstart.length;
            _loc6_ = param1.indexOf(tokend,_loc5_);
            if(_loc6_ <= _loc5_)
            {
               param2.error("GpTextHelper.preProcessText broken end-token in [" + param1 + "]");
               break;
            }
            _loc7_ = param1.substring(_loc5_,_loc6_);
            _loc8_ = Enum.parse(GpControlButton,_loc7_,false,param2) as GpControlButton;
            if(!_loc8_)
            {
               param2.error("No such gp control button for token " + _loc7_);
            }
            if(_loc8_ == GpControlButton.MENU)
            {
               _loc9_ = !!GpControlButton.REPLACE_MENU_BUTTON ? GuiGp.ctorPrimaryBitmap(GpControlButton.REPLACE_MENU_BUTTON,true) : null;
            }
            else
            {
               _loc9_ = !!_loc8_ ? GuiGp.ctorPrimaryBitmap(_loc8_,true) : null;
            }
            if(_loc9_)
            {
               _loc9_.global = true;
            }
            _loc3_ = _loc4_;
            this.gp_infos.push(_loc9_);
            param1 = param1.substr(0,_loc4_) + GP_MARKER + param1.substr(_loc6_ + tokend.length);
         }
         return param1;
      }
      
      public function set iconsVisible(param1:Boolean) : void
      {
         this.iconsSprite.visible = param1;
      }
      
      private function rectUnion(param1:Rectangle, param2:Rectangle) : Rectangle
      {
         if(param1 == null)
         {
            return param2;
         }
         if(param2 == null)
         {
            return param1;
         }
         return param1.union(param2);
      }
      
      private function computeTextBoundingRect(param1:TextField, param2:int, param3:int) : Rectangle
      {
         var _loc4_:Rectangle = null;
         var _loc5_:int = 0;
         var _loc6_:TextLineMetrics = null;
         var _loc7_:Number = NaN;
         var _loc8_:TextFormat = null;
         var _loc9_:Number = NaN;
         var _loc10_:Rectangle = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(param3 == 0)
         {
            return null;
         }
         if(param3 < 0)
         {
            throw new ArgumentError("length");
         }
         _loc4_ = null;
         if(PlatformStarling.instance)
         {
            _loc5_ = param1.getLineIndexOfChar(param2);
            _loc6_ = param1.getLineMetrics(_loc5_);
            _loc7_ = _loc6_.leading;
            if(DEBUG_VERBOSE)
            {
               this.logger.debug("tf.lineheight:  " + _loc6_.height.toString());
               this.logger.debug("tf.ascent:  " + _loc6_.ascent.toString());
               this.logger.debug("tf.descent:  " + _loc6_.descent.toString());
               this.logger.debug("tf.leading:  " + _loc6_.leading.toString());
               this.logger.debug("tf.x:\t" + _loc6_.x.toString());
            }
            _loc8_ = param1.getTextFormat();
            _loc9_ = _loc8_.leftMargin != null ? _loc8_.leftMargin as Number : 2;
            _loc9_ += 2;
            _loc10_ = param1.getCharBoundaries(0);
            _loc11_ = -(_loc10_.x - _loc9_) + _loc6_.x;
            _loc12_ = -(_loc10_.y - _loc7_);
            _loc13_ = 0;
            while(_loc13_ < param3)
            {
               _loc10_ = param1.getCharBoundaries(param2 + _loc13_);
               _loc10_.x += _loc11_;
               _loc10_.y += _loc12_;
               _loc4_ = this.rectUnion(_loc4_,_loc10_);
               _loc13_++;
            }
         }
         else
         {
            _loc14_ = 0;
            while(_loc14_ < param3)
            {
               _loc4_ = this.rectUnion(_loc4_,param1.getCharBoundaries(param2 + _loc14_));
               _loc14_++;
            }
         }
         return _loc4_;
      }
      
      private function computeGamepadIconScale(param1:TextField, param2:Rectangle) : Number
      {
         var _loc3_:Object = param1.defaultTextFormat.size;
         var _loc4_:Number = (!!_loc3_ ? _loc3_ as Number : param2.height) + 8;
         return _loc4_ / gp_scalefactor;
      }
      
      private function drawRect(param1:Graphics, param2:Rectangle, param3:uint, param4:Boolean, param5:Number = 1) : void
      {
         if(param4)
         {
            param1.beginFill(param3,param5);
            param1.drawRect(param2.x,param2.y,param2.width,param2.height);
            param1.endFill();
         }
         else
         {
            param1.lineStyle(1,param3);
            param1.beginFill(0,0);
            param1.drawRect(param2.x,param2.y,param2.width,param2.height);
            param1.endFill();
         }
      }
      
      private function resetSprite() : void
      {
         if(this.iconsSprite.numChildren > 0)
         {
            this.iconsSprite.removeChildren(0,this.iconsSprite.numChildren - 1);
         }
      }
      
      private function getNumConsecutiveSpaces(param1:String, param2:uint) : uint
      {
         var _loc3_:uint = param2;
         while(_loc3_ < param1.length && param1.charAt(_loc3_) == " ")
         {
            _loc3_++;
         }
         return _loc3_ - param2;
      }
      
      private function addGpIcon(param1:DisplayObject, param2:Rectangle) : void
      {
         var _loc3_:Shape = null;
         if(param1 == null)
         {
            _loc3_ = new Shape();
            _loc3_.visible = true;
            _loc3_.graphics.beginFill(16711680);
            _loc3_.graphics.drawRect(0,0,20,20);
            _loc3_.graphics.endFill();
            param1 = _loc3_;
         }
         param1.x = param2.x + 0.5 * (param2.width - param1.width);
         param1.y = param2.y + 0.5 * (param2.height - param1.height);
         param1.visible = true;
         this.iconsSprite.addChild(param1);
      }
      
      private function debugRender(param1:Rectangle, param2:TextField) : void
      {
         var _loc10_:int = 0;
         var _loc3_:TextFormat = param2.getTextFormat();
         var _loc4_:int = param2.getLineIndexOfChar(_loc10_);
         var _loc5_:TextLineMetrics = param2.getLineMetrics(_loc4_);
         var _loc6_:Number = _loc3_.leftMargin != null ? _loc3_.leftMargin as Number : 2;
         _loc6_ += 2;
         var _loc7_:Rectangle = param2.getCharBoundaries(0);
         var _loc8_:Number = -(_loc7_.x - _loc6_) + _loc5_.x;
         var _loc9_:Number = -(_loc7_.y - 2);
         _loc10_ = 0;
         while(_loc10_ < param2.text.length)
         {
            _loc7_ = param2.getCharBoundaries(_loc10_);
            if(_loc7_)
            {
               _loc7_.x += _loc8_;
               _loc7_.y += _loc9_;
               this.debugRenderRect(_loc7_,16711680);
            }
            _loc10_++;
         }
         var _loc11_:Shape = new Shape();
         this.drawRect(_loc11_.graphics,param1,8453888,true,0.5);
         this.iconsSprite.addChild(_loc11_);
         var _loc12_:Shape = new Shape();
         var _loc13_:Rectangle = new Rectangle(0,0,param2.width / param2.scaleX,param2.height / param2.scaleY);
         this.drawRect(_loc12_.graphics,_loc13_,16711935,false);
         this.iconsSprite.addChild(_loc12_);
      }
      
      private function debugRenderRect(param1:Rectangle, param2:uint) : void
      {
         var _loc3_:Shape = new Shape();
         this.drawRect(_loc3_.graphics,param1,param2,false,0.5);
         this.iconsSprite.addChild(_loc3_);
      }
      
      private function doLayout(param1:Object) : void
      {
         var _loc7_:uint = 0;
         var _loc8_:Rectangle = null;
         var _loc9_:DisplayObject = null;
         var _loc10_:GuiGpBitmap = null;
         var _loc2_:TextField = param1.textField;
         var _loc3_:DisplayObjectContainer = param1.parent;
         var _loc4_:Vector.<GuiGpBitmap> = param1.icons;
         if(!_loc2_)
         {
            this.logger.error("GuiGpTextHelper.doLayout null tf");
            return;
         }
         if(DEBUG_VERBOSE)
         {
            this.debugPrint("******************************************************************");
            this.debugPrint("GuiGpTextHelper.doLayout: [" + _loc2_.text + "]");
            this.debugPrint("tf.scale:  " + _loc2_.scaleX + ", " + _loc2_.scaleY);
            this.debugPrint("tf.border: " + _loc2_.border);
            this.debugPrint(!!("icons:     " + (_loc4_ == null)) ? "null" : _loc4_.length.toString());
         }
         this.resetSprite();
         this._locale.fixTextFieldFormat(_loc2_);
         this.iconsSprite.x = _loc2_.x;
         this.iconsSprite.y = _loc2_.y;
         this.iconsSprite.scaleX = _loc2_.scaleX;
         this.iconsSprite.scaleY = _loc2_.scaleY;
         var _loc5_:int = 0;
         var _loc6_:int = _loc2_.text.indexOf(GP_MARKER,0);
         while(_loc6_ >= 0)
         {
            _loc7_ = this.getNumConsecutiveSpaces(_loc2_.text,_loc6_);
            if(_loc7_ > 0)
            {
               _loc8_ = this.computeTextBoundingRect(_loc2_,_loc6_,_loc7_);
               if(_loc8_ != null && _loc8_.width > 0 && _loc8_.height > 0)
               {
                  if(DEBUG_RENDER)
                  {
                     this.debugRender(_loc8_,_loc2_);
                  }
                  if(!DISABLE_ICONS)
                  {
                     if(_loc4_ != null && _loc5_ < _loc4_.length)
                     {
                        _loc10_ = _loc4_[_loc5_];
                        if(!_loc10_)
                        {
                           this.logger.error("GuiGpTextHelper.doLayout icon " + _loc5_ + " is null");
                           _loc5_++;
                           break;
                        }
                        _loc10_.scale = this.computeGamepadIconScale(_loc2_,_loc8_);
                        _loc9_ = _loc10_;
                     }
                     this.addGpIcon(_loc9_,_loc8_);
                  }
               }
               _loc5_++;
            }
            _loc6_ = _loc2_.text.indexOf(GP_MARKER,_loc6_ + _loc7_ + 1);
         }
         if(DEBUG_VERBOSE)
         {
            this.debugPrint("done with doLayout");
            this.debugPrint("iconsSprite.numChildren=" + this.iconsSprite.numChildren);
            this.debugPrint("******************************************************************");
         }
         _loc3_.addChild(this.iconsSprite);
      }
      
      public function finishProcessing(param1:TextField) : void
      {
         var _loc2_:Object = null;
         if(!param1 || !param1.parent || !param1.visible)
         {
            return;
         }
         if(this.gp_infos != null || DEBUG_RENDER)
         {
            _loc2_ = new Object();
            _loc2_.textField = param1;
            _loc2_.parent = param1.parent;
            _loc2_.icons = this.gp_infos;
            TweenMax.killDelayedCallsTo(this.doLayout);
            TweenMax.delayedCall(1,this.doLayout,[_loc2_],true);
         }
      }
      
      private function debugPrint(param1:String) : void
      {
         if(DEBUG_VERBOSE)
         {
            if(this.logger)
            {
               this.logger.info(param1);
            }
         }
      }
   }
}
