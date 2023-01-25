package engine.path
{
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class PathFloodSolver implements IPathFloodResult
   {
      
      public static var ENABLE_REJECTED_DEBUG:Boolean;
      
      public static var _nodeCache:Vector.<PathFloodSolverNode> = new Vector.<PathFloodSolverNode>();
       
      
      private var open:Dictionary;
      
      public var closed:Dictionary;
      
      private var nodes:Dictionary;
      
      public var resultSet:Dictionary;
      
      public var resultList:Array;
      
      private var openQueue:Array;
      
      public var complete:Boolean;
      
      public var success:Boolean;
      
      public var steps:int;
      
      public var invalidated:Boolean;
      
      public var nodeBlockedFunc:Function;
      
      public var src:IPathGraphNode;
      
      public var costLimit:Number;
      
      private var heuristic:Function;
      
      private var hazardHeuristic:Function;
      
      public var refcount:int;
      
      public var cleanedup:Boolean;
      
      public var cacheKey:String;
      
      public var desc:String;
      
      public var rejected:Dictionary;
      
      public function PathFloodSolver(param1:IPathGraphNode, param2:Function, param3:Function, param4:Function, param5:Number, param6:String, param7:String)
      {
         this.open = new Dictionary();
         this.closed = new Dictionary();
         this.nodes = new Dictionary();
         this.resultSet = new Dictionary();
         this.resultList = [];
         this.openQueue = new Array();
         super();
         this.cacheKey = param6;
         this.desc = param7;
         this.costLimit = param5;
         this.src = param1;
         this.nodeBlockedFunc = param4;
         this.heuristic = param2;
         this.hazardHeuristic = param3;
         var _loc8_:PathFloodSolverNode = this.getNode(param1);
         _loc8_.gg = _loc8_.hazardHeuristic;
         this.openQueue.push(_loc8_);
         this.open[_loc8_] = _loc8_;
         if(ENABLE_REJECTED_DEBUG)
         {
            this.rejected = new Dictionary();
         }
      }
      
      public static function clearCache() : void
      {
         _nodeCache.splice(0,_nodeCache.length);
      }
      
      public function cleanup() : void
      {
         var _loc1_:PathFloodSolverNode = null;
         if(this.cleanedup)
         {
            return;
         }
         this.cleanedup = true;
         for each(_loc1_ in this.nodes)
         {
            _loc1_.cleanup();
            if(_nodeCache)
            {
               _nodeCache.push(_loc1_);
            }
         }
         this.heuristic = null;
         this.nodeBlockedFunc = null;
         this.src = null;
         this.open = null;
         this.openQueue = null;
         this.resultList = null;
         this.resultSet = null;
         this.nodes = null;
         this.closed = null;
         this.open = null;
      }
      
      public function hasNode(param1:IPathGraphNode) : Boolean
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         return this.nodes[param1] != null;
      }
      
      public function hasResultKey(param1:Object) : Boolean
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         return this.resultSet[param1] != null;
      }
      
      public function getNode(param1:IPathGraphNode) : PathFloodSolverNode
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         if(!param1)
         {
            return null;
         }
         var _loc2_:PathFloodSolverNode = this.nodes[param1];
         if(!_loc2_)
         {
            if(Boolean(_nodeCache) && Boolean(_nodeCache.length))
            {
               _loc2_ = _nodeCache.pop();
               _loc2_.reset(param1);
            }
            else
            {
               _loc2_ = new PathFloodSolverNode(param1);
            }
            if(this.hazardHeuristic != null)
            {
               _loc2_.hazardHeuristic = this.hazardHeuristic(param1.key);
            }
            this.nodes[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function getNodesAtDistance(param1:int) : Array
      {
         var _loc3_:PathFloodSolverNode = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         var _loc2_:Array = [];
         for each(_loc3_ in this.nodes)
         {
            if(_loc3_.g == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function update(param1:int, param2:Function) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:PathFloodSolverNode = null;
         var _loc8_:Object = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         var _loc3_:int = null != param2 ? param2() : 0;
         while(!this.complete)
         {
            this.complete = this.step();
            ++this.steps;
            if(param2 != null)
            {
               _loc6_ = param2() - _loc3_;
               if(!this.complete)
               {
                  if(param1 >= 0 && _loc6_ > param1)
                  {
                     return;
                  }
               }
            }
         }
         this.complete = true;
         for(_loc5_ in this.resultSet)
         {
            _loc7_ = this.resultSet[_loc5_];
            if(this.nodeBlockedFunc(_loc7_.node,false))
            {
               if(!_loc4_)
               {
                  _loc4_ = [];
               }
               _loc4_.push(_loc5_);
            }
         }
         if(_loc4_)
         {
            for each(_loc8_ in _loc4_)
            {
               delete this.resultSet[_loc8_];
            }
         }
      }
      
      public function step() : Boolean
      {
         var _loc2_:IPathGraphLink = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:PathFloodSolverNode = null;
         var _loc6_:Object = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Object = null;
         var _loc13_:Object = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         if(this.openQueue.length == 0)
         {
            return true;
         }
         var _loc1_:PathFloodSolverNode = this.openQueue.pop();
         delete this.open[_loc1_];
         this.closed[_loc1_] = _loc1_;
         for each(_loc2_ in _loc1_.node.links)
         {
            _loc5_ = this.getNode(_loc2_.dst);
            _loc6_ = _loc5_.node.key;
            if(this.nodeBlockedFunc != null)
            {
               if(this.nodeBlockedFunc(_loc5_.node,true))
               {
                  if(this.rejected)
                  {
                     this.rejected[_loc6_] = "blocked";
                  }
                  continue;
               }
            }
            if(!_loc5_.node.enabled)
            {
               if(this.rejected)
               {
                  this.rejected[_loc6_] = "disabled";
               }
            }
            else if(_loc5_ == _loc1_)
            {
               if(this.rejected)
               {
                  this.rejected[_loc6_] = "closed";
               }
            }
            else if(this.closed[_loc5_])
            {
               if(this.rejected)
               {
                  this.rejected[_loc6_] = "closed";
               }
            }
            else
            {
               _loc7_ = 1 + _loc2_.cost + _loc2_.dst.cost;
               _loc8_ = _loc1_.g + _loc7_;
               _loc9_ = _loc1_.gg + _loc5_.hazardHeuristic + _loc7_;
               if(_loc8_ > this.costLimit)
               {
                  if(this.rejected)
                  {
                     this.rejected[_loc6_] = "cost";
                  }
               }
               else
               {
                  this.resultSet[_loc5_.node.key] = _loc5_;
                  this.resultList.push(_loc5_.node.key);
                  _loc10_ = false;
                  _loc11_ = false;
                  if(!this.open[_loc5_])
                  {
                     this.open[_loc5_] = _loc5_;
                     this.openQueue.push(_loc5_);
                     _loc10_ = true;
                     if(this.heuristic != null)
                     {
                        _loc12_ = this.src.key;
                        _loc13_ = _loc5_.node.key;
                        _loc5_.h = this.heuristic(_loc12_,_loc13_);
                     }
                  }
                  else if(_loc9_ < _loc5_.gg)
                  {
                     _loc11_ = true;
                  }
                  if(_loc11_ || _loc10_)
                  {
                     _loc5_.parentLink = _loc2_;
                     _loc5_.parent = _loc1_;
                     _loc5_.g = _loc8_;
                     _loc5_.gg = _loc9_;
                  }
               }
            }
         }
         _loc3_ = int(this.openQueue.length);
         this.openQueue.sort(this.openQueueComparator);
         _loc4_ = int(this.openQueue.length);
         if(_loc4_ != _loc3_)
         {
            throw new IllegalOperationError("Failed to sort the array: resulted " + _loc4_ + " length, expected " + _loc3_);
         }
         return false;
      }
      
      private function openQueueComparator(param1:PathFloodSolverNode, param2:PathFloodSolverNode) : int
      {
         if(param1.f < param2.f)
         {
            return 1;
         }
         if(param2.f < param1.f)
         {
            return -1;
         }
         return 0;
      }
      
      public function reconstructPathTo(param1:IPathGraphNode) : IPath
      {
         var _loc5_:IPathGraphLink = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         var _loc2_:PathHeuristicSolverNode = this.getNode(param1);
         var _loc3_:Vector.<IPathGraphLink> = new Vector.<IPathGraphLink>();
         while(Boolean(_loc2_) && _loc2_.node != this.src)
         {
            _loc5_ = _loc2_.parentLink;
            if(!_loc5_)
            {
               return null;
            }
            _loc3_.push(_loc5_);
            _loc2_ = _loc2_.parent;
         }
         _loc3_.reverse();
         var _loc4_:Path = new Path(this.src,param1);
         _loc4_.links = _loc3_;
         _loc4_.status = PathStatus.COMPLETE;
         return _loc4_;
      }
      
      public function inResultSet(param1:Object) : Boolean
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("PathFloodSolver has been cleanedup");
         }
         return this.resultSet[param1] != null;
      }
      
      public function get numResults() : int
      {
         return this.resultList.length;
      }
      
      public function getResultKey(param1:int) : Object
      {
         return this.resultList[param1];
      }
   }
}
