package engine.core.locale
{
   import engine.core.BoxString;
   import engine.core.logging.ILogger;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.errors.IllegalOperationError;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class Localizer
   {
      
      public static var KEEP_TOKEN_LIST:Boolean;
      
      public static var REPORT_ERRORS:Boolean;
       
      
      public var id:LocaleCategory;
      
      public var tokens:Dictionary;
      
      public var tokenList:Vector.<String>;
      
      public var logger:ILogger;
      
      public var locale:Locale;
      
      public var overlay:Localizer;
      
      private var _reported:Dictionary;
      
      private var boxToken:BoxString;
      
      public function Localizer(param1:LocaleCategory, param2:ILogger)
      {
         this.tokens = new Dictionary();
         this.boxToken = new BoxString();
         super();
         this.id = param1;
         this.logger = param2;
      }
      
      public static function save(param1:Localizer) : Object
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:Object = {};
         if(!param1.tokenList)
         {
            throw new IllegalOperationError("If you want to save Localizers, then enable KEEP_TOKEN_LIST");
         }
         for each(_loc3_ in param1.tokenList)
         {
            _loc4_ = param1.translate(_loc3_,true);
            _loc2_[_loc3_] = _loc4_;
         }
         return _loc2_;
      }
      
      public function cleanup() : void
      {
         this.id = null;
         this.tokens = null;
         this.tokenList = null;
         this.logger = null;
         this.locale = null;
      }
      
      public function hasToken(param1:String) : Boolean
      {
         return param1 in this.tokens;
      }
      
      public function findTranslationId(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         for(_loc2_ in this.tokens)
         {
            _loc3_ = String(this.tokens[_loc2_]);
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function addTranslation(param1:String, param2:String) : void
      {
         if(KEEP_TOKEN_LIST)
         {
            if(!(param1 in this.tokens))
            {
               if(!this.tokenList)
               {
                  this.tokenList = new Vector.<String>();
               }
               this.tokenList.push(param1);
            }
         }
         this.tokens[param1] = param2;
      }
      
      public function removeToken(param1:String) : void
      {
         var _loc2_:int = 0;
         if(this.tokenList)
         {
            _loc2_ = this.tokenList.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.tokenList.splice(_loc2_,1);
            }
         }
         delete this.tokens[param1];
      }
      
      public function setValue(param1:String, param2:String) : void
      {
         if(Boolean(param2) && param2.charAt(0) == "{")
         {
            return;
         }
         this.addTranslation(param1,param2);
         if(this.locale)
         {
            this.locale.modified = true;
         }
      }
      
      public function translate(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:String = null;
         if(this.overlay)
         {
            _loc3_ = this.overlay.translate(param1,true);
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         if(param1 in this.tokens)
         {
            return this.tokens[param1];
         }
         if(param2)
         {
            return null;
         }
         if(Boolean(this.logger) && REPORT_ERRORS)
         {
            if(!this._reported)
            {
               this._reported = new Dictionary();
            }
            if(!this._reported[param1])
            {
               this.logger.error("Localizer.translate " + this + ":[" + param1 + "] failed.");
               this._reported[param1] = true;
            }
         }
         if(this.id != LocaleCategory.GUI)
         {
            return "{" + this.id.name + ":" + param1 + "}";
         }
         return "{" + param1 + "}";
      }
      
      public function toString() : String
      {
         return this.id.toString();
      }
      
      private function getToken(param1:String) : String
      {
         var _loc2_:int = !!param1 ? param1.indexOf("$") : -1;
         return _loc2_ >= 0 ? param1.substring(_loc2_ + 1) : null;
      }
      
      public function translateDisplayObjects(param1:DisplayObject, param2:ILogger) : void
      {
         var _loc6_:DisplayObject = null;
         if(!param1)
         {
            return;
         }
         if(param1.hasOwnProperty("blockLocalization") && Boolean(param1["blockLocalization"]))
         {
            return;
         }
         var _loc3_:String = this.getTranslationDisplayObject(param1,this.boxToken);
         this.locale.updateDisplayObjectTranslation(param1,_loc3_,this.boxToken,0);
         var _loc4_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.numChildren)
         {
            _loc6_ = _loc4_.getChildAt(_loc5_);
            this.translateDisplayObjects(_loc6_,param2);
            _loc5_++;
         }
      }
      
      public function getTranslationDisplayObject(param1:DisplayObject, param2:BoxString) : String
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(!param1)
         {
            return null;
         }
         var _loc3_:String = this.getToken(param1.name);
         var _loc4_:TextField = param1 as TextField;
         if(_loc4_)
         {
            _loc5_ = this.getToken(_loc4_.text);
            _loc6_ = null;
            if(_loc5_)
            {
               if(param2)
               {
                  param2.value = _loc5_;
               }
               return this.translate(_loc5_);
            }
         }
         if(_loc3_)
         {
            if(param2)
            {
               param2.value = _loc3_;
            }
            return this.translate(_loc3_);
         }
         return null;
      }
      
      public function getStringIdInfos(param1:Vector.<StringIdInfo>, param2:Dictionary, param3:String, param4:Boolean) : void
      {
         var _loc5_:StringIdInfo = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         if(!this.tokenList)
         {
            return;
         }
         for each(_loc8_ in this.tokenList)
         {
            _loc7_ = String(this.tokens[_loc8_]);
            _loc6_ = this.id.name + ":" + _loc8_;
            if(param4 && !StringIdInfo.stringNeedsAttention(_loc7_))
            {
               _loc9_ = this.locale.id.reverseTranslateLocaleUrl(param3);
               _loc9_ += ":" + _loc6_;
               param2[_loc9_] = true;
            }
            else
            {
               _loc5_ = new StringIdInfo().fromEngineString(_loc6_,param3,_loc7_);
               param1.push(_loc5_);
            }
         }
      }
      
      public function get info() : LocaleInfo
      {
         return !!this.locale ? this.locale.info : null;
      }
      
      public function init(param1:Object, param2:Boolean) : Localizer
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         for(_loc3_ in param1)
         {
            _loc4_ = String(param1[_loc3_]);
            this.addTranslation(_loc3_,_loc4_);
         }
         if(this.tokenList)
         {
            this.tokenList.sort(0);
         }
         return this;
      }
   }
}
