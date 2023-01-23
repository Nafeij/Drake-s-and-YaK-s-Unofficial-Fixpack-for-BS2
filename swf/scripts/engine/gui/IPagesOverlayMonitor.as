package engine.gui
{
   import flash.events.IEventDispatcher;
   
   public interface IPagesOverlayMonitor extends IEventDispatcher
   {
       
      
      function get isPagesOverlayActive() : Boolean;
   }
}
