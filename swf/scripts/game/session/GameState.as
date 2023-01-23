package game.session
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.State;
   import engine.core.fsm.StateData;
   import engine.core.http.HttpCommunicator;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import flash.events.Event;
   import game.cfg.GameConfig;
   
   public class GameState extends State
   {
      
      public static var EVENT_PAGE_READY:String = "GameState.EVENT_PAGE_READY";
       
      
      public var pageReady:Boolean;
      
      public function GameState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      public function get gameFsm() : GameFsm
      {
         return fsm as GameFsm;
      }
      
      public function get credentials() : Credentials
      {
         return this.gameFsm.credentials;
      }
      
      public function get communicator() : HttpCommunicator
      {
         return this.gameFsm.communicator;
      }
      
      public function get config() : GameConfig
      {
         return this.gameFsm.config;
      }
      
      public function handlePageReady() : void
      {
         this.pageReady = true;
         dispatchEvent(new Event(EVENT_PAGE_READY));
      }
   }
}
