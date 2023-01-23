package engine.gui
{
   import engine.core.util.Enum;
   
   public class GuiGpAlignV extends Enum
   {
      
      public static const N_UP:GuiGpAlignV = new GuiGpAlignV("N_UP",enumCtorKey,true,false,false);
      
      public static const N:GuiGpAlignV = new GuiGpAlignV("TOP",enumCtorKey,true,false,false);
      
      public static const N_DOWN:GuiGpAlignV = new GuiGpAlignV("N_DOWN",enumCtorKey,true,false,false);
      
      public static const C_UP:GuiGpAlignV = new GuiGpAlignV("C_UP",enumCtorKey,false,true,false);
      
      public static const C:GuiGpAlignV = new GuiGpAlignV("C",enumCtorKey,false,true,false);
      
      public static const C_DOWN:GuiGpAlignV = new GuiGpAlignV("C_DOWN",enumCtorKey,false,true,false);
      
      public static const S_UP:GuiGpAlignV = new GuiGpAlignV("S_UP",enumCtorKey,false,false,true);
      
      public static const S:GuiGpAlignV = new GuiGpAlignV("S",enumCtorKey,false,false,true);
      
      public static const S_DOWN:GuiGpAlignV = new GuiGpAlignV("S_DOWN",enumCtorKey,false,false,true);
       
      
      public var n:Boolean;
      
      public var c:Boolean;
      
      public var s:Boolean;
      
      public function GuiGpAlignV(param1:String, param2:Object, param3:Boolean, param4:Boolean, param5:Boolean)
      {
         super(param1,param2);
         this.n = param3;
         this.c = param4;
         this.s = param5;
      }
   }
}
