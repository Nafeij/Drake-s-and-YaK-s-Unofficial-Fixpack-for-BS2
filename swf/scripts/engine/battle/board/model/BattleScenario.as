package engine.battle.board.model
{
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.state.BattleStateFinish;
   import engine.battle.fsm.state.BattleStateFinished;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   
   public class BattleScenario implements IBattleScenario
   {
       
      
      public var def:BattleScenarioDef;
      
      public var board:IBattleBoard;
      
      public var objectives:Vector.<BattleObjective>;
      
      public var hints:Vector.<BattleObjective>;
      
      private var completes:int;
      
      public var _complete:Boolean;
      
      public var logger:ILogger;
      
      public var saga:ISaga;
      
      public function BattleScenario(param1:BattleScenarioDef, param2:IBattleBoard, param3:ISaga)
      {
         var _loc4_:BattleObjectiveDef = null;
         var _loc5_:BattleObjective = null;
         this.objectives = new Vector.<BattleObjective>();
         this.hints = new Vector.<BattleObjective>();
         super();
         this.saga = param3;
         this.board = param2;
         this.def = param1;
         this.logger = param2.logger;
         for each(_loc4_ in param1.objectives)
         {
            _loc5_ = _loc4_.createObjective(this);
            if(_loc5_)
            {
               this.objectives.push(_loc5_);
            }
            else
            {
               this.logger.info("BattleScenario " + param1.id + " skipping objective " + _loc4_);
            }
         }
         for each(_loc4_ in param1.hints)
         {
            _loc5_ = _loc4_.createHint(this);
            if(_loc5_)
            {
               this.hints.push(_loc5_);
            }
            else
            {
               this.logger.info("BattleScenario " + param1.id + " skipping hint " + _loc4_);
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:BattleObjective = null;
         for each(_loc1_ in this.objectives)
         {
            _loc1_.cleanup();
         }
         for each(_loc1_ in this.hints)
         {
            _loc1_.cleanup();
         }
         this.objectives = null;
      }
      
      public function handleBattleStarted() : void
      {
         var _loc1_:BattleObjective = null;
         for each(_loc1_ in this.objectives)
         {
            _loc1_.handleBattleStarted();
         }
         for each(_loc1_ in this.hints)
         {
            _loc1_.handleBattleStarted();
         }
      }
      
      public function handleTurnStart(param1:IBattleEntity) : void
      {
         var _loc2_:BattleObjective = null;
         for each(_loc2_ in this.objectives)
         {
            _loc2_.handleTurnStart(param1);
         }
         for each(_loc2_ in this.hints)
         {
            _loc2_.handleTurnStart(param1);
         }
      }
      
      public function handleFreeTurn(param1:IBattleEntity) : void
      {
         var _loc2_:BattleObjective = null;
         for each(_loc2_ in this.objectives)
         {
            _loc2_.handleFreeTurn(param1);
         }
         for each(_loc2_ in this.hints)
         {
            _loc2_.handleFreeTurn(param1);
         }
      }
      
      public function doCompleteAll() : void
      {
         var _loc1_:BattleObjective = null;
         this.doCompleteAllHints();
         for each(_loc1_ in this.objectives)
         {
            _loc1_.complete = true;
         }
      }
      
      public function doCompleteAllHints() : void
      {
         var _loc1_:BattleObjective = null;
         for each(_loc1_ in this.hints)
         {
            _loc1_.hintSuppress = true;
            _loc1_.complete = true;
         }
      }
      
      public function doExpireHintsForCompleteObjective(param1:String) : void
      {
         var _loc2_:BattleObjective = null;
         if(!param1)
         {
            return;
         }
         for each(_loc2_ in this.hints)
         {
            if(_loc2_.def.requiredObjectivesIncompleteDict)
            {
               if(_loc2_.def.requiredObjectivesIncompleteDict[param1])
               {
                  _loc2_.hintSuppress = true;
                  _loc2_.complete = true;
               }
            }
         }
      }
      
      public function handleObjectiveComplete(param1:BattleObjective) : void
      {
         var _loc2_:String = null;
         if(param1.hint)
         {
            if(!param1.hintSuppress)
            {
               this.logger.info("HINT " + param1.def.token);
               if(this.saga)
               {
                  _loc2_ = this.saga.locale.translate(LocaleCategory.BATTLE_OBJ,param1.def.token);
                  this.saga.performSpeak(null,null,_loc2_,5,"landscape.anchor_tips",null,false);
               }
            }
            return;
         }
         ++this.completes;
         if(param1.def.id)
         {
            this.doExpireHintsForCompleteObjective(param1.def.id);
         }
         if(this.completes >= this.objectives.length)
         {
            this._complete = true;
            this.doCompleteAllHints();
            this.terminateBattle(true);
         }
      }
      
      public function terminateBattle(param1:Boolean) : void
      {
         this.logger.info("BattleScenario.terminateBattle win=" + param1);
         var _loc2_:IBattleFsm = !!this.board ? this.board.fsm : null;
         if(_loc2_)
         {
            if(!_loc2_.aborted)
            {
               if(_loc2_.currentClass != BattleStateFinish && _loc2_.currentClass != BattleStateFinished)
               {
                  _loc2_.abortBattle(param1);
               }
            }
         }
      }
      
      public function handleBattleWin() : void
      {
         var _loc4_:BattleObjective = null;
         var _loc1_:IBattleFsm = !!this.board ? this.board.fsm : null;
         var _loc2_:BattleTurn = !!_loc1_ ? _loc1_.turn as BattleTurn : null;
         var _loc3_:BattleTurnOrder = !!_loc1_ ? _loc1_.order as BattleTurnOrder : null;
         if(Boolean(_loc3_) && Boolean(_loc2_))
         {
            if(Boolean(_loc2_._entity) && _loc2_._entity == _loc3_._freeTurn)
            {
               ++_loc2_._entity.freeTurns;
               _loc3_._freeTurn = null;
               this.handleFreeTurn(_loc2_._entity);
            }
         }
         for each(_loc4_ in this.objectives)
         {
            _loc4_.handleBattleWin();
         }
         if(!this._complete)
         {
            this.logger.info("Scenario \'won\' the battle but objectives were not met.  fail.");
            this.terminateBattle(false);
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
   }
}
