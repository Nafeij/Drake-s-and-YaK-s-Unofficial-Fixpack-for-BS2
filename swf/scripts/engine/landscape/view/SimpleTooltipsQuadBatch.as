package engine.landscape.view
{
   import starling.display.QuadBatch;
   import starling.utils.VertexData;
   
   public class SimpleTooltipsQuadBatch extends QuadBatch
   {
       
      
      public var depth:int;
      
      public function SimpleTooltipsQuadBatch(param1:int)
      {
         super();
         this.depth = param1;
         this.forceTinted = true;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      public function updateQuadVerts(param1:int, param2:VertexData) : void
      {
         var _loc3_:int = param1 * 4;
         param2.copyTransformedTo(mVertexData,_loc3_);
      }
      
      public function notifyChange() : void
      {
         super.onVertexDataChanged();
      }
   }
}
