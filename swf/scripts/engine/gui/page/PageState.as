package engine.gui.page
{
   import engine.core.util.Enum;
   
   public class PageState extends Enum
   {
      
      public static const INIT:PageState = new PageState("INIT",enumCtorKey);
      
      public static const LOADING:PageState = new PageState("LOADING",enumCtorKey);
      
      public static const READY:PageState = new PageState("READY",enumCtorKey);
      
      public static const TERMINATED:PageState = new PageState("TERMINATED",enumCtorKey);
       
      
      public function PageState(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
