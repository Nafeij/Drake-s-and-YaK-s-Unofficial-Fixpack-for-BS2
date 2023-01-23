package json.frigga.schema
{
   public class FriggaSchemaHeader
   {
       
      
      public var name:String;
      
      public var description:String;
      
      public var type:String;
      
      public function FriggaSchemaHeader(param1:String, param2:String, param3:String)
      {
         super();
         this.name = param1;
         this.description = param2;
         this.type = param3;
      }
   }
}
