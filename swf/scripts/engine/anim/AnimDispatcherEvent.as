package engine.anim
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import flash.events.Event;
   
   public class AnimDispatcherEvent extends Event
   {
      
      public static const ANIM_EVENT:String = "AnimDispatcherEvent.ANIM_EVENT";
      
      public static const SOUND_ERROR:String = "AnimDispatcherEvent.SOUND_ERROR";
      
      public static const BATTLE_TRAUMA:String = "AnimDispatcherEvent.BATTLE_TRAUMA";
      
      public static const FRONTIFY_GUI:String = "AnimDispatcherEvent.FRONTIFY_GUI";
       
      
      public var entity:IBattleEntity;
      
      public var id:String;
      
      public var animId:String;
      
      public var eventId:String;
      
      public var value:Number = 0;
      
      public var winning:String;
      
      public var musicdef:String;
      
      public function AnimDispatcherEvent(param1:String, param2:IBattleEntity, param3:String, param4:String, param5:String, param6:String = null, param7:Number = 0, param8:String = null)
      {
         super(param1,false,false);
         this.entity = param2;
         this.id = param3;
         this.animId = param4;
         this.eventId = param5;
         this.value = param7;
         this.winning = param6;
         this.musicdef = param8;
      }
      
      public function get board() : IBattleBoard
      {
         return target as IBattleBoard;
      }
   }
}
