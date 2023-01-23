package engine.landscape.view
{
   import engine.core.logging.ILogger;
   import engine.resource.BitmapResource;
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   
   public class SimpleTooltipsLayer implements ISimpleTooltipsLayer
   {
       
      
      public var logger:ILogger;
      
      public function SimpleTooltipsLayer(param1:ILogger)
      {
         super();
         this.logger = param1;
      }
      
      public function cleanup() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function addQuad_BitmapResource(param1:int, param2:String, param3:BitmapResource) : ISimpleTooltipsLayerHandle
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function addQuad_BitmapData(param1:String, param2:BitmapData) : ISimpleTooltipsLayerHandle
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function sort() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function forgetHandle(param1:ISimpleTooltipsLayerHandle) : void
      {
         throw new IllegalOperationError("pure virtual");
      }
   }
}
