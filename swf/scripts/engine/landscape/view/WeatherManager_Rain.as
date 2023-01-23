package engine.landscape.view
{
   import engine.saga.SagaVar;
   
   public class WeatherManager_Rain extends WeatherManager_Particle
   {
       
      
      public var _category_urls:Array;
      
      public var _category_counts:Array;
      
      protected var _category_speed:Array;
      
      protected var _category_alphas:Array;
      
      public function WeatherManager_Rain(param1:WeatherManager)
      {
         this._category_urls = [["common/scene/weather/rain/rain_16_a.png","common/scene/weather/rain/rain_32_a.png","common/scene/weather/rain/rain_64_a.png"],["common/scene/weather/rain/rain_16_a.png","common/scene/weather/rain/rain_32_a.png","common/scene/weather/rain/rain_64_a.png"],["common/scene/weather/rain/rain_04_a.png","common/scene/weather/rain/rain_04_a.png","common/scene/weather/rain/rain_16_a.png"]];
         this._category_counts = [1,1,0.1];
         this._category_speed = [2,3,4.5];
         this._category_alphas = [0.5,0.7,1];
         super("rain",param1,SagaVar.VAR_WEATHER_RAIN_DENSITY,SagaVar.VAR_WEATHER_RAIN_GRAVITY,SagaVar.VAR_WEATHER_RAIN_VARIANCE,SagaVar.VAR_WEATHER_RAIN_COLOR);
         this.fmodEvent = "world/travel_ambience/rain";
         this.fmodDensityParam = "rain_density";
         this.fmodDensityScale = 1.5;
         this.density = 0;
         this.variance = 0;
         this.category_urls = this._category_urls;
         this.category_counts = this._category_counts;
         this.category_speed = this._category_speed;
         this.category_alphas = this._category_alphas;
         this.stretch = 20;
         this.orients = true;
      }
   }
}
