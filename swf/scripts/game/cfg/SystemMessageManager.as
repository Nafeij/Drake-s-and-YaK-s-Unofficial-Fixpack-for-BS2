package game.cfg
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SystemMessageManager extends EventDispatcher
   {
       
      
      private var _msg:String;
      
      private var locale:Locale;
      
      public function SystemMessageManager(param1:Locale)
      {
         super();
         this.locale = param1;
      }
      
      public function get msg() : String
      {
         return this._msg;
      }
      
      public function set msg(param1:String) : void
      {
         var _loc2_:String = this.locale.getLocalizer(LocaleCategory.GUI).translate(param1,true);
         if(_loc2_ != null)
         {
            param1 = _loc2_;
         }
         if(this._msg == param1)
         {
            return;
         }
         this._msg = param1;
         dispatchEvent(new Event(Event.CHANGE));
      }
   }
}
