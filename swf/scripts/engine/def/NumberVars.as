package engine.def
{
   public class NumberVars
   {
       
      
      public function NumberVars()
      {
         super();
      }
      
      public static function parse(param1:*, param2:Number = 0) : Number
      {
         if(param1 == undefined)
         {
            return param2;
         }
         if(param1 is Number)
         {
            return param1;
         }
         if(param1 is String)
         {
            return param1;
         }
         return param2;
      }
   }
}
