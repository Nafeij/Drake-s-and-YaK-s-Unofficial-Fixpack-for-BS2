package engine.core.http
{
   import engine.core.util.Enum;
   
   public class HttpRequestMethod extends Enum
   {
      
      public static const POST:HttpRequestMethod = new HttpRequestMethod("POST",enumCtorKey);
      
      public static const GET:HttpRequestMethod = new HttpRequestMethod("GET",enumCtorKey);
       
      
      public function HttpRequestMethod(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
