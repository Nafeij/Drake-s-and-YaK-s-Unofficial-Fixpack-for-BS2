package engine.battle.entity.model
{
   import engine.battle.board.model.IBattleEntity;
   import flash.events.Event;
   
   public class BattleEntityEvent extends Event
   {
      
      public static const ADDED:String = "BattleEntityEvent.ADDED";
      
      public static const REMOVED:String = "BattleEntityEvent.REMOVED";
      
      public static const REMOVING:String = "BattleEntityEvent.REMOVING";
      
      public static const MOVED:String = "BattleEntityEvent.MOVED";
      
      public static const TILE_CHANGED:String = "BattleEntityEvent.TILE_CHANGED";
      
      public static const MOVE_FINISHING:String = "BattleEntityEvent.MOVE_FINISHING";
      
      public static const MOVE_EXECUTING:String = "BattleEntityEvent.MOVE_EXECUTING";
      
      public static const SELECTED:String = "BattleEntityEvent.SELECTED";
      
      public static const TARGETED:String = "BattleEntityEvent.TARGETED";
      
      public static const ATTACK_TARGET:String = "BattleEntityEvent.ATTACK_TARGET";
      
      public static const GO_ANIMATION:String = "BattleEntityEvent.GO_ANIMATION";
      
      public static const ENOUGH_KILLS_TO_PROMOTE_VFX:String = "BattleEntityEvent.ENOUGH_KILLS_TO_PROMOTE_VFX";
      
      public static const DAMAGE_FLAG:String = "BattleEntityEvent.DAMAGE_FLAG";
      
      public static const FLY_TEXT:String = "BattleEntityEvent.FLY_TEXT";
      
      public static const TRIGGERING:String = "BattleEntityEvent.TRIGGERING";
      
      public static const FACING:String = "BattleEntityEvent.FACING";
      
      public static const ALIVE:String = "BattleEntityEvent.ALIVE";
      
      public static const BONUS_RENOWN:String = "BattleEntityEvent.BONUS_RENOWN";
      
      public static const BATTLE_INFO_FLAG_VISIBLE:String = "BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE";
      
      public static const BATTLE_DAMAGE_FLAG_VISIBLE:String = "BattleEntityEvent.BATTLE_DAMAGE_FLAG_VISIBLE";
      
      public static const BATTLE_DAMAGE_FLAG_VALUE:String = "BattleEntityEvent.BATTLE_DAMAGE_FLAG_VALUE";
      
      public static const VISIBLE:String = "BattleEntityEvent.VISIBLE";
      
      public static const FLASH_VISIBLE:String = "BattleEntityEvent.FLASH_VISIBLE";
      
      public static const BATTLE_HUD_INDICATOR_VISIBLE:String = "BattleEntityEvent.BATTLE_HUD_INDICATOR_VISIBLE";
      
      public static const COLLIDABLE:String = "BattleEntityEvent.COLLIDABLE";
      
      public static const ENABLED:String = "BattleEntityEvent.ENABLED";
      
      public static const DEPLOYMENT_READY:String = "BattleEntityEvent.DEPLOYMENT_READY";
      
      public static const MISSED:String = "BattleEntityEvent.MISSED";
      
      public static const KILL_STOP:String = "BattleEntityEvent.KILL_STOP";
      
      public static const TWICEBORN:String = "BattleEntityEvent.TWICEBORN";
      
      public static const RESISTED:String = "BattleEntityEvent.RESISTED";
      
      public static const DIVERTED:String = "BattleEntityEvent.DIVERTED";
      
      public static const DODGE:String = "BattleEntityEvent.DODGE";
      
      public static const CRIT:String = "BattleEntityEvent.CRIT";
      
      public static const ABSORBING:String = "BattleEntityEvent.ABSORBING";
      
      public static const KILLING_EFFECT:String = "BattleEntityEvent.KILLING_EFFECT";
      
      public static const DAMAGED:String = "BattleEntityEvent.DAMAGED";
      
      public static const FORCE_CAMERA_CENTER:String = "BattleEntityEvent.FORCE_CAMERA_CENTER";
      
      public static const HOVERING:String = "BattleEntityEvent.HOVERING";
      
      public static const CAMERA_CENTER:String = "BattleEntityEvent.CAMERA_CENTER";
      
      public static const COLLISION:String = "BattleEntityEvent.COLLISION";
      
      public static const ACTIVE:String = "BattleEntityEvent.ACTIVE";
      
      public static const IMMORTAL_STOPPED:String = "BattleEntityEvent.IMMORTAL_STOPPED";
      
      public static const SUBMERGED:String = "BattleEntityEvent.SUBMERGED";
      
      public static const TELEPORTING:String = "BattleEntityEvent.TELEPORTING";
      
      public static const END_TURN_IF_NO_ENEMIES_REMAIN:String = "BattleEntityEvent.END_TURN_IF_NO_ENEMIES_REMAIN";
      
      public static const REMOVE_AURAS:String = "BattleEntityEvent.REMOVE_AURAS";
       
      
      public var entity:IBattleEntity;
      
      public var other:IBattleEntity;
      
      public function BattleEntityEvent(param1:String, param2:IBattleEntity, param3:IBattleEntity = null)
      {
         super(param1,false,false);
         this.entity = param2;
         this.other = param3;
      }
   }
}
