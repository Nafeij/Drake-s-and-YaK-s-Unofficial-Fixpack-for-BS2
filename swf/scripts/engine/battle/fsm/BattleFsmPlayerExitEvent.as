package engine.battle.fsm
{
   import flash.events.Event;
   
   public class BattleFsmPlayerExitEvent extends Event
   {
      
      public static const PLAYER_EXIT:String = "BattleFsmPlayerExitEvent.PLAYER_EXIT";
       
      
      public var id:int;
      
      public var display_name:String;
      
      public function BattleFsmPlayerExitEvent(param1:String, param2:int, param3:String)
      {
         super(param1);
         this.id = param2;
         this.display_name = param3;
      }
   }
}
