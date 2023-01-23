package engine.landscape.view
{
   import flash.events.Event;
   
   public class LandscapeViewEvent extends Event
   {
      
      public static const EVENT_SHOW_ANCHORS:String = "LandscapeView.EVENT_SHOW_ANCHORS";
      
      public static const EVENT_SHOW_ANIMS:String = "LandscapeView.EVENT_SHOW_ANIMS";
      
      public static const EVENT_SHOW_PATHS:String = "LandscapeView.EVENT_SHOW_PATHS";
      
      public static const EVENT_CLICKABLES_CHANGED:String = "LandscapeView.EVENT_CLICKABLES_CHANGED";
       
      
      public function LandscapeViewEvent(param1:String)
      {
         super(param1);
      }
   }
}
