package engine.battle.board.view.phantasm
{
   import engine.battle.ability.phantasm.def.PhantasmDefColorPulsator;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.view.EntityView;
   import flash.errors.IllegalOperationError;
   
   public class PhantasmViewColorPulsator extends PhantasmView
   {
       
      
      private var defColorPulsator:PhantasmDefColorPulsator;
      
      private var entityView:EntityView;
      
      private var pulsatorId:String;
      
      private var ent:BattleEntity;
      
      public function PhantasmViewColorPulsator(param1:BattleBoardView, param2:ChainPhantasms, param3:PhantasmDefColorPulsator)
      {
         super(param1,param2,param3);
         this.needsRemove = true;
         this.defColorPulsator = param3;
      }
      
      override public function execute() : void
      {
         super.execute();
         if(!chain.effect)
         {
            return;
         }
         this.ent = chain.effect.target as BattleEntity;
         if(!this.ent)
         {
            throw new IllegalOperationError("no ent?");
         }
         this.pulsatorId = this.ent.addColorPulsator(this.defColorPulsator.pulsator);
      }
      
      override public function remove() : void
      {
         super.remove();
         if(Boolean(this.ent) && Boolean(this.pulsatorId))
         {
            this.ent.removeColorPulsator(this.pulsatorId);
         }
         this.pulsatorId = null;
         this.ent = null;
      }
   }
}
