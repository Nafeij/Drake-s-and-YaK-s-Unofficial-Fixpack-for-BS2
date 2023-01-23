package engine.session
{
   import engine.core.util.Enum;
   
   public class AlertOrientationType extends Enum
   {
      
      public static const LEFT:AlertOrientationType = new AlertOrientationType("LEFT",enumCtorKey);
      
      public static const RIGHT:AlertOrientationType = new AlertOrientationType("RIGHT",enumCtorKey);
      
      public static const RIGHT_BOTTOM_VS:AlertOrientationType = new AlertOrientationType("RIGHT_BOTTOM_VS",enumCtorKey);
       
      
      public function AlertOrientationType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
