package game.gui.page
{
   import flash.events.Event;
   
   public class BattleHudPageEvent extends Event
   {
      
      public static const BOARDCHANGE:String = "BattleHudPageEvent.BOARDCHANGE";
      
      public static const CHAT_ENABLED:String = "BattleHudPageEvent.CHAT_ENABLED";
       
      
      public function BattleHudPageEvent(param1:String)
      {
         super(param1,false,false);
      }
   }
}
