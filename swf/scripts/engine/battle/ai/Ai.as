package engine.battle.ai
{
   import engine.battle.ai.def.AiDef;
   import engine.battle.ai.phase.AiPhase;
   import engine.battle.ai.phase.AiPhaseOrder;
   import engine.battle.ai.strat.AiStrat;
   import engine.battle.fsm.aimodule.AiConfig;
   
   public class Ai
   {
       
      
      public var def:AiDef;
      
      private var _phase:AiPhase;
      
      public var complete:Boolean;
      
      public var config:AiConfig;
      
      public var strat:AiStrat;
      
      public var entity:IAiEntity;
      
      public var enemies:Vector.<IAiEntity>;
      
      private var _startTickMs:int;
      
      public var _lastTickTimeMs:int;
      
      public var _lastTickStopped:Boolean;
      
      public function Ai(param1:AiDef, param2:AiConfig)
      {
         this.enemies = new Vector.<IAiEntity>();
         super();
         this.def = param1;
         this.config = param2;
      }
      
      public function get phase() : AiPhase
      {
         return this._phase;
      }
      
      public function set phase(param1:AiPhase) : void
      {
         if(this._phase == param1)
         {
            return;
         }
         if(this._phase)
         {
            this._phase.cleanup();
         }
         this._phase = param1;
      }
      
      public function update(param1:int) : void
      {
         this._lastTickTimeMs = 0;
         this._lastTickStopped = false;
         if(this.complete)
         {
            return;
         }
         if(!this._phase || this._phase.complete)
         {
            this.nextPhase();
         }
         if(this.complete)
         {
            return;
         }
         this._startTickMs = this.config.getTimerMs();
         this._phase.update(param1);
         var _loc2_:int = this.config.getTimerMs();
         var _loc3_:int = _loc2_ - this._startTickMs;
         this._phase.incrementElapsedThinkMs(_loc3_);
      }
      
      public function nextPhase() : void
      {
         if(this.complete)
         {
            return;
         }
         var _loc1_:Boolean = false;
         var _loc2_:Class = AiPhaseOrder.getNextClazz(this.phase,_loc1_);
         if(!_loc2_)
         {
            this.phase = null;
            this.complete = true;
            return;
         }
         this.phase = new _loc2_(this) as AiPhase;
      }
      
      final public function checkStopTick() : Boolean
      {
         if(this.config.max_think_ms < 0)
         {
            return false;
         }
         var _loc1_:int = this.config.getTimerMs();
         var _loc2_:int = _loc1_ - this._startTickMs;
         if(_loc2_ >= this.config.max_think_ms)
         {
            this._lastTickTimeMs = _loc2_;
            this._lastTickStopped = true;
            return true;
         }
         return false;
      }
   }
}
