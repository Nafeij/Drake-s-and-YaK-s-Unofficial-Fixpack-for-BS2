package engine.landscape.view
{
   import engine.saga.SagaVar;
   
   public class WeatherManager_Snow extends WeatherManager_Particle
   {
      
      private static var _snow_category_urls:Array = [["common/scene/weather/snow/04_a.png","common/scene/weather/snow/04_b.png","common/scene/weather/snow/04_c.png"],["common/scene/weather/snow/04_a.png","common/scene/weather/snow/04_b.png","common/scene/weather/snow/04_c.png","common/scene/weather/snow/08_a.png","common/scene/weather/snow/08_b.png","common/scene/weather/snow/08_c.png","common/scene/weather/snow/16_a.png","common/scene/weather/snow/16_b.png"],["common/scene/weather/snow/16_a.png","common/scene/weather/snow/16_b.png","common/scene/weather/snow/24_a.png","common/scene/weather/snow/24_b.png"]];
       
      
      public var _snow_category_counts:Array;
      
      protected var _snow_category_speed:Array;
      
      protected var _category_alphas:Array;
      
      public function WeatherManager_Snow(param1:WeatherManager)
      {
         this._snow_category_counts = [1,1,0.05];
         this._snow_category_speed = [0.5,1,3];
         this._category_alphas = [1,1,1];
         super("snow",param1,SagaVar.VAR_WEATHER_SNOW_DENSITY,SagaVar.VAR_WEATHER_SNOW_GRAVITY,SagaVar.VAR_WEATHER_SNOW_VARIANCE,SagaVar.VAR_WEATHER_SNOW_COLOR);
         this.category_urls = _snow_category_urls;
         this.category_counts = this._snow_category_counts;
         this.category_speed = this._snow_category_speed;
         this.category_alphas = this._category_alphas;
      }
   }
}
