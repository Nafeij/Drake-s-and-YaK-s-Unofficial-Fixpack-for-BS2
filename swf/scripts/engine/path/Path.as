package engine.path
{
   import flash.events.EventDispatcher;
   
   public class Path extends EventDispatcher implements IPath
   {
      
      private static var m_lastId:int;
       
      
      private var m_dst:IPathGraphNode;
      
      private var m_elapsed:int;
      
      private var m_links:Vector.<IPathGraphLink>;
      
      private var m_nodes:Vector.<IPathGraphNode>;
      
      private var m_src:IPathGraphNode;
      
      private var m_status:PathStatus;
      
      private var m_id:int;
      
      public function Path(param1:IPathGraphNode, param2:IPathGraphNode)
      {
         this.m_links = new Vector.<IPathGraphLink>();
         this.m_status = PathStatus.WAITING;
         super();
         this.m_id = ++m_lastId;
         if(!param1 || !param2)
         {
            throw new ArgumentError("bad nodes!");
         }
         this.m_src = param1;
         this.m_dst = param2;
      }
      
      public function get dispatcher() : EventDispatcher
      {
         return this;
      }
      
      public function get dst() : IPathGraphNode
      {
         return this.m_dst;
      }
      
      public function get elapsed() : int
      {
         return this.m_elapsed;
      }
      
      public function set elapsed(param1:int) : void
      {
         this.m_elapsed = param1;
      }
      
      public function get links() : Vector.<IPathGraphLink>
      {
         return this.m_links;
      }
      
      public function set links(param1:Vector.<IPathGraphLink>) : void
      {
         this.m_nodes = null;
         this.m_links = param1;
      }
      
      public function get nodes() : Vector.<IPathGraphNode>
      {
         this.cacheNodes();
         return this.m_nodes;
      }
      
      public function get src() : IPathGraphNode
      {
         return this.m_src;
      }
      
      public function get status() : PathStatus
      {
         return this.m_status;
      }
      
      public function set status(param1:PathStatus) : void
      {
         if(param1 != this.m_status)
         {
            this.m_status = param1;
            dispatchEvent(new PathEvent(PathEvent.EVENT_PATH_STATUS_CHANGED));
         }
      }
      
      private function cacheNodes() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IPathGraphLink = null;
         if(this.status != PathStatus.COMPLETE)
         {
            return;
         }
         if(!this.m_nodes)
         {
            if(Boolean(this.links) && this.links.length > 0)
            {
               this.m_nodes = new Vector.<IPathGraphNode>(this.links.length + 1);
               _loc1_ = 0;
               while(_loc1_ < this.links.length)
               {
                  _loc2_ = this.links[_loc1_];
                  this.m_nodes[_loc1_] = _loc2_.src;
                  _loc1_++;
               }
               this.m_nodes[this.links.length] = this.links[this.links.length - 1].dst;
            }
            else if(this.m_src == this.m_dst)
            {
               this.m_nodes = new Vector.<IPathGraphNode>(1);
               this.m_nodes[0] = this.m_src;
            }
            else
            {
               this.m_nodes = new Vector.<IPathGraphNode>();
            }
         }
      }
      
      private function simplify(param1:Function) : void
      {
         var _loc3_:IPathGraphLink = null;
         var _loc4_:IPathGraphLink = null;
         var _loc2_:int = 1;
         while(_loc2_ < this.links.length)
         {
            _loc3_ = this.links[_loc2_ - 1];
            _loc4_ = this.links[_loc2_];
            if(param1(_loc3_.src,_loc4_.src,_loc4_.dst))
            {
               this.links.splice(_loc2_,1);
            }
            else
            {
               _loc2_++;
            }
         }
      }
      
      override public function toString() : String
      {
         return "[Path " + this.m_id + " status=" + this.m_status.name + " len=" + (!!this.links ? this.links.length : 0) + " " + (!!this.m_nodes ? this.m_nodes.join(",") : "null") + "]";
      }
   }
}
