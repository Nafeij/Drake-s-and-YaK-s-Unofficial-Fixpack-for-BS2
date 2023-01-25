package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.math.Rng;
   import engine.saga.ISagaExpression;
   import engine.saga.convo.Convo;
   import engine.saga.happening.IHappeningProvider;
   import engine.saga.vars.IVariableProvider;
   import flash.errors.IllegalOperationError;
   import flash.utils.ByteArray;
   
   public class ConvoNodeDef implements IConvoLinkable, IConvoConditional, IConvoFlaggable
   {
      
      public static var war_risk_str:String;
      
      public static var ENABLE_ACTOR_CHECK:Boolean = true;
      
      private static var ITALIC_INKLE_EMPTY:String = "/==/";
      
      private static var ITALIC_INKLE_EMPTY_SPACE:String = "/= =/";
      
      private static var ITALIC_INKLE_START:String = "/=";
      
      private static var ITALIC_INKLE_END:String = "=/";
      
      private static var ITALIC_HTAG_START:String = "<i>";
      
      private static var ITALIC_HTAG_END:String = "</i>";
      
      private static var ITALIC_HTML_START:String = "<font face=\'Minion Pro Italic\'>";
      
      private static var ITALIC_HTML_END:String = "</font>";
      
      private static var GP_INKLE_START:String = "//-";
      
      private static var GP_INLKE_END:String = "-//";
      
      private static var GP_GAME_START:String = "<<";
      
      private static var GP_GAME_END:String = ">>";
      
      public static var _bit:int = 1;
      
      public static const BIT_SPEAKER:int = _bit;
      
      public static const BIT_CAMERA:int = _bit = _bit << 1;
      
      public static const BIT_LINK:int = _bit = _bit << 1;
      
      public static const BIT_PAGELABEL:int = _bit = _bit << 1;
      
      public static const BIT_CAMERAUNITFACING:int = _bit = _bit << 1;
      
      public static const BIT_CONDITIONS:int = _bit = _bit << 1;
      
      public static const BIT_RUNON:int = _bit = _bit << 1;
      
      public static const BIT_SKIP:int = _bit = _bit << 1;
      
      public static const BIT_ADVANCEIFSKIPPED:int = _bit = _bit << 1;
      
      public static const BIT_PAGEBREAK:int = _bit = _bit << 1;
      
      public static const BIT_NOTRANSLATE:int = _bit = _bit << 1;
      
      public static const BIT_JOINNEXT:int = _bit = _bit << 1;
       
      
      public var id:String;
      
      public var _text:String;
      
      public var speaker:String;
      
      public var camera:String;
      
      public var link:ConvoLinkDef;
      
      public var options:Vector.<ConvoOptionDef>;
      
      public var flags:Vector.<ConvoFlagDef>;
      
      public var metaflags:Vector.<ConvoFlagDef>;
      
      public var pageNum:int;
      
      public var pageLabel:String;
      
      public var runOn:Boolean;
      
      public var skip:Boolean;
      
      public var cameraStageIndex:int = 0;
      
      public var cameraUnitFacing:String;
      
      public var convo:ConvoDef;
      
      public var cameraMarkFacing:int = 0;
      
      public var advanceIfSkipped:Boolean;
      
      public var pageBreak:Boolean;
      
      public var notranslate:Boolean;
      
      public var joinNext:Boolean;
      
      public var rawText:String;
      
      public var json:Object;
      
      public var conditions:ConvoConditionsDef = null;
      
      public function ConvoNodeDef(param1:ConvoDef)
      {
         super();
         this.convo = param1;
      }
      
      public static function makeReason(param1:Array, param2:String) : void
      {
         if(param1)
         {
            param1.push(param2);
         }
      }
      
      public static function comparator(param1:ConvoNodeDef, param2:ConvoNodeDef, param3:Array, param4:Boolean) : Boolean
      {
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            return false;
         }
         return param1.equals(param2,param3,param4);
      }
      
      private static function _checkActorSyntax(param1:String, param2:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(ENABLE_ACTOR_CHECK)
         {
            if(param1.match(/[^a-zA-Z0-9_$]/))
            {
               throw new ArgumentError("Invalid non-alphanumeric characters in " + param2 + " [" + param1 + "]");
            }
         }
      }
      
      public static function stripText(param1:String, param2:String, param3:Boolean) : String
      {
         var _loc5_:int = 0;
         param2 = param2.replace(ITALIC_INKLE_EMPTY,"");
         param2 = param2.replace(ITALIC_INKLE_EMPTY_SPACE,"");
         if(war_risk_str)
         {
            param2 = param2.replace("$risk",war_risk_str);
         }
         param2 = parseEmbeddedCodes(param2,null);
         var _loc4_:int = -1;
         if(Boolean(param2) && param2.charAt(0) == "[")
         {
            _loc5_ = param2.indexOf("]");
            if(_loc5_ < 0)
            {
               throw new ArgumentError("invalid speaker syntax on " + param1 + " for " + param2);
            }
            _loc4_ = param2.indexOf(" ");
            param2 = parseInkleCodes(StringUtil.stripSurroundingSpace(param2.substr(_loc5_ + 1)));
         }
         else if(!(Boolean(param2) && param2.toLowerCase().indexOf("{skip}") == 0))
         {
            param2 = parseInkleCodes(param2);
         }
         return param2;
      }
      
      private static function parseEmbeddedCodes(param1:String, param2:Object) : String
      {
         if(!param1)
         {
            return param1;
         }
         param1 = parseEmbeddedCode(param1,"{advanceIfSkipped}","advanceIfSkipped",param2);
         param1 = parseEmbeddedCode(param1,"{pageBreak}","pageBreak",param2);
         param1 = parseEmbeddedCode(param1,"{notranslate}","notranslate",param2);
         return parseEmbeddedCode(param1,"{joinNext}","joinNext",param2);
      }
      
      private static function parseEmbeddedCode(param1:String, param2:String, param3:String, param4:Object) : String
      {
         if(!param1)
         {
            return param1;
         }
         var _loc5_:int = param1.indexOf(param2);
         if(_loc5_ >= 0)
         {
            param1 = param1.replace(param2,"");
            if(param4)
            {
               param4[param3] = true;
            }
         }
         return param1;
      }
      
      public static function parseInkleCodes(param1:String) : String
      {
         var _loc2_:Boolean = false;
         param1 = parseItalicCodes(param1,ITALIC_INKLE_START,ITALIC_INKLE_END,ITALIC_HTML_START,ITALIC_HTML_END);
         param1 = parseItalicCodes(param1,ITALIC_HTAG_START,ITALIC_HTAG_END,ITALIC_HTML_START,ITALIC_HTML_END);
         return parseItalicCodes(param1,GP_INKLE_START,GP_INLKE_END,GP_GAME_START,GP_GAME_END);
      }
      
      public static function unparseInkleCodes(param1:String) : String
      {
         param1 = parseItalicCodes(param1,ITALIC_HTML_START,ITALIC_HTML_END,ITALIC_INKLE_START,ITALIC_INKLE_END);
         return parseItalicCodes(param1,GP_GAME_START,GP_GAME_END,GP_INKLE_START,GP_INLKE_END);
      }
      
      public static function parseItalicCodes(param1:String, param2:String, param3:String, param4:String, param5:String) : String
      {
         var _loc6_:RegExp = null;
         var _loc7_:RegExp = null;
         if(param1 == null)
         {
            throw new ArgumentError("ConvoNodDef.parseItalicCodes invalid string");
         }
         if(param1.indexOf(param2) >= 0)
         {
            _loc6_ = new RegExp(param2,"g");
            _loc7_ = new RegExp(param3,"g");
            param1 = param1.replace(_loc6_,param4);
            param1 = param1.replace(_loc7_,param5);
         }
         return param1;
      }
      
      public static function readFlagsVector(param1:ByteArray, param2:ILogger) : Vector.<ConvoFlagDef>
      {
         var _loc3_:Vector.<ConvoFlagDef> = null;
         var _loc5_:int = 0;
         var _loc6_:ConvoFlagDef = null;
         var _loc4_:int = param1.readByte();
         if(_loc4_)
         {
            _loc3_ = new Vector.<ConvoFlagDef>();
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc6_ = new ConvoFlagDef().readBytes(param1,param2);
               _loc3_.push(_loc6_);
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      public static function writeFlagsVector(param1:ByteArray, param2:Vector.<ConvoFlagDef>) : void
      {
         var _loc3_:ConvoFlagDef = null;
         param1.writeByte(!!param2 ? int(param2.length) : 0);
         if(param2)
         {
            for each(_loc3_ in param2)
            {
               _loc3_.writeBytes(param1);
            }
         }
      }
      
      public function addFlags(param1:Vector.<ConvoFlagDef>) : void
      {
         var _loc2_:ConvoFlagDef = null;
         for each(_loc2_ in param1)
         {
            this.addFlag(_loc2_);
         }
      }
      
      public function addFlag(param1:ConvoFlagDef) : void
      {
         if(param1.meta)
         {
            this.metaflags = this.addFlagTo(param1,this.metaflags);
         }
         else
         {
            this.flags = this.addFlagTo(param1,this.flags);
         }
      }
      
      public function addFlagTo(param1:ConvoFlagDef, param2:Vector.<ConvoFlagDef>) : Vector.<ConvoFlagDef>
      {
         if(!param2)
         {
            param2 = new Vector.<ConvoFlagDef>();
         }
         param2.push(param1);
         return param2;
      }
      
      public function getDebugStringFlags() : String
      {
         var _loc2_:ConvoFlagDef = null;
         var _loc3_:ConvoFlagDef = null;
         var _loc1_:String = "";
         if(this.flags)
         {
            for each(_loc2_ in this.flags)
            {
               _loc1_ += "~(" + _loc2_.labelString + ") ";
            }
         }
         if(this.metaflags)
         {
            for each(_loc3_ in this.metaflags)
            {
               _loc1_ += "~(" + _loc3_.labelString + ") ";
            }
         }
         return _loc1_;
      }
      
      public function equals(param1:ConvoNodeDef, param2:Array, param3:Boolean) : Boolean
      {
         if(!param3)
         {
            if(this.id != param1.id)
            {
               makeReason(param2,"ConvoNode(id " + this.id + ")");
               return false;
            }
         }
         if(this._text != param1._text)
         {
            makeReason(param2,"ConvoNode(text " + this.id + ")");
            return false;
         }
         if(this.speaker != param1.speaker)
         {
            makeReason(param2,"ConvoNode(speaker " + this.id + ")");
            return false;
         }
         if(this.camera != param1.camera)
         {
            makeReason(param2,"ConvoNode(camera " + this.id + ")");
            return false;
         }
         if(!ConvoLinkDef.comparator(this.link,param1.link,param2,param3))
         {
            makeReason(param2,"ConvoNode(link " + this.id + ")");
            return false;
         }
         if(!ConvoOptionDef.comparatorVectors(this.options,param1.options,param2,param3))
         {
            makeReason(param2,"ConvoNode(opts " + this.id + ")");
            return false;
         }
         if(!ConvoFlagDef.comparatorVectors(this.flags,param1.flags))
         {
            makeReason(param2,"ConvoNode(flags " + this.id + ")");
            return false;
         }
         if(!ConvoFlagDef.comparatorVectors(this.metaflags,param1.metaflags))
         {
            makeReason(param2,"ConvoNode(metaflags " + this.id + ")");
            return false;
         }
         if(this.pageNum != param1.pageNum)
         {
            makeReason(param2,"ConvoNode(pageNum " + this.id + ")");
            return false;
         }
         if(this.pageLabel != param1.pageLabel)
         {
            makeReason(param2,"ConvoNode(pageLabel " + this.id + ")");
            return false;
         }
         if(this.runOn != param1.runOn)
         {
            makeReason(param2,"ConvoNode(runOn " + this.id + ")");
            return false;
         }
         if(this.skip != param1.skip)
         {
            makeReason(param2,"ConvoNode(skip " + this.id + ")");
            return false;
         }
         if(this.cameraStageIndex != param1.cameraStageIndex)
         {
            makeReason(param2,"ConvoNode(cameraStageIndex " + this.id + ")");
            return false;
         }
         if(this.cameraUnitFacing != param1.cameraUnitFacing)
         {
            makeReason(param2,"ConvoNode(cameraUnitFacing " + this.id + ")");
            return false;
         }
         if(this.cameraMarkFacing != param1.cameraMarkFacing)
         {
            makeReason(param2,"ConvoNode(cameraMarkFacing " + this.id + ")");
            return false;
         }
         if(this.advanceIfSkipped != param1.advanceIfSkipped)
         {
            makeReason(param2,"ConvoNode(advanceIfSkipped " + this.id + ")");
            return false;
         }
         if(this.pageBreak != param1.pageBreak)
         {
            makeReason(param2,"ConvoNode(pageBreak " + this.id + ")");
            return false;
         }
         if(this.notranslate != param1.notranslate)
         {
            makeReason(param2,"ConvoNode(notranslate " + this.id + ")");
            return false;
         }
         if(this.joinNext != param1.joinNext)
         {
            makeReason(param2,"ConvoNode(joinNext " + this.id + ")");
            return false;
         }
         if(!ConvoConditionsDef.comparator(this.conditions,param1.conditions))
         {
            return false;
         }
         return true;
      }
      
      public function getText(param1:String, param2:ILogger) : String
      {
         var _loc3_:String = null;
         if(this.convo.strings)
         {
            if(param1)
            {
               _loc3_ = String(this.convo.strings.stitches[this.id + param1]);
            }
            if(!_loc3_)
            {
               _loc3_ = String(this.convo.strings.stitches[this.id]);
            }
            if(!_loc3_ && !param1)
            {
               _loc3_ = String(this.convo.strings.stitches[this.id + "^m"]);
               if(!_loc3_)
               {
               }
            }
            return _loc3_;
         }
         return this._text;
      }
      
      public function get isEmptyText() : Boolean
      {
         return !this._text;
      }
      
      public function get isEnd() : Boolean
      {
         return !this.options || !this.link;
      }
      
      public function get debugStringOptions() : String
      {
         return !!this.options ? this.options.length.toString() : "0";
      }
      
      public function toString() : String
      {
         return this.id;
      }
      
      public function applyFlags(param1:IHappeningProvider, param2:IVariableProvider, param3:Convo, param4:Rng) : void
      {
         var _loc5_:ConvoFlagDef = null;
         var _loc6_:ConvoFlagDef = null;
         if(this.flags)
         {
            for each(_loc5_ in this.flags)
            {
               _loc5_.apply(param1,param2,param3,param4);
            }
         }
         if(this.metaflags)
         {
            for each(_loc6_ in this.metaflags)
            {
               _loc6_.apply(param1,param2,param3,param4);
            }
         }
      }
      
      public function advanceLink(param1:Convo, param2:ConvoLinkDef, param3:String, param4:ISagaExpression, param5:ILogger) : ConvoNodeDef
      {
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         if(!param2)
         {
            return null;
         }
         var _loc6_:ConvoNodeDef = param1.def.getNodeDef(param2.path);
         if(_loc6_)
         {
            _loc7_ = _loc6_.skip || !_loc6_._text;
            _loc8_ = !_loc6_._text && Boolean(_loc6_.conditions);
            _loc9_ = !param2.conditions || param2.conditions.checkConditions(param2.toString(),param4,param5);
            _loc10_ = !_loc6_.conditions || _loc6_.conditions.checkConditions(_loc6_.id,param4,param5);
            _loc11_ = _loc9_ && _loc10_;
            if(_loc7_ && _loc9_ && (!_loc8_ || _loc10_))
            {
               _loc6_.applyFlags(param1.happs,param1.vars,param1,param1.rng);
            }
            _loc12_ = _loc7_ || !_loc10_ || !_loc11_;
            if(_loc12_)
            {
               return _loc6_.advance(param1,param3,param4,param5);
            }
         }
         return _loc6_;
      }
      
      public function advance(param1:Convo, param2:String, param3:ISagaExpression, param4:ILogger) : ConvoNodeDef
      {
         if(!this.link)
         {
            if(!this.options)
            {
               return null;
            }
            return this;
         }
         return this.advanceLink(param1,this.link,param2,param3,param4);
      }
      
      public function getOption(param1:String) : ConvoOptionDef
      {
         var _loc2_:ConvoOptionDef = null;
         if(Boolean(this.link) || !this.options)
         {
            throw new IllegalOperationError("No options this node: " + this.id);
         }
         for each(_loc2_ in this.options)
         {
            if(_loc2_.link.path == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      protected function parseText(param1:String, param2:Boolean, param3:Boolean) : void
      {
         var _loc5_:int = 0;
         this.rawText = param1;
         param1 = param1.replace(ITALIC_INKLE_EMPTY,"");
         param1 = param1.replace(ITALIC_INKLE_EMPTY_SPACE,"");
         if(war_risk_str)
         {
            param1 = param1.replace("$risk",war_risk_str);
         }
         param1 = parseEmbeddedCodes(param1,this);
         var _loc4_:int = -1;
         if(Boolean(param1) && param1.charAt(0) == "[")
         {
            _loc5_ = param1.indexOf("]");
            if(_loc5_ < 0)
            {
               throw new ArgumentError("invalid speaker syntax on " + this.id + " for " + param1);
            }
            _loc4_ = param1.indexOf(" ");
            if(_loc4_ < 0 || _loc4_ > _loc5_)
            {
               this.speaker = param1.substring(1,_loc5_).toLowerCase();
            }
            else
            {
               this.speaker = param1.substring(1,_loc4_).toLowerCase();
               if(this.speaker == "." || this.speaker == "*" || this.speaker == "none")
               {
                  this.speaker = null;
               }
               this.camera = param1.substring(_loc4_ + 1,_loc5_).toLowerCase();
            }
            _checkActorSyntax(this.camera,"camera");
            _checkActorSyntax(this.speaker,"speaker");
            this._text = parseInkleCodes(StringUtil.stripSurroundingSpace(param1.substr(_loc5_ + 1)));
         }
         else if(Boolean(param1) && param1.toLowerCase().indexOf("{skip}") == 0)
         {
            if(param2)
            {
               this.skip = true;
               this._text = param1;
               if(param3)
               {
                  this.parseKvp();
               }
            }
         }
         else
         {
            this._text = parseInkleCodes(param1);
         }
      }
      
      private function parseKvp() : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:Vector.<String> = null;
         var _loc8_:String = null;
         var _loc1_:Array = this._text.split(" ");
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = _loc2_.indexOf("=");
            if(_loc3_ > 0)
            {
               _loc4_ = _loc2_.substr(0,_loc3_);
               _loc5_ = _loc2_.substr(_loc3_ + 1);
               _loc6_ = _loc5_.split(",");
               switch(_loc4_)
               {
                  case "mark1":
                     _loc7_ = this.convo.mark1;
                     break;
                  case "mark2":
                     _loc7_ = this.convo.mark2;
                     break;
                  case "mark3":
                     _loc7_ = this.convo.mark3;
                     break;
                  case "mark4":
                     _loc7_ = this.convo.mark4;
               }
               if(_loc7_)
               {
                  for each(_loc8_ in _loc6_)
                  {
                     if(_loc8_)
                     {
                        _loc7_.push(_loc8_);
                     }
                  }
               }
            }
         }
      }
      
      public function processCamera(param1:ILogger, param2:Boolean = false) : void
      {
         var _loc4_:String = null;
         var _loc3_:int = !!this.camera ? this.convo.getMarkFromUnit(this.camera) : 0;
         if(_loc3_ == 0)
         {
            if(this.camera)
            {
               _loc4_ = "Invalid camera target: " + this.camera + " in " + this.convo.url + " at " + this.id;
               param1.error(_loc4_);
               if(param2)
               {
                  throw new ArgumentError(_loc4_);
               }
            }
            this.camera = null;
            this.cameraStageIndex = 0;
            this.cameraUnitFacing = null;
            this.cameraMarkFacing = 0;
            return;
         }
         this.cameraStageIndex = ConvoDef.getCameraStageIndexForMarkDst(_loc3_);
         this.cameraMarkFacing = _loc3_;
         this.cameraUnitFacing = this.camera;
      }
      
      public function scrapeText() : String
      {
         var _loc4_:ConvoOptionDef = null;
         var _loc1_:* = "\t" + this.id + "\t";
         if(this.speaker)
         {
            _loc1_ += this.speaker;
         }
         _loc1_ += "\t";
         var _loc2_:String = unparseInkleCodes(this._text);
         _loc1_ += _loc2_ + "\n";
         var _loc3_:int = 0;
         for each(_loc4_ in this.options)
         {
            _loc1_ += _loc4_.scrapeText(++_loc3_);
         }
         return _loc1_;
      }
      
      public function readBytes(param1:ByteArray, param2:ILogger) : ConvoNodeDef
      {
         var _loc13_:ConvoOptionDef = null;
         var _loc3_:int = param1.readInt();
         var _loc4_:* = (_loc3_ & BIT_SPEAKER) != 0;
         var _loc5_:* = (_loc3_ & BIT_CAMERA) != 0;
         var _loc6_:* = (_loc3_ & BIT_LINK) != 0;
         var _loc7_:* = (_loc3_ & BIT_PAGELABEL) != 0;
         var _loc8_:* = (_loc3_ & BIT_CAMERAUNITFACING) != 0;
         var _loc9_:* = (_loc3_ & BIT_CONDITIONS) != 0;
         this.runOn = (_loc3_ & BIT_RUNON) != 0;
         this.skip = (_loc3_ & BIT_SKIP) != 0;
         this.advanceIfSkipped = (_loc3_ & BIT_ADVANCEIFSKIPPED) != 0;
         this.pageBreak = (_loc3_ & BIT_PAGEBREAK) != 0;
         this.notranslate = (_loc3_ & BIT_NOTRANSLATE) != 0;
         this.joinNext = (_loc3_ & BIT_JOINNEXT) != 0;
         this.id = param1.readUTF();
         var _loc10_:String = param1.readUTF();
         this.parseText(_loc10_,true,false);
         if(_loc4_)
         {
            this.speaker = param1.readUTF();
         }
         if(_loc5_)
         {
            this.camera = param1.readUTF();
         }
         if(_loc6_)
         {
            this.link = new ConvoLinkDef(this.convo).readBytes(param1);
         }
         var _loc11_:int = 0;
         var _loc12_:int = param1.readByte();
         if(_loc12_)
         {
            this.options = new Vector.<ConvoOptionDef>();
            _loc11_ = 0;
            while(_loc11_ < _loc12_)
            {
               _loc13_ = new ConvoOptionDef(this).readBytes(param1,param2);
               _loc13_.nodeId = this.id;
               _loc13_.index = this.options.length;
               this.options.push(_loc13_);
               _loc11_++;
            }
         }
         this.flags = readFlagsVector(param1,param2);
         this.metaflags = readFlagsVector(param1,param2);
         this.pageNum = param1.readByte();
         if(_loc7_)
         {
            this.pageLabel = param1.readUTF();
         }
         this.cameraStageIndex = param1.readInt();
         if(_loc8_)
         {
            this.cameraUnitFacing = param1.readUTF();
         }
         this.cameraMarkFacing = param1.readByte();
         if(_loc5_)
         {
            if(this.cameraMarkFacing <= 0)
            {
               param2.error("Convo node has invalid cameraMarkFacing " + this.cameraMarkFacing + " for camera [" + this.camera + "] speaker [" + this.speaker + "]");
            }
         }
         if(_loc9_)
         {
            this.conditions = new ConvoConditionsDef().readBytes(param1);
         }
         return this;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc3_:ConvoOptionDef = null;
         var _loc2_:* = 0;
         _loc2_ |= !!this.speaker ? BIT_SPEAKER : 0;
         _loc2_ |= !!this.camera ? BIT_CAMERA : 0;
         _loc2_ |= !!this.link ? BIT_LINK : 0;
         _loc2_ |= !!this.pageLabel ? BIT_PAGELABEL : 0;
         _loc2_ |= !!this.cameraUnitFacing ? BIT_CAMERAUNITFACING : 0;
         _loc2_ |= Boolean(this.conditions) && this.conditions.hasConditions ? BIT_CONDITIONS : 0;
         _loc2_ |= this.runOn ? BIT_RUNON : 0;
         _loc2_ |= this.skip ? BIT_SKIP : 0;
         _loc2_ |= this.advanceIfSkipped ? BIT_ADVANCEIFSKIPPED : 0;
         _loc2_ |= this.pageBreak ? BIT_PAGEBREAK : 0;
         _loc2_ |= this.notranslate ? BIT_NOTRANSLATE : 0;
         _loc2_ |= this.joinNext ? BIT_JOINNEXT : 0;
         param1.writeInt(_loc2_);
         param1.writeUTF(this.id);
         param1.writeUTF(!!this._text ? this._text : "");
         if(this.speaker)
         {
            param1.writeUTF(this.speaker);
         }
         if(this.camera)
         {
            param1.writeUTF(this.camera);
         }
         if(this.link)
         {
            this.link.writeBytes(param1);
         }
         param1.writeByte(!!this.options ? int(this.options.length) : 0);
         if(this.options)
         {
            for each(_loc3_ in this.options)
            {
               _loc3_.writeBytes(param1);
            }
         }
         writeFlagsVector(param1,this.flags);
         writeFlagsVector(param1,this.metaflags);
         param1.writeByte(this.pageNum);
         if(this.pageLabel)
         {
            param1.writeUTF(this.pageLabel);
         }
         param1.writeInt(this.cameraStageIndex);
         if(this.cameraUnitFacing)
         {
            param1.writeUTF(this.cameraUnitFacing);
         }
         param1.writeByte(this.cameraMarkFacing);
         if(Boolean(this.conditions) && this.conditions.hasConditions)
         {
            this.conditions.writeBytes(param1);
         }
      }
      
      public function addOption(param1:ConvoOptionDef) : void
      {
         if(!this.options)
         {
            this.options = new Vector.<ConvoOptionDef>();
         }
         param1.index = this.options.length;
         param1.nodeId = this.id;
         param1.node = this;
         this.options.push(param1);
      }
      
      public function createLink(param1:String) : void
      {
         if(!param1 || param1 == "END")
         {
            return;
         }
         this.link = new ConvoLinkDef(this.convo);
         this.link.path = param1;
      }
      
      public function getLink() : ConvoLinkDef
      {
         return this.link;
      }
      
      public function getConditions() : ConvoConditionsDef
      {
         return this.conditions;
      }
      
      public function addIfCondition(param1:String) : void
      {
         if(!this.conditions)
         {
            this.conditions = new ConvoConditionsDef();
         }
         this.conditions.addIfCondition(param1);
      }
      
      public function addFlagFromString(param1:String, param2:ILogger) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:ConvoFlagDef = new ConvoFlagDef();
         _loc3_.parse(param1,param2);
         this.addFlag(_loc3_);
      }
   }
}
