package engine.core.locale
{
   import engine.core.BoxString;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.gui.IGuiButton;
   import engine.gui.IGuiGpTextHelper;
   import engine.gui.IGuiGpTextHelperFactory;
   import engine.gui.IGuiToolTip;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   
   public class Locale
   {
      
      public static var en_id:String = "en";
      
      private static var __textFieldGuiGpTextHelpers:Dictionary = new Dictionary();
      
      public static var APP_TITLE_TOKEN:String;
      
      private static const deIceChars:Object = {
         "ý":"y",
         "Á":"A",
         "Þ":"Th",
         "ó":"o",
         "ú":"u",
         "ð":"d",
         "í":"i"
      };
       
      
      public var id:LocaleId;
      
      private var localizers:Dictionary;
      
      public var localizerList:Vector.<Localizer>;
      
      private var _modified:Boolean;
      
      private var _logger:ILogger;
      
      public var url:String;
      
      public var ggthFactory:IGuiGpTextHelperFactory;
      
      public var isEn:Boolean;
      
      public var info:LocaleInfo;
      
      public function Locale(param1:LocaleId, param2:IGuiGpTextHelperFactory, param3:ILogger)
      {
         this.localizers = new Dictionary();
         this.localizerList = new Vector.<Localizer>();
         super();
         this.info = !!param1 ? LocaleInfo.fetch(param1.id) : null;
         this.ggthFactory = param2;
         this._logger = param3;
         if(param1)
         {
            this.id = param1;
         }
         else
         {
            this.id = new LocaleId("en");
         }
         if(this.id.id == en_id)
         {
            this.isEn = true;
         }
      }
      
      private static function setTextFieldGuiGpTextHelper(param1:TextField, param2:IGuiGpTextHelper) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:IGuiGpTextHelper = __textFieldGuiGpTextHelpers[param1];
         if(_loc3_)
         {
            _loc3_.cleanup();
         }
         if(param2)
         {
            param1.addEventListener(Event.REMOVED_FROM_STAGE,textFieldRemovedFromStageHandler);
            __textFieldGuiGpTextHelpers[param1] = param2;
         }
         else
         {
            param1.removeEventListener(Event.REMOVED_FROM_STAGE,textFieldRemovedFromStageHandler);
            delete __textFieldGuiGpTextHelpers[param1];
         }
      }
      
      public static function updateTextFieldGuiGpTextHelper(param1:TextField) : void
      {
         var _loc2_:IGuiGpTextHelper = __textFieldGuiGpTextHelpers[param1];
         if(_loc2_)
         {
            _loc2_.iconsVisible = param1.visible;
            if(param1.visible)
            {
               _loc2_.finishProcessing(param1);
            }
         }
      }
      
      private static function textFieldRemovedFromStageHandler(param1:Event) : void
      {
         var _loc2_:TextField = param1.target as TextField;
         setTextFieldGuiGpTextHelper(_loc2_,null);
      }
      
      public static function isFontVinque(param1:String) : Boolean
      {
         return param1 == "Vinque-Regular";
      }
      
      public static function isFontMinion(param1:String) : Boolean
      {
         return param1 == "Minion Pro" || param1 == "Minion Pro Bold" || param1 == "Minion Pro Bold Cond" || param1 == "Minion Pro Italic";
      }
      
      public static function resetTextFieldFormat(param1:TextField, param2:int) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:TextFormat = null;
         var _loc3_:TextFormat = param1.getTextFormat();
         var _loc4_:TextFormat = param1.defaultTextFormat;
         if(Boolean(_loc3_) && Boolean(_loc4_))
         {
            _loc5_ = _loc3_.font;
            _loc6_ = _loc4_.font;
            if(_loc5_)
            {
               if(_loc6_.indexOf("Minion Pro") == 0 && _loc5_.indexOf("Minion Pro") == 0)
               {
                  return;
               }
            }
            _loc7_ = new TextFormat(param1.defaultTextFormat.font,param1.defaultTextFormat.size + param2,null);
            param1.setTextFormat(_loc7_);
         }
      }
      
      public function toString() : String
      {
         return !!this.id ? this.id.toString() : "ERROR";
      }
      
      public function cleanup() : void
      {
         var _loc1_:Localizer = null;
         for each(_loc1_ in this.localizerList)
         {
            _loc1_.cleanup();
         }
         this.localizers = null;
         this.localizerList = null;
         this._logger = null;
         this.id = null;
      }
      
      public function consumeOverlay(param1:Locale) : void
      {
         var _loc2_:Localizer = null;
         var _loc3_:* = null;
         var _loc4_:String = null;
         for each(_loc2_ in param1.localizerList)
         {
            for(_loc3_ in _loc2_.tokens)
            {
               _loc4_ = _loc2_.tokens[_loc3_];
               this.addTranslation(_loc2_.id,_loc3_,_loc4_);
            }
         }
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function addCategory(param1:LocaleCategory) : Localizer
      {
         return this.getLocalizer(param1,true);
      }
      
      public function removeLocalizer(param1:Localizer) : void
      {
         delete this.localizers[param1.id];
         var _loc2_:int = this.localizerList.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.localizerList.splice(_loc2_,1);
         }
         param1.locale = null;
      }
      
      protected function addLocalizer(param1:Localizer) : void
      {
         var old:Localizer;
         var localizer:Localizer = param1;
         if(!this.logger)
         {
         }
         old = this.getLocalizer(localizer.id);
         if(old)
         {
            if(this.logger)
            {
               this.logger.error("Locale.addLocalizer already has localize " + localizer.id);
            }
            throw new ArgumentError("Locale.addLocalizer already have a localizer of id " + localizer.id);
         }
         this.localizers[localizer.id] = localizer;
         this.localizerList.push(localizer);
         localizer.locale = this;
         this.localizerList.sort(function(param1:Localizer, param2:Localizer):int
         {
            if(param1.id.name < param2.id.name)
            {
               return -1;
            }
            if(param1.id.name > param2.id.name)
            {
               return 1;
            }
            return 0;
         });
         if(!this.logger)
         {
         }
      }
      
      public function getLocalizer(param1:LocaleCategory, param2:Boolean = false) : Localizer
      {
         var _loc3_:Localizer = this.localizers[param1];
         if(!_loc3_)
         {
            if(param2)
            {
               _loc3_ = new Localizer(param1,this.logger);
               this.addLocalizer(_loc3_);
            }
         }
         return _loc3_;
      }
      
      public function addTranslation(param1:LocaleCategory, param2:String, param3:String) : void
      {
         var _loc4_:Localizer = this.getLocalizer(param1,true);
         _loc4_.addTranslation(param2,param3);
      }
      
      public function translateGui(param1:String, param2:Boolean = false) : String
      {
         return this.translate(LocaleCategory.GUI,param1,param2);
      }
      
      public function translate(param1:LocaleCategory, param2:String, param3:Boolean = false) : String
      {
         var _loc4_:Localizer = this.getLocalizer(param1);
         if(!_loc4_)
         {
            if(param3)
            {
               return null;
            }
            if(param1 != LocaleCategory.GUI)
            {
               return "{" + param1.name + ":" + param2 + "}";
            }
            return "{" + param2 + "}";
         }
         return _loc4_.translate(param2,param3);
      }
      
      public function getTokens(param1:LocaleCategory) : Vector.<String>
      {
         var _loc2_:Localizer = this.getLocalizer(param1);
         return _loc2_.tokenList;
      }
      
      public function translateDisplayObjects(param1:LocaleCategory, param2:DisplayObject, param3:ILogger) : void
      {
         var _loc4_:Localizer = this.getLocalizer(param1,true);
         _loc4_.translateDisplayObjects(param2,param3);
      }
      
      public function updateDisplayObjectTranslation(param1:DisplayObject, param2:String, param3:BoxString, param4:int) : void
      {
         var _loc9_:IGuiGpTextHelper = null;
         if(param2 == null)
         {
            return;
         }
         var _loc5_:TextField = param1 as TextField;
         if(_loc5_)
         {
            if(Boolean(_loc5_.parent) && this.ggthFactory.hasGpTokens(param2))
            {
               _loc9_ = this.ggthFactory.factory(this,this.logger);
               param2 = _loc9_.preProcessText(param2,this.logger);
            }
            _loc5_.htmlText = param2;
            if(_loc9_)
            {
               _loc9_.locale = this;
               _loc9_.finishProcessing(_loc5_);
            }
            setTextFieldGuiGpTextHelper(_loc5_,_loc9_);
            this.fixTextFieldFormat(_loc5_,null,null,true,param4);
            return;
         }
         var _loc6_:SimpleButton = param1 as SimpleButton;
         if(_loc6_)
         {
            LocaleUtil.setText(_loc6_,param2);
            return;
         }
         var _loc7_:IGuiButton = param1 as IGuiButton;
         if(_loc7_)
         {
            if(param3)
            {
               _loc7_.buttonToken = param3.value;
            }
            _loc7_.buttonText = param2;
         }
         var _loc8_:IGuiToolTip = param1 as IGuiToolTip;
         if(_loc8_)
         {
            _loc8_.setText(param2);
         }
      }
      
      public function getTranslationDisplayObject(param1:LocaleCategory, param2:DisplayObject, param3:BoxString) : String
      {
         var _loc4_:Localizer = this.getLocalizer(param1,true);
         return _loc4_.getTranslationDisplayObject(param2,param3);
      }
      
      public function get modified() : Boolean
      {
         return this._modified;
      }
      
      public function set modified(param1:Boolean) : void
      {
         this._modified = param1;
      }
      
      public function replaceTranslatedTokens(param1:String, param2:Array) : String
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc3_:String = param1;
         var _loc4_:int = _loc3_.indexOf("%");
         var _loc5_:int = 0;
         while(_loc4_ >= 0 && _loc5_ < param2.length)
         {
            if(_loc3_.length <= _loc4_)
            {
               break;
            }
            _loc6_ = _loc3_.charAt(_loc4_ + 1);
            _loc7_ = null;
            switch(_loc6_)
            {
               case "%":
                  _loc7_ = "%";
                  continue;
               case "s":
                  _loc7_ = param2[_loc5_];
                  _loc5_++;
                  continue;
               default:
                  continue;
            }
            if(_loc7_ != null)
            {
               _loc3_ = _loc3_.substr(0,_loc4_) + _loc7_ + _loc3_.substr(_loc4_ + 2);
            }
            _loc4_ = _loc3_.indexOf("%",_loc4_ + _loc7_.length);
         }
         return _loc3_;
      }
      
      public function translateEncodedToken(param1:String, param2:Boolean) : String
      {
         var _loc5_:String = null;
         var _loc3_:LocaleCategory = LocaleCategory.GUI;
         var _loc4_:int = param1.indexOf(":");
         if(_loc4_ > 0)
         {
            _loc5_ = param1.substr(0,_loc4_);
            param1 = param1.substr(_loc4_ + 1);
            _loc3_ = Enum.parse(LocaleCategory,_loc5_) as LocaleCategory;
         }
         return this.translate(_loc3_,param1,param2);
      }
      
      public function getStringIdInfos(param1:Vector.<StringIdInfo>, param2:Dictionary, param3:Boolean, param4:Dictionary) : void
      {
         var _loc5_:StringIdInfo = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Localizer = null;
         for each(_loc8_ in this.localizerList)
         {
            if(!(Boolean(param4) && Boolean(param4[_loc8_.id])))
            {
               _loc8_.getStringIdInfos(param1,param2,this.url,param3);
            }
         }
      }
      
      public function fromStringIdInfos(param1:Vector.<StringIdInfo>) : Locale
      {
         var _loc3_:StringIdInfo = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:LocaleCategory = null;
         var _loc8_:Localizer = null;
         var _loc9_:String = null;
         var _loc2_:int = 0;
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc3_.id.indexOf(":");
            if(_loc4_ < 0)
            {
               _loc9_ = "Invalid StringIdInfo, no colon: " + _loc3_;
               this.logger.error(_loc9_);
               _loc2_++;
            }
            else
            {
               _loc5_ = _loc3_.id.substring(0,_loc4_);
               _loc6_ = _loc3_.id.substr(_loc4_ + 1);
               _loc7_ = Enum.parse(LocaleCategory,_loc5_) as LocaleCategory;
               if(_loc7_ != LocaleCategory.STAT)
               {
                  _loc6_ = _loc6_.toLowerCase();
               }
               _loc8_ = this.getLocalizer(_loc7_,true);
               _loc8_.addTranslation(_loc6_,_loc3_.original);
            }
         }
         if(_loc2_)
         {
            throw new ArgumentError("Encountered " + _loc2_ + " errors, failed.  See log for details");
         }
         return this;
      }
      
      public function fixTextFieldFormat(param1:TextField, param2:String = null, param3:* = null, param4:Boolean = true, param5:int = 0) : Boolean
      {
         return this.info._fixTextFieldFormat(param1,param2,param3,param4,param5);
      }
      
      public function setOverlay(param1:LocaleCategory, param2:LocaleCategory) : void
      {
         var _loc4_:Localizer = null;
         var _loc3_:Localizer = this.getLocalizer(param1);
         if(_loc3_)
         {
            _loc4_ = this.getLocalizer(param2);
            _loc3_.overlay = _loc4_;
         }
      }
      
      public function translateAppTitle(param1:String) : String
      {
         if(!param1)
         {
            return param1;
         }
         var _loc2_:String = this.translateGui(APP_TITLE_TOKEN);
         return param1.replace("{APP_TITLE}",_loc2_);
      }
      
      public function translateAppTitleToken(param1:String, param2:LocaleCategory = null) : String
      {
         if(!param1)
         {
            return null;
         }
         if(!param2)
         {
            param2 = LocaleCategory.GUI;
         }
         var _loc3_:String = this.translate(param2,param1);
         return this.translateAppTitle(_loc3_);
      }
      
      public function deIce(param1:String) : String
      {
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc4_:RegExp = null;
         for(_loc2_ in deIceChars)
         {
            _loc3_ = deIceChars[_loc2_];
            _loc4_ = new RegExp(_loc2_,"g");
            param1 = param1.replace(_loc4_,_loc3_);
         }
         return param1;
      }
   }
}
