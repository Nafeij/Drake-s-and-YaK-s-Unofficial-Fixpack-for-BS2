package game.cfg
{
   import flash.events.Event;
   import tbs.srv.data.LobbyData;
   
   public class LobbyManagerEvent extends Event
   {
      
      public static const DATA:String = "LobbyManagerEvent.DATA";
      
      public static const CURRENT:String = "LobbyManagerEvent.CURRENT";
       
      
      public var data:LobbyData;
      
      public function LobbyManagerEvent(param1:String, param2:LobbyData)
      {
         super(param1);
         this.data = param2;
      }
   }
}
