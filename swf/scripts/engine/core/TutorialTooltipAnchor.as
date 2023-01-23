package engine.core
{
   import engine.core.util.Enum;
   
   public class TutorialTooltipAnchor extends Enum
   {
      
      public static const LEFT:TutorialTooltipAnchor = new TutorialTooltipAnchor("LEFT",enumCtorKey);
      
      public static const RIGHT:TutorialTooltipAnchor = new TutorialTooltipAnchor("RIGHT",enumCtorKey);
      
      public static const TOP:TutorialTooltipAnchor = new TutorialTooltipAnchor("TOP",enumCtorKey);
      
      public static const BOTTOM:TutorialTooltipAnchor = new TutorialTooltipAnchor("BOTTOM",enumCtorKey);
      
      public static const NONE:TutorialTooltipAnchor = new TutorialTooltipAnchor("NONE",enumCtorKey);
      
      public static const CENTER:TutorialTooltipAnchor = new TutorialTooltipAnchor("CENTER",enumCtorKey);
       
      
      public function TutorialTooltipAnchor(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
