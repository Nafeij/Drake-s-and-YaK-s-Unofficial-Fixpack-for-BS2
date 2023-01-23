package engine.battle.behavior
{
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   
   public class Behavior extends EventDispatcher
   {
       
      
      public var entity:IBattleEntity;
      
      public var logger:ILogger;
      
      public function Behavior(param1:IBattleEntity)
      {
         super();
         this.entity = param1;
         this.logger = param1.logger;
      }
   }
}
