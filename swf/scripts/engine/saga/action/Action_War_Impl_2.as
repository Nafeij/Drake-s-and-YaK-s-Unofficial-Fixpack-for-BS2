package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleRewardData;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Saga;
   import engine.saga.SagaLegend;
   import engine.saga.SagaVar;
   import engine.saga.WarOutcome;
   import engine.saga.WarOutcomeType;
   import engine.saga.convo.def.ConvoNodeDef;
   import engine.saga.vars.IVariable;
   import engine.stat.def.StatType;
   
   public class Action_War_Impl_2 implements IAction_War_Impl
   {
      
      public static var DANGER_POWER_FACTOR:Number = 100;
      
      public static var POWER_CASUALTY_FACTOR:Number = 0.2;
      
      public static var CASUALTY_BASE_FACTOR:Number = 0.15;
      
      public static var CASUALTY_MIN_FACTOR:Number = 0.05;
      
      public static var CASUALTY_MAX_FACTOR:Number = 0.3;
      
      public static var POWER_CASUALTY_CLAN_FACTOR:Number = 0.5;
      
      public static var CASUALTY_CLAN_MAX_FACTOR:Number = 0.5;
      
      public static var MORALE_WIN:int = 30;
      
      public static var MORALE_LOSE:int = -30;
      
      public static var CLANSMAN_RENOWN:Number = 0.05;
      
      public static var BATTLE_DANGER_RISK_MOD:Number = 0.1;
       
      
      private var action:Action_War;
      
      private var saga:Saga;
      
      private var war_danger:int;
      
      private var war_enemy_power:int;
      
      private var war_player_power:Number;
      
      private var war_risk:int;
      
      public function Action_War_Impl_2(param1:Action_War)
      {
         super();
         this.action = param1;
         this.saga = param1.saga;
      }
      
      public function handleStarted() : void
      {
         this._setupDangerPower();
         this._setupRisk();
         this.saga.suppressVariableFlytext = true;
         this.saga.setVar(SagaVar.VAR_WAR_BATTLE,1);
         this.saga.setVar(SagaVar.VAR_WAR_ROSTER_INJURY_MOD,0);
         this.saga.setVar(SagaVar.VAR_WAR_MORALE_WIN_BONUS,0);
         this.saga.setVar(SagaVar.VAR_WAR_DANGER,this.war_danger);
         this.saga.setVar(SagaVar.VAR_WAR_ENEMY_POWER,this.war_enemy_power);
         this.saga.setVar(SagaVar.VAR_WAR_PLAYER_POWER,this.war_player_power);
         this.saga.setVar(SagaVar.VAR_WAR_RISK,this.war_risk);
         this.saga.suppressVariableFlytext = false;
      }
      
      public function handleProcessWarPlan() : void
      {
      }
      
      private function _setupRisk() : void
      {
         var _loc1_:Number = this.war_enemy_power / this.war_player_power;
         this.war_risk = 0;
         if(_loc1_ <= 1)
         {
            this.war_risk = 50 * _loc1_;
         }
         else
         {
            this.war_risk = 50 + _loc1_ * 5;
         }
         var _loc2_:int = (this.war_risk - 50) * BATTLE_DANGER_RISK_MOD;
         this.war_danger += _loc2_;
      }
      
      private function _setupDangerPower() : void
      {
         this.war_danger = Action_Battle.computeDanger(this.saga,"WAR");
         this.war_enemy_power = DANGER_POWER_FACTOR * this.war_danger;
         var _loc1_:int = this.action.numFighters;
         var _loc2_:int = this.action.numVarl;
         this.war_player_power = _loc1_ + _loc2_ * 2;
         this.war_player_power = Math.max(10,this.war_player_power);
      }
      
      private function _computePlayerCasualtyPower() : int
      {
         var _loc1_:int = this.action.numFighters;
         var _loc2_:int = this.action.numVarl;
         return this._computeCombatantCasualtyPower(this.war_player_power,this.war_enemy_power);
      }
      
      private function _computeEnemyCasualtyNumber() : int
      {
         return this._computeCombatantCasualtyPower(this.war_enemy_power,this.war_player_power);
      }
      
      private function _computeCombatantCasualtyPower(param1:int, param2:int) : int
      {
         var _loc3_:int = param2 - param1;
         var _loc4_:int = param1 * CASUALTY_MIN_FACTOR;
         var _loc5_:int = param1 * CASUALTY_MAX_FACTOR;
         var _loc6_:int = param1 * CASUALTY_BASE_FACTOR;
         var _loc7_:int = _loc3_ * POWER_CASUALTY_FACTOR;
         return int(Math.max(_loc4_,Math.min(_loc5_,_loc6_ + _loc7_)));
      }
      
      private function _computeClansmanCasualtyNumber() : int
      {
         var _loc1_:int = this.action.numFighters;
         var _loc2_:int = this.action.numVarl;
         var _loc3_:int = this.action.numPeasants;
         var _loc4_:int = this.war_enemy_power - this.war_player_power;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = _loc3_ * CASUALTY_CLAN_MAX_FACTOR;
         var _loc8_:int = _loc4_ * POWER_CASUALTY_CLAN_FACTOR;
         return int(Math.max(_loc5_,Math.min(_loc7_,_loc6_ + _loc8_)));
      }
      
      public function determineWarOutcome(param1:WarOutcome) : BattleFinishedData
      {
         var _loc2_:IVariable = this.saga.getVar(SagaVar.VAR_WAR_RETREAT,null);
         var _loc3_:Boolean = Boolean(_loc2_) && _loc2_.asBoolean;
         param1.type = WarOutcomeType.RETREAT;
         return null;
      }
      
      public function applyBattleResults(param1:WarOutcome, param2:BattleFinishedData) : void
      {
         var _loc12_:String = null;
         var _loc13_:BattleRewardData = null;
         var _loc14_:int = 0;
         this.checkForInjuries(param1);
         this.grantKillsToRoster(param1);
         param1.renown = this.saga.getVar(SagaVar.VAR_WAR_RENOWN,null).asInteger;
         var _loc3_:int = this._computePlayerCasualtyPower();
         var _loc4_:int = this._computeEnemyCasualtyNumber();
         var _loc5_:int = this._computeClansmanCasualtyNumber();
         var _loc6_:int = MORALE_LOSE;
         if(param1.type == WarOutcomeType.VICTORY)
         {
            _loc3_ /= 2;
            _loc5_ /= 2;
            _loc6_ = MORALE_WIN;
            this.action.addVars(SagaVar.VAR_MORALE,SagaVar.VAR_WAR_MORALE_WIN_BONUS);
         }
         var _loc7_:Number = this.action.numVarl * 2 / this.war_player_power;
         var _loc8_:int = _loc3_ * _loc7_ / 2;
         _loc3_ -= _loc8_ * 2;
         var _loc9_:int = _loc3_;
         param1.casualties_peasants = _loc5_;
         param1.casualties_fighters = _loc9_;
         param1.casualties_varl = _loc8_;
         this.action.numPeasants -= param1.casualties_peasants;
         this.action.numFighters -= param1.casualties_fighters;
         this.action.numVarl -= param1.casualties_varl;
         if(this.saga.caravan)
         {
            this.saga.caravan.vars.incrementVar("tot_war_casualty_peasants",_loc5_);
            this.saga.caravan.vars.incrementVar("tot_war_casualty_fighters",_loc9_);
            this.saga.caravan.vars.incrementVar("tot_war_casualty_varl",_loc8_);
         }
         var _loc10_:int = this.saga.getVar(SagaVar.VAR_MORALE,null).asInteger;
         _loc10_ += _loc6_;
         this.saga.setVar(SagaVar.VAR_MORALE,_loc10_);
         param1.clansmen_saved = this.action.numPeasants;
         param1.renown_clansmen = param1.clansmen_saved * CLANSMAN_RENOWN;
         param1.renown += param1.renown_clansmen;
         var _loc11_:BattleBoard = this.saga.getBattleBoard();
         if(_loc11_)
         {
            if(_loc11_.fsm.unitsReadyToPromote)
            {
               for each(_loc12_ in _loc11_.fsm.unitsReadyToPromote)
               {
                  if(param1.unitsReadyToPromote.indexOf(_loc12_) < 0)
                  {
                     param1.unitsReadyToPromote.push(_loc12_);
                  }
               }
            }
            this.collectInjuries(_loc11_,param1);
         }
         if(Boolean(param2) && Boolean(this.saga.caravan))
         {
            _loc13_ = param2.getReward(0);
            _loc14_ = param1.renown;
            if(_loc13_)
            {
               _loc14_ += _loc13_.total_renown;
            }
            this.saga.caravan._legend.renown += _loc14_;
         }
      }
      
      private function collectInjuries(param1:BattleBoard, param2:WarOutcome) : void
      {
         var _loc3_:String = null;
         if(param1.fsm.unitsInjured)
         {
            for each(_loc3_ in param1.fsm.unitsInjured)
            {
               if(param2.unitsInjured.indexOf(_loc3_) < 0)
               {
                  param2.unitsInjured.push(_loc3_);
               }
            }
         }
      }
      
      private function checkForInjuries(param1:WarOutcome) : void
      {
         var _loc10_:IEntityDef = null;
         var _loc11_:Number = NaN;
         var _loc12_:* = false;
         var _loc2_:IVariable = this.saga.getVar(SagaVar.VAR_WAR_ROSTER_INJURY_MOD,null);
         var _loc3_:int = !!_loc2_ ? _loc2_.asInteger : 0;
         var _loc4_:Number = this.war_risk + _loc3_;
         if(_loc4_ <= 0)
         {
            return;
         }
         var _loc5_:Number = Math.min(1,_loc4_ / 100);
         var _loc6_:SagaLegend = this.saga.caravan._legend;
         var _loc7_:IEntityListDef = _loc6_.roster;
         var _loc8_:IPartyDef = _loc6_.party;
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_.numCombatants)
         {
            _loc10_ = _loc7_.getEntityDef(_loc9_);
            if(!_loc8_.hasMemberId(_loc10_.id))
            {
               _loc11_ = this.saga.rng.nextNumber();
               _loc12_ = _loc11_ <= _loc5_;
               if(_loc12_)
               {
                  param1.injuries.push(_loc10_.id);
               }
            }
            _loc9_++;
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
            _loc4_++;
         }
      }
      
      public function setupWarRiskString() : void
      {
         var _loc1_:String = null;
         if(this.war_risk <= 20)
         {
            _loc1_ = "war_risk_20";
         }
         else if(this.war_risk <= 40)
         {
            _loc1_ = "war_risk_40";
         }
         else if(this.war_risk <= 60)
         {
            _loc1_ = "war_risk_60";
         }
         else if(this.war_risk <= 80)
         {
            _loc1_ = "war_risk_80";
         }
         else
         {
            _loc1_ = "war_risk_100";
         }
         var _loc2_:String = this.saga.locale.translateGui(_loc1_);
         ConvoNodeDef.war_risk_str = _loc2_;
      }
   }
}
