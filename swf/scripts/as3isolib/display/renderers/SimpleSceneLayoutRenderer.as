package as3isolib.display.renderers
{
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.display.scene.IIsoScene;
   
   public class SimpleSceneLayoutRenderer implements ISceneLayoutRenderer
   {
       
      
      public var sortOnProps:Array;
      
      private var collisionDetectionFunc:Function = null;
      
      public function SimpleSceneLayoutRenderer()
      {
         this.sortOnProps = ["y","x","z"];
         super();
      }
      
      public function renderScene(param1:IIsoScene) : void
      {
         var _loc3_:IIsoDisplayObject = null;
         var _loc4_:uint = 0;
         var _loc2_:Array = param1.displayListChildren.slice();
         _loc2_.sortOn(this.sortOnProps,Array.NUMERIC);
         var _loc5_:uint = _loc2_.length;
         while(_loc4_ < _loc5_)
         {
            _loc3_ = IIsoDisplayObject(_loc2_[_loc4_]);
            if(_loc3_.depth != _loc4_)
            {
               param1.setChildIndex(_loc3_,_loc4_);
            }
            _loc4_++;
         }
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
