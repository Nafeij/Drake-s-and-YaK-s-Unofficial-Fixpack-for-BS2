package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.achievement.AchievementDef;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleScenario;
   import engine.battle.board.model.BattleScenarioDef;
   import engine.battle.board.model.BattleSnapshot;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import engine.battle.sim.IBattleParty;
   import engine.core.analytic.Ga;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Caravan;
   import engine.saga.IBattleTutorial;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaLegend;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableType;
   import engine.scene.model.SceneLoaderBattleInfo;
   import flash.utils.getTimer;
   
   public class Action_Battle extends Action
   {
      
      public static var USE_DANGER_BONUS_COMBATANTS:Boolean = true;
      
      public static var FINISH_SAGA_DELAY:Number = 3;
      
      public static var ASSEMBLE_SKIP:Boolean = false;
       
      
      public var skipFinished:Boolean;
      
      private var tut:IBattleTutorial;
      
      public var skipResolution:Boolean;
      
      public var skipRewards:Boolean;
      
      public var snap:BattleSnapshot;
      
      public var board:BattleBoard;
      
      private var fsm:BattleFsm;
      
      private var _sceneUniqueId:int;
      
      private var _exitedUniqueId:int = 0;
      
      private var _hasFinished:Boolean;
      
      public function Action_Battle(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
         if(!param1.scene)
         {
            throw new ArgumentError("No scene for battle");
         }
      }
      
      public static function computeDanger(param1:Saga, param2:String) : int
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         _loc3_ += param1.getVar(SagaVar.VAR_DANGER,VariableType.INTEGER).asInteger;
         if(USE_DANGER_BONUS_COMBATANTS)
         {
            _loc5_ = param1.getVar(SagaVar.VAR_DANGER_BONUS_COMBATANTS,VariableType.INTEGER).asInteger;
            if(_loc5_)
            {
               param1.logger.info("   " + param2 + " danger caravan combatants bonus " + StringUtil.numberWithSign(_loc5_,0));
               _loc3_ += _loc5_;
            }
         }
         var _loc4_:int = param1.getDifficultyDanger();
         if(_loc4_)
         {
            param1.logger.info("   " + param2 + " danger difficulty bonus " + StringUtil.numberWithSign(_loc4_,0));
            _loc3_ += _loc4_;
         }
         return _loc3_;
      }
      
      override protected function handleStarted() : void
      {
         if(!saga || !saga.caravan)
         {
            throw new ArgumentError("No caravan active on saga.  Caravan required.");
         }
         if(def.battle_snap)
         {
            this.snap = saga.getBattleSnap(def.battle_snap);
            if(!this.snap)
            {
               throw new ArgumentError("No such battle snap [" + id + "]");
            }
         }
         this.skipFinished = def.battle_skip_finished;
         if(def.restore_scene && !def.instant)
         {
            this.sceneStateSave();
         }
         var _loc1_:Caravan = saga.caravan;
         var _loc2_:SagaLegend = !!_loc1_ ? _loc1_._legend : null;
         var _loc3_:IPartyDef = !!_loc2_ ? _loc2_.party : null;
         if(def.assemble_heroes)
         {
            if(!Action_Battle.ASSEMBLE_SKIP || !_loc3_ || _loc3_.numMembers == 0)
            {
               this.launchAssembleHeroes();
               return;
            }
         }
         this.triggerAssembleHeroesComplete();
      }
      
      override protected function handleEnded() : void
      {
         TweenMax.killDelayedCallsTo(this.handleDelayedBattleFinished);
      }
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         var _loc3_:Number = NaN;
         logger.i("ABAT","----  handleTriggerSceneLoaded " + param1 + " " + param2 + " vs. " + this._sceneUniqueId);
         if(param1 == def.scene)
         {
            this._sceneUniqueId = param2;
            this.board = saga.getBattleBoard();
            this.fsm = !!this.board ? this.board.fsm as BattleFsm : null;
            _loc3_ = (getTimer() - startTime) / 1000;
            logger.info("Action_Battle Load time " + this + " " + _loc3_.toFixed(2) + " s");
            if(this._exitedUniqueId == param2)
            {
               this.doTheBattleExit();
            }
            if(def.instant)
            {
               end();
            }
         }
      }
      
      override public function triggerSceneExit(param1:String, param2:int) : void
      {
         logger.i("ABAT","----  triggerSceneExit " + param1 + " " + param2 + " vs. " + this._sceneUniqueId);
         if(param1 == def.scene)
         {
            if(param2 != this._sceneUniqueId)
            {
               this._exitedUniqueId = param2;
               logger.i("ABAT","----  triggerSceneExit MISMATCHED IDS " + param2 + " vs. " + this._sceneUniqueId);
               return;
            }
            this.doTheBattleExit();
         }
      }
      
      private function handleDelayedBattleFinished() : void
      {
         logger.i("ABAT","----  handleDelayedBattleFinished " + this.skipResolution + " " + this.fin);
         if(this.skipResolution)
         {
            this.triggerBattleResolutionClosed();
         }
         else
         {
            saga.performBattleResolution(this.fin,false);
         }
      }
      
      public function get fin() : BattleFinishedData
      {
         return !!this.fsm ? this.fsm._finishedData : null;
      }
      
      override public function triggerBattleFinished(param1:String) : void
      {
         var _loc2_:BattleScenario = null;
         var _loc3_:* = false;
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:IBattleParty = null;
         var _loc9_:Number = NaN;
         var _loc10_:BattleRewardData = null;
         var _loc11_:AchievementDef = null;
         logger.i("ABAT","----  triggerBattleFinished " + param1 + " " + this.fin);
         if(param1 != def.scene)
         {
            return;
         }
         if(this.fin)
         {
            _loc3_ = this.fin.victoriousTeam == "0";
            _loc4_ = StringUtil.getBasename(param1);
            _loc5_ = !!happening ? happening.def.id : "???";
            _loc4_ += "#" + _loc5_;
            if(_loc2_)
            {
               _loc4_ += ":" + _loc2_.def.id;
            }
            if(this.board && this.board.fsm && this.board.fsm.respawnedBattle)
            {
               _loc4_ += "!respawned";
            }
            _loc6_ = saga.difficultyId;
            _loc7_ = _loc3_ ? 1 : 0;
            if(saga.isSurvival)
            {
               _loc4_ = StringUtil.padLeft(saga.survivalProgress.toString(),"0",2) + "__" + _loc4_;
               Ga.normal("survival_battle",_loc6_,_loc4_,_loc7_);
            }
            else
            {
               Ga.normal("battle_win",_loc6_,_loc4_,_loc7_);
            }
            if(this.board)
            {
               if(Boolean(this.board.fsm) && Boolean(this.board.fsm.unitsInjured))
               {
                  if(saga.isSurvival)
                  {
                     Ga.normal("survival_deaths",_loc6_,_loc4_,this.board.fsm.unitsInjured.length);
                  }
                  else
                  {
                     Ga.normal("battle_injuries",_loc6_,_loc4_,this.board.fsm.unitsInjured.length);
                  }
                  if(this.board.waves)
                  {
                     this.board.waves.reportWaveAnalytics(this.board.waves.wave);
                     Ga.normal("battle_waves_defeated",_loc6_,_loc4_,this.board.waves.waveNumber - 1);
                  }
               }
               _loc8_ = this.board.getPartyById("0");
               _loc9_ = 0;
               if(_loc8_ && _loc8_.numMembers && _loc3_)
               {
                  _loc9_ = _loc8_.numAlive / _loc8_.numMembers;
               }
               if(saga.isSurvival)
               {
                  Ga.normal("survival_alive",_loc6_,_loc4_,_loc9_);
                  Ga.normal("survival_elapsed",_loc6_,_loc4_,saga.survivalElapsedSed);
               }
               else
               {
                  Ga.normal("battle_alive",_loc6_,_loc4_,_loc9_);
               }
            }
         }
         if(this.skipFinished)
         {
            logger.info("SKIP FINISHED for " + this);
            return;
         }
         _loc2_ = !!this.board ? this.board._scenario : null;
         if(_loc2_)
         {
            if(_loc2_.complete)
            {
               if(!this.fin)
               {
                  logger.error("Action_Battle scenario arrived with no BattleFinishedData");
               }
               else
               {
                  _loc10_ = this.fin.getReward(0);
               }
               if(_loc2_.def.achievement)
               {
                  _loc11_ = saga.def.achievements.fetch(_loc2_.def.achievement);
                  if(SagaAchievements.unlockAchievement(_loc11_,saga.minutesPlayed,true))
                  {
                     if(_loc10_)
                     {
                        _loc10_.achievements[_loc11_.id] = _loc11_.renownAwardAmount;
                        _loc10_.total_renown += _loc11_.renownAwardAmount;
                     }
                  }
               }
               if(_loc2_.def.renown)
               {
                  if(_loc10_)
                  {
                     _loc10_.addRenownAward(BattleRenownAwardType.TRAINING,_loc2_.def.renown);
                  }
               }
            }
         }
         if(this.fin)
         {
            saga.performBattleFinishMusic(_loc3_);
         }
         TweenMax.delayedCall(FINISH_SAGA_DELAY,this.handleDelayedBattleFinished);
      }
      
      override public function triggerBattleResolutionClosed() : void
      {
         logger.i("ABAT","----  triggerBattleResolutionClosed");
         this.doTheBattleExit();
      }
      
      private function doTheBattleExit() : void
      {
         var _loc1_:BattleRewardData = null;
         var _loc2_:int = 0;
         logger.i("ABAT","----  doTheBattleExit " + this.skipFinished + " " + this._hasFinished);
         if(!this.skipFinished && !this._hasFinished)
         {
            this._hasFinished = true;
            if(Boolean(this.fin) && Boolean(saga.caravan))
            {
               if(!this.skipRewards)
               {
                  _loc1_ = this.fin.getReward(0);
                  _loc2_ = !!_loc1_ ? _loc1_.total_renown : 0;
                  saga.caravan._legend.renown += _loc2_;
               }
            }
         }
         end();
      }
      
      private function launchAssembleHeroes() : void
      {
         saga.performAssembleHeroes();
      }
      
      private function _ensureRequiredParty() : void
      {
         var _loc4_:int = 0;
         var _loc5_:IEntityDef = null;
         var _loc1_:Vector.<IEntityDef> = new Vector.<IEntityDef>();
         var _loc2_:SagaLegend = saga.caravan._legend;
         var _loc3_:IPartyDef = _loc2_.party;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.numMembers)
         {
            _loc5_ = _loc3_.getMember(_loc4_);
            if(!_loc5_.partyRequired)
            {
               _loc1_.push(_loc5_);
            }
            _loc4_++;
         }
         var _loc6_:IEntityListDef = _loc2_.roster;
         _loc4_ = 0;
         while(_loc4_ < _loc6_.numCombatants)
         {
            _loc5_ = _loc6_.getEntityDef(_loc4_);
            if(_loc5_.partyRequired)
            {
               if(!_loc3_.hasMemberId(_loc5_.id))
               {
                  logger.info("Action_Battle._ensureRequiredParty " + _loc5_.id + " ADDED");
                  _loc3_.addMember(_loc5_.id);
                  if(_loc1_.length)
                  {
                     _loc5_ = _loc1_.pop();
                     logger.info("Action_Battle._ensureRequiredParty " + _loc5_.id + " REMOVED");
                     _loc3_.removeMember(_loc5_.id);
                  }
               }
            }
            _loc4_++;
         }
      }
      
      override public function triggerAssembleHeroesComplete() : void
      {
         var _loc6_:String = null;
         var _loc9_:BattleScenarioDef = null;
         this._ensureRequiredParty();
         if(def.battle_sparring)
         {
            def.bucket_quota = saga.computeTrainingQuota();
         }
         var _loc1_:String = def.bucket;
         var _loc2_:int = def.bucket_quota;
         if(_loc1_)
         {
            if(!_loc2_)
            {
               _loc2_ = Action_Battle.computeDanger(saga,"BATTLE");
               if(!_loc2_)
               {
                  throw new ArgumentError("Cannot start battle with zero danger/bucket_quota");
               }
            }
         }
         var _loc3_:String = !!_loc1_ ? "bucket_spawn" : null;
         var _loc4_:String = !!def.board_id ? def.board_id : "*";
         if(this.snap)
         {
            _loc4_ = this.snap.boardId;
         }
         var _loc5_:String = def.battle_vitalities;
         var _loc7_:int = _loc4_.indexOf(":");
         if(_loc7_ >= 0)
         {
            _loc6_ = _loc4_.substr(_loc7_ + 1);
            _loc4_ = _loc4_.substring(0,_loc7_);
         }
         saga.logger.info("BATTLE STARTING scene=" + StringUtil.getBasename(def.scene) + " board=[" + _loc4_ + "] bucket=[" + _loc1_ + "] tags=" + def.spawn_tags + " danger=" + _loc2_);
         var _loc8_:SceneLoaderBattleInfo = new SceneLoaderBattleInfo();
         _loc8_.snap = this.snap;
         _loc8_.url = def.scene;
         _loc8_.happening = def.happeningId;
         _loc8_.battle_board_id = _loc4_;
         _loc8_.battle_deployment_area = _loc6_;
         _loc8_.battle_bucket_deployment = _loc3_;
         _loc8_.battle_spawn_tags = def.spawn_tags;
         _loc8_.battle_bucket_quota = _loc2_;
         _loc8_.battle_bucket = _loc1_;
         _loc8_.scenarioDef = null;
         _loc8_.music_url = def.battle_music;
         _loc8_.music_override = def.battle_music_override;
         _loc8_.war = def.war;
         _loc8_.sparring = def.battle_sparring;
         if(def.battle_scenario_id)
         {
            _loc9_ = saga.getBattleScenarioDef(def.battle_scenario_id);
            _loc8_.scenarioDef = _loc9_;
            _loc9_.updateBattleInfo(_loc8_);
         }
         saga.performBattleStart(_loc8_,_loc5_);
      }
      
      public function handleSuppressFinish(param1:Boolean) : void
      {
         logger.i("ABAT","----  handleSuppressFinish " + param1);
         if(param1 == this.skipFinished)
         {
            return;
         }
         this.skipFinished = param1;
         if(!this.skipFinished)
         {
            if(this.fin)
            {
               this.triggerBattleFinished(def.scene);
            }
         }
      }
   }
}
