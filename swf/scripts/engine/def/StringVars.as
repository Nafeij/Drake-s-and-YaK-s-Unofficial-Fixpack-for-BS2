package engine.def
{
   public class StringVars
   {
       
      
      public function StringVars()
      {
         super();
      }
      
      public static function parse(param1:*, param2:String = null) : String
      {
         if(param1 == undefined)
         {
            return param2;
         }
         if(param1 is String)
         {
            return param1;
         }
         return param2;
      }
   }
}
