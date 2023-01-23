package engine.battle.ability.event
{
   import engine.battle.board.model.IBattleEntity;
   import flash.events.Event;
   
   public class TargetAnimEvent extends Event
   {
      
      public static const EVENT:String = "TargetAnimEvent.EVENT";
       
      
      public var animId:String;
      
      public var eventId:String;
      
      public function TargetAnimEvent(param1:String, param2:String, param3:String)
      {
         super(param1);
         this.animId = param2;
         this.eventId = param3;
      }
      
      public function get entity() : IBattleEntity
      {
         return target as IBattleEntity;
      }
   }
}
