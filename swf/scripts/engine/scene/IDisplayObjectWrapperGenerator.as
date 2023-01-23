package engine.scene
{
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.display.BitmapData;
   
   public interface IDisplayObjectWrapperGenerator
   {
       
      
      function createDisplayObjectWrapperForBitmapData(param1:Object, param2:BitmapData) : DisplayObjectWrapper;
      
      function createDisplayObjectWrapper() : DisplayObjectWrapper;
      
      function destroyBitmapDataWrapper(param1:DisplayObjectWrapper) : void;
   }
}
