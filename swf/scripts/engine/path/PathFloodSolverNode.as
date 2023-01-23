package engine.path
{
   public class PathFloodSolverNode extends PathHeuristicSolverNode
   {
       
      
      public var hazardHeuristic:Number = 0;
      
      public function PathFloodSolverNode(param1:IPathGraphNode)
      {
         super(param1);
      }
      
      override public function toString() : String
      {
         return super.toString() + " hz=" + this.hazardHeuristic;
      }
      
      override public function reset(param1:IPathGraphNode) : void
      {
         super.reset(param1);
         this.hazardHeuristic = 0;
      }
   }
}
