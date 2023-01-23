package engine.battle.ai.phase
{
   import engine.battle.ai.Ai;
   import engine.battle.ai.def.AiCtor;
   import engine.battle.ai.def.AiPlanningModuleDef;
   import engine.battle.ai.plan.AiPlanningModule;
   import engine.battle.ai.strat.AiStrat;
   
   public class AiPhase_Plan extends AiPhase
   {
       
      
      public var modules:Vector.<AiPlanningModule>;
      
      public var _strat:AiStrat;
      
      public function AiPhase_Plan(param1:Ai)
      {
         var _loc2_:AiPlanningModuleDef = null;
         var _loc3_:AiPlanningModule = null;
         this.modules = new Vector.<AiPlanningModule>();
         super(param1);
         for each(_loc2_ in param1.def.planningModuleDefs)
         {
            _loc3_ = AiCtor.ctorPlanningModule(this,_loc2_);
            this.modules.push(_loc3_);
         }
      }
      
      override public function update(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:AiPlanningModule = null;
         super.update(param1);
         for each(_loc3_ in this.modules)
         {
            if(!_loc3_.complete)
            {
               _loc3_.update(param1);
            }
            if(!_loc3_.complete)
            {
               _loc2_++;
            }
         }
         if(!_loc2_)
         {
            complete = true;
         }
      }
      
      public function considerStrat(param1:AiStrat) : Boolean
      {
         if(!this._strat || param1.weight > this._strat.weight)
         {
            this.strat = param1;
            return true;
         }
         return false;
      }
      
      public function set strat(param1:AiStrat) : void
      {
         if(this._strat == param1)
         {
            return;
         }
         if(this._strat)
         {
            this._strat.cleanup();
         }
         this._strat = param1;
      }
   }
}
