package engine.def
{
   public class BooleanVars
   {
       
      
      public function BooleanVars()
      {
         super();
      }
      
      public static function parse(param1:*, param2:Boolean = false) : Boolean
      {
         if(param1 == undefined)
         {
            return param2;
         }
         if(param1 is Boolean)
         {
            return param1;
         }
         if(param1 == "false" || param1 == "0" || param1 == 0)
         {
            return false;
         }
         return true;
      }
   }
}
