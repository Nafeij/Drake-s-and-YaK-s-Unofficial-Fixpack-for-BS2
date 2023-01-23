package engine.path
{
   public class PathHeuristicSolverNode
   {
       
      
      public var f:Number = 0;
      
      public var node:IPathGraphNode;
      
      public var parentLink:IPathGraphLink;
      
      public var parent:PathHeuristicSolverNode;
      
      private var m_g:Number = 0;
      
      private var m_gg:Number = 0;
      
      private var m_h:Number = 0;
      
      public function PathHeuristicSolverNode(param1:IPathGraphNode)
      {
         super();
         this.node = param1;
      }
      
      public function toString() : String
      {
         return "node=" + this.node + " f=" + this.f + " gg=" + this.m_gg + " g=" + this.m_g + " h=" + this.m_h;
      }
      
      public function reset(param1:IPathGraphNode) : void
      {
         this.node = param1;
         this.f = 0;
         this.m_gg = 0;
         this.m_g = 0;
         this.m_h = 0;
         this.parentLink = null;
         this.parent = null;
      }
      
      public function cleanup() : void
      {
         this.node = null;
         this.parentLink = null;
         this.parent = null;
      }
      
      public function get g() : Number
      {
         return this.m_g;
      }
      
      public function set g(param1:Number) : void
      {
         this.m_g = param1;
         this.f = Math.max(this.m_g,this.m_gg) + this.m_h;
      }
      
      public function get gg() : Number
      {
         return this.m_gg;
      }
      
      public function set gg(param1:Number) : void
      {
         this.m_gg = param1;
         this.f = Math.max(this.m_g,this.m_gg) + this.m_h;
      }
      
      public function get h() : Number
      {
         return this.m_h;
      }
      
      public function set h(param1:Number) : void
      {
         this.m_h = param1;
         this.f = Math.max(this.m_g,this.m_gg) + this.m_h;
      }
   }
}
