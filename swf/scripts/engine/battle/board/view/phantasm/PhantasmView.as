package engine.battle.board.view.phantasm
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.phantasm.def.PhantasmDef;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.logging.ILogger;
   
   public class PhantasmView
   {
       
      
      public var boardView:BattleBoardView;
      
      public var def:PhantasmDef;
      
      public var chain:ChainPhantasms;
      
      public var needsUpdate:Boolean;
      
      public var needsRemove:Boolean;
      
      public var effect:Effect;
      
      public var logger:ILogger;
      
      public function PhantasmView(param1:BattleBoardView, param2:ChainPhantasms, param3:PhantasmDef)
      {
         super();
         this.def = param3;
         this.boardView = param1;
         this.chain = param2;
         this.effect = param2.effect;
         this.logger = param1.board.logger;
      }
      
      public function toString() : String
      {
         return "def=" + this.def;
      }
      
      public function cleanup() : void
      {
         if(this.needsRemove)
         {
            this.remove();
         }
      }
      
      public function execute() : void
      {
      }
      
      public function remove() : void
      {
      }
      
      public function update(param1:int) : Boolean
      {
         return false;
      }
   }
}
