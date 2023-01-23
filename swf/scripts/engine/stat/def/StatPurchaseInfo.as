package engine.stat.def
{
   public class StatPurchaseInfo
   {
       
      
      public var stat:StatType;
      
      public var delta:int;
      
      public function StatPurchaseInfo(param1:StatType, param2:int)
      {
         this.stat = param1;
         this.delta = param2;
         super();
      }
   }
}
