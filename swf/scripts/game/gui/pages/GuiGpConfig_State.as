package game.gui.pages
{
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpTextHelper;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.IGuiContext;
   
   public class GuiGpConfig_State extends MovieClip
   {
       
      
      private var gui:GuiGpConfig;
      
      private var caption:String;
      
      public var control:GpControlButton;
      
      public var display:GpControlButton;
      
      public var children:Vector.<GuiGpConfig_State>;
      
      public var child:GuiGpConfig_State;
      
      public var cursor:int = -1;
      
      private var _complete:Boolean;
      
      public var started:Boolean;
      
      public var _parentStage:GuiGpConfig_State;
      
      public var gpbmp:GuiGpBitmap;
      
      public var _checkmark:MovieClip;
      
      public var _xmark:MovieClip;
      
      public var _text:TextField;
      
      private var context:IGuiContext;
      
      public var expectedValue:Number = 1;
      
      public var isAxis:Boolean;
      
      public var canAxisButton:Boolean;
      
      public var canAxisButtonPos:Boolean;
      
      public var canAxisButtonNeg:Boolean;
      
      public var canAxisButtonOpposite:GpControlButton;
      
      public var completionCallback:Function;
      
      public var optional:Boolean;
      
      public var keyboardOnly:Boolean;
      
      public var keyboardOmit:Boolean;
      
      private var token:String;
      
      private var guiGpTextHelper:GuiGpTextHelper;
      
      private var GP_CONTROL_STRING_START:String = "((GP.";
      
      private var GP_CONTROL_STRING_END:String = "))";
      
      public var ignored:Boolean;
      
      public var skipped:Boolean;
      
      public function GuiGpConfig_State()
      {
         super();
         this._checkmark = getChildByName("checkmark") as MovieClip;
         this._xmark = getChildByName("xmark") as MovieClip;
         this._text = getChildByName("text") as TextField;
      }
      
      public static function ctor(param1:GuiGpConfig, param2:String, param3:GpControlButton, param4:GpControlButton = null) : GuiGpConfig_State
      {
         var _loc5_:GuiGpConfig_State = new GuiGpConfig.mcClazz_state();
         return _loc5_.init(param1,param2,param3,param4);
      }
      
      private static function getLocalization(param1:LocaleCategory, param2:Locale, param3:String, param4:String) : String
      {
         var _loc5_:* = null;
         var _loc6_:String = null;
         if(param4)
         {
            _loc5_ = param3 + "_vis";
            _loc6_ = param2.translate(param1,_loc5_,true);
            if(!_loc6_)
            {
               _loc5_ = param3 + "_" + param4.charAt(0);
               _loc6_ = param2.translate(param1,_loc5_,true);
            }
         }
         if(!_loc6_)
         {
            _loc5_ = param3;
            _loc6_ = param2.translate(param1,_loc5_);
         }
         return _loc6_;
      }
      
      public function replaceGpControlStrings(param1:Locale, param2:String, param3:String, param4:ILogger) : String
      {
         var i:int;
         var orig:String = null;
         var controlstart:int = 0;
         var tokstart:int = 0;
         var tokend:int = 0;
         var tok:String = null;
         var cb:GpControlButton = null;
         var str:String = null;
         var locale:Locale = param1;
         var value:String = param2;
         var vis:String = param3;
         var logger:ILogger = param4;
         if(!value)
         {
            return value;
         }
         orig = value;
         i = 0;
         try
         {
            while(i >= 0)
            {
               i = value.indexOf(this.GP_CONTROL_STRING_START,i);
               if(i < 0)
               {
                  break;
               }
               controlstart = i;
               tokstart = i + this.GP_CONTROL_STRING_START.length;
               tokend = value.indexOf(this.GP_CONTROL_STRING_END,tokstart);
               if(tokend < 0)
               {
                  break;
               }
               if(tokend > tokstart)
               {
                  tok = value.substring(tokstart,tokend);
                  cb = Enum.parse(GpControlButton,tok,true,logger) as GpControlButton;
                  str = cb.getLocName(locale,vis);
                  value = value.substring(0,controlstart) + str + value.substring(tokend + this.GP_CONTROL_STRING_END.length);
                  i = tokstart + str.length;
               }
            }
         }
         catch(e:Error)
         {
            logger.error("Failed to parse control string for [" + orig + "]");
         }
         return value;
      }
      
      public function init(param1:GuiGpConfig, param2:String, param3:GpControlButton, param4:GpControlButton = null) : GuiGpConfig_State
      {
         this.context = param1.context;
         this.gui = param1;
         this.token = param2;
         this.guiGpTextHelper = new GuiGpTextHelper(this.context.locale,this.context.logger);
         var _loc5_:String = !!param1.device ? param1.device.type.visualCategory : null;
         this.updateLocalization(_loc5_);
         this.control = param3;
         if(!param4)
         {
            param4 = param3;
         }
         this.display = param4;
         if(this.display)
         {
            this.gpbmp = GuiGp.ctorPrimaryBitmap(param4,true);
            this.gpbmp.scale = 1.5;
            addChild(this.gpbmp);
            this.gpbmp.y = -10;
            this.gpbmp.x = 80;
            this.gpbmp.visible = false;
         }
         return this;
      }
      
      public function updateLocalization(param1:String) : void
      {
         var _loc2_:GuiGpConfig_State = null;
         this.context.locale.fixTextFieldFormat(this._text,null,null,true);
         this.caption = getLocalization(LocaleCategory.GUI,this.context.locale,this.token,param1);
         this.caption = this.replaceGpControlStrings(this.context.locale,this.caption,param1,this.context.logger);
         for each(_loc2_ in this.children)
         {
            _loc2_.updateLocalization(param1);
         }
      }
      
      public function setKeyboardOnly(param1:Boolean) : GuiGpConfig_State
      {
         this.keyboardOnly = param1;
         return this;
      }
      
      public function setKeyboardOmit(param1:Boolean) : GuiGpConfig_State
      {
         this.keyboardOmit = param1;
         return this;
      }
      
      public function setOptional(param1:Boolean) : GuiGpConfig_State
      {
         this.optional = param1;
         return this;
      }
      
      public function setCompletionCallback(param1:Function) : GuiGpConfig_State
      {
         this.completionCallback = param1;
         return this;
      }
      
      public function setCanAxisButton(param1:GpControlButton, param2:Boolean = true, param3:Boolean = true) : GuiGpConfig_State
      {
         this.canAxisButton = true;
         this.canAxisButtonPos = param2;
         this.canAxisButtonNeg = param3;
         this.canAxisButtonOpposite = param1;
         return this;
      }
      
      public function setAxis(param1:Number) : GuiGpConfig_State
      {
         this.isAxis = true;
         this.expectedValue = param1;
         return this;
      }
      
      public function cleanup() : void
      {
         this.resetConfigStage();
         if(this.gpbmp)
         {
            if(this.gpbmp.parent)
            {
               this.gpbmp.parent.removeChild(this.gpbmp);
            }
            GuiGp.releasePrimaryBitmap(this.gpbmp);
            this.gpbmp = null;
         }
      }
      
      public function resetConfigStage() : void
      {
         var _loc1_:int = 0;
         var _loc2_:GuiGpConfig_State = null;
         if(this.gpbmp)
         {
            this.gpbmp.visible = false;
         }
         this._checkmark.visible = false;
         this._xmark.visible = false;
         this.child = null;
         this.cursor = -1;
         this.started = false;
         this.complete = false;
         this.skipped = false;
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this.children)
         {
            _loc1_ = 0;
            while(_loc1_ < this.children.length)
            {
               _loc2_ = this.children[_loc1_];
               _loc2_.resetConfigStage();
               _loc1_++;
            }
         }
      }
      
      public function get bindingButton() : GpControlButton
      {
         if(this.child)
         {
            return this.child.bindingButton;
         }
         return this.control;
      }
      
      public function get leafState() : GuiGpConfig_State
      {
         return !!this.child ? this.child.leafState : this;
      }
      
      public function ignore() : void
      {
         this.ignored = true;
         this.complete = true;
      }
      
      public function start() : void
      {
         if(!parent)
         {
            if(!this._parentStage)
            {
               this.gui.addChild(this);
            }
         }
         this.next();
      }
      
      public function next() : void
      {
         if(this.child)
         {
            this.child.next();
            if(!this.child.complete)
            {
               return;
            }
         }
         if(this.children)
         {
            while(this.cursor < this.children.length)
            {
               ++this.cursor;
               if(this.cursor >= this.children.length)
               {
                  this.child = null;
                  break;
               }
               this.child = this.children[this.cursor];
               this.child.start();
               if(!this.child.complete)
               {
                  break;
               }
            }
         }
         if(!this.child)
         {
            if(this.children)
            {
               this.complete = true;
            }
            else if(!this.started)
            {
               this.started = true;
            }
            else
            {
               this.complete = true;
            }
         }
      }
      
      public function addChildStage(param1:GuiGpConfig_State) : GuiGpConfig_State
      {
         if(!this.children)
         {
            this.children = new Vector.<GuiGpConfig_State>();
         }
         this.children.push(param1);
         param1._parentStage = this;
         return this;
      }
      
      public function updateGui(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc5_:* = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:GuiGpConfig_State = null;
         this._text.selectable = false;
         this._text.mouseEnabled = false;
         if(this.ignored)
         {
            visible = false;
            return;
         }
         if(this._complete && Boolean(this.display))
         {
            if(param1)
            {
               _loc5_ = "ctl_" + this.display.name.toLowerCase() + "_" + param1 + "_name";
               _loc2_ = String(this.context.translateCategoryRaw(_loc5_,LocaleCategory.GP));
               if(!_loc2_)
               {
                  _loc5_ = "ctl_" + this.display.name.toLowerCase() + "_" + param1.charAt(0) + "_name";
                  _loc2_ = String(this.context.translateCategoryRaw(_loc5_,LocaleCategory.GP));
               }
            }
            if(!_loc2_)
            {
               _loc5_ = "ctl_" + this.display.name.toLowerCase() + "_name";
               _loc2_ = String(this.context.translateCategory(_loc5_,LocaleCategory.GP));
            }
         }
         else
         {
            _loc2_ = this.caption;
         }
         if(!this._complete)
         {
            if(this.optional)
            {
               _loc6_ = String(this.context.translateCategory("cfg_optional",LocaleCategory.GP));
               _loc2_ += "\n" + _loc6_;
            }
         }
         if(_loc2_)
         {
            _loc2_ = this.guiGpTextHelper.preProcessText(_loc2_,this.context.logger);
         }
         this._text.condenseWhite = false;
         this._text.width = 1300;
         this._text.htmlText = _loc2_;
         this.context.locale.fixTextFieldFormat(this._text,null,null,true);
         this._text.height = this._text.textHeight + 4;
         this._text.cacheAsBitmap = true;
         this.guiGpTextHelper.finishProcessing(this._text);
         if(this.gpbmp)
         {
            this.gpbmp.gplayer = GpBinder.gpbinder.lastCmdId;
            this.gpbmp.visible = true;
         }
         this._checkmark.visible = this._complete && !this.skipped;
         this._xmark.visible = this._complete && this.skipped;
         var _loc3_:int = 2;
         var _loc4_:int = this._text.height + this._text.y + _loc3_;
         if(this.children)
         {
            _loc7_ = 0;
            while(_loc7_ < this.children.length)
            {
               _loc8_ = this.children[_loc7_];
               if(_loc7_ > this.cursor || this._complete)
               {
                  if(_loc8_.parent)
                  {
                     _loc8_.parent.removeChild(_loc8_);
                  }
               }
               else
               {
                  if(!_loc8_.parent)
                  {
                     addChild(_loc8_);
                  }
                  _loc8_.x = 100;
                  _loc8_.y = _loc4_;
                  _loc8_.updateGui(param1);
                  _loc4_ += _loc8_.height + _loc3_;
               }
               _loc7_++;
            }
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function set complete(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GuiGpConfig_State = null;
         if(this._complete == param1)
         {
            return;
         }
         this._complete = param1;
         if(this._complete)
         {
            if(this.skipped)
            {
               this._xmark.visible = true;
            }
            else
            {
               this._checkmark.visible = true;
               this._checkmark.gotoAndPlay(1);
            }
            if(this.children)
            {
               _loc2_ = 0;
               while(_loc2_ < this.children.length)
               {
                  _loc3_ = this.children[_loc2_];
                  if(_loc3_.parent)
                  {
                     _loc3_.parent.removeChild(_loc3_);
                  }
                  this.skipped = this.skipped || _loc3_.skipped && !_loc3_.optional;
                  _loc2_++;
               }
            }
            if(this.completionCallback != null)
            {
               this.completionCallback();
            }
         }
      }
   }
}
