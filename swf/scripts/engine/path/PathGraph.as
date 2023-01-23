package engine.path
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class PathGraph implements IPathGraph
   {
       
      
      private var _nodes:Dictionary;
      
      private var solvers:Vector.<PathHeuristicSolver>;
      
      private var updateSolvers:Vector.<PathHeuristicSolver>;
      
      private var _heuristicDistance:Function;
      
      private var _coherenceHeuristic:Function;
      
      internal var timingFunction:Function;
      
      private var graphDirty:Boolean = false;
      
      private var logger:ILogger;
      
      private var _regionsMapping:PathRegionsMapping;
      
      private var updating:Boolean;
      
      private var islandSizes:Dictionary;
      
      public function PathGraph(param1:Function, param2:Function, param3:ILogger, param4:PathRegionsMapping)
      {
         this._nodes = new Dictionary();
         this.solvers = new Vector.<PathHeuristicSolver>();
         this.updateSolvers = new Vector.<PathHeuristicSolver>();
         this.timingFunction = getTimer;
         this.islandSizes = new Dictionary();
         super();
         this._heuristicDistance = param1;
         this._coherenceHeuristic = param2;
         this.logger = param3;
         this._regionsMapping = param4;
         PathDebug.it.addEventListener(PathDebugEvent.PATHFINDING_ENABLED,this.pathfindingEnabledHandler);
      }
      
      public function cleanup() : void
      {
         var _loc1_:PathHeuristicSolver = null;
         PathDebug.it.removeEventListener(PathDebugEvent.PATHFINDING_ENABLED,this.pathfindingEnabledHandler);
         this._heuristicDistance = null;
         this._coherenceHeuristic = null;
         this.logger = null;
         for each(_loc1_ in this.solvers)
         {
            _loc1_.cleanup();
            _loc1_ = null;
         }
         this.solvers = null;
      }
      
      protected function pathfindingEnabledHandler(param1:PathDebugEvent) : void
      {
         var _loc2_:PathHeuristicSolver = null;
         if(!PathDebug.it.pathfindingEnabled)
         {
            for each(_loc2_ in this.solvers)
            {
               if(_loc2_.path.status != PathStatus.TERMINATE)
               {
                  _loc2_.path.status = PathStatus.TERMINATE;
               }
            }
            this.solvers.splice(0,this.solvers.length);
         }
      }
      
      public function get nodes() : Dictionary
      {
         return this._nodes;
      }
      
      public function addLinkPair(param1:Object, param2:Object, param3:Number) : void
      {
         this.addLink(param1,param2,param3);
         this.addLink(param2,param1,param3);
      }
      
      public function addLink(param1:Object, param2:Object, param3:Number) : IPathGraphLink
      {
         this.graphDirty = true;
         var _loc4_:IPathGraphNode = this.getNode(param1);
         var _loc5_:IPathGraphNode = this.getNode(param2);
         if(!_loc4_)
         {
            throw new ArgumentError("no such src");
         }
         if(!_loc5_)
         {
            throw new ArgumentError("no such dst");
         }
         return _loc4_.addLink(_loc5_,param3);
      }
      
      public function addNodes(param1:Array, param2:Array, param3:Array) : void
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = Boolean(param2) && param2.length > _loc4_ ? int(param2[_loc4_]) : 0;
            _loc7_ = Boolean(param3) && param3.length > _loc4_ ? int(param3[_loc4_]) : 0;
            this.addNode(_loc5_,_loc6_,_loc7_);
            _loc4_++;
         }
      }
      
      public function addNode(param1:Object, param2:Number, param3:int) : IPathGraphNode
      {
         this.graphDirty = true;
         var _loc4_:IPathGraphNode = new PathGraphNode(param1,param2,param3);
         this.nodes[param1] = _loc4_;
         return _loc4_;
      }
      
      public function getLink(param1:Object, param2:Object) : IPathGraphLink
      {
         var _loc3_:IPathGraphNode = this.getNode(param1);
         var _loc4_:IPathGraphNode = this.getNode(param2);
         if(!_loc3_)
         {
            throw new ArgumentError("no such src");
         }
         if(!_loc4_)
         {
            throw new ArgumentError("no such dst");
         }
         return _loc3_.getLink(_loc4_);
      }
      
      public function getLinks(param1:Object) : Vector.<IPathGraphLink>
      {
         var _loc2_:IPathGraphNode = this.getNode(param1);
         if(!_loc2_)
         {
            throw new ArgumentError("no such source");
         }
         return _loc2_.links;
      }
      
      public function getNode(param1:Object) : IPathGraphNode
      {
         if(param1 is IPathGraphNode)
         {
            return param1 as IPathGraphNode;
         }
         return this.nodes[param1];
      }
      
      public function getPath(param1:Object, param2:Object, param3:Function, param4:Function) : IPath
      {
         if(!PathDebug.it.pathfindingEnabled)
         {
            return null;
         }
         if(this.graphDirty)
         {
            throw new IllegalOperationError("Cannot pathfind until graph is finished generating");
         }
         var _loc5_:IPathGraphNode = this.getNode(param1);
         var _loc6_:IPathGraphNode = this.getNode(param2);
         if(!_loc5_)
         {
            throw new ArgumentError("no such src");
         }
         if(!_loc6_)
         {
            throw new ArgumentError("no such dst");
         }
         if(_loc5_.islandId != _loc6_.islandId)
         {
            this.logger.info("PathGraph: Attempt to pathfind across islands... cannot succeed.");
            return null;
         }
         if(param3 != null)
         {
            if(param3(_loc5_))
            {
               this.logger.info("PathGraph: source node is blocked for this solver");
               return null;
            }
            if(param3(_loc6_))
            {
               this.logger.info("PathGraph: destination node is blocked for this solver");
               return null;
            }
         }
         if(!_loc5_.enabled)
         {
            this.logger.info("PathGraph: source node is disabled");
            return null;
         }
         if(!_loc6_.enabled)
         {
            this.logger.info("PathGraph: destination node is disabled");
            return null;
         }
         var _loc7_:IPath = new Path(_loc5_,_loc6_);
         var _loc8_:PathHeuristicSolver = new PathHeuristicSolver(_loc7_,this._heuristicDistance,this._coherenceHeuristic,param3,param4,this._regionsMapping);
         this.solvers.push(_loc8_);
         return _loc7_;
      }
      
      public function update(param1:int) : void
      {
         var _loc6_:PathHeuristicSolver = null;
         if(this.solvers.length == 0)
         {
            return;
         }
         this.updating = true;
         var _loc2_:Vector.<PathHeuristicSolver> = this.updateSolvers;
         this.updateSolvers = this.solvers;
         this.solvers = _loc2_;
         this.solvers.splice(0,this.solvers.length);
         var _loc3_:int = this.timingFunction();
         var _loc4_:int = 0;
         var _loc5_:* = false;
         for each(_loc6_ in this.updateSolvers)
         {
            if(_loc6_.invalidated)
            {
               _loc6_ = new PathHeuristicSolver(_loc6_.path,this._heuristicDistance,this._coherenceHeuristic,_loc6_.nodeBlockedFunc,_loc6_.nodeHazardFunc,this._regionsMapping);
            }
            if(_loc6_.path.status != PathStatus.TERMINATE)
            {
               if(_loc5_)
               {
                  this.solvers.push(_loc6_);
               }
               else
               {
                  _loc6_.update(param1,this.timingFunction);
                  _loc4_ = param1 >= 0 ? this.timingFunction() - _loc3_ : param1;
                  if(param1 >= 0)
                  {
                     _loc5_ = _loc4_ > param1;
                  }
                  if(!_loc6_.complete)
                  {
                     this.solvers.push(_loc6_);
                  }
               }
            }
         }
         this.updating = false;
      }
      
      public function finishGraphGeneration(param1:int, param2:Function) : void
      {
         this.destroyNodeIslands();
         this.assignNodeIslands();
         this.cullNodeIslands(param1,param2);
         this.graphDirty = false;
      }
      
      private function destroyNodeIslands() : void
      {
         var _loc1_:* = null;
         var _loc2_:PathGraphNode = null;
         for(_loc1_ in this._nodes)
         {
            _loc2_ = this._nodes[_loc1_] as PathGraphNode;
            _loc2_.islandId = 0;
         }
      }
      
      private function assignNodeIslandIteratively(param1:PathGraphNode, param2:int, param3:Dictionary) : int
      {
         var _loc6_:PathGraphNode = null;
         var _loc7_:IPathGraphLink = null;
         var _loc4_:Vector.<PathGraphNode> = new Vector.<PathGraphNode>();
         _loc4_.push(param1);
         delete param3[param1];
         var _loc5_:int = 0;
         while(_loc4_.length)
         {
            _loc6_ = _loc4_.pop();
            if(_loc6_.islandId == 0)
            {
               _loc6_.islandId = param2;
               _loc5_++;
            }
            for each(_loc7_ in _loc6_.links)
            {
               if(param3[_loc7_.dst])
               {
                  delete param3[_loc7_.dst];
                  _loc4_.push(_loc7_.dst as PathGraphNode);
               }
            }
         }
         return _loc5_;
      }
      
      private function createOpenSet() : Dictionary
      {
         var _loc2_:* = null;
         var _loc3_:PathGraphNode = null;
         var _loc1_:Dictionary = new Dictionary();
         for(_loc2_ in this._nodes)
         {
            _loc3_ = this._nodes[_loc2_] as PathGraphNode;
            _loc1_[_loc3_] = _loc3_;
         }
         return _loc1_;
      }
      
      private function assignNodeIslands() : void
      {
         var _loc4_:* = null;
         var _loc5_:PathGraphNode = null;
         var _loc6_:int = 0;
         var _loc1_:Dictionary = this.createOpenSet();
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         while(!_loc3_)
         {
            _loc3_ = true;
            var _loc7_:int = 0;
            var _loc8_:* = _loc1_;
            for(_loc4_ in _loc8_)
            {
               _loc2_++;
               _loc5_ = _loc4_ as PathGraphNode;
               _loc6_ = this.assignNodeIslandIteratively(_loc5_,_loc2_,_loc1_);
               this.islandSizes[_loc2_] = _loc6_;
               _loc3_ = false;
            }
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("PathGraph Assigned " + _loc2_ + " disconnected pathfinding islands");
         }
      }
      
      public function cullNodeIslands(param1:int, param2:Function) : void
      {
         var _loc5_:* = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:PathGraphNode = null;
         if(0 == param1)
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for(_loc5_ in this.islandSizes)
         {
            _loc7_ = _loc5_ as int;
            _loc8_ = int(this.islandSizes[_loc7_]);
            if(_loc8_ > _loc4_)
            {
               _loc4_ = _loc8_;
               _loc3_ = _loc7_;
            }
         }
         if(_loc3_ == 0)
         {
            return;
         }
         var _loc6_:Dictionary = new Dictionary();
         for(_loc5_ in this._nodes)
         {
            _loc9_ = this._nodes[_loc5_] as PathGraphNode;
            if(_loc9_.islandId != _loc3_)
            {
               if(null != param2)
               {
                  param2(_loc5_);
               }
            }
            else
            {
               _loc6_[_loc5_] = _loc9_;
            }
         }
      }
      
      public function setNodeEnabled(param1:IPathGraphNode, param2:Boolean) : void
      {
         var _loc4_:PathHeuristicSolver = null;
         var _loc3_:PathGraphNode = param1 as PathGraphNode;
         if(_loc3_.enabled != param2)
         {
            _loc3_._enabled = param2;
            for each(_loc4_ in this.solvers)
            {
               _loc4_.invalidated = true;
            }
         }
      }
   }
}
