package json.frigga.report
{
   public class FriggaMessage
   {
      
      public static const INSTANCE_TYPE_ERROR:String = "invalid type on instance";
      
      public static const PROPERTY_TYPE_ERROR:String = "invalid type on property";
      
      public static const PROPERTY_NOT_FOUND_IN_SCHEMA_ERROR:String = "property not defined in schema";
      
      public static const PROPERTY_NOT_FOUND_IN_INSTANCE_ERROR:String = "mandatory property not found in instance";
      
      public static const PROPERTY_OUT_OF_RANGE_ERROR:String = "number is out of range";
      
      public static const PROPERTY_MIN_ITEMS_ERROR:String = "array items below the minimum";
      
      public static const PROPERTY_MAX_ITEMS_ERROR:String = "array items over the maximum";
      
      public static const PROPERTY_NOT_IN_ENUM_ERROR:String = "value is not in enum values";
      
      public static const PROPERTY_REGEX_ERROR:String = "value does not match the regular expression";
      
      public static const PROPERTY_LENGTH_ERROR:String = "value lenght is out of range";
       
      
      public var message:String = "";
      
      public var property:String = "";
      
      public var actual = "";
      
      public function FriggaMessage(param1:String, param2:String = "", param3:* = "")
      {
         super();
         this.message = param1;
         this.property = param2;
         this.actual = param3;
      }
   }
}
