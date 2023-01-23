package engine.battle.ai.phase
{
   import engine.battle.ai.Ai;
   import engine.battle.fsm.aimodule.AiConfig;
   
   public class AiPhase
   {
       
      
      public var ai:Ai;
      
      public var complete:Boolean;
      
      public var config:AiConfig;
      
      public var elapsedWallMs:int;
      
      public var elapsedThinkMs:int;
      
      public function AiPhase(param1:Ai)
      {
         super();
         this.ai = param1;
         this.config = param1.config;
      }
      
      public function cleanup() : void
      {
         this.ai = null;
      }
      
      public function update(param1:int) : void
      {
         this.elapsedWallMs += param1;
      }
      
      public function incrementElapsedThinkMs(param1:int) : void
      {
         this.elapsedThinkMs += param1;
      }
   }
}
