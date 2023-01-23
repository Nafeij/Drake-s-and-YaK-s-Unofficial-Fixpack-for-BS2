package engine.gui
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class PagesOverlayMonitor extends EventDispatcher implements IPagesOverlayMonitor
   {
       
      
      private var _isPagesOverlayActive:Boolean;
      
      public function PagesOverlayMonitor()
      {
         super();
      }
      
      public function get isPagesOverlayActive() : Boolean
      {
         return this._isPagesOverlayActive;
      }
      
      public function set isPagesOverlayActive(param1:Boolean) : void
      {
         if(this._isPagesOverlayActive == param1)
         {
            return;
         }
         this._isPagesOverlayActive = param1;
         dispatchEvent(new Event(Event.CHANGE));
      }
   }
}
