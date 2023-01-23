package engine.core.locale
{
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import flash.utils.Dictionary;
   
   public class StringIdInfo
   {
      
      public static const PREFIX_UNTRANSLATED:String = "UNTRANSLATED: ";
      
      public static const PREFIX_DEPRECATED:String = "DEPRECATED: ";
      
      public static const PREFIX_REVIEW:String = "REVIEW: ";
      
      public static const PREFIX_INKLE:String = "INKLE: ";
       
      
      public var id:String;
      
      public var filename:String;
      
      public var original:String;
      
      public var fullId:String;
      
      public var baseline:String;
      
      public var baseline_translation:String;
      
      public function StringIdInfo()
      {
         super();
      }
      
      public static function stringNeedsAttention(param1:String) : Boolean
      {
         return stringIsUntranslated(param1) || stringIsDeprecated(param1) || stringIsReview(param1);
      }
      
      public static function stringIsUntranslated(param1:String) : Boolean
      {
         return StringUtil.startsWith(param1,PREFIX_UNTRANSLATED);
      }
      
      public static function stringIsDeprecated(param1:String) : Boolean
      {
         return StringUtil.startsWith(param1,PREFIX_DEPRECATED);
      }
      
      public static function stringIsReview(param1:String) : Boolean
      {
         return StringUtil.startsWith(param1,PREFIX_REVIEW);
      }
      
      public static function encodeStringForCsv(param1:String) : String
      {
         param1 = param1.replace(/""/g,"\"");
         param1 = param1.replace(/"/g,"\"\"");
         param1 = param1.replace(/\r\n/g,"\r");
         param1 = param1.replace(/\n/g,"\r");
         param1 = param1.replace(/\<br\>/g,"\r");
         return param1.replace(/\\n/g,"\r");
      }
      
      public static function decodeString(param1:String) : String
      {
         if(!param1)
         {
            return param1;
         }
         param1 = param1.replace(/\"\"/g,"\"");
         param1 = param1.replace(/\r\n/g,"\n");
         param1 = param1.replace(/\r/g,"\n");
         return param1.replace(/\n/g,"\\n");
      }
      
      public function clone() : StringIdInfo
      {
         var _loc1_:StringIdInfo = new StringIdInfo();
         _loc1_.id = this.id;
         _loc1_.filename = this.filename;
         _loc1_.original = this.original;
         _loc1_.fullId = this.fullId;
         _loc1_.baseline = this.baseline;
         _loc1_.baseline_translation = this.baseline_translation;
         return _loc1_;
      }
      
      public function get wordCount() : int
      {
         var _loc1_:int = StringUtil.countWords(this.original);
         if(StringIdInfo.stringNeedsAttention(this.original))
         {
            _loc1_--;
         }
         return _loc1_;
      }
      
      public function toString() : String
      {
         return "id=[" + this.id + "] filename=[" + this.filename + "] original=[" + this.original + "]";
      }
      
      public function makeUntranslated() : void
      {
         if(!this.original)
         {
            return;
         }
         if(this.id.indexOf("eyvindImNotSureI") >= 0)
         {
            this.id = this.id;
         }
         if(!stringIsUntranslated(this.original))
         {
            this.original = PREFIX_UNTRANSLATED + this.original;
         }
      }
      
      public function makeReview(param1:String, param2:String) : void
      {
         if(!stringIsReview(this.original))
         {
            this.baseline = "PRE-EN: " + param1;
            if(!this.baseline_translation)
            {
               this.baseline_translation = "PRE-TR: " + this.original;
            }
            this.original = PREFIX_REVIEW + param1;
         }
         this.original = PREFIX_REVIEW + param2;
      }
      
      public function makeDeprecated() : void
      {
         if(!stringIsDeprecated(this.original))
         {
            this.original = PREFIX_DEPRECATED + this.original;
         }
      }
      
      public function fromEngineString(param1:String, param2:String, param3:String) : StringIdInfo
      {
         this.id = param1;
         this.filename = param2;
         this.fullId = param2 + ":" + param1;
         this.original = encodeStringForCsv(param3);
         return this;
      }
      
      public function fromCsvString(param1:String, param2:String, param3:String) : StringIdInfo
      {
         this.filename = param2;
         this.id = param1;
         this.fullId = param2 + ":" + param1;
         this.original = decodeString(param3);
         return this;
      }
      
      public function toCsvRow() : String
      {
         var _loc1_:* = "";
         if(this.id == "ABILITY:abl_arc_lightning_pg_desc")
         {
            this.id = this.id;
         }
         _loc1_ += "\"" + this.filename + "\",";
         _loc1_ += "\"" + this.id + "\",";
         _loc1_ += "\"" + encodeStringForCsv(this.original) + "\",";
         if(this.baseline)
         {
            _loc1_ += "\"" + encodeStringForCsv(this.baseline) + "\",";
         }
         else
         {
            _loc1_ += ",";
         }
         if(this.baseline_translation)
         {
            _loc1_ += "\"" + encodeStringForCsv(this.baseline_translation) + "\",";
         }
         else
         {
            _loc1_ += ",";
         }
         return _loc1_ + "\r\n";
      }
      
      public function shouldBeOmitted(param1:Dictionary) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:LocaleCategory = null;
         if(!param1)
         {
            return false;
         }
         var _loc2_:int = this.id.indexOf(":");
         if(_loc2_ > 0)
         {
            _loc3_ = this.id.substr(0,_loc2_);
            _loc4_ = Enum.parse(LocaleCategory,_loc3_,false) as LocaleCategory;
            if(_loc4_)
            {
               if(param1[_loc4_])
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}
