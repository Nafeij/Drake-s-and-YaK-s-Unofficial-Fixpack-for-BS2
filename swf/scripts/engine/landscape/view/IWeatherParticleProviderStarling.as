package engine.landscape.view
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface IWeatherParticleProviderStarling extends IWeatherParticleProvider
   {
       
      
      function getParticleUvs(param1:int) : Rectangle;
      
      function getParticleSize(param1:int) : Point;
   }
}
