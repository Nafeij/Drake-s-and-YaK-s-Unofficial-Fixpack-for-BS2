package game.session
{
   import flash.events.Event;
   
   public class GameFsmEvent extends Event
   {
      
      public static const PLAYERS_ONLINE:String = "GameFsmEvent.PLAYERS_ONLINE";
       
      
      public function GameFsmEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
