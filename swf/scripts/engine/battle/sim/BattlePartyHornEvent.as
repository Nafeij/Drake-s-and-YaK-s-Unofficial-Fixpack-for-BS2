package engine.battle.sim
{
   import flash.events.Event;
   
   public class BattlePartyHornEvent extends Event
   {
      
      public static const HORN:String = "BattlePartyEvent.HORN";
       
      
      public var old:int;
      
      public function BattlePartyHornEvent(param1:String, param2:int)
      {
         super(param1);
         this.old = param2;
      }
      
      public function get party() : IBattleParty
      {
         return target as IBattleParty;
      }
   }
}
