package engine.landscape.view
{
   import flash.display.BitmapData;
   
   public interface IWeatherParticleProviderFlash extends IWeatherParticleProvider
   {
       
      
      function getBitmapData(param1:int) : BitmapData;
   }
}
