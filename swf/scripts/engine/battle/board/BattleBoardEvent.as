package engine.battle.board
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import flash.events.Event;
   
   public class BattleBoardEvent extends Event
   {
      
      public static const TRIGGERS:String = "BattleBoardEvent.TRIGGERS";
      
      public static const SELECTED_TRIGGERS:String = "BattleBoardEvent.SELECTED_TRIGGERS";
      
      public static const ENABLED:String = "BattleBoardEvent.ENABLED";
      
      public static const PARTY:String = "BattleBoardEvent.ENABLED";
      
      public static const BOARDSETUP:String = "BattleBoardEvent.BOARDSETUP";
      
      public static const SELECT_TILE:String = "BattleBoardEvent.SELECT_TILE";
      
      public static const HOVER_TILE:String = "BattleBoardEvent.HOVER_TILE";
      
      public static const BOARD_ENTITY_ALIVE:String = "BattleBoardEvent.BOARD_ENTITY_ALIVE";
      
      public static const BOARD_ENTITY_BONUS_RENOWN:String = "BattleBoardEvent.BOARD_ENTITY_BONUS_RENOWN";
      
      public static const BOARD_TILE_CONFIGURATION:String = "BattleBoardEvent.BOARD_TILE_CONFIGURATION";
      
      public static const DEPLOYMENT_STARTED:String = "BattleBoardEvent.DEPLOYMENT_STARTED";
      
      public static const BOARD_ENTITY_ENABLED:String = "BattleBoardEvent.BOARD_ENTITY_ENABLED";
      
      public static const BOARD_ENTITY_KILLING_EFFECT:String = "BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT";
      
      public static const BOARD_ENTITY_DAMAGED:String = "BattleBoardEvent.BOARD_ENTITY_DAMAGED";
      
      public static const BOARD_ENTITY_FORCE_CAMERA_CENTER:String = "BattleBoardEvent.BOARD_ENTITY_FORCE_CAMERA_CENTER";
      
      public static const BOARD_ENTITY_MOVING:String = "BattleBoardEvent.BOARD_ENTITY_MOVING";
      
      public static const BOARD_ENTITY_TILE_CHANGED:String = "BattleBoardEvent.BOARD_ENTITY_TILE_CHANGED";
      
      public static const BOARD_ENTITY_TILE_TRIGGER:String = "BattleBoardEvent.BOARD_ENTITY_TILE_TRIGGER";
      
      public static const BOARD_ENTITY_COLLIDED:String = "BattleBoardEvent.BOARD_ENTITY_COLLIDED";
      
      public static const OBJECTIVES:String = "BattleBoardEvent.OBJECTIVES";
      
      public static const BOARD_SURVIVAL_DIED:String = "BattleBoardEvent.BOARD_SURVIVAL_DIED";
      
      public static const BOARD_SURVIVAL_ITEM:String = "BattleBoardEvent.BOARD_SURVIVAL_ITEM";
      
      public static const BOARD_ENTITY_USING_START:String = "BattleBoardEvent.BOARD_ENTITY_USING_START";
      
      public static const BOARD_ENTITY_USING_END:String = "BattleBoardEvent.BOARD_ENTITY_USING_END";
      
      public static const BOARD_PARTY_CHANGED:String = "BattleBoardEvent.BOARD_PARTY_CHANGED";
      
      public static const WALKABLE:String = "BattleBoardEvent.WALKABLE";
      
      public static const CAMERA_FOLLOW:String = "BattleEntityEvent.CAMERA_FOLLOW";
      
      public static const CAMERA_UNFOLLOW:String = "BattleEntityEvent.CAMERA_UNFOLLOW";
       
      
      public var entity:IBattleEntity;
      
      public var other:IBattleEntity;
      
      public function BattleBoardEvent(param1:String, param2:IBattleEntity = null, param3:IBattleEntity = null)
      {
         super(param1,false,false);
         this.entity = param2;
         this.other = param3;
      }
      
      public function get board() : IBattleBoard
      {
         return target as IBattleBoard;
      }
   }
}
