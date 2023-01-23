package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import engine.saga.ISagaExpression;
   import engine.saga.convo.Convo;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class ConvoDef
   {
      
      public static var INKLE_READ_URL:String = "http://writer.inklestudios.com/stories/";
      
      public static var INKLE_WRITE_URL:String = "http://writer.inklestudios.com/?storyID=";
      
      public static var CALCULATE_WORD_COUNT:Boolean;
      
      private static const SKIP_TOKEN:String = "{skip}";
       
      
      public var json:Object;
      
      public var url:String;
      
      public var inkleUrlKey:String;
      
      public var nodesArray:Array;
      
      public var nodesById:Dictionary;
      
      public var speakers:Dictionary;
      
      public var initial:String;
      
      public var mark1:Vector.<String>;
      
      public var mark2:Vector.<String>;
      
      public var mark3:Vector.<String>;
      
      public var mark4:Vector.<String>;
      
      public var marks:Array;
      
      public var strings:ConvoStringsDef;
      
      public var wordCount:int;
      
      public function ConvoDef(param1:ConvoStringsDef)
      {
         this.nodesArray = [];
         this.nodesById = new Dictionary();
         this.speakers = new Dictionary();
         this.mark1 = new Vector.<String>();
         this.mark2 = new Vector.<String>();
         this.mark3 = new Vector.<String>();
         this.mark4 = new Vector.<String>();
         this.marks = [this.mark1,this.mark2,this.mark3,this.mark4];
         super();
         this.strings = param1;
      }
      
      public static function makeReason(param1:Array, param2:String) : void
      {
         if(param1)
         {
            param1.push(param2);
         }
      }
      
      public static function getCameraStageIndexForMarkDst(param1:int) : int
      {
         if(param1 == 1 || param1 == 3)
         {
            return 0;
         }
         return 1;
      }
      
      public static function getBackMarkForMark(param1:int) : int
      {
         switch(param1)
         {
            case 1:
               return 2;
            case 2:
               return 1;
            case 3:
               return 4;
            case 4:
               return 3;
            default:
               return 0;
         }
      }
      
      public static function getStringsUrl(param1:String) : String
      {
         var _loc2_:int = param1.indexOf("/");
         if(_loc2_ > 0)
         {
            return param1.substr(0,_loc2_) + "/locale/en/" + param1.substr(_loc2_ + 1);
         }
         return null;
      }
      
      private static function readStringsVector(param1:ByteArray, param2:Vector.<String>, param3:ILogger) : Vector.<String>
      {
         var _loc5_:int = 0;
         var _loc4_:int = param1.readByte();
         if(_loc4_)
         {
            if(!param2)
            {
               param2 = new Vector.<String>();
            }
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               param2.push(param1.readUTF());
               _loc5_++;
            }
         }
         return param2;
      }
      
      private static function writeStringsVector(param1:ByteArray, param2:Vector.<String>) : void
      {
         var _loc3_:String = null;
         param1.writeByte(!!param2 ? param2.length : 0);
         if(param2)
         {
            for each(_loc3_ in param2)
            {
               param1.writeUTF(_loc3_);
            }
         }
      }
      
      private static function writeStringsArray(param1:ByteArray, param2:Array) : void
      {
         var _loc3_:String = null;
         param1.writeByte(!!param2 ? param2.length : 0);
         if(param2)
         {
            for each(_loc3_ in param2)
            {
               param1.writeUTF(_loc3_);
            }
         }
      }
      
      public function toString() : String
      {
         return "ConvoDef:" + this.url;
      }
      
      public function equals(param1:ConvoDef, param2:Array, param3:Boolean = false) : Boolean
      {
         if(param1 == this)
         {
            return true;
         }
         if(!ArrayUtil.isEqual(this.nodesArray,param1.nodesArray,param2,ConvoNodeDef.comparator,param3))
         {
            makeReason(param2,"ConvoDef(nodes " + this.url + ")");
            return false;
         }
         if(param3)
         {
            if(!ArrayUtil.isDictEqualLength(this.nodesById,param1.nodesById))
            {
               makeReason(param2,"ConvoDef(dict-len " + this.url + ")");
               return false;
            }
         }
         else
         {
            if(!ArrayUtil.isDictEqualKeys(this.nodesById,param1.nodesById))
            {
               makeReason(param2,"ConvoDef(dict-keys " + this.url + ")");
               return false;
            }
            if(this.initial != param1.initial)
            {
               makeReason(param2,"ConvoDef(initial-id-" + this.url + ")");
               return false;
            }
         }
         var _loc4_:ConvoNodeDef = this.getNodeDef(this.initial);
         var _loc5_:ConvoNodeDef = param1.getNodeDef(param1.initial);
         if(!_loc4_ || !_loc5_)
         {
            makeReason(param2,"ConvoDef(intial-nul" + this.url + ")");
            return false;
         }
         if(!_loc4_.equals(_loc5_,param2,param3))
         {
            makeReason(param2,"ConvoDef(intials" + this.url + ")");
            return false;
         }
         if(!ArrayUtil.isDictEqualKeys(this.speakers,param1.speakers))
         {
            return false;
         }
         if(!ArrayUtil.isEqualStringVectors(this.mark1,param1.mark1))
         {
            return false;
         }
         if(!ArrayUtil.isEqualStringVectors(this.mark2,param1.mark2))
         {
            return false;
         }
         if(!ArrayUtil.isEqualStringVectors(this.mark3,param1.mark3))
         {
            return false;
         }
         if(!ArrayUtil.isEqualStringVectors(this.mark4,param1.mark4))
         {
            return false;
         }
         return true;
      }
      
      public function getNodeDef(param1:String) : ConvoNodeDef
      {
         return this.nodesById[param1];
      }
      
      public function countWords() : void
      {
         var _loc2_:ConvoNodeDef = null;
         var _loc3_:ConvoOptionDef = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.nodesById)
         {
            if(_loc2_._text)
            {
               _loc1_ += StringUtil.countWords(_loc2_._text);
            }
            if(Boolean(_loc2_.options) && _loc2_.options.length > 0)
            {
               for each(_loc3_ in _loc2_.options)
               {
                  if(Boolean(_loc3_._text) && _loc3_._text.indexOf(SKIP_TOKEN) < 0)
                  {
                     _loc1_ += StringUtil.countWords(_loc3_._text);
                  }
               }
            }
         }
         this.wordCount = _loc1_;
      }
      
      public function advance(param1:Convo, param2:ConvoNodeDef, param3:String, param4:ISagaExpression, param5:ILogger) : ConvoNodeDef
      {
         return param2.advance(param1,param3,param4,param5);
      }
      
      public function select(param1:ConvoNodeDef, param2:String, param3:String) : ConvoNodeDef
      {
         var _loc4_:ConvoOptionDef = param1.getOption(param2);
         if(!_loc4_)
         {
            return null;
         }
         return this.getNodeDef(_loc4_.link.path);
      }
      
      public function getUnitsFromMark(param1:int) : Vector.<String>
      {
         switch(param1)
         {
            case 1:
               return this.mark1;
            case 2:
               return this.mark2;
            case 3:
               return this.mark3;
            case 4:
               return this.mark4;
            default:
               return null;
         }
      }
      
      public function getMarkFromUnit(param1:String) : int
      {
         if(param1 == "hero")
         {
            param1 = param1;
         }
         if(this.mark1.indexOf(param1) >= 0)
         {
            return 1;
         }
         if(this.mark2.indexOf(param1) >= 0)
         {
            return 2;
         }
         if(this.mark3.indexOf(param1) >= 0)
         {
            return 3;
         }
         if(this.mark4.indexOf(param1) >= 0)
         {
            return 4;
         }
         return 0;
      }
      
      public function scrapeText(param1:String) : String
      {
         var _loc2_:ConvoNodeDef = null;
         param1 += this.url + "\n";
         param1 += "=HYPERLINK(\"" + INKLE_READ_URL + this.inkleUrlKey + "\")\n";
         param1 += "=HYPERLINK(\"" + INKLE_WRITE_URL + this.inkleUrlKey + "\")\n";
         for each(_loc2_ in this.nodesById)
         {
            param1 += _loc2_.scrapeText();
         }
         return param1;
      }
      
      public function readBytes(param1:ByteArray, param2:ILogger) : ConvoDef
      {
         var _loc7_:ConvoNodeDef = null;
         var _loc8_:String = null;
         var _loc3_:int = param1.readInt();
         var _loc4_:int = param1.readInt();
         this.initial = param1.readUTF();
         this.inkleUrlKey = param1.readUTF();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc7_ = new ConvoNodeDef(this);
            _loc7_.readBytes(param1,param2);
            _loc7_.convo = this;
            this.nodesArray.push(_loc7_);
            this.nodesById[_loc7_.id] = _loc7_;
            _loc5_++;
         }
         var _loc6_:int = param1.readByte();
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            _loc8_ = param1.readUTF();
            this.speakers[_loc8_] = _loc8_;
            _loc5_++;
         }
         readStringsVector(param1,this.mark1,param2);
         readStringsVector(param1,this.mark2,param2);
         readStringsVector(param1,this.mark3,param2);
         readStringsVector(param1,this.mark4,param2);
         return this;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc3_:ConvoNodeDef = null;
         var _loc4_:Array = null;
         var _loc2_:int = 0;
         param1.writeInt(_loc2_);
         param1.writeInt(this.nodesArray.length);
         param1.writeUTF(!!this.initial ? this.initial : "");
         param1.writeUTF(!!this.inkleUrlKey ? this.inkleUrlKey : "");
         for each(_loc3_ in this.nodesArray)
         {
            _loc3_.writeBytes(param1);
         }
         _loc4_ = ArrayUtil.getDictionaryKeys(this.speakers);
         _loc4_.sort();
         writeStringsArray(param1,_loc4_);
         writeStringsVector(param1,this.mark1);
         writeStringsVector(param1,this.mark2);
         writeStringsVector(param1,this.mark3);
         writeStringsVector(param1,this.mark4);
      }
      
      public function applyStrings(param1:ConvoStringsDef, param2:ILogger) : void
      {
      }
      
      public function addMark(param1:int, param2:String) : void
      {
         var _loc3_:Vector.<String> = this.getUnitsFromMark(param1);
         _loc3_.push(param2);
      }
      
      public function getDebugStringNodePrefix(param1:ConvoNodeDef) : String
      {
         var _loc2_:String = "";
         var _loc3_:* = "";
         _loc3_ = "";
         if(param1._text)
         {
            _loc3_ = param1._text.substr(0,20).replace("\n","\\n");
         }
         else
         {
            _loc3_ += "NULL";
         }
         return _loc2_ + ("> " + StringUtil.padRight(param1.id," ",14) + " " + StringUtil.padRight(_loc3_," ",20));
      }
      
      public function getDebugStringNodeSuffix(param1:ConvoNodeDef) : String
      {
         var _loc2_:String = "";
         var _loc3_:* = "";
         if(param1.link)
         {
            _loc3_ = "-> (";
            _loc3_ += param1.link.path;
            _loc3_ += param1.link.conditions.getDebugString();
            _loc3_ += ")";
         }
         _loc2_ += _loc3_;
         _loc3_ = "";
         if(param1.conditions)
         {
            _loc3_ += param1.conditions.getDebugString();
            if(_loc3_)
            {
               _loc3_ += " ";
            }
         }
         _loc3_ += param1.getDebugStringFlags();
         if(_loc3_)
         {
            _loc2_ += " :: " + _loc3_;
         }
         return _loc2_;
      }
      
      public function getDebugStringOption(param1:ConvoOptionDef) : String
      {
         if(!param1)
         {
            return "NULL OPT!";
         }
         var _loc2_:* = "";
         var _loc3_:* = "";
         _loc2_ += "    * ";
         _loc3_ = "";
         var _loc4_:String = param1._text;
         if(_loc4_)
         {
            _loc4_ = _loc4_.substr(0,20).replace("\n","\\n");
         }
         _loc3_ += _loc4_;
         _loc2_ += StringUtil.padRight(_loc3_," ",20);
         _loc3_ = !!param1.link ? " -> " + param1.link.path : "";
         _loc3_ = StringUtil.padRight(_loc3_," ",20);
         _loc2_ += _loc3_;
         _loc3_ = "";
         if(Boolean(param1.link) && Boolean(param1.link.conditions))
         {
            _loc3_ += param1.link.conditions.getDebugString();
            if(_loc3_)
            {
               _loc3_ += " ";
            }
         }
         _loc3_ += param1.getDebugStringFlags();
         if(_loc3_)
         {
            _loc2_ += " :: " + _loc3_;
         }
         return _loc2_;
      }
      
      public function getDebugStringMarks() : String
      {
         var _loc3_:Vector.<String> = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < this.marks.length)
         {
            _loc3_ = this.marks[_loc2_];
            _loc1_ += "  " + (_loc2_ + 1) + "  [" + _loc3_.join(",") + "]\n";
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getDebugString() : String
      {
         var _loc2_:ConvoNodeDef = null;
         var _loc3_:ConvoOptionDef = null;
         var _loc1_:* = "";
         for each(_loc2_ in this.nodesArray)
         {
            _loc1_ += this.getDebugStringNodePrefix(_loc2_);
            if(_loc2_.options)
            {
               _loc1_ += "\n";
               for each(_loc3_ in _loc2_.options)
               {
                  _loc1_ += this.getDebugStringOption(_loc3_);
                  _loc1_ += "\n";
               }
            }
            else
            {
               _loc1_ += this.getDebugStringNodeSuffix(_loc2_);
               _loc1_ += "\n";
            }
         }
         return _loc1_;
      }
      
      public function checkBadHeroes(param1:ILogger) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc6_:Vector.<String> = null;
         var _loc7_:String = null;
         var _loc5_:Dictionary = new Dictionary();
         for each(_loc6_ in this.marks)
         {
            for each(_loc7_ in _loc6_)
            {
               _loc5_[_loc7_] = true;
               _loc2_ = _loc2_ || _loc7_ == "$hero";
               _loc3_ = _loc3_ || _loc7_ == "alette";
               _loc4_ = _loc4_ || _loc7_ == "rook";
               if(_loc2_ && (_loc4_ || _loc3_))
               {
                  param1.error("convo has $hero but also rook=" + _loc4_ + " or alette=" + _loc3_ + ": " + this.url);
                  return true;
               }
            }
         }
         return false;
      }
   }
}
