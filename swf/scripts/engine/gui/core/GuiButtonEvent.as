package engine.gui.core
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuiButtonEvent extends Event
   {
      
      public static const CLICKED:String = "GuiButtonEvent.CLICKED";
      
      public static const ROLLOVER:String = "GuiButtonEvent.ROLLOVER";
       
      
      public var orig:MouseEvent;
      
      public function GuiButtonEvent(param1:String, param2:MouseEvent)
      {
         super(param1);
         this.orig = param2;
      }
   }
}
