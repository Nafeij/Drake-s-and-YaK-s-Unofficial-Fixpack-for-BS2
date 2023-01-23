package engine.stat.def
{
   public class StatRange
   {
       
      
      public var type:StatType;
      
      public var min:int;
      
      public var max:int;
      
      public function StatRange(param1:StatType, param2:int, param3:int)
      {
         super();
         this.type = param1;
         this.min = param2;
         this.max = param3;
      }
      
      public function clone() : StatRange
      {
         return new StatRange(this.type,this.min,this.max);
      }
   }
}
