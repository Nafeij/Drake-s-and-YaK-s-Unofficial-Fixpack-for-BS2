package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.core.fsm.StateData;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.saga.action.Action;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   
   public class BattleStateWaveRedeploy_Prepare_Tutorial extends BattleStateWave_Base implements IBattleStateWaveRedeploy_Prepare, IBattleStateUserDeploying
   {
       
      
      public function BattleStateWaveRedeploy_Prepare_Tutorial(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
         var _loc4_:String = data.getValue(BattleStateDataEnum.BATTLE_WAVE_DEPLOYMENT_ID);
         var _loc5_:String = data.getValue(BattleStateDataEnum.BATTLE_WAVE_RESPAWN_DEPLOYMENT_ID);
         this.showDeploymentId = _loc4_;
         this.showRespawnDeploymentId = _loc5_;
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         board.getSaga().performTutorialRemoveAll("Enter State BattleStateWaveRedeploy_Prepare_Tutorial");
         board.redeploy.enabled = true;
         BattleFsmConfig.guiWaveDeployEnabled = false;
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.TUTORIAL_POPUP;
         _loc1_.msg = board.scene.context.locale.translate(LocaleCategory.TUTORIAL,"tut_wave_battle_4_body");
         _loc1_.param = "arrow";
         _loc1_.location = "BOTTOM:NONE";
         _loc1_.anchor = "ScenePage|BattleHudPage|assets.battle_hud|waveRedeployTop|deployment_outer";
         _loc1_.varvalue = 60;
         var _loc2_:Action = board.getSaga().executeActionDef(_loc1_,null,null);
         board.getSaga().setVar("tip_battle_wave_fight_or_flee",1);
      }
      
      override protected function handleInterrupted() : void
      {
         board.redeploy.enabled = false;
      }
      
      public function chooseToFlee() : void
      {
         board.redeploy.enabled = false;
         data.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,"0");
         fsm.transitionTo(BattleStateFinish,data);
      }
      
      public function chooseToFight() : void
      {
         BattleFsmConfig.guiWaveDeployEnabled = true;
         fsm.transitionTo(BattleStateWaveRedeploy_Assemble,data);
      }
   }
}
