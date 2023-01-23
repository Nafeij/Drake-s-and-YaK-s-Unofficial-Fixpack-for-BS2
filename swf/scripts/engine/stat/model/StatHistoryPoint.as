package engine.stat.model
{
   public class StatHistoryPoint
   {
       
      
      public var turn:int;
      
      public var delta:int;
      
      public var cumulative:int;
      
      public function StatHistoryPoint(param1:int, param2:int, param3:int)
      {
         super();
         this.turn = param1;
         this.delta = param2;
         this.cumulative = param2 + param3;
      }
   }
}
