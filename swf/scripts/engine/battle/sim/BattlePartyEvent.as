package engine.battle.sim
{
   import flash.events.Event;
   
   public class BattlePartyEvent extends Event
   {
      
      public static const DEPLOYED:String = "BattlePartyEvent.DEPLOYED";
      
      public static const TRAUMA:String = "BattlePartyEvent.TRAUMA";
       
      
      public function BattlePartyEvent(param1:String)
      {
         super(param1);
      }
      
      public function get party() : IBattleParty
      {
         return target as IBattleParty;
      }
   }
}
