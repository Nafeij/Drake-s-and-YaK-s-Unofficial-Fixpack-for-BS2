package engine.saga.action
{
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaLegend;
   import engine.saga.SagaVar;
   import engine.saga.WarOutcome;
   import engine.saga.WarOutcomeType;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   import engine.stat.def.StatType;
   
   public class Action_War_Impl_1 implements IAction_War_Impl
   {
       
      
      private var action:Action_War;
      
      private var saga:Saga;
      
      public function Action_War_Impl_1(param1:Action_War)
      {
         super();
         this.action = param1;
         this.saga = param1.saga;
      }
      
      public function handleStarted() : void
      {
         var _loc1_:int = Action_Battle.computeDanger(this.saga,"WAR");
         var _loc2_:Number = 20;
         var _loc3_:Number = 110;
         var _loc4_:int = this.action.numFighters;
         var _loc5_:int = this.action.numVarl;
         var _loc6_:int = this.action.numHeroes;
         var _loc7_:Number = _loc4_ + _loc5_ * 2 + _loc6_ * 4;
         var _loc8_:Number = 0;
         var _loc9_:Number = 0.5;
         var _loc10_:Number = 2;
         var _loc11_:Number = 0;
         if(_loc1_ >= 10)
         {
            _loc11_ = (_loc1_ - 10) / 10;
            _loc8_ = MathUtil.lerp(1,_loc10_,_loc11_);
         }
         else
         {
            _loc11_ = _loc1_ / 10;
            _loc8_ = MathUtil.lerp(_loc9_,1,_loc11_);
         }
         _loc8_ *= _loc7_;
         var _loc12_:Number = this.saga.rng.nextNumber();
         var _loc13_:Number = _loc12_ * 0.1;
         _loc8_ += _loc8_ * _loc13_;
         var _loc14_:Number = _loc1_ + _loc1_ * _loc13_;
         var _loc15_:int = this.saga.getVar(SagaVar.VAR_MORALE_BONUS_THREAT,VariableType.INTEGER).asInteger;
         if(_loc15_)
         {
            this.saga.logger.info("   WAR morale threat bonus " + StringUtil.numberWithSign(_loc15_));
            _loc14_ += _loc15_;
         }
         this.saga.logger.info("   WAR threat " + _loc14_);
         this.saga.suppressVariableFlytext = true;
         this.saga.setVar(SagaVar.VAR_WAR_DANGER,_loc1_);
         this.saga.setVar(SagaVar.VAR_WAR_ENEMY_POWER,_loc8_);
         this.saga.setVar(SagaVar.VAR_WAR_PLAYER_POWER,_loc7_);
         this.saga.setVar(SagaVar.VAR_WAR_THREAT,_loc14_);
         this.saga.suppressVariableFlytext = false;
      }
      
      public function handleProcessWarPlan() : void
      {
      }
      
      public function determineWarOutcome(param1:WarOutcome) : BattleFinishedData
      {
         var _loc2_:IVariable = this.saga.getVar(SagaVar.VAR_WAR_RETREAT,null);
         var _loc3_:Boolean = Boolean(_loc2_) && _loc2_.asBoolean;
         if(_loc3_)
         {
            param1.type = WarOutcomeType.RETREAT;
            return null;
         }
         var _loc4_:IVariable = this.saga.getVar(SagaVar.VAR_WAR_THREAT,null);
         var _loc5_:int = !!_loc4_ ? _loc4_.asInteger : 0;
         var _loc6_:Number = Number(_loc5_) / 20;
         _loc6_ *= this.saga.getDifficultyOverseeDefeatMod();
         var _loc7_:Number = this.saga.rng.nextNumber();
         if(_loc7_ > _loc6_)
         {
            param1.type = WarOutcomeType.VICTORY;
            this.saga.setVar(SagaVar.VAR_BATTLE_VICTORY,true);
         }
         else
         {
            param1.type = WarOutcomeType.DEFEAT;
            this.saga.setVar(SagaVar.VAR_BATTLE_VICTORY,false);
            this.saga.incrementGlobalVar(Saga.VAR_PRG_WARS_LOST);
         }
         return this._computeOverseeRewards(param1);
      }
      
      private function _computeOverseeRewards(param1:WarOutcome) : BattleFinishedData
      {
         var _loc9_:IEntityDef = null;
         var _loc10_:* = false;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:BattleFinishedData = new BattleFinishedData();
         _loc2_.setupTeams(1);
         var _loc3_:int = !!this.saga ? this.saga.getDifficultyRenownKill() : 1;
         var _loc4_:int = !!this.saga ? this.saga.getDifficultyRenownWin() : 2;
         _loc3_ = Math.max(1,_loc3_ / 2);
         _loc4_ = Math.max(1,_loc3_ / 2);
         var _loc5_:Number = 0.75;
         if(param1.type == WarOutcomeType.VICTORY)
         {
            _loc2_.addRenownAward(0,BattleRenownAwardType.WIN,_loc4_);
         }
         else
         {
            _loc5_ = 0.35;
         }
         var _loc6_:int = 0;
         var _loc7_:IPartyDef = this.saga.caravan._legend.party;
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_.numMembers)
         {
            _loc9_ = _loc7_.getMember(_loc8_);
            if(_loc9_)
            {
               _loc10_ = this.saga.rng.nextNumber() <= _loc5_;
               if(_loc10_)
               {
                  _loc11_ = _loc9_.stats.getBase(StatType.KILLS) + 1;
                  _loc9_.stats.setBase(StatType.KILLS,_loc11_);
                  _loc6_++;
                  _loc12_ = this.saga.def.unitStatCosts.getKillsRequiredToPromote(_loc9_.stats.rank);
                  if(_loc12_ == _loc11_)
                  {
                     param1.unitsReadyToPromote.push(_loc9_.id);
                  }
               }
            }
            _loc8_++;
         }
         _loc2_.addRenownAward(0,BattleRenownAwardType.KILLS,_loc6_ * _loc3_);
         return _loc2_;
      }
      
      public function applyBattleResults(param1:WarOutcome, param2:BattleFinishedData) : void
      {
         var _loc8_:BattleRewardData = null;
         var _loc9_:int = 0;
         this.checkForInjuries(param1);
         this.grantKillsToRoster(param1);
         param1.renown = this.saga.getVar(SagaVar.VAR_WAR_RENOWN,null).asInteger;
         var _loc3_:Number = this.saga.rng.nextNumber();
         if(param1.type != WarOutcomeType.VICTORY)
         {
            this.action.threat += Math.round(_loc3_ * 3) + 1;
         }
         else
         {
            this.action.threat -= Math.round(_loc3_ * 3) + 2;
         }
         var _loc4_:Array = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
         var _loc5_:Array = [0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40];
         var _loc6_:int = this.action.computeRandomPercentage(this.action.threat,_loc4_);
         var _loc7_:Number = this.action.computeRandomPercentage(this.action.threat,_loc5_);
         param1.casualties_peasants = _loc6_ * this.action.numPeasants;
         param1.casualties_fighters = _loc7_ * this.action.numFighters;
         param1.casualties_varl = _loc7_ * this.action.numVarl;
         this.action.numPeasants -= param1.casualties_peasants;
         this.action.numFighters -= param1.casualties_fighters;
         this.action.numVarl -= param1.casualties_varl;
         this.action.addVars(SagaVar.VAR_MORALE,SagaVar.VAR_WAR_MORALE);
         if(param2)
         {
            _loc8_ = param2.getReward(0);
            _loc9_ = param1.renown;
            if(_loc8_)
            {
               _loc9_ += _loc8_.total_renown;
            }
            if(Boolean(this.saga) && Boolean(this.saga.caravan))
            {
               this.saga.caravan._legend.renown += _loc9_;
            }
         }
      }
      
      private function checkForInjuries(param1:WarOutcome) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:* = false;
         var _loc9_:IEntityDef = null;
         if(this.action.battle)
         {
            return;
         }
         var _loc2_:IVariable = this.saga.getVar(SagaVar.VAR_WAR_INJURY,null);
         var _loc3_:Number = !!_loc2_ ? _loc2_.asNumber : 0;
         if(_loc3_ <= 0)
         {
            return;
         }
         var _loc4_:Number = _loc3_ / 100;
         var _loc5_:IEntityListDef = this.saga.caravan._legend.roster;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.numCombatants)
         {
            _loc7_ = this.saga.rng.nextNumber();
            _loc8_ = _loc7_ <= _loc4_;
            if(_loc8_)
            {
               _loc9_ = _loc5_.getEntityDef(_loc6_);
               param1.injuries.push(_loc9_.id);
            }
            if(param1.injuries.length >= 6)
            {
               break;
            }
            _loc6_++;
         }
      }
      
      private function grantKillsToRoster(param1:WarOutcome) : void
      {
         var _loc5_:IEntityDef = null;
         var _loc6_:int = 0;
         var _loc2_:SagaLegend = this.saga.caravan._legend;
         var _loc3_:IEntityListDef = _loc2_.roster;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.numCombatants)
         {
            _loc5_ = _loc3_.getEntityDef(_loc4_);
            if(!_loc2_.party.hasMemberId(_loc5_.id))
            {
               _loc6_ = int(_loc5_.stats.getValue(StatType.KILLS));
               _loc5_.stats.setBase(StatType.KILLS,_loc6_ + 1);
            }
            if(param1.injuries.length >= 6)
            {
               break;
            }
            _loc4_++;
         }
      }
      
      public function setupWarRiskString() : void
      {
      }
   }
}
