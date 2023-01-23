package engine.gui
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.math.MathUtil;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextLineMetrics;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class GuiUtil
   {
      
      public static var SHOW_TEXTFIELD_BORDERS:Boolean = false;
      
      public static var MIN_SCALE_BEFORE_WORDWRAP:Number = 0.9;
      
      private static var SCALE2D_Y_EASE_STEPS:int = 4;
      
      public static var HAS_STOP_ALL_MOVIE_CLIPS:Boolean = true;
       
      
      public function GuiUtil()
      {
         super();
      }
      
      public static function delayPlay(param1:Number, param2:MovieClip) : void
      {
         var myTimer:Timer = null;
         var resume:Function = null;
         var secs:Number = param1;
         var movie:MovieClip = param2;
         resume = function(param1:TimerEvent):void
         {
            movie.play();
            myTimer.removeEventListener(TimerEvent.TIMER,resume);
         };
         movie.stop();
         myTimer = new Timer(secs * 1000,1);
         myTimer.addEventListener(TimerEvent.TIMER,resume);
         myTimer.start();
      }
      
      public static function delayFunction(param1:Number, param2:Function) : void
      {
         var myTimer:Timer = null;
         var resume:Function = null;
         var secs:Number = param1;
         var func:Function = param2;
         resume = function(param1:TimerEvent):void
         {
            func();
            myTimer.removeEventListener(TimerEvent.TIMER,resume);
         };
         if(func == null)
         {
            throw new Error("Argument error function is null");
         }
         myTimer = new Timer(secs * 1000,1);
         myTimer.addEventListener(TimerEvent.TIMER,resume);
         myTimer.start();
      }
      
      private static function playReverse(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_.currentFrame == 1)
         {
            _loc2_.stop();
            _loc2_.removeEventListener(Event.ENTER_FRAME,playReverse);
         }
         else
         {
            _loc2_.prevFrame();
         }
      }
      
      public static function stopPlayReverse(param1:MovieClip) : void
      {
         param1.addEventListener(Event.ENTER_FRAME,playReverse);
      }
      
      public static function playStopOnFrame(param1:MovieClip, param2:int, param3:Function) : void
      {
         var movieClip:MovieClip = param1;
         var frameToStop:int = param2;
         var callback:Function = param3;
         movieClip.play();
         movieClip.addEventListener(Event.EXIT_FRAME,function stop():void
         {
            if(movieClip.currentFrame == frameToStop)
            {
               movieClip.removeEventListener(Event.EXIT_FRAME,stop);
               movieClip.stop();
               if(callback != null)
               {
                  callback();
               }
            }
         });
      }
      
      public static function playStopOnLastFrame(param1:MovieClip, param2:Function) : void
      {
         playStopOnFrame(param1,param1.totalFrames,param2);
      }
      
      public static function figureOutTextWidth(param1:TextField) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc2_:Number = param1.textWidth;
         if(!_loc2_ && Boolean(param1.text))
         {
            _loc3_ = param1.text.length;
            while(_loc3_ >= 0)
            {
               _loc4_ = param1.getCharBoundaries(_loc3_);
               if(_loc4_)
               {
                  _loc2_ = _loc4_.right;
                  break;
               }
               _loc3_--;
            }
         }
         return _loc2_;
      }
      
      public static function scaleTextToFitRect(param1:TextField, param2:Rectangle, param3:Boolean, param4:Boolean) : void
      {
         _showBorders(param1,255);
         param1.scaleX = param1.scaleY = 1;
         param1.width = param2.width;
         var _loc5_:Number = 1;
         var _loc6_:TextFormat = param1.defaultTextFormat;
         var _loc7_:int = _loc6_.size != null ? int(_loc6_.size) : 12;
         var _loc8_:Number = 2 + _loc7_ / 16;
         var _loc9_:Number = 2 + _loc7_ / 16;
         var _loc10_:Number = figureOutTextWidth(param1);
         if(_loc10_ + _loc8_ > param2.width)
         {
            _loc10_ += _loc8_;
            _loc5_ = Math.min(1,param2.width / _loc10_);
            param1.scaleX = param1.scaleY = _loc5_;
            param1.width = param2.width / _loc5_;
         }
         param1.height = param1.textHeight + _loc9_;
         if(param4)
         {
            param1.y -= (param1.height - param2.height) * 0.5;
         }
         if(param3)
         {
            param1.x -= (param1.width - param2.width) * 0.5;
         }
         Locale.updateTextFieldGuiGpTextHelper(param1);
      }
      
      public static function scaleTextToFit(param1:TextField, param2:Number, param3:Boolean = true) : void
      {
         _showBorders(param1,65280);
         param1.scaleX = param1.scaleY = 1;
         param1.width = param2;
         var _loc4_:Number = param1.height;
         var _loc5_:Number = 1;
         var _loc6_:TextFormat = param1.defaultTextFormat;
         var _loc7_:int = _loc6_.size != null ? int(_loc6_.size) : 12;
         var _loc8_:Number = 2 + _loc7_ / 8;
         var _loc9_:Number = 2 + _loc7_ / 16;
         var _loc10_:Number = figureOutTextWidth(param1);
         if(_loc10_ + _loc8_ > param2)
         {
            _loc10_ += _loc8_;
            _loc5_ = Math.min(1,param2 / _loc10_);
            param1.scaleX = param1.scaleY = _loc5_;
            param1.width = param2 / _loc5_;
         }
         param1.height = param1.textHeight + _loc9_;
         if(param3)
         {
            param1.y -= (param1.height - _loc4_) * 0.5;
         }
         Locale.updateTextFieldGuiGpTextHelper(param1);
      }
      
      public static function scaleTextToFitAlign(param1:TextField, param2:String, param3:Rectangle) : void
      {
         _showBorders(param1,16711680);
         param1.scaleX = param1.scaleY = 1;
         param1.width = param3.width;
         param1.height = param3.height;
         if(param1.textWidth > param3.width)
         {
            GuiUtil.scaleTextToFit(param1,param3.width);
         }
         param1.x = param3.x;
         if(Boolean(param2) && Boolean(param3))
         {
            switch(param2)
            {
               case "center":
                  param1.y = param3.y + (param3.height - param1.height) * 0.5;
                  break;
               case "top":
                  param1.y = param3.y;
                  break;
               case "bottom":
                  param1.y = param3.bottom - param1.height;
                  break;
               default:
                  throw new ArgumentError("Invalid align: " + param2);
            }
         }
         Locale.updateTextFieldGuiGpTextHelper(param1);
      }
      
      private static function _getTextWidthScale(param1:TextField, param2:Number) : Number
      {
         var _loc3_:Number = param1.scaleX;
         var _loc4_:TextFormat = param1.defaultTextFormat;
         var _loc5_:int = _loc4_.size != null ? int(_loc4_.size) : 12;
         var _loc6_:Number = 2 + _loc5_ / 8;
         var _loc7_:Number = figureOutTextWidth(param1);
         if(_loc7_ + _loc6_ > param2)
         {
            _loc7_ += _loc6_;
            _loc3_ = Math.min(1,param2 / _loc7_);
         }
         return _loc3_;
      }
      
      public static function scaleTextToFit2dWordwrap(param1:TextField, param2:Number, param3:Number, param4:Boolean = false) : void
      {
         _showBorders(param1,16776960);
         param1.wordWrap = false;
         var _loc5_:Number = _getTextWidthScale(param1,param2);
         if(_loc5_ < MIN_SCALE_BEFORE_WORDWRAP)
         {
            param1.wordWrap = true;
         }
         scaleTextToFit2d(param1,param2,param3,param4);
      }
      
      public static function scaleTextToFit2d(param1:TextField, param2:Number, param3:Number, param4:Boolean = false) : void
      {
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         _showBorders(param1,16711935);
         var _loc5_:Number = param1.height;
         param1.scaleX = param1.scaleY = 1;
         param1.width = param2;
         param1.height = param3;
         var _loc6_:Number = 1;
         _loc6_ = _getTextWidthScale(param1,param2);
         param1.scaleX = param1.scaleY = _loc6_;
         param1.width = param2 / _loc6_;
         var _loc7_:TextFormat = param1.defaultTextFormat;
         var _loc8_:int = _loc7_.size != null ? int(_loc7_.size) : 12;
         var _loc9_:Number = 2 + _loc8_ / 16;
         var _loc10_:Number = calculateActualHeight(param1);
         param1.height = Math.max(calculateActualHeight(param1),param1.textHeight + _loc9_);
         if(_loc10_ + _loc9_ > param3)
         {
            _loc11_ = _loc10_ + _loc9_;
            _loc12_ = Math.min(_loc6_,Math.min(1,param3 / _loc11_));
            if(_loc12_ < 1)
            {
               _loc13_ = 1;
               while(_loc13_ <= SCALE2D_Y_EASE_STEPS)
               {
                  _loc6_ = MathUtil.lerp(1,_loc12_,_loc13_ / SCALE2D_Y_EASE_STEPS);
                  param1.scaleX = param1.scaleY = _loc6_;
                  param1.width = param2 / _loc6_;
                  _loc10_ = Math.max(calculateActualHeight(param1),param1.textHeight);
                  param1.height = _loc10_ + _loc9_;
                  if(_loc10_ + _loc9_ <= param3)
                  {
                     break;
                  }
                  _loc13_++;
               }
            }
         }
         if(param4)
         {
            param1.y -= (param1.height - _loc5_) * 0.5;
         }
         Locale.updateTextFieldGuiGpTextHelper(param1);
      }
      
      private static function calculateActualHeight(param1:TextField) : Number
      {
         var _loc8_:TextLineMetrics = null;
         var _loc2_:TextFormat = param1.defaultTextFormat;
         var _loc3_:int = _loc2_.size != null ? int(_loc2_.size) : 12;
         var _loc4_:Number = 2 + _loc3_ / 32;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:int = 0;
         while(_loc7_ < param1.numLines)
         {
            _loc8_ = param1.getLineMetrics(_loc7_);
            _loc5_ += _loc8_.ascent + _loc8_.descent + _loc6_;
            _loc6_ = _loc8_.leading;
            _loc7_++;
         }
         return _loc5_ + 2 * _loc4_;
      }
      
      private static function _showBorders(param1:TextField, param2:uint) : void
      {
         param1.border = SHOW_TEXTFIELD_BORDERS;
         param1.borderColor = param2;
         param1.thickness = 2;
      }
      
      public static function cloneDictionary(param1:Dictionary) : Dictionary
      {
         var _loc3_:* = null;
         var _loc2_:Dictionary = new Dictionary();
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public static function countKeys(param1:Dictionary) : int
      {
         var _loc3_:* = undefined;
         var _loc2_:int = 0;
         for(_loc3_ in param1)
         {
            _loc2_++;
         }
         return _loc2_;
      }
      
      public static function updateDisplayList(param1:Sprite, param2:Sprite) : void
      {
         if(!param2)
         {
            return;
         }
         if(param1.visible)
         {
            if(param1.parent == null)
            {
               param2.addChild(param1);
            }
         }
         else if(param1.parent == param2)
         {
            param2.removeChild(param1);
         }
      }
      
      public static function updateDisplayListAtIndex(param1:Sprite, param2:Sprite, param3:int) : void
      {
         if(param1.visible)
         {
            param2.addChildAt(param1,param3);
         }
         else if(param1.parent == param2)
         {
            param2.removeChild(param1);
         }
      }
      
      public static function attemptStopAllMovieClips(param1:MovieClip) : void
      {
         if(!param1)
         {
            return;
         }
         if(HAS_STOP_ALL_MOVIE_CLIPS)
         {
            param1.stopAllMovieClips();
         }
         else
         {
            param1.stop();
         }
      }
      
      public static function getFullPath(param1:DisplayObject) : String
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:String = param1.name;
         var _loc3_:DisplayObject = param1.parent;
         while(Boolean(_loc3_) && Boolean(_loc3_.name))
         {
            _loc2_ = _loc3_.name + "." + _loc2_;
            _loc3_ = _loc3_.parent;
         }
         return _loc2_;
      }
      
      public static function performCensor(param1:MovieClip, param2:String, param3:ILogger) : DisplayObject
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:DisplayObject = null;
         var _loc7_:DisplayObject = null;
         var _loc8_:* = false;
         if(!param1)
         {
            return null;
         }
         if(param2)
         {
            _loc4_ = param1.getChildByName(param2);
         }
         if(!_loc4_)
         {
            _loc4_ = param1.getChildByName("all");
         }
         var _loc6_:int = 0;
         while(_loc6_ < param1.numChildren)
         {
            _loc7_ = param1.getChildAt(_loc6_);
            if(_loc7_)
            {
               _loc8_ = _loc4_ == _loc7_;
               _loc7_.visible = _loc8_;
               if(_loc7_.visible)
               {
                  _loc5_ = _loc7_;
               }
            }
            _loc6_++;
         }
         return _loc5_;
      }
   }
}
