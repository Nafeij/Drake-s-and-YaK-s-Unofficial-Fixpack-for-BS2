package as3isolib.display.renderers
{
   import as3isolib.core.IsoDisplayObject;
   import as3isolib.core.as3isolib_internal;
   import as3isolib.display.scene.IIsoScene;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class DefaultSceneLayoutRenderer implements ISceneLayoutRenderer
   {
       
      
      private var depth:uint;
      
      private var visited:Dictionary;
      
      private var scene:IIsoScene;
      
      private var dependency:Dictionary;
      
      private var collisionDetectionFunc:Function = null;
      
      public function DefaultSceneLayoutRenderer()
      {
         this.visited = new Dictionary();
         super();
      }
      
      public function renderScene(param1:IIsoScene) : void
      {
         var _loc6_:IsoDisplayObject = null;
         var _loc7_:Array = null;
         var _loc8_:IsoDisplayObject = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:uint = 0;
         var _loc13_:IsoDisplayObject = null;
         this.scene = param1;
         var _loc2_:uint = getTimer();
         this.dependency = new Dictionary();
         var _loc3_:Array = param1.displayListChildren;
         var _loc4_:uint = _loc3_.length;
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            _loc7_ = [];
            _loc8_ = _loc3_[_loc5_];
            _loc9_ = _loc8_.x + _loc8_.width;
            _loc10_ = _loc8_.y + _loc8_.length;
            _loc11_ = _loc8_.z + _loc8_.height;
            _loc12_ = 0;
            while(_loc12_ < _loc4_)
            {
               _loc13_ = _loc3_[_loc12_];
               if(this.collisionDetectionFunc != null)
               {
                  this.collisionDetectionFunc.call(null,_loc8_,_loc13_);
               }
               if(_loc13_.x < _loc9_ && _loc13_.y < _loc10_ && _loc13_.z < _loc11_ && _loc5_ !== _loc12_)
               {
                  _loc7_.push(_loc13_);
               }
               _loc12_++;
            }
            this.dependency[_loc8_] = _loc7_;
            _loc5_++;
         }
         this.depth = 0;
         for each(_loc6_ in _loc3_)
         {
            if(true !== this.visited[_loc6_])
            {
               this.place(_loc6_);
            }
         }
         this.visited = new Dictionary();
      }
      
      private function place(param1:IsoDisplayObject) : void
      {
         var _loc2_:IsoDisplayObject = null;
         this.visited[param1] = true;
         for each(_loc2_ in this.dependency[param1])
         {
            if(true !== this.visited[_loc2_])
            {
               this.place(_loc2_);
            }
         }
         if(this.depth != param1.depth)
         {
            this.scene.setChildIndex(param1,this.depth);
         }
         ++this.depth;
      }
      
      public function get collisionDetection() : Function
      {
         return this.collisionDetectionFunc;
      }
      
      public function set collisionDetection(param1:Function) : void
      {
         this.collisionDetectionFunc = param1;
      }
   }
}
