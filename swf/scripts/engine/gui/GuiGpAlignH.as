package engine.gui
{
   import engine.core.util.Enum;
   
   public class GuiGpAlignH extends Enum
   {
      
      public static const W_LEFT:GuiGpAlignH = new GuiGpAlignH("W_LEFT",enumCtorKey,true,false,false);
      
      public static const W:GuiGpAlignH = new GuiGpAlignH("W",enumCtorKey,true,false,false);
      
      public static const W_RIGHT:GuiGpAlignH = new GuiGpAlignH("W_RIGHT",enumCtorKey,true,false,false);
      
      public static const C_LEFT:GuiGpAlignH = new GuiGpAlignH("C_LEFT",enumCtorKey,false,true,false);
      
      public static const C:GuiGpAlignH = new GuiGpAlignH("C",enumCtorKey,false,true,false);
      
      public static const C_RIGHT:GuiGpAlignH = new GuiGpAlignH("C_RIGHT",enumCtorKey,false,true,false);
      
      public static const E_LEFT:GuiGpAlignH = new GuiGpAlignH("E_LEFT",enumCtorKey,false,false,true);
      
      public static const E:GuiGpAlignH = new GuiGpAlignH("E",enumCtorKey,false,false,true);
      
      public static const E_RIGHT:GuiGpAlignH = new GuiGpAlignH("E_RIGHT",enumCtorKey,false,false,true);
       
      
      public var w:Boolean;
      
      public var c:Boolean;
      
      public var e:Boolean;
      
      public function GuiGpAlignH(param1:String, param2:Object, param3:Boolean, param4:Boolean, param5:Boolean)
      {
         super(param1,param2);
         this.w = param3;
         this.c = param4;
         this.e = param5;
      }
   }
}
