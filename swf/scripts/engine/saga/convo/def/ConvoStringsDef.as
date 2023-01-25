package engine.saga.convo.def
{
   import engine.core.locale.LocaleId;
   import engine.core.locale.StringIdInfo;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class ConvoStringsDef
   {
      
      public static const schema:Object = {
         "name":"ConvoStringsDef",
         "type":"object",
         "properties":{
            "stitches":{
               "type":"object",
               "skip":true
            },
            "options":{
               "type":"object",
               "skip":true
            },
            "convoUrl":{"type":"string"},
            "urlKey":{"type":"string"}
         }
      };
      
      private static const SKIP_TOKEN:String = "{skip}";
       
      
      public var stitches:Dictionary;
      
      public var options:Dictionary;
      
      public var convoUrl:String;
      
      public var urlKey:String;
      
      public var url:String;
      
      public function ConvoStringsDef(param1:String)
      {
         this.stitches = new Dictionary();
         this.options = new Dictionary();
         super();
         this.url = param1;
      }
      
      public function fromStringIdInfos(param1:String, param2:String, param3:Vector.<StringIdInfo>, param4:String, param5:ILogger) : ConvoStringsDef
      {
         var _loc6_:StringIdInfo = null;
         this.url = param1;
         this.convoUrl = param2;
         this.urlKey = param4;
         for each(_loc6_ in param3)
         {
            if(!this.fromStringIdInfoOption(_loc6_))
            {
               if(Boolean(_loc6_.original) && _loc6_.original.indexOf(SKIP_TOKEN) < 0)
               {
                  if(!this.hasStitch(_loc6_.id))
                  {
                     this.addStitch(_loc6_.id,_loc6_.original);
                  }
               }
            }
         }
         this.purgeNonGendered(param5);
         return this;
      }
      
      private function fromStringIdInfoOption(param1:StringIdInfo) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc2_:int = param1.id.indexOf("[");
         if(_loc2_ > 0)
         {
            if(StringUtil.startsWith(param1.id,"svenYouFeelUpToT"))
            {
               param1 = param1;
            }
            _loc4_ = param1.id.indexOf("]",_loc2_);
            if(_loc4_ <= _loc2_ + 1)
            {
               throw new ArgumentError("Invalid Stringid for option [" + param1.id + "]");
            }
            _loc5_ = int(param1.id.substring(_loc2_ + 1,_loc4_));
            _loc3_ = param1.id.substring(0,_loc2_);
            if(param1.id.length > _loc4_ + 1)
            {
               _loc3_ += param1.id.substring(_loc4_ + 1);
            }
            _loc6_ = this.getOptions(_loc3_,true);
            while(_loc6_.length <= _loc5_)
            {
               _loc6_.push("");
            }
            _loc6_[_loc5_] = param1.original;
            return true;
         }
         return false;
      }
      
      public function getOptions(param1:String, param2:Boolean) : Array
      {
         var _loc3_:String = param1;
         if(!_loc3_)
         {
            _loc3_ = param1;
         }
         var _loc4_:Array = this.options[_loc3_];
         if(!_loc4_ && param2)
         {
            _loc4_ = new Array();
            this.options[param1] = _loc4_;
         }
         return _loc4_;
      }
      
      public function getStringIdInfos(param1:Vector.<StringIdInfo>, param2:Dictionary, param3:Boolean, param4:LocaleId) : void
      {
         var _loc5_:StringIdInfo = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc11_:StringIdInfo = null;
         var _loc12_:String = null;
         var _loc13_:Array = null;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc8_:Boolean = true;
         if(param3)
         {
            _loc8_ = false;
         }
         var _loc9_:String = param4.reverseTranslateLocaleUrl(this.url);
         var _loc10_:Array = [];
         for(_loc6_ in this.stitches)
         {
            _loc7_ = String(this.stitches[_loc6_]);
            if(!(!_loc7_ || _loc7_.indexOf("{skip}") >= 0))
            {
               if(param3)
               {
                  _loc12_ = _loc6_;
                  _loc12_ = _loc12_.replace("^m","");
                  _loc12_ = _loc12_.replace("^f","");
                  if(!StringIdInfo.stringNeedsAttention(_loc7_))
                  {
                     param2[_loc9_ + ":" + _loc12_] = true;
                     continue;
                  }
                  delete param2[_loc9_ + ":" + _loc12_];
                  _loc8_ = true;
               }
               _loc5_ = new StringIdInfo().fromEngineString(_loc6_,this.url,_loc7_);
               _loc10_.push(_loc5_);
            }
         }
         for(_loc6_ in this.options)
         {
            _loc13_ = this.options[_loc6_];
            _loc14_ = "";
            if(_loc6_.charAt(_loc6_.length - 2) == "^")
            {
               _loc14_ = _loc6_.substring(_loc6_.length - 2);
               _loc6_ = _loc6_.substring(0,_loc6_.length - 2);
            }
            _loc15_ = 0;
            for(; _loc15_ < _loc13_.length; _loc15_++)
            {
               _loc16_ = _loc6_ + "[" + _loc15_ + "]" + _loc14_;
               _loc7_ = String(_loc13_[_loc15_]);
               if(!(!_loc7_ || _loc7_.indexOf("{skip}") >= 0))
               {
                  if(param3)
                  {
                     if(!StringIdInfo.stringNeedsAttention(_loc7_))
                     {
                        param2[_loc9_ + ":" + _loc16_] = true;
                        continue;
                     }
                     _loc8_ = true;
                  }
                  _loc5_ = new StringIdInfo().fromEngineString(_loc16_,this.url,_loc7_);
                  _loc10_.push(_loc5_);
               }
            }
         }
         if(!_loc8_)
         {
            return;
         }
         _loc10_.sortOn("id");
         for each(_loc11_ in _loc10_)
         {
            param1.push(_loc11_);
         }
      }
      
      public function addStitch(param1:String, param2:String) : void
      {
         this.stitches[param1] = param2;
      }
      
      public function getStitchString(param1:String) : String
      {
         var _loc2_:String = param1;
         return !!_loc2_ ? String(this.stitches[_loc2_]) : null;
      }
      
      public function hasStitch(param1:String) : Boolean
      {
         return param1 in this.stitches;
      }
      
      public function getStitchOptionString(param1:String, param2:int) : String
      {
         var _loc3_:Array = this.getOptions(param1,false);
         if(_loc3_)
         {
            if(param2 >= 0 && param2 < _loc3_.length)
            {
               return _loc3_[param2];
            }
         }
         return null;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : ConvoStringsDef
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.convoUrl = param1.convoUrl;
         this.urlKey = param1.urlKey;
         for(_loc4_ in param1.stitches)
         {
            _loc5_ = String(param1.stitches[_loc4_]);
            if(param3)
            {
               _loc5_ = ConvoNodeDef.stripText(_loc4_,_loc5_,false);
            }
            this.addStitch(_loc4_,_loc5_);
         }
         for(_loc4_ in param1.options)
         {
            _loc6_ = param1.options[_loc4_];
            if(_loc6_)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  _loc5_ = String(_loc6_[_loc7_]);
                  if(param3)
                  {
                     _loc5_ = ConvoNodeDef.parseInkleCodes(_loc5_);
                  }
                  _loc6_[_loc7_] = _loc5_;
                  _loc7_++;
               }
            }
            this.options[_loc4_] = _loc6_;
         }
         this.purgeNonGendered(param2);
         return this;
      }
      
      public function performChecks() : void
      {
         this._performCheckStitches();
         this._performCheckOptions();
      }
      
      private function _performCheckOptions() : void
      {
         var _loc1_:String = null;
         for each(_loc1_ in this.options)
         {
            if(_loc1_.indexOf("[") >= 0 && _loc1_.indexOf("]") > 0)
            {
               throw new ArgumentError("Option looks like it attempted to have an actor block in it: " + _loc1_);
            }
         }
      }
      
      private function _performCheckStitches() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc1_ in this.stitches)
         {
            _loc2_ = _loc1_.indexOf("[");
            _loc3_ = _loc1_.indexOf("]");
            if(_loc3_ >= 0 && (_loc3_ < _loc2_ || _loc2_ < 0))
            {
               throw new ArgumentError("Found a close before an open: \'" + _loc1_ + "\'");
            }
            if(_loc2_ >= 0 && _loc3_ < 0)
            {
               throw new ArgumentError("Found an open without a close: \'" + _loc1_ + "\'");
            }
         }
      }
      
      private function purgeNonGendered(param1:ILogger) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         for(_loc2_ in this.stitches)
         {
            if(_loc2_.lastIndexOf("^") == _loc2_.length - 2)
            {
               _loc3_ = _loc2_.substr(0,_loc2_.length - 2);
               if(this.stitches[_loc3_])
               {
                  param1.error("ConvoStringsDef.purgeNonGendered [" + this.url + "] STITCH [" + _loc3_ + "]");
                  delete this.stitches[_loc3_];
               }
            }
         }
         for(_loc2_ in this.options)
         {
            if(_loc2_.lastIndexOf("^") != _loc2_.length - 2)
            {
               _loc4_ = this.options[_loc2_];
               _loc5_ = this.options[_loc2_ + "^m"];
               _loc6_ = this.options[_loc2_ + "^f"];
               if(_loc5_)
               {
                  this.balanceArrays(_loc4_,_loc5_);
               }
               if(_loc6_)
               {
                  this.balanceArrays(_loc4_,_loc6_);
               }
            }
         }
      }
      
      private function balanceArrays(param1:Array, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(!param1 || !param2)
         {
            return;
         }
         var _loc4_:int = Math.max(param1.length,param2.length);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            if(_loc3_ >= param1.length)
            {
               param1.push("");
            }
            if(_loc3_ >= param2.length)
            {
               param2.push("");
            }
            _loc3_++;
         }
      }
      
      public function save() : Object
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc1_:Object = {
            "stitches":{},
            "options":{},
            "convoUrl":(!!this.convoUrl ? this.convoUrl : ""),
            "urlKey":(!!this.urlKey ? this.urlKey : "")
         };
         for(_loc2_ in this.stitches)
         {
            _loc3_ = String(this.stitches[_loc2_]);
            _loc1_.stitches[_loc2_] = _loc3_;
         }
         for(_loc2_ in this.options)
         {
            _loc4_ = this.options[_loc2_];
            _loc1_.options[_loc2_] = _loc4_;
         }
         return _loc1_;
      }
      
      public function fromConvoDef(param1:ConvoDef, param2:ILogger) : ConvoStringsDef
      {
         var _loc3_:ConvoNodeDef = null;
         var _loc4_:Array = null;
         var _loc5_:Boolean = false;
         var _loc6_:ConvoOptionDef = null;
         this.convoUrl = StringUtil.stripSuffix(param1.url,".z");
         this.urlKey = param1.inkleUrlKey;
         for each(_loc3_ in param1.nodesById)
         {
            if(Boolean(_loc3_.rawText) && _loc3_.rawText.indexOf(SKIP_TOKEN) < 0)
            {
               this.stitches[_loc3_.id] = _loc3_.rawText;
               if(_loc3_.speaker)
               {
                  this.stitches[_loc3_.id] = "[" + _loc3_.speaker + "] " + this.stitches[_loc3_.id];
               }
            }
            if(Boolean(_loc3_.options) && _loc3_.options.length > 0)
            {
               _loc4_ = [];
               this.options[_loc3_.id] = _loc4_;
               _loc5_ = false;
               for each(_loc6_ in _loc3_.options)
               {
                  if(Boolean(_loc6_._text) && _loc6_._text.indexOf(SKIP_TOKEN) < 0)
                  {
                     _loc5_ = true;
                  }
                  _loc4_.push(_loc6_._text);
               }
               if(!_loc5_)
               {
                  delete this.options[_loc3_.id];
               }
            }
         }
         return this;
      }
   }
}
