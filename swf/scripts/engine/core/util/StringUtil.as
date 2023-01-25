package engine.core.util
{
   import engine.core.BoxInt;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   
   public class StringUtil
   {
      
      private static const FUZZY_INSERTION_WEIGHT:int = 3;
       
      
      public function StringUtil()
      {
         super();
      }
      
      public static function nonnull(param1:String) : String
      {
         return !!param1 ? param1 : "";
      }
      
      public static function formatHex(param1:int, param2:int) : String
      {
         return "0x" + padLeft(param1.toString(16),"0",param2 * 2);
      }
      
      public static function formatCommaInteger(param1:int) : String
      {
         var _loc2_:String = param1.toString();
         var _loc3_:int = _loc2_.length - 3;
         while(_loc3_ > 0)
         {
            _loc2_ = _loc2_.substring(0,_loc3_) + "," + _loc2_.substring(_loc3_);
            _loc3_ -= 3;
         }
         return _loc2_;
      }
      
      public static function formatPoint(param1:Point) : String
      {
         return padLeft(param1.x.toString()," ",4) + " " + padLeft(param1.y.toString()," ",4);
      }
      
      public static function formatMinSec(param1:int) : String
      {
         var _loc2_:int = param1 / 60;
         param1 -= _loc2_ * 60;
         var _loc3_:String = padLeft(_loc2_.toString(),"0",2);
         var _loc4_:String = padLeft(param1.toString(),"0",2);
         return _loc3_ + ":" + _loc4_;
      }
      
      public static function padRight(param1:String, param2:String, param3:int) : String
      {
         if(!param2)
         {
            throw new ArgumentError("Bad pad");
         }
         if(param1 == null)
         {
            param1 = "";
         }
         if(param1.length >= param3)
         {
            return param1;
         }
         var _loc4_:String = param1;
         var _loc5_:int = (param3 - _loc4_.length) / param2.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_ += param2;
            _loc6_++;
         }
         return _loc4_;
      }
      
      public static function repeat(param1:String, param2:int) : String
      {
         if(!param1)
         {
            throw new ArgumentError("Bad pad");
         }
         var _loc3_:String = "";
         var _loc4_:int = (param2 - _loc3_.length) / param1.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = param1 + _loc3_;
            _loc5_++;
         }
         return _loc3_;
      }
      
      public static function padLeft(param1:String, param2:String, param3:int) : String
      {
         if(!param2)
         {
            throw new ArgumentError("Bad pad");
         }
         if(param1.length >= param3)
         {
            return param1;
         }
         var _loc4_:String = param1;
         var _loc5_:int = (param3 - _loc4_.length) / param2.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_ = param2 + _loc4_;
            _loc6_++;
         }
         return _loc4_;
      }
      
      public static function stripSurroundingSpace(param1:String, param2:BoxInt = null) : String
      {
         var _loc3_:String = param1.replace(/^[ \t\n]+/,"");
         if(param2)
         {
            param2.value += param1.length - _loc3_.length;
         }
         param1 = _loc3_;
         return param1.replace(/[ \t]+$/,"");
      }
      
      public static function stripWhitespace(param1:String, param2:BoxInt = null) : String
      {
         var _loc3_:String = param1.replace(/[ \t]+/,"");
         if(param2)
         {
            param2.value += param1.length - _loc3_.length;
         }
         return _loc3_;
      }
      
      public static function stripCarriageReturns(param1:String, param2:BoxInt = null) : String
      {
         var _loc3_:String = param1.replace(/[\r]+/,"");
         if(param2)
         {
            param2.value += param1.length - _loc3_.length;
         }
         return _loc3_;
      }
      
      public static function stripLeadingSpace(param1:String, param2:BoxInt = null) : String
      {
         var _loc3_:String = param1.replace(/^[ \t]+/,"");
         if(param2)
         {
            param2 += param1.length - _loc3_.length;
         }
         return _loc3_;
      }
      
      public static function stripTrailingSpace(param1:String) : String
      {
         return param1.replace(/[ \t]+$/,"");
      }
      
      public static function stripTrailingNewlines(param1:String) : String
      {
         return param1.replace(/[\n]+$/,"");
      }
      
      public static function getShortPath(param1:String) : String
      {
         var _loc3_:int = 0;
         if(!param1)
         {
            return param1;
         }
         var _loc2_:int = param1.lastIndexOf("/");
         if(_loc2_ >= 0)
         {
            _loc3_ = param1.indexOf(".",_loc2_);
            if(_loc3_ > _loc2_)
            {
               return param1.substring(_loc2_ + 1,_loc3_);
            }
            return param1.substring(_loc2_ + 1);
         }
         return param1;
      }
      
      public static function truncate(param1:String, param2:int) : String
      {
         var _loc3_:String = null;
         if(param2 < param1.length)
         {
            _loc3_ = param1.substring(0,param2 - 3);
            _loc3_ = stripSurroundingSpace(_loc3_);
            return _loc3_ + "...";
         }
         return param1;
      }
      
      public static function stripSuffix(param1:String, param2:String) : String
      {
         if(!param1)
         {
            return param1;
         }
         var _loc3_:int = param1.lastIndexOf(param2);
         if(_loc3_ < 0)
         {
            return param1;
         }
         return param1.substring(0,_loc3_);
      }
      
      public static function stripPrefix(param1:String, param2:String) : String
      {
         var _loc3_:int = param1.indexOf(param2);
         if(_loc3_ != 0)
         {
            return param1;
         }
         return param1.substring(param2.length);
      }
      
      public static function numberWithSign(param1:Number, param2:int = 2) : String
      {
         if(param1 < 0)
         {
            return param1.toFixed(param2);
         }
         return "+" + param1.toFixed(param2);
      }
      
      public static function startsWith(param1:String, param2:String) : Boolean
      {
         if(!param1 || !param2)
         {
            return false;
         }
         if(param1.length < param2.length)
         {
            return false;
         }
         if(param1.charAt(0) != param2.charAt(0))
         {
            return false;
         }
         return param1.indexOf(param2) == 0;
      }
      
      public static function endsWith(param1:String, param2:String) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc3_:int = param1.lastIndexOf(param2);
         return _loc3_ >= 0 && _loc3_ == param1.length - param2.length;
      }
      
      public static function getDotSuffix(param1:String) : String
      {
         return getSuffix(param1,".");
      }
      
      public static function getSuffix(param1:String, param2:String) : String
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:int = param1.lastIndexOf(param2);
         if(_loc3_ >= 0)
         {
            return param1.substring(_loc3_ + param2.length);
         }
         return param1;
      }
      
      public static function getPrefix(param1:String, param2:String) : String
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:int = param1.indexOf(param2);
         if(_loc3_ >= 0)
         {
            return param1.substring(0,_loc3_);
         }
         return param1;
      }
      
      public static function getFilename(param1:String, param2:String = "/") : String
      {
         var _loc3_:int = param1.lastIndexOf(param2);
         if(_loc3_ >= 0)
         {
            return param1.substring(_loc3_ + param2.length);
         }
         return param1;
      }
      
      public static function getBasename(param1:String) : String
      {
         if(!param1)
         {
            return null;
         }
         param1 = param1.replace(/.*[\/|\\]/,"");
         var _loc2_:int = -1;
         _loc2_ = param1.indexOf(".");
         if(_loc2_ >= 0)
         {
            return param1.substring(0,_loc2_);
         }
         return param1;
      }
      
      public static function getFolder(param1:String) : String
      {
         var _loc2_:int = param1.lastIndexOf("/");
         if(_loc2_ >= 0)
         {
            if(_loc2_ == param1.length - 1)
            {
               _loc2_ = param1.lastIndexOf("/",_loc2_ - 1);
            }
            if(_loc2_ >= 0)
            {
               return param1.substring(0,_loc2_);
            }
         }
         return param1;
      }
      
      public static function isWhitespace(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1.charAt(_loc2_);
            if(!isWhitespaceChar(_loc3_))
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public static function isWhitespaceChar(param1:String) : Boolean
      {
         switch(param1)
         {
            case " ":
            case "\t":
            case "\r":
            case "\n":
            case "\f":
               return true;
            default:
               return false;
         }
      }
      
      public static function trim(param1:String) : String
      {
         if(param1 == null)
         {
            return null;
         }
         if(!param1)
         {
            return param1;
         }
         var _loc2_:int = param1.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ && isWhitespace(param1.charAt(_loc3_)))
         {
            _loc3_++;
         }
         if(_loc3_ >= _loc2_)
         {
            return "";
         }
         var _loc4_:int = param1.length - 1;
         while(_loc4_ >= 0 && isWhitespace(param1.charAt(_loc4_)))
         {
            _loc4_--;
         }
         if(_loc4_ >= _loc3_)
         {
            return param1.slice(_loc3_,_loc4_ + 1);
         }
         return "";
      }
      
      public static function dateStringSansTZ(param1:Date) : String
      {
         var _loc2_:* = "";
         _loc2_ += param1.fullYear.toString();
         _loc2_ += "/";
         _loc2_ += StringUtil.padLeft((param1.month + 1).toString(),"0",2);
         _loc2_ += "/";
         _loc2_ += StringUtil.padLeft(param1.date.toString(),"0",2);
         _loc2_ += " ";
         _loc2_ += StringUtil.padLeft(param1.hours.toString(),"0",2);
         _loc2_ += ":";
         return _loc2_ + StringUtil.padLeft(param1.minutes.toString(),"0",2);
      }
      
      public static function convertBytesToHexString(param1:ByteArray) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = "";
         param1.position = 0;
         while(param1.bytesAvailable)
         {
            _loc3_ = int(param1.readUnsignedByte());
            _loc4_ = _loc3_.toString(16);
            if(_loc4_.length == 0)
            {
               _loc4_ = "0" + _loc4_;
            }
            _loc2_ += _loc4_;
         }
         return _loc2_;
      }
      
      public static function convertHexStringToBytes(param1:String) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         if(param1.length % 2 != 0)
         {
            throw new ArgumentError("hex string must have 2 characters per byte");
         }
         return _loc2_;
      }
      
      public static function countWords(param1:String) : int
      {
         if(!param1)
         {
            return 0;
         }
         return int(param1.match(/[^\s]+/g).length);
      }
      
      public static function countTokens(param1:String, param2:String) : int
      {
         if(!param1 || !param2)
         {
            return 0;
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc4_ = param1.indexOf(param2,_loc4_);
            if(_loc4_ < 0)
            {
               break;
            }
            _loc3_++;
            _loc4_ += param2.length;
         }
         return _loc3_;
      }
      
      public static function fuzzyComparison(param1:String, param2:String) : int
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         if(param1 == param2)
         {
            return 0;
         }
         if(!param1 || !param2)
         {
            return 100000;
         }
         var _loc3_:int = Math.min(param1.length,param2.length);
         var _loc4_:int = Math.max(param1.length - _loc3_,param2.length - _loc3_);
         _loc4_ *= FUZZY_INSERTION_WEIGHT;
         if(!_loc3_)
         {
            return _loc4_;
         }
         var _loc7_:String = param1.charAt(0);
         var _loc8_:String = param2.charAt(0);
         var _loc9_:int = 0;
         for(; _loc9_ < _loc3_; _loc9_++)
         {
            _loc10_ = _loc7_;
            _loc11_ = _loc8_;
            if(_loc9_ < _loc3_ - 1)
            {
               _loc7_ = param1.charAt(_loc9_ + 1);
               _loc8_ = param1.charAt(_loc9_ + 1);
            }
            else
            {
               _loc7_ = null;
               _loc8_ = null;
            }
            if(_loc10_ != _loc11_)
            {
               if(Boolean(_loc7_) && Boolean(_loc8_))
               {
                  if(_loc7_ == _loc11_ || _loc8_ == _loc10_)
                  {
                     _loc4_++;
                     continue;
                  }
               }
               if(Boolean(_loc5_) && Boolean(_loc6_))
               {
                  if(_loc5_ == _loc11_ || _loc6_ == _loc10_)
                  {
                     _loc4_++;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public static function levenshtein(param1:String, param2:String) : uint
      {
         var _loc4_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         if(param1 == null)
         {
            param1 = "";
         }
         if(param2 == null)
         {
            param2 = "";
         }
         if(param1 == param2)
         {
            return 0;
         }
         var _loc3_:Array = new Array();
         var _loc5_:uint = uint(param1.length);
         var _loc6_:uint = uint(param2.length);
         if(_loc5_ == 0)
         {
            return _loc6_;
         }
         if(_loc6_ == 0)
         {
            return _loc5_;
         }
         _loc7_ = 0;
         while(_loc7_ <= _loc5_)
         {
            _loc3_[_loc7_] = new Array();
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ <= _loc5_)
         {
            _loc3_[_loc7_][0] = _loc7_;
            _loc7_++;
         }
         _loc8_ = 0;
         while(_loc8_ <= _loc6_)
         {
            _loc3_[0][_loc8_] = _loc8_;
            _loc8_++;
         }
         _loc7_ = 1;
         while(_loc7_ <= _loc5_)
         {
            _loc9_ = param1.charAt(_loc7_ - 1);
            _loc8_ = 1;
            while(_loc8_ <= _loc6_)
            {
               _loc10_ = param2.charAt(_loc8_ - 1);
               if(_loc9_ == _loc10_)
               {
                  _loc4_ = 0;
               }
               else
               {
                  _loc4_ = 1;
               }
               _loc3_[_loc7_][_loc8_] = Math.min(_loc3_[_loc7_ - 1][_loc8_] + 1,Math.min(_loc3_[_loc7_][_loc8_ - 1] + 1,Math.min(_loc3_[_loc7_ - 1][_loc8_ - 1] + _loc4_,_loc3_[_loc7_ - 1][_loc8_] + 1)));
               _loc8_++;
            }
            _loc7_++;
         }
         return _loc3_[_loc5_][_loc6_];
      }
      
      public static function similarity(param1:String, param2:String) : Number
      {
         var _loc3_:uint = levenshtein(param1,param2);
         var _loc4_:uint = Math.max(param1.length,param2.length);
         if(_loc4_ == 0)
         {
            return 1;
         }
         return 1 - _loc3_ / _loc4_;
      }
      
      public static function truncateLines(param1:String, param2:int, param3:int) : String
      {
         var _loc4_:Boolean = false;
         var _loc5_:RegExp = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         if(param2 > 0)
         {
            _loc5_ = /\n/g;
            _loc6_ = _loc5_.exec(param1);
            _loc7_ = 0;
            while(_loc6_)
            {
               _loc7_++;
               if(_loc7_ >= param2)
               {
                  param1 = param1.substr(0,_loc6_.index);
                  param1 = stripSurroundingSpace(param1);
                  _loc4_ = true;
                  break;
               }
               _loc6_ = _loc5_.exec(param1);
            }
         }
         if(param3 > 0)
         {
            if(param1.length > param3)
            {
               param1 = param1.substring(0,param3);
               param1 = stripSurroundingSpace(param1);
               _loc4_ = true;
            }
         }
         if(_loc4_)
         {
            param1 += " ... [TRUNCATED]";
         }
         return param1;
      }
   }
}
