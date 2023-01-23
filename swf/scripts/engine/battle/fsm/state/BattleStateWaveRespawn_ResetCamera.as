package engine.battle.fsm.state
{
   import engine.battle.BattleCameraEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.wave.BattleWave;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.gp.GpBinder;
   import engine.core.logging.ILogger;
   
   public class BattleStateWaveRespawn_ResetCamera extends BaseBattleState
   {
       
      
      public function BattleStateWaveRespawn_ResetCamera(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         GpBinder.DISALLOW_INPUT_DURING_LOAD = true;
         var _loc1_:BattleBoard = battleFsm.board as BattleBoard;
         var _loc2_:BattleCameraEvent = new BattleCameraEvent(BattleCameraEvent.CAMERA_ZOOM_OUT_MAX,this.zoomOutCompleteHandler);
         _loc2_.duration = 2;
         _loc1_.dispatchEvent(_loc2_);
      }
      
      private function zoomOutCompleteHandler() : void
      {
         var _loc3_:BattleCameraEvent = null;
         var _loc1_:BattleBoard = battleFsm.board as BattleBoard;
         var _loc2_:BattleWave = _loc1_.waves.wave;
         _loc3_ = new BattleCameraEvent(BattleCameraEvent.CAMERA_SHOW_ALL_ENEMIES,this.onZoomToVillainsComplete);
         _loc3_.duration = 2;
         _loc3_.delay = 0.35;
         _loc1_.dispatchEvent(_loc3_);
      }
      
      private function onZoomToVillainsComplete() : void
      {
         GpBinder.DISALLOW_INPUT_DURING_LOAD = false;
         phase = StatePhase.COMPLETED;
      }
   }
}
