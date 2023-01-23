package engine.entity.def
{
   import engine.battle.board.model.IBattleEntity;
   
   public class ShitlistEntry
   {
       
      
      public var target:IBattleEntity;
      
      public var weight:int;
      
      public function ShitlistEntry(param1:IBattleEntity, param2:int)
      {
         super();
         this.target = param1;
         this.weight = param2;
      }
      
      public function toString() : String
      {
         return this.target + " w=" + this.weight;
      }
   }
}
