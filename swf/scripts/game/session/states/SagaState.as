package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.saga.save.SagaSave;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.session.GameState;
   
   public class SagaState extends GameState
   {
       
      
      public function SagaState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc5_:SagaSave = null;
         var _loc7_:String = null;
         config.addEventListener(GameConfig.EVENT_SAGA,this.sagaHandler);
         var _loc1_:String = data.getValue(GameStateDataEnum.SAGA_URL);
         var _loc2_:String = data.getValue(GameStateDataEnum.HAPPENING_ID);
         var _loc3_:String = data.getValue(GameStateDataEnum.SAGA_SAVELOAD);
         var _loc4_:int = data.getValue(GameStateDataEnum.SAGA_SAVELOAD_PROFILE);
         data.removeValue(GameStateDataEnum.HAPPENING_ID);
         data.removeValue(GameStateDataEnum.SAGA_SAVELOAD);
         data.removeValue(GameStateDataEnum.SAGA_SAVELOAD_PROFILE);
         var _loc6_:int = _loc4_;
         if(_loc3_)
         {
            _loc2_ = null;
            _loc6_ = Math.max(0,_loc6_);
            _loc7_ = StringUtil.getBasename(_loc1_);
            if(_loc7_ && _loc7_.length > 2 && _loc7_.charAt(1) == ":")
            {
               _loc6_ = _loc7_.substr(0,1) as int;
               _loc7_ = _loc7_.substr(3);
            }
            _loc5_ = config.saveManager.getSave(_loc7_,_loc3_,_loc6_,false);
            if(_loc5_)
            {
               logger.info("SagaState found " + _loc5_);
            }
         }
         config.loadSaga(_loc1_,_loc2_,_loc5_,0,_loc6_);
      }
      
      private function sagaHandler(param1:Event) : void
      {
         phase = StatePhase.COMPLETED;
      }
   }
}
