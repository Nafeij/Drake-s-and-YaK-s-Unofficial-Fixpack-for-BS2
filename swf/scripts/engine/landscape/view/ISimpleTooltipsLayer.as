package engine.landscape.view
{
   import engine.resource.BitmapResource;
   import flash.display.BitmapData;
   
   public interface ISimpleTooltipsLayer
   {
       
      
      function addQuad_BitmapResource(param1:int, param2:String, param3:BitmapResource) : ISimpleTooltipsLayerHandle;
      
      function addQuad_BitmapData(param1:String, param2:BitmapData) : ISimpleTooltipsLayerHandle;
      
      function cleanup() : void;
      
      function sort() : void;
      
      function forgetHandle(param1:ISimpleTooltipsLayerHandle) : void;
   }
}
