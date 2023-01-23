package game.gui
{
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.wave.BattleWaves;
   import engine.core.fsm.FsmEvent;
   import flash.events.Event;
   import game.gui.battle.IGuiWaveTurnCounter;
   import game.gui.page.BattleHudPage;
   
   public class WaveTurnCounterHelper
   {
       
      
      private var _waves:BattleWaves;
      
      private var _fsm:IBattleFsm;
      
      private var _waveTurnCounter:IGuiWaveTurnCounter;
      
      public function WaveTurnCounterHelper(param1:BattleWaves, param2:BattleHudPage)
      {
         super();
         this._waves = param1;
         this._waveTurnCounter = param2.bhpLoadHelper.guihud.initiative.waveTurnCounter;
         this._waveTurnCounter.visible = false;
         this._fsm = param2.fsm;
         this.initListeners();
      }
      
      public function get waveTurnCounter() : IGuiWaveTurnCounter
      {
         return this._waveTurnCounter;
      }
      
      private function initListeners() : void
      {
         if(this._waves)
         {
            this._waves.addEventListener(BattleWaves.TURNS_REMAINING_UPDATED,this.turnsRemainingUpdateHandler);
            this._fsm.addEventListener(FsmEvent.COMPLETED,this.deploymentCompleteHandler);
         }
      }
      
      public function cleanup() : void
      {
         if(this._waves)
         {
            this._waves.removeEventListener(BattleWaves.TURNS_REMAINING_UPDATED,this.turnsRemainingUpdateHandler);
            this._fsm.removeEventListener(FsmEvent.COMPLETED,this.deploymentCompleteHandler);
         }
      }
      
      private function turnsRemainingUpdateHandler(param1:Event) : void
      {
         if(Boolean(this._waveTurnCounter) && Boolean(this._waves))
         {
            this._waveTurnCounter.SetTurnCount(this._waves.wave);
         }
      }
      
      private function deploymentCompleteHandler(param1:FsmEvent) : void
      {
         if(this._waveTurnCounter && this._waves && this._fsm && this._fsm.current is BattleStateDeploy)
         {
            this._waveTurnCounter.SetTurnCount(this._waves.wave);
         }
      }
   }
}
