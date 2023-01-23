package engine.core
{
   import engine.core.util.Enum;
   
   public class TutorialTooltipAlign extends Enum
   {
      
      public static const LEFT:TutorialTooltipAlign = new TutorialTooltipAlign("LEFT",enumCtorKey);
      
      public static const RIGHT:TutorialTooltipAlign = new TutorialTooltipAlign("RIGHT",enumCtorKey);
      
      public static const TOP:TutorialTooltipAlign = new TutorialTooltipAlign("TOP",enumCtorKey);
      
      public static const BOTTOM:TutorialTooltipAlign = new TutorialTooltipAlign("BOTTOM",enumCtorKey);
      
      public static const NONE:TutorialTooltipAlign = new TutorialTooltipAlign("NONE",enumCtorKey);
      
      public static const CENTER:TutorialTooltipAlign = new TutorialTooltipAlign("CENTER",enumCtorKey);
       
      
      public function TutorialTooltipAlign(param1:String, param2:Object)
      {
         super(param1,param2);
      }
      
      public function get oppositeAnchor() : TutorialTooltipAnchor
      {
         switch(this)
         {
            case LEFT:
               return TutorialTooltipAnchor.LEFT;
            case RIGHT:
               return TutorialTooltipAnchor.RIGHT;
            case TOP:
               return TutorialTooltipAnchor.TOP;
            case BOTTOM:
               return TutorialTooltipAnchor.BOTTOM;
            default:
               return TutorialTooltipAnchor.CENTER;
         }
      }
   }
}
