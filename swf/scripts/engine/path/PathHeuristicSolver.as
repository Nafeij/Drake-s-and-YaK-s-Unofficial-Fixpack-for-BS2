package engine.path
{
   import flash.utils.Dictionary;
   
   public class PathHeuristicSolver
   {
       
      
      private var open:Dictionary;
      
      private var closed:Dictionary;
      
      private var nodes:Dictionary;
      
      private var openQueue:Array;
      
      public var path:IPath;
      
      private var heuristic:Function;
      
      private var coherenceHeuristic:Function;
      
      public var complete:Boolean;
      
      public var success:Boolean;
      
      public var steps:int;
      
      public var invalidated:Boolean;
      
      public var nodeBlockedFunc:Function;
      
      public var nodeHazardFunc:Function;
      
      public var regionsMapping:PathRegionsMapping;
      
      public function PathHeuristicSolver(param1:IPath, param2:Function, param3:Function, param4:Function, param5:Function, param6:PathRegionsMapping)
      {
         this.open = new Dictionary();
         this.closed = new Dictionary();
         this.nodes = new Dictionary();
         this.openQueue = new Array();
         super();
         this.nodeBlockedFunc = param4;
         this.nodeHazardFunc = param5;
         this.path = param1;
         this.heuristic = param2;
         this.coherenceHeuristic = param3;
         this.regionsMapping = param6;
         var _loc7_:PathHeuristicSolverNode = this.getNode(param1.src);
         this.openQueue.push(_loc7_);
         this.open[_loc7_] = _loc7_;
      }
      
      public function cleanup() : void
      {
      }
      
      public function getNode(param1:IPathGraphNode) : PathHeuristicSolverNode
      {
         var _loc2_:PathHeuristicSolverNode = this.nodes[param1];
         if(!_loc2_)
         {
            _loc2_ = new PathHeuristicSolverNode(param1);
            this.nodes[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function update(param1:int, param2:Function) : void
      {
         var _loc4_:int = 0;
         this.path.status = PathStatus.WORKING;
         var _loc3_:int = param2();
         while(!this.complete)
         {
            this.complete = this.step();
            ++this.steps;
            _loc4_ = param2() - _loc3_;
            this.path.elapsed += _loc4_;
            if(!this.complete)
            {
               if(param1 >= 0 && _loc4_ > param1)
               {
                  return;
               }
            }
         }
         this.complete = true;
         this.success = this.reconstructPath();
         this.path.status = this.success ? PathStatus.COMPLETE : PathStatus.FAILED;
      }
      
      public function step() : Boolean
      {
         var _loc2_:IPathGraphLink = null;
         var _loc3_:PathHeuristicSolverNode = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this.openQueue.length == 0)
         {
            return true;
         }
         var _loc1_:PathHeuristicSolverNode = this.openQueue.pop();
         delete this.open[_loc1_];
         this.closed[_loc1_] = _loc1_;
         if(_loc1_.node == this.path.dst)
         {
            return true;
         }
         for each(_loc2_ in _loc1_.node.links)
         {
            if(!_loc2_.isDisabled)
            {
               _loc3_ = this.getNode(_loc2_.dst);
               if(this.regionsMapping)
               {
                  if(!this.regionsMapping.canLink(_loc1_.node.region,_loc3_.node.region))
                  {
                     continue;
                  }
               }
               if(this.nodeBlockedFunc != null)
               {
                  if(this.nodeBlockedFunc(_loc3_.node))
                  {
                     continue;
                  }
               }
               if(_loc3_.node.enabled)
               {
                  if(_loc3_.node == this.path.dst)
                  {
                     _loc3_.parent = _loc1_;
                     _loc3_.parentLink = _loc2_;
                     return true;
                  }
                  if(_loc3_ != _loc1_)
                  {
                     if(!this.closed[_loc3_])
                     {
                        _loc4_ = 0;
                        if(this.nodeHazardFunc != null)
                        {
                           _loc4_ = this.nodeHazardFunc(_loc3_.node);
                        }
                        _loc5_ = _loc1_.g + 1 + _loc2_.cost + _loc2_.dst.cost + _loc4_;
                        if(Boolean(_loc1_.parent) && this.coherenceHeuristic != null)
                        {
                           _loc8_ = this.coherenceHeuristic(_loc1_.parent.node.key,_loc1_.node.key,_loc3_.node.key);
                           _loc9_ = (1 - _loc8_) * Math.max(0,_loc1_.node.links.length - 2);
                           _loc5_ += _loc9_;
                        }
                        if(!this.open[_loc3_])
                        {
                           this.open[_loc3_] = _loc3_;
                           this.openQueue.push(_loc3_);
                           _loc6_ = true;
                        }
                        else if(_loc5_ < _loc3_.g)
                        {
                           _loc7_ = true;
                        }
                        if(_loc7_ || _loc6_)
                        {
                           _loc3_.parentLink = _loc2_;
                           _loc3_.parent = _loc1_;
                           _loc3_.g = _loc5_;
                           if(_loc6_)
                           {
                              if(this.heuristic != null)
                              {
                                 _loc3_.h = this.heuristic(_loc3_.node.key,this.path.dst.key);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         this.openQueue.sortOn("f",Array.NUMERIC | Array.DESCENDING);
         return false;
      }
      
      private function reconstructPath() : Boolean
      {
         var _loc3_:IPathGraphLink = null;
         var _loc1_:PathHeuristicSolverNode = this.getNode(this.path.dst);
         var _loc2_:Vector.<IPathGraphLink> = new Vector.<IPathGraphLink>();
         while(Boolean(_loc1_) && _loc1_.node != this.path.src)
         {
            _loc3_ = _loc1_.parentLink;
            if(!_loc3_)
            {
               return false;
            }
            _loc2_.push(_loc3_);
            _loc1_ = _loc1_.parent;
         }
         _loc2_.reverse();
         this.path.links = _loc2_;
         return true;
      }
   }
}
