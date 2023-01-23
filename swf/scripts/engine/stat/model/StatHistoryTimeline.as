package engine.stat.model
{
   public class StatHistoryTimeline
   {
       
      
      public var points:Vector.<StatHistoryPoint>;
      
      public var turnProvider:IStatHistoryTurnProvider;
      
      public function StatHistoryTimeline(param1:IStatHistoryTurnProvider)
      {
         this.points = new Vector.<StatHistoryPoint>();
         super();
         this.turnProvider = param1;
      }
      
      public function get cumulative() : int
      {
         return this.points.length > 0 ? this.points[this.points.length - 1].cumulative : 0;
      }
      
      public function addDelta(param1:int) : void
      {
         var _loc2_:StatHistoryPoint = new StatHistoryPoint(this.turnProvider.turn,param1,this.cumulative);
         this.points.push(_loc2_);
      }
   }
}
