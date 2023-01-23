package engine.landscape.view
{
   import starling.display.QuadBatch;
   import starling.utils.VertexData;
   
   public class WeatherQuadBatch extends QuadBatch
   {
       
      
      public function WeatherQuadBatch()
      {
         super();
         this.forceTinted = true;
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
