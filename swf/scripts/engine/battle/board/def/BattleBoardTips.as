package engine.battle.board.def
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.IBattleTurn;
   import engine.core.logging.ILogger;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   
   public class BattleBoardTips
   {
       
      
      public var def:BattleBoardTipsDef;
      
      public var board:BattleBoard;
      
      public var logger:ILogger;
      
      public var saga:Saga;
      
      public var randomsAvailable:int;
      
      public var sagavars:Vector.<IVariable>;
      
      public var delayvar:IVariable;
      
      public var fsm:BattleFsm;
      
      public function BattleBoardTips(param1:BattleBoardTipsDef, param2:BattleBoard)
      {
         var _loc4_:BattleBoardTipDef = null;
         var _loc5_:String = null;
         var _loc6_:IVariable = null;
         this.sagavars = new Vector.<IVariable>();
         super();
         this.def = param1;
         this.board = param2;
         this.logger = param2.logger;
         this.saga = param2.scene.saga as Saga;
         var _loc3_:int = 0;
         while(_loc3_ < param1.randomCount)
         {
            _loc5_ = param1.randomVarPrefix + _loc3_.toString();
            _loc6_ = this.saga.getVar(_loc5_,VariableType.BOOLEAN);
            this.sagavars.push(_loc6_);
            if(!_loc6_ || !_loc6_.asBoolean)
            {
               ++this.randomsAvailable;
            }
            _loc3_++;
         }
         this.delayvar = this.saga.getVar(param1.delayVarname,VariableType.INTEGER);
         this.delayvar.def.lowerBound = -1;
         this.fsm = param2.fsm as BattleFsm;
         for each(_loc4_ in param1.tips)
         {
            if(!param2.abilityFactory.fetch(_loc4_.abilityId,false))
            {
               this.logger.error("No such ability for tips [" + _loc4_.abilityId + "]");
            }
         }
         this.fsm.addEventListener(BattleFsmEvent.TURN,this.battleFsmTurnHandler);
      }
      
      public function cleanup() : void
      {
         this.fsm.removeEventListener(BattleFsmEvent.TURN,this.battleFsmTurnHandler);
      }
      
      private function battleFsmTurnHandler(param1:BattleFsmEvent) : void
      {
         var _loc7_:IVariable = null;
         var _loc2_:IBattleTurn = this.board.fsm.turn;
         if(!_loc2_)
         {
            return;
         }
         if(!_loc2_.entity || !_loc2_.entity.isPlayer)
         {
            return;
         }
         if(this.randomsAvailable <= 0)
         {
            return;
         }
         var _loc3_:int = this.decrementDelay();
         if(_loc3_ > 0)
         {
            return;
         }
         var _loc4_:int = MathUtil.randomInt(0,this.randomsAvailable - 1);
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < this.def.randomCount)
         {
            _loc7_ = this.sagavars[_loc6_];
            if(!_loc7_ || !_loc7_.asBoolean)
            {
               if(_loc5_ == _loc4_)
               {
                  this.performRandom(_loc5_);
                  break;
               }
               _loc5_++;
            }
            _loc6_++;
         }
      }
      
      private function decrementDelay() : int
      {
         var _loc1_:int = this.delayvar.asInteger - 1;
         this.delayvar.asInteger = _loc1_;
         return _loc1_;
      }
      
      private function performRandom(param1:int) : void
      {
         this.saga.setVar(this.def.randomVarPrefix + param1.toString(),true);
         this.delayvar.asInteger = this.def.delayRandom;
         var _loc2_:String = this.def.randomTokenPrefix + param1.toString();
         this.performSpeak(_loc2_);
         --this.randomsAvailable;
      }
      
      private function performSpeak(param1:String) : void
      {
         var _loc2_:ActionDef = new ActionDef(null);
         _loc2_.type = ActionType.SPEAK;
         _loc2_.msg = param1;
         _loc2_.time = 6;
         _loc2_.anchor = this.def.speakAnchor;
         this.saga.executeActionDef(_loc2_,null,null);
      }
      
      public function triggerBattleAbilityCompleted(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc4_:BattleBoardTipDef = this.def.tipsByAbilityId[param2];
         if(!_loc4_)
         {
            return;
         }
         if(_loc4_.playerOnly && !param3)
         {
            return;
         }
         var _loc5_:IVariable = this.saga.getVar(_loc4_.varname,VariableType.BOOLEAN);
         if(Boolean(_loc5_) && _loc5_.asBoolean)
         {
            return;
         }
         this.delayvar.asInteger = this.def.delayRandom;
         this.performSpeak(_loc4_.token);
      }
   }
}
