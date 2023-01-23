package engine.battle.board.model
{
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleObjective extends EventDispatcher
   {
       
      
      public var def:BattleObjectiveDef;
      
      public var board:IBattleBoard;
      
      public var _complete:Boolean;
      
      public var count:int;
      
      public var logger:ILogger;
      
      public var manager:BattleAbilityManager;
      
      public var scenario:BattleScenario;
      
      public var hint:Boolean;
      
      public var hintSuppress:Boolean;
      
      public var rules:Vector.<BattleObjectiveRule>;
      
      private var entityAliveDispatchers:Vector.<IBattleEntity>;
      
      private var saga:ISaga;
      
      public function BattleObjective(param1:BattleScenario, param2:BattleObjectiveDef, param3:Object, param4:ISaga)
      {
         var _loc5_:BattleObjectiveRuleDef = null;
         var _loc6_:BattleObjectiveRule = null;
         this.rules = new Vector.<BattleObjectiveRule>();
         super();
         this.saga = param4;
         this.scenario = param1;
         this.saga = param4;
         this.board = param1.board;
         this.def = param2;
         this.manager = this.board.abilityManager as BattleAbilityManager;
         this.logger = this.board.logger;
         for each(_loc5_ in param2.rules)
         {
            _loc6_ = _loc5_.createObjectiveRule(this);
            this.rules.push(_loc6_);
         }
      }
      
      public function handleBattleWin() : void
      {
         var _loc1_:BattleObjectiveRule = null;
         for each(_loc1_ in this.rules)
         {
            if(this._complete)
            {
               break;
            }
            if(!_loc1_.complete)
            {
               _loc1_.handleBattleWin();
            }
         }
      }
      
      public function handleBattleStarted() : void
      {
         var _loc1_:BattleObjectiveRule = null;
         var _loc2_:String = null;
         var _loc3_:IBattleEntity = null;
         if(Boolean(this.def.requiredPlayerUnits) && !this.hint)
         {
            this.entityAliveDispatchers = new Vector.<IBattleEntity>();
            for each(_loc2_ in this.def.requiredPlayerUnits)
            {
               _loc3_ = this.board.getEntityByIdOrByDefId(_loc2_,null,false);
               if(!_loc3_)
               {
                  this.logger.error("Required unit [" + _loc2_ + "] not present at battle start for " + this);
               }
               else
               {
                  _loc3_.addEventListener(BattleEntityEvent.ALIVE,this.requiredAliveHandler);
                  this.entityAliveDispatchers.push(_loc3_);
               }
            }
         }
         for each(_loc1_ in this.rules)
         {
            if(this._complete)
            {
               break;
            }
            if(!_loc1_.complete)
            {
               _loc1_.handleBattleStarted();
            }
         }
      }
      
      private function requiredAliveHandler(param1:BattleEntityEvent) : void
      {
         if(this.hint)
         {
            return;
         }
         if(this.complete)
         {
            return;
         }
         this.scenario.terminateBattle(false);
      }
      
      override public function toString() : String
      {
         return !!this.def ? this.def.toString() : null;
      }
      
      protected function handleComplete() : void
      {
      }
      
      public function handleFreeTurn(param1:IBattleEntity) : void
      {
         var _loc2_:BattleObjectiveRule = null;
         for each(_loc2_ in this.rules)
         {
            if(this._complete)
            {
               break;
            }
            if(!_loc2_.complete)
            {
               _loc2_.handleFreeTurn(param1);
            }
         }
      }
      
      public function handleTurnStart(param1:IBattleEntity) : void
      {
         var _loc2_:BattleObjectiveRule = null;
         for each(_loc2_ in this.rules)
         {
            if(this._complete)
            {
               break;
            }
            if(!_loc2_.complete)
            {
               _loc2_.handleTurnStart(param1);
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:IBattleEntity = null;
         for each(_loc1_ in this.entityAliveDispatchers)
         {
            _loc1_.removeEventListener(BattleEntityEvent.ALIVE,this.requiredAliveHandler);
         }
         this.manager = null;
         this.board = null;
         this.def = null;
      }
      
      public function set complete(param1:Boolean) : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:Saga = null;
         if(this._complete == param1)
         {
            return;
         }
         if(param1 && Boolean(this.def.count))
         {
            ++this.count;
            this.logger.info("  COUNT " + this.count + " / " + this.def.count);
            dispatchEvent(new Event(Event.CHANGE));
            if(this.count < this.def.count)
            {
               return;
            }
         }
         this._complete = param1;
         if(this._complete)
         {
            this.logger.info("BattleObjective.complete " + this);
            if(this.def.negate)
            {
               this.scenario.terminateBattle(false);
               return;
            }
            for each(_loc2_ in this.entityAliveDispatchers)
            {
               _loc2_.removeEventListener(BattleEntityEvent.ALIVE,this.requiredAliveHandler);
            }
            _loc3_ = Saga.instance;
            if(_loc3_ && _loc3_.sound && _loc3_.sound.system && Boolean(_loc3_.sound.system.controller))
            {
               _loc3_.sound.system.controller.playSound("ui_training_tent_success",null);
            }
            this.handleComplete();
            dispatchEvent(new Event(Event.COMPLETE));
            if(this.scenario)
            {
               this.scenario.handleObjectiveComplete(this);
            }
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function handleRuleFailed(param1:BattleObjectiveRule) : void
      {
         this.scenario.terminateBattle(false);
      }
      
      public function handleRuleComplete(param1:BattleObjectiveRule) : void
      {
         var _loc2_:BattleObjectiveRuleDef = null;
         var _loc3_:int = 0;
         var _loc4_:BattleObjectiveRule = null;
         this.complete = true;
         if(!this._complete)
         {
            if(param1._complete)
            {
               _loc2_ = param1.def;
               _loc3_ = this.rules.indexOf(param1);
               param1.cleanup();
               _loc4_ = _loc2_.createObjectiveRule(this);
               this.rules[_loc3_] = _loc4_;
            }
         }
      }
   }
}
