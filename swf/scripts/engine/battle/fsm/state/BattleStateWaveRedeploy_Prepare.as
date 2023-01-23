package engine.battle.fsm.state
{
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.battle.board.model.BattleBoard_SpawnConstants;
   import engine.battle.board.model.BattleDeployer_Saga;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.sim.IBattleParty;
   import engine.battle.wave.def.BattleWaveDef;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   
   public class BattleStateWaveRedeploy_Prepare extends BattleStateWave_Base implements IBattleStateWaveRedeploy_Prepare, IBattleStateUserDeploying
   {
       
      
      public var nextWave:BattleWaveDef;
      
      public function BattleStateWaveRedeploy_Prepare(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.nextWave = waves.previewNextWave();
         var _loc4_:String = this.discoverPlayerDeploymentId();
         data.setValue(BattleStateDataEnum.BATTLE_WAVE_DEPLOYMENT_ID,_loc4_);
         var _loc5_:String = this.discoverRespawnDeploymentId();
         data.setValue(BattleStateDataEnum.BATTLE_WAVE_RESPAWN_DEPLOYMENT_ID,_loc5_);
         this.showDeploymentId = _loc4_;
         this.showRespawnDeploymentId = _loc5_;
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         if(!this.nextWave)
         {
            logger.e("WAVE","No next wave for " + this);
            phase = StatePhase.FAILED;
            return;
         }
         battleFsm.turn = null;
         if(!this.nextWave.forceFight)
         {
            battleFsm.dispatchEvent(new BattleFsmEvent(BattleFsmEvent.WAVE_RESPITE));
         }
         this.moveEverybody();
         this.cleanupAuras();
         this.enableDeployment();
         board.redeploy.enabled = true;
         if(this.nextWave.forceFight)
         {
            this.chooseToFight();
         }
      }
      
      override protected function handleInterrupted() : void
      {
         board.redeploy.enabled = false;
      }
      
      private function discoverRespawnDeploymentId() : String
      {
         if(!this.nextWave)
         {
            return null;
         }
         var _loc1_:String = this.nextWave.bucket.deploymentId;
         if(!_loc1_)
         {
            _loc1_ = BattleBoard_SpawnConstants.DEFAULT_BUCKET_DEPLOYMENT_ID;
         }
         return _loc1_;
      }
      
      private function discoverPlayerDeploymentId() : String
      {
         if(!this.nextWave)
         {
            return null;
         }
         var _loc1_:String = this.nextWave.playerDeployment;
         if(!_loc1_)
         {
            _loc1_ = BattleStateDeploy.DEFAULT_PLAYER_DEPLOY_ID;
         }
         return _loc1_;
      }
      
      private function enableDeployment() : void
      {
         var _loc2_:Vector.<IBattleEntity> = null;
         var _loc3_:Vector.<String> = null;
         var _loc4_:int = 0;
         var _loc1_:IBattleParty = board.getPartyById("0");
         if(Boolean(_loc1_) && _loc1_.isPlayer)
         {
            _loc2_ = new Vector.<IBattleEntity>();
            _loc3_ = new Vector.<String>();
            _loc1_.getAllMembers(_loc2_);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc2_[_loc4_].deploymentFinalized = false;
               _loc3_.push(_loc2_[_loc4_].id);
               _loc4_++;
            }
            data.setValue(BattleStateDataEnum.BATTLE_WAVE_PREVIOUS_WAVE_PARTY,_loc3_);
         }
      }
      
      private function cleanupAuras() : void
      {
         var _loc1_:IBattleEntity = null;
         for each(_loc1_ in board.entities)
         {
            if(_loc1_.alive)
            {
               board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.REMOVE_AURAS,_loc1_));
            }
         }
      }
      
      private function moveEverybody() : void
      {
         var seenTip:int = 0;
         var p:IBattleParty = board.getPartyById("0");
         var bd:BattleDeployer_Saga = new BattleDeployer_Saga(board);
         var areas:BattleDeploymentAreas = board.def.getDeploymentAreasById(p.deployment,null);
         p.visit(function(param1:IBattleEntity):void
         {
         });
         p.changeDeployment(showDeploymentId);
         p.deployed = false;
         if(!board.getSaga().getVarBool("battle_hud_tips_disabled"))
         {
            seenTip = int(board.getSaga().getVarInt("tip_battle_wave_fight_or_flee"));
            if(seenTip < 1)
            {
               fsm.transitionTo(BattleStateWaveRedeploy_Prepare_Tutorial,data);
            }
         }
      }
      
      public function chooseToFlee() : void
      {
         board.redeploy.enabled = false;
         data.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,"0");
         fsm.transitionTo(BattleStateFinish,data);
      }
      
      public function chooseToFight() : void
      {
         fsm.transitionTo(BattleStateWaveRedeploy_Assemble,data);
      }
   }
}
