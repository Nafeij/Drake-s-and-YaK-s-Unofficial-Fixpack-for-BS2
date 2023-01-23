package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.sim.IBattleParty;
   import engine.core.analytic.Ga;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.ItemDef;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   import engine.saga.SagaLegend;
   import engine.saga.SagaVar;
   import engine.saga.WarOutcome;
   import engine.saga.WarOutcomeType;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   import engine.stat.def.StatType;
   import flash.errors.IllegalOperationError;
   
   public class Action_War extends Action implements IActionListener
   {
      
      public static var IMPL_CLASS:Class;
      
      public static var POPPENING_URL:String;
      
      public static var POPPENING_CONTINUE_URL:String;
       
      
      private var outcome:WarOutcome;
      
      private var a_popup:Action_Convo;
      
      private var a_battle:Action_Battle;
      
      private var a_popup_decision:Action;
      
      private var fin_war:BattleFinishedData;
      
      private var impl:IAction_War_Impl;
      
      private var url_poppening:String;
      
      private var url_poppening_continue:String;
      
      public function Action_War(param1:ActionDef, param2:Saga)
      {
         var _loc3_:Array = null;
         this.outcome = new WarOutcome();
         this.url_poppening = POPPENING_URL;
         this.url_poppening_continue = POPPENING_CONTINUE_URL;
         super(param1,param2);
         if(!param1.scene)
         {
            throw new ArgumentError("No scene for battle");
         }
         if(!IMPL_CLASS)
         {
            throw new IllegalOperationError("Must set Action_War.IMPL_CLASS");
         }
         this.impl = new IMPL_CLASS(this) as IAction_War_Impl;
         if(param1.url)
         {
            _loc3_ = param1.url.split(",");
            if(_loc3_.length > 0 && Boolean(_loc3_[0]))
            {
               this.url_poppening = _loc3_[0];
            }
            if(_loc3_.length > 1 && Boolean(_loc3_[1]))
            {
               this.url_poppening_continue = _loc3_[1];
            }
         }
      }
      
      override protected function handleEnded() : void
      {
         TweenMax.killDelayedCallsTo(this.finishDoWarResolution);
      }
      
      override protected function handleStarted() : void
      {
         paused = true;
         saga.setVar(SagaVar.VAR_BATTLE_VICTORY,true);
         if(def.restore_scene && !def.instant)
         {
            this.sceneStateSave();
         }
         this.setupWarVars();
         this.impl.handleStarted();
         this.startPoppening();
      }
      
      private function startPoppening() : void
      {
         if(!this.url_poppening)
         {
            throw new IllegalOperationError("Must have poppening url");
         }
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.POPUP;
         _loc1_.url = this.url_poppening;
         _loc1_.poppening_top = def.poppening_top;
         _loc1_.war = true;
         this.a_popup = Action.factory(_loc1_,saga,happening,this) as Action_Convo;
         this.impl.setupWarRiskString();
         saga.executeAction(this.a_popup);
         this.actionListenerHandleActionEnded(this.a_popup);
      }
      
      public function actionListenerHandleActionEnded(param1:Action) : void
      {
         if(param1 == this.a_popup)
         {
            if(!this.a_popup.ended)
            {
               return;
            }
            this.a_popup.listener = null;
            this.processWarPlan();
         }
         else if(param1 == this.a_battle)
         {
            if(!this.a_battle.ended)
            {
               return;
            }
            this.a_battle.listener = null;
            end();
         }
         else if(param1 == this.a_popup_decision)
         {
            if(!this.a_popup_decision.ended)
            {
               return;
            }
            this.a_popup_decision.listener = null;
            this.processWarDecision();
         }
      }
      
      private function launchAssembleHeroes() : void
      {
         saga.performAssembleHeroes();
      }
      
      override public function triggerAssembleHeroesComplete() : void
      {
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.BATTLE;
         _loc1_.scene = def.scene;
         _loc1_.bucket = def.bucket;
         _loc1_.assemble_heroes = false;
         _loc1_.restore_scene = false;
         _loc1_.board_id = def.board_id;
         _loc1_.battle_music = def.battle_music;
         _loc1_.battle_music_override = def.battle_music_override;
         _loc1_.bucket_quota = saga.getVar(SagaVar.VAR_WAR_DANGER,null).asInteger;
         _loc1_.war = true;
         _loc1_.happeningId = def.happeningId;
         this.a_battle = saga.executeActionDef(_loc1_,null,this) as Action_Battle;
         this.a_battle.skipFinished = true;
      }
      
      private function processWarPlan() : void
      {
         var _loc1_:IVariable = saga.getVar(SagaVar.VAR_WAR_BATTLE,null);
         var _loc2_:Boolean = Boolean(_loc1_) && _loc1_.asBoolean;
         this.impl.handleProcessWarPlan();
         var _loc3_:Caravan = saga.caravan;
         var _loc4_:SagaLegend = !!_loc3_ ? _loc3_._legend : null;
         var _loc5_:IPartyDef = !!_loc4_ ? _loc4_.party : null;
         if(_loc2_)
         {
            if(def.assemble_heroes)
            {
               if(!Action_Battle.ASSEMBLE_SKIP || !_loc5_ || _loc5_.numMembers == 0)
               {
                  this.launchAssembleHeroes();
                  return;
               }
            }
            this.triggerAssembleHeroesComplete();
         }
         else
         {
            this.fin_war = this.impl.determineWarOutcome(this.outcome);
            this.doWarResolution();
         }
      }
      
      private function processBonusRoundVariables() : void
      {
         if(!this.outcome || this.outcome.type != WarOutcomeType.VICTORY)
         {
            return;
         }
         var _loc1_:int = saga.getVar(SagaVar.VAR_WAR_CONTINUE_ITEM,null).asInteger;
         var _loc2_:int = saga.getVar(SagaVar.VAR_WAR_CONTINUE_MORALE,null).asInteger;
         var _loc3_:int = saga.getVar(SagaVar.VAR_WAR_CONTINUE_RENOWN,null).asInteger;
         var _loc4_:int = saga.getVar(SagaVar.VAR_WAR_CONTINUE_THREAT,null).asInteger;
         this.addVars(SagaVar.VAR_WAR_THREAT,SagaVar.VAR_WAR_CONTINUE_THREAT);
         this.addVars(SagaVar.VAR_WAR_MORALE,SagaVar.VAR_WAR_CONTINUE_MORALE);
         this.addVars(SagaVar.VAR_WAR_ITEM,SagaVar.VAR_WAR_CONTINUE_ITEM);
         this.addVars(SagaVar.VAR_WAR_RENOWN,SagaVar.VAR_WAR_CONTINUE_RENOWN);
      }
      
      private function processWarDecision() : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc1_:IVariable = saga.getVar(SagaVar.VAR_WAR_CONTINUE,null);
         var _loc2_:Boolean = Boolean(_loc1_) && _loc1_.asBoolean;
         var _loc3_:int = saga.getVar(SagaVar.VAR_WAR_DANGER,null).asInteger;
         if(_loc2_)
         {
            Ga.normal("war","continue","",0);
         }
         else
         {
            Ga.normal("war","retreat","",0);
         }
         if(_loc2_)
         {
            this.processBonusRoundVariables();
            _loc4_ = "bucket_respawn";
            _loc6_ = "bucket_respawn";
            saga.performWarRespawn(_loc3_,_loc4_,_loc5_,_loc6_);
         }
         else
         {
            this.doWarResolution();
         }
      }
      
      override public function triggerWarResolutionClosed() : void
      {
         if(this.a_battle)
         {
            this.a_battle.end();
         }
         end();
      }
      
      public function get fin() : BattleFinishedData
      {
         if(this.fin_war)
         {
            return this.fin_war;
         }
         return !!this.a_battle ? this.a_battle.fin : null;
      }
      
      override public function triggerBattleFinished(param1:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:IBattleEntity = null;
         var _loc6_:ActionDef = null;
         if(this.fin.victoriousTeam == "0")
         {
            this.outcome.type = WarOutcomeType.VICTORY;
         }
         else
         {
            this.outcome.type = WarOutcomeType.DEFEAT;
         }
         var _loc2_:BattleBoard = !!this.a_battle ? this.a_battle.board : null;
         var _loc3_:IBattleParty = !!_loc2_ ? _loc2_.getPartyById("0") : null;
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numMembers)
            {
               _loc5_ = _loc3_.getMember(_loc4_);
               if(_loc5_.stats.getValue(StatType.STRENGTH) <= 0 || this.outcome.type == WarOutcomeType.DEFEAT)
               {
                  if(this.outcome.injuries.indexOf(_loc5_.def.id) < 0)
                  {
                     this.outcome.injuries.push(_loc5_.def.id);
                  }
               }
               _loc4_++;
            }
         }
         if(this.outcome.type == WarOutcomeType.VICTORY)
         {
            if(!this.a_popup_decision && Boolean(this.url_poppening_continue))
            {
               _loc6_ = new ActionDef(null);
               _loc6_.type = ActionType.POPUP;
               _loc6_.war = true;
               _loc6_.url = this.url_poppening_continue;
               this.a_popup_decision = saga.executeActionDef(_loc6_,null,this);
               this.actionListenerHandleActionEnded(this.a_popup_decision);
            }
            else
            {
               this.doWarResolution();
            }
            return;
         }
         this.doWarResolution();
      }
      
      private function computeItemDrop() : Boolean
      {
         var _loc3_:ItemDef = null;
         var _loc4_:ActionDef = null;
         if(this.outcome.type === WarOutcomeType.DEFEAT)
         {
            logger.info("Action_War defeat, no item drop");
            return false;
         }
         var _loc1_:int = saga.getVar(SagaVar.VAR_WAR_ITEM,VariableType.INTEGER).asInteger;
         if(_loc1_ <= 0)
         {
            return false;
         }
         var _loc2_:int = saga.rng.nextMax(100);
         if(_loc2_ <= _loc1_)
         {
            _loc3_ = saga.generateRandomItemDefForPartyRanks();
            if(!_loc3_)
            {
               logger.info("Action_War unable to generate item");
               return false;
            }
            _loc4_ = new ActionDef(null);
            _loc4_.type = ActionType.ITEM_ADD;
            _loc4_.id = _loc3_.id;
            saga.executeActionDef(_loc4_,null,null);
            TweenMax.delayedCall(3,this.finishDoWarResolution);
            return true;
         }
         return false;
      }
      
      private function doWarResolution() : void
      {
         if(!this.computeItemDrop())
         {
            this.finishDoWarResolution();
         }
      }
      
      private function finishDoWarResolution() : void
      {
         this.impl.applyBattleResults(this.outcome,this.fin);
         saga.performWarResolution(this.outcome,this.fin);
      }
      
      private function setupWarVars() : void
      {
         saga.suppressVariableFlytext = true;
         saga.setVar(SagaVar.VAR_WAR_RETREAT,0);
         saga.setVar(SagaVar.VAR_WAR_BATTLE,0);
         saga.setVar(SagaVar.VAR_WAR_CONTINUE,0);
         saga.setVar(SagaVar.VAR_WAR_MORALE,0);
         saga.setVar(SagaVar.VAR_WAR_ITEM,0);
         saga.setVar(SagaVar.VAR_WAR_RENOWN,0);
         saga.setVar(SagaVar.VAR_WAR_CONTINUE_ITEM,0);
         saga.setVar(SagaVar.VAR_WAR_CONTINUE_MORALE,0);
         saga.setVar(SagaVar.VAR_WAR_CONTINUE_RENOWN,0);
         saga.setVar(SagaVar.VAR_WAR_CONTINUE_THREAT,0);
         saga.setVar(SagaVar.VAR_WAR_INJURY,0);
         saga.setVar(SagaVar.VAR_WAR_THREAT,0);
         saga.suppressVariableFlytext = false;
      }
      
      public function addVars(param1:String, param2:String) : void
      {
         var _loc3_:int = saga.getVar(param1,null).asInteger;
         var _loc4_:int = saga.getVar(param2,null).asInteger;
         saga.suppressVariableFlytext = true;
         saga.setVar(param1,_loc3_ + _loc4_);
         saga.suppressVariableFlytext = false;
      }
      
      public function get battle() : Boolean
      {
         return saga.getVar(SagaVar.VAR_WAR_BATTLE,null).asBoolean;
      }
      
      public function get threat() : Number
      {
         return saga.getVar(SagaVar.VAR_WAR_THREAT,null).asNumber;
      }
      
      public function set threat(param1:Number) : void
      {
         saga.suppressVariableFlytext = true;
         saga.setVar(SagaVar.VAR_WAR_THREAT,param1);
         saga.suppressVariableFlytext = false;
      }
      
      public function computeRandomPercentage(param1:Number, param2:Array) : Number
      {
         var _loc3_:Number = Number(param2[Math.max(0,Math.min(param2.length - 1,param1))]);
         var _loc4_:Number = saga.rng.nextNumber();
         var _loc5_:Number = _loc4_ * _loc3_ / 2 + _loc3_ / 2;
         return _loc5_ / 100;
      }
      
      public function get numFighters() : int
      {
         var _loc1_:IVariable = saga.getVar(SagaVar.VAR_NUM_FIGHTERS,null);
         return !!_loc1_ ? _loc1_.asInteger : 0;
      }
      
      public function get numVarl() : int
      {
         var _loc1_:IVariable = saga.getVar(SagaVar.VAR_NUM_VARL,null);
         return !!_loc1_ ? _loc1_.asInteger : 0;
      }
      
      public function get numPeasants() : int
      {
         var _loc1_:IVariable = saga.getVar(SagaVar.VAR_NUM_PEASANTS,null);
         return !!_loc1_ ? _loc1_.asInteger : 0;
      }
      
      private function _setPopulationComponent(param1:String, param2:int) : void
      {
         var _loc3_:IVariable = saga.getVar(param1,null);
         if(_loc3_)
         {
            _loc3_.asAny = param2;
            this.updatePopulation();
         }
      }
      
      public function set numFighters(param1:int) : void
      {
         this._setPopulationComponent(SagaVar.VAR_NUM_FIGHTERS,param1);
      }
      
      public function set numVarl(param1:int) : void
      {
         this._setPopulationComponent(SagaVar.VAR_NUM_VARL,param1);
      }
      
      public function set numPeasants(param1:int) : void
      {
         this._setPopulationComponent(SagaVar.VAR_NUM_PEASANTS,param1);
      }
      
      private function updatePopulation() : void
      {
         var _loc1_:IVariable = saga.getVar(SagaVar.VAR_NUM_POPULATION,null);
         if(_loc1_)
         {
            _loc1_.asAny = this.numPeasants + this.numFighters + this.numVarl;
         }
      }
      
      public function get numHeroes() : int
      {
         var _loc2_:IEntityDef = null;
         var _loc1_:int = 0;
         for each(_loc2_ in saga.caravan._legend.roster)
         {
            if(_loc2_.stats.getValue(StatType.STRENGTH) > 0)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
   }
}
