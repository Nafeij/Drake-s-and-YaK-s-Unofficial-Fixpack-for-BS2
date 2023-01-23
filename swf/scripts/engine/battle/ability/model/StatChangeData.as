package engine.battle.ability.model
{
   public class StatChangeData
   {
       
      
      public var other:int;
      
      public var amount:int;
      
      public var missChance:int;
      
      public function StatChangeData()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.amount + "@" + this.missChance;
      }
   }
}
