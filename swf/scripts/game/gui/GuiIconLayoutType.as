package game.gui
{
   import engine.core.util.Enum;
   
   public class GuiIconLayoutType extends Enum
   {
      
      public static const ACTUAL:GuiIconLayoutType = new GuiIconLayoutType("ACTUAL",enumCtorKey);
      
      public static const CENTER:GuiIconLayoutType = new GuiIconLayoutType("CENTER",enumCtorKey);
      
      public static const CENTER_FIT:GuiIconLayoutType = new GuiIconLayoutType("CENTER_FIT",enumCtorKey);
      
      public static const STRETCH:GuiIconLayoutType = new GuiIconLayoutType("STRETCH",enumCtorKey);
       
      
      public function GuiIconLayoutType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
