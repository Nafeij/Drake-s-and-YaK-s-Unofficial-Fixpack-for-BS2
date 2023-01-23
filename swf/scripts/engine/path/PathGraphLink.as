package engine.path
{
   public class PathGraphLink implements IPathGraphLink
   {
       
      
      private var m_cost:Number;
      
      private var m_dst:IPathGraphNode;
      
      private var m_src:IPathGraphNode;
      
      private var m_isDisabled:Boolean;
      
      public function PathGraphLink(param1:IPathGraphNode, param2:IPathGraphNode, param3:Number)
      {
         super();
         if(!param1 || !param2 || param1 == param2)
         {
            throw new ArgumentError("bad nodes!");
         }
         this.m_src = param1;
         this.m_dst = param2;
         this.m_cost = param3;
      }
      
      public function toString() : String
      {
         return this.m_src + "->" + this.m_dst;
      }
      
      public function get cost() : Number
      {
         return this.m_cost;
      }
      
      public function get dst() : IPathGraphNode
      {
         return this.m_dst;
      }
      
      public function get src() : IPathGraphNode
      {
         return this.m_src;
      }
      
      public function get isDisabled() : Boolean
      {
         return this.m_isDisabled;
      }
      
      public function set isDisabled(param1:Boolean) : void
      {
         this.m_isDisabled = param1;
      }
   }
}
