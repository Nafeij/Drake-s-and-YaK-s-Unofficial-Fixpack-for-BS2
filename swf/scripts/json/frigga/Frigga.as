package json.frigga
{
   import json.frigga.report.FriggaReport;
   import json.frigga.report.FriggaWriter;
   import json.frigga.schema.FriggaSchema;
   import json.frigga.validator.FriggaValidator;
   
   public class Frigga implements IFrigga
   {
       
      
      private var validator:FriggaValidator;
      
      public var schema:FriggaSchema;
      
      public function Frigga(param1:FriggaSchema)
      {
         super();
         this.schema = param1;
         this.validator = new FriggaValidator(param1);
      }
      
      public static function forSchema(param1:Object) : Frigga
      {
         var _loc2_:FriggaSchema = FriggaSchema.fromObject(param1);
         return new Frigga(_loc2_);
      }
      
      public function validate(param1:Object) : FriggaReport
      {
         var _loc2_:FriggaWriter = FriggaReport.getWriter();
         this.validator.traverse(param1,_loc2_);
         return _loc2_.getOutput();
      }
   }
}
