package engine.saga.save
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   public class GameSaveSynchronizer extends EventDispatcher
   {
      
      public static const EVENT_PULL_COMPLETE:String = "GameSaveSynchronizer.PULL_COMPLETE";
      
      public static const EVENT_PULL_UPDATE:String = "GameSaveSynchronizer.PULL_UPDATE";
      
      public static const EVENT_PUSH_COMPLETE:String = "GameSaveSynchronizer.PUSH_COMPLETE";
      
      public static var PULL_ENABLED:Boolean = true;
      
      public static var MULTIPLE_PULL:Boolean = true;
      
      private static var _instance:GameSaveSynchronizer;
       
      
      public var hasPulled:Boolean = false;
      
      public var pull_complete:Boolean = false;
      
      public var logger:ILogger;
      
      public function GameSaveSynchronizer(param1:ILogger)
      {
         super();
         this.logger = param1;
         _instance = this;
      }
      
      public static function get instance() : GameSaveSynchronizer
      {
         return _instance;
      }
      
      public function get isBusy() : Boolean
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function saveGameAndPush(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         this.saveGame(param1,param2,param3);
         this.push();
      }
      
      public function deleteGameAndPush(param1:String, param2:String = null) : void
      {
         this.deleteFile(param1);
         if(param2)
         {
            this.deleteFile(param2);
         }
         this.push();
      }
      
      public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
      }
      
      public function deleteFile(param1:String) : void
      {
      }
      
      public function push() : void
      {
         dispatchEvent(new Event(EVENT_PUSH_COMPLETE));
      }
      
      public function pull() : void
      {
         this.hasPulled = true;
         dispatchEvent(new Event(EVENT_PULL_COMPLETE));
      }
      
      public function cancelPull() : void
      {
      }
      
      public function update(param1:int) : void
      {
      }
   }
}
