package engine.landscape.view
{
   public interface IWeatherParticleProvider
   {
       
      
      function get layer() : WeatherLayer;
      
      function get particleSystem() : WeatherManager_Particle;
   }
}
