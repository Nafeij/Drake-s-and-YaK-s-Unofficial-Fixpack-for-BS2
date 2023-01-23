package engine.battle.fsm.state
{
   import engine.battle.BattleCameraEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.action.Action;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   
   public class BattleStateWaveRedeploy_Assemble extends BattleStateWave_Base implements IBattleStateUserDeploying
   {
       
      
      private var _party:Vector.<String>;
      
      public function BattleStateWaveRedeploy_Assemble(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
         var _loc4_:String = data.getValue(BattleStateDataEnum.BATTLE_WAVE_DEPLOYMENT_ID);
         var _loc5_:String = data.getValue(BattleStateDataEnum.BATTLE_WAVE_RESPAWN_DEPLOYMENT_ID);
         this.showDeploymentId = _loc4_;
         this.showRespawnDeploymentId = _loc5_;
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:BattleCameraEvent = null;
         super.handleEnteredState();
         board.redeploy.enabled = true;
         this._party = this.data.getValue(BattleStateDataEnum.BATTLE_WAVE_PREVIOUS_WAVE_PARTY) as Vector.<String>;
         if(!board.getSaga().getVarBool("battle_hud_tips_disabled"))
         {
            if(board.getSaga().getVarInt("tip_battle_wave_spawning_indicators") < 1)
            {
               _loc1_ = new BattleCameraEvent(BattleCameraEvent.CAMERA_PAN_TO_DEPLOYMENT_AREA,null);
               _loc1_.targetString = waves.previewNextWave().bucket.deploymentId;
               _loc1_.duration = 0.5;
               board.dispatchEvent(_loc1_);
               this.showTutorial();
            }
         }
      }
      
      private function showTutorial() : void
      {
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.HAPPENING;
         _loc1_.happeningId = "tutorial_waves";
         _loc1_.instant = false;
         var _loc2_:Action = board.getSaga().executeActionDef(_loc1_,null,null);
         board.getSaga().setVar("tip_battle_wave_spawning_indicators",1);
      }
      
      override protected function handleInterrupted() : void
      {
         board.redeploy.enabled = false;
         this.reenableGui();
      }
      
      override public function handleTransitioningOut() : void
      {
         super.handleTransitioningOut();
         this.reenableGui();
      }
      
      private function reenableGui() : void
      {
         BattleFsmConfig.guiWaveDeployEnabled = true;
         BattleFsmConfig.guiTilesEnabled = true;
      }
      
      public function redeployComplete() : void
      {
         var _loc2_:Vector.<IBattleEntity> = null;
         var _loc3_:int = 0;
         board.redeploy.enabled = false;
         this.countCharactersReplaced();
         var _loc1_:IBattleParty = board.getPartyById("0");
         if(_loc1_)
         {
            battleFsm.order.removeParty(_loc1_);
            battleFsm.order.addParty(_loc1_);
            _loc2_ = _loc1_.getAllMembers(null);
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(!_loc2_[_loc3_].mobile)
               {
                  battleFsm.order.removeEntity(_loc2_[_loc3_]);
               }
               _loc3_++;
            }
         }
         phase = StatePhase.COMPLETED;
      }
      
      private function countCharactersReplaced() : void
      {
         var _loc1_:IBattleParty = board.getPartyById("0");
         if(!this._party || !_loc1_)
         {
            return;
         }
         var _loc2_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc3_:int = 0;
         _loc1_.getAllMembers(_loc2_);
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(this._party.indexOf(_loc2_[_loc4_].id) < 0)
            {
               _loc3_++;
            }
            _loc4_++;
         }
         board.waves.wave.charsSwapped = _loc3_;
         this.data.removeValue(BattleStateDataEnum.BATTLE_WAVE_PREVIOUS_WAVE_PARTY);
         if(this._party)
         {
            this._party.length = 0;
            this._party = null;
         }
      }
   }
}
