package engine.battle.fsm
{
   import engine.battle.board.model.IBattleEntity;
   import flash.events.Event;
   
   public class BattleTurnOrderEvent extends Event
   {
      
      public static const CHANGED:String = "BattleTurnOrderEvent.CHANGED";
      
      public static const CURRENT:String = "BattleTurnOrderEvent.CURRENT";
      
      public static const PILLAGE:String = "BattleTurnOrderEvent.PILLAGE";
      
      public static const REFRESH_INITIATIVE:String = "BattleTurnOrderEvent.REFRESH_INITIATIVE";
      
      public static const PLAY_FORGE_AHEAD_VFX:String = "BattleTurnOrderEvent.PLAY_FORGE_AHEAD_VFX";
      
      public static const PLAY_FORGE_AHEAD_PILLAGE_VFX:String = "BattleTurnOrderEvent.PLAY_FORGE_AHEAD_PILLAGE_VFX";
      
      public static const PLAY_INSULT_VFX:String = "BattleTurnOrderEvent.PLAY_INSULT_VFX";
       
      
      public var ent:IBattleEntity;
      
      public function BattleTurnOrderEvent(param1:String, param2:IBattleEntity = null)
      {
         super(param1);
         this.ent = param2;
      }
   }
}
