package engine.path
{
   public class PathGraphNode implements IPathGraphNode
   {
       
      
      public var m_cost:Number;
      
      public var m_key:Object;
      
      public var m_links:Vector.<IPathGraphLink>;
      
      public var _islandId:int = 0;
      
      internal var _enabled:Boolean = true;
      
      public var m_region:int;
      
      public function PathGraphNode(param1:Object, param2:Number, param3:int)
      {
         this.m_links = new Vector.<IPathGraphLink>();
         super();
         this.m_key = param1;
         this.m_cost = param2;
         this.m_region = param3;
      }
      
      public function get region() : int
      {
         return this.m_region;
      }
      
      public function set region(param1:int) : void
      {
         this.m_region = param1;
      }
      
      public function toString() : String
      {
         return !!this.m_key ? this.m_key.toString() : "NULL";
      }
      
      public function addLink(param1:IPathGraphNode, param2:Number) : IPathGraphLink
      {
         var _loc3_:IPathGraphLink = new PathGraphLink(this,param1,param2);
         this.m_links.push(_loc3_);
         return _loc3_;
      }
      
      public function get cost() : Number
      {
         return this.m_cost;
      }
      
      public function getLink(param1:IPathGraphNode) : IPathGraphLink
      {
         var _loc2_:IPathGraphLink = null;
         for each(_loc2_ in this.m_links)
         {
            if(_loc2_.dst == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function get key() : Object
      {
         return this.m_key;
      }
      
      public function get links() : Vector.<IPathGraphLink>
      {
         return this.m_links;
      }
      
      public function get islandId() : int
      {
         return this._islandId;
      }
      
      public function set islandId(param1:int) : void
      {
         this._islandId = param1;
      }
      
      public function get enabled() : Object
      {
         return this._enabled;
      }
   }
}
