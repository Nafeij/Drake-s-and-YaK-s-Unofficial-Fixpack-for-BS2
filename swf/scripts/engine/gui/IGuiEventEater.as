package engine.gui
{
   import flash.events.MouseEvent;
   
   public interface IGuiEventEater
   {
       
      
      function eatEvent(param1:MouseEvent) : void;
      
      function isEventEaten(param1:MouseEvent) : Boolean;
   }
}
