package engine.stat.def
{
   public class StatModDef
   {
       
      
      public var amount:int;
      
      public var stat:StatType;
      
      public function StatModDef()
      {
         super();
      }
      
      public function clone() : StatModDef
      {
         var _loc1_:StatModDef = new StatModDef();
         _loc1_.amount = this.amount;
         _loc1_.stat = this.stat;
         return _loc1_;
      }
   }
}
