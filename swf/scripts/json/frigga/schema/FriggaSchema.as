package json.frigga.schema
{
   import flash.utils.Dictionary;
   
   public class FriggaSchema
   {
       
      
      private var header:FriggaSchemaHeader;
      
      private var mandatory:Vector.<String>;
      
      public var index:Dictionary;
      
      public function FriggaSchema(param1:Dictionary = null, param2:Vector.<String> = null, param3:String = "", param4:String = "", param5:String = "")
      {
         this.mandatory = new Vector.<String>();
         this.index = new Dictionary();
         super();
         this.header = new FriggaSchemaHeader(param3,param4,param5);
         if(param2 != null)
         {
            this.mandatory = param2;
         }
         this.index = param1;
      }
      
      public static function fromObject(param1:Object) : FriggaSchema
      {
         return FriggaSchema.builder().extractNameFrom(param1).extractDescriptionFrom(param1).extractTypeFrom(param1).extractPropertyDescriptorsFrom(param1).getIt();
      }
      
      public static function builder() : FriggaSchemaBuilder
      {
         return new FriggaSchemaBuilder();
      }
      
      public function getPropDescriptorForPath(param1:String) : FriggaPropertyDescriptor
      {
         if(param1 == null || param1 == "")
         {
            return null;
         }
         if(param1.indexOf(".") == -1)
         {
            if(this.index == null)
            {
               return null;
            }
            return this.index[param1];
         }
         var _loc2_:String = param1.substr(0,param1.indexOf("."));
         var _loc3_:String = param1.substr(param1.indexOf(".") + 1,param1.length - _loc2_.length - 1);
         var _loc4_:FriggaPropertyDescriptor = this.index[_loc2_] as FriggaPropertyDescriptor;
         if(_loc4_ != null)
         {
            if(_loc4_.type.header.type == "array")
            {
               if(_loc4_.items != null)
               {
                  return _loc4_.items.getPropDescriptorForPath(_loc3_);
               }
               return null;
            }
            return _loc4_.type.getPropDescriptorForPath(_loc3_);
         }
         return null;
      }
      
      public function getHeader() : FriggaSchemaHeader
      {
         return this.header;
      }
      
      public function getMandatory() : Vector.<String>
      {
         return this.mandatory;
      }
   }
}
