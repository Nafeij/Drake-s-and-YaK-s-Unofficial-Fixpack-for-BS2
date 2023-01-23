package engine.landscape.view
{
   import engine.saga.SagaVar;
   
   public class WeatherManager_Gust extends WeatherManager_Particle
   {
      
      private static var _gust_category_urls:Array = [["common/scene/weather/gust/gust_16_a.png"],["common/scene/weather/gust/gust_32_a.png","common/scene/weather/gust/gust_64_a.png"],["common/scene/weather/gust/gust_128_a.png"]];
       
      
      public var _gust_category_counts:Array;
      
      protected var _gust_category_speed:Array;
      
      protected var _category_alphas:Array;
      
      public function WeatherManager_Gust(param1:WeatherManager)
      {
         this._gust_category_counts = [1,1,0.05];
         this._gust_category_speed = [0.5,1,3];
         this._category_alphas = [1,1,1];
         super("gust",param1,SagaVar.VAR_WEATHER_GUST_DENSITY,SagaVar.VAR_WEATHER_GUST_GRAVITY,SagaVar.VAR_WEATHER_GUST_VARIANCE,SagaVar.VAR_WEATHER_GUST_COLOR);
         this.category_urls = _gust_category_urls;
         this.category_counts = this._gust_category_counts;
         this.category_speed = this._gust_category_speed;
         this.category_alphas = this._category_alphas;
      }
   }
}
