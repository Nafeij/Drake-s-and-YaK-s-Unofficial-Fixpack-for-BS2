package engine.battle.fsm.state
{
   import engine.achievement.AchievementDef;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.entity.def.Item;
   import engine.saga.ISagaAchievements;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import flash.errors.IllegalOperationError;
   
   public class BattleStateFinish extends BaseBattleState
   {
       
      
      public var finishedData:BattleFinishedData;
      
      private var total_kill_count:int;
      
      private var total_kill_renown:int;
      
      public function BattleStateFinish(param1:StateData, param2:BattleFsm, param3:ILogger, param4:int = 0)
      {
         super(param1,param2,param3,param4,1000);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         battleFsm.battleFinished = true;
         this.doFinish();
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         if(param1["class"] == "tbs.srv.battle.data.client.BattleFinishedData")
         {
            this.finishedData = new BattleFinishedData();
            this.finishedData.fromJson(param1);
            this.doFinish();
            return true;
         }
         return false;
      }
      
      private function doFinish() : void
      {
         var _loc1_:Saga = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:BattleBoard = null;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:IBattleParty = null;
         var _loc12_:BattleRewardData = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(phase != StatePhase.ENTERED)
         {
            return;
         }
         if(!battleFsm.isOnline)
         {
            if(this.finishedData)
            {
               throw new IllegalOperationError("Should not have finished data already");
            }
            this.finishedData = data.getValue(BattleStateDataEnum.FINISHED);
            _loc1_ = Saga.instance;
            _loc2_ = !!_loc1_ ? _loc1_.getDifficultyRenownKill() : 1;
            _loc3_ = !!_loc1_ ? _loc1_.getDifficultyRenownWin() : 2;
            _loc4_ = Math.max(0,_loc2_ - 1);
            if(Boolean(_loc1_) && _loc1_.inTrainingBattle)
            {
               _loc4_ = 0;
            }
            if(!this.finishedData)
            {
               _loc5_ = data.getValue(BattleStateDataEnum.VICTORIOUS_TEAM);
               this.finishedData = new BattleFinishedData();
               this.finishedData.victoriousTeam = _loc5_;
               _loc6_ = battleFsm.board as BattleBoard;
               _loc7_ = _loc6_.scene.def.url;
               _loc8_ = battleFsm.aborted;
               _loc9_ = battleFsm.halted;
               _loc1_.triggerBattleFinishing(_loc7_,this.finishedData,_loc6_);
               if(!battleFsm || !battleFsm.board)
               {
                  return;
               }
               if(!_loc8_ && battleFsm.aborted)
               {
                  return;
               }
               if(!_loc9_ && battleFsm.halted)
               {
                  return;
               }
               _loc10_ = 0;
               while(_loc10_ < battleFsm.board.numParties)
               {
                  _loc11_ = battleFsm.board.getParty(_loc10_);
                  _loc12_ = new BattleRewardData();
                  this.finishedData.rewards.push(_loc12_);
                  this.computePartyKillInfo(_loc11_);
                  _loc13_ = this.total_kill_renown;
                  _loc13_ += this.total_kill_count * _loc4_;
                  _loc14_ = _loc11_.bonusRenown;
                  _loc13_ += _loc14_;
                  if(_loc10_ == 0)
                  {
                     this.processGainedAchievements(_loc12_);
                     this.processGainedItems(_loc12_);
                  }
                  _loc12_.awards[BattleRenownAwardType.KILLS] = _loc13_;
                  _loc12_.total_renown += _loc13_;
                  if(_loc11_.team == _loc5_)
                  {
                     _loc12_.awards[BattleRenownAwardType.WIN] = _loc3_;
                     _loc12_.total_renown += _loc3_;
                  }
                  _loc10_++;
               }
            }
         }
         if(this.finishedData)
         {
            battleFsm.setFinishedData(this.finishedData);
            data.setValue(BattleStateDataEnum.FINISHED,this.finishedData);
            phase = StatePhase.COMPLETED;
         }
      }
      
      private function processGainedAchievements(param1:BattleRewardData) : void
      {
         var _loc6_:String = null;
         var _loc7_:AchievementDef = null;
         var _loc8_:int = 0;
         var _loc2_:Saga = Saga.instance;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc4_:ISagaAchievements = SagaAchievements.impl;
         var _loc5_:Vector.<String> = _loc4_.unlocked;
         for each(_loc6_ in _loc5_)
         {
            if(!battleFsm.startingAchievements[_loc6_])
            {
               _loc7_ = _loc2_.def.achievements.fetch(_loc6_);
               _loc8_ = _loc7_.renownAwardAmount;
               _loc3_ += _loc8_;
               param1.achievements[_loc6_] = _loc8_;
            }
         }
         param1.total_renown += _loc3_;
      }
      
      private function processGainedItems(param1:BattleRewardData) : void
      {
         var _loc4_:Item = null;
         var _loc2_:Saga = Saga.instance;
         if(!_loc2_ || !_loc2_.caravan)
         {
            return;
         }
         var _loc3_:Vector.<Item> = _loc2_.caravan._legend._items.items;
         for each(_loc4_ in _loc3_)
         {
            if(!battleFsm.startingItems[_loc4_.id])
            {
               param1.items.push(_loc4_.id);
            }
         }
      }
      
      private function computePartyKillInfo(param1:IBattleParty) : void
      {
         var _loc4_:IBattleParty = null;
         var _loc5_:int = 0;
         var _loc6_:IBattleEntity = null;
         var _loc7_:int = 0;
         this.total_kill_count = 0;
         this.total_kill_renown = 0;
         var _loc2_:int = 0;
         while(_loc2_ < battleFsm.board.numParties)
         {
            _loc4_ = battleFsm.board.getParty(_loc2_);
            if(!(_loc4_ == param1 || _loc4_.team == param1.team))
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.numMembers)
               {
                  _loc6_ = _loc4_.getMember(_loc5_);
                  if(!_loc6_.alive)
                  {
                     ++this.total_kill_count;
                     _loc7_ = _loc6_.killRenown;
                     this.total_kill_renown += _loc7_;
                  }
                  _loc5_++;
               }
            }
            _loc2_++;
         }
         var _loc3_:Saga = Saga.instance;
         if(Boolean(_loc3_) && _loc3_.inTrainingBattle)
         {
            this.total_kill_renown = 0;
         }
         logger.info("BattleStateFinish.computePartyKillInfo for " + param1 + " count=" + this.total_kill_count + " ranks=" + this.total_kill_renown);
      }
   }
}
