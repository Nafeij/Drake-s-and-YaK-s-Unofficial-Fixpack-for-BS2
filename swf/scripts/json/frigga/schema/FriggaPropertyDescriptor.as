package json.frigga.schema
{
   public class FriggaPropertyDescriptor
   {
       
      
      public var title:String;
      
      public var description:String;
      
      public var optional:Boolean;
      
      public var minimum:Number;
      
      public var maximum:Number;
      
      public var minimumCanEqual:Boolean;
      
      public var maximumCanEqual:Boolean;
      
      public var minItems:Number;
      
      public var maxItems:Number;
      
      public var uniqueItems:Boolean;
      
      public var pattern:String;
      
      public var maxLength:Number;
      
      public var minLength:Number;
      
      public var enum:Array;
      
      public var defaultValue:Object;
      
      public var type:FriggaSchema;
      
      public var items:FriggaSchema;
      
      public var skip:Boolean;
      
      public function FriggaPropertyDescriptor(param1:String, param2:String, param3:Boolean, param4:Number, param5:Number, param6:Boolean, param7:Boolean, param8:Number, param9:Number, param10:Boolean, param11:String, param12:Number, param13:Number, param14:Array, param15:Object, param16:FriggaSchema, param17:FriggaSchema, param18:Boolean)
      {
         super();
         this.title = param1;
         this.description = param2;
         this.optional = param3;
         this.minimum = param4;
         this.maximum = param5;
         this.minimumCanEqual = param6;
         this.maximumCanEqual = param7;
         this.minItems = param8;
         this.maxItems = param9;
         this.uniqueItems = param10;
         this.pattern = param11;
         this.maxLength = param12;
         this.minLength = param13;
         this.enum = param14;
         this.defaultValue = param15;
         this.type = param16;
         this.items = param17;
         this.skip = param18;
      }
   }
}
