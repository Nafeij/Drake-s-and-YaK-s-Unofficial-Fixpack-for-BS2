package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class FlashState extends GameState
   {
       
      
      public var url:String;
      
      public var time:Number;
      
      public var msg:String;
      
      public var disableCloseButton:Boolean;
      
      public var lang:String;
      
      public function FlashState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         this.url = data.getValue(GameStateDataEnum.FLASH_URL);
         this.time = data.getValue(GameStateDataEnum.FLASH_TIME);
         this.msg = data.getValue(GameStateDataEnum.FLASH_MSG);
         this.lang = data.getValue(GameStateDataEnum.FLASH_LOCALE);
         this.disableCloseButton = data.getValue(GameStateDataEnum.DISABLE_PAGE_CLOSE_BUTTON);
      }
      
      public function handleFlashComplete() : void
      {
         phase = StatePhase.COMPLETED;
         if(config.saga)
         {
            config.saga.triggerFlashPageFinished(this.url);
         }
      }
   }
}
