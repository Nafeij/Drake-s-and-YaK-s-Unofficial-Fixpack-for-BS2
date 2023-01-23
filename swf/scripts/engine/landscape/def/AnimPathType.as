package engine.landscape.def
{
   import engine.core.util.Enum;
   
   public class AnimPathType extends Enum
   {
      
      public static const WAIT:AnimPathType = new AnimPathType("WAIT",enumCtorKey);
      
      public static const MOVE:AnimPathType = new AnimPathType("MOVE",enumCtorKey);
      
      public static const HIDE:AnimPathType = new AnimPathType("HIDE",enumCtorKey);
      
      public static const SCALE:AnimPathType = new AnimPathType("SCALE",enumCtorKey);
      
      public static const PLAYING:AnimPathType = new AnimPathType("PLAYING",enumCtorKey);
      
      public static const ALPHA:AnimPathType = new AnimPathType("ALPHA",enumCtorKey);
      
      public static const FLOAT:AnimPathType = new AnimPathType("FLOAT",enumCtorKey);
      
      public static const ROTATE:AnimPathType = new AnimPathType("ROTATE",enumCtorKey);
      
      public static const WOBBLE:AnimPathType = new AnimPathType("WOBBLE",enumCtorKey);
      
      public static const SOUND:AnimPathType = new AnimPathType("SOUND",enumCtorKey);
       
      
      public function AnimPathType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
