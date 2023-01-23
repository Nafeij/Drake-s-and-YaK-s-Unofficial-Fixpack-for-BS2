package engine.landscape.view
{
   import engine.saga.SagaVar;
   
   public class WeatherManager_Spark extends WeatherManager_Blinker
   {
      
      private static var _spark_category_urls:Array = [["common/scene/weather/spark/spark_04_a.png","common/scene/weather/spark/spark_04_b.png"],["common/scene/weather/spark/spark_04_a.png","common/scene/weather/spark/spark_04_b.png","common/scene/weather/spark/spark_08_a.png","common/scene/weather/spark/spark_08_b.png","common/scene/weather/spark/spark_16_a.png","common/scene/weather/spark/spark_16_b.png"],["common/scene/weather/spark/spark_16_a.png","common/scene/weather/spark/spark_16_b.png","common/scene/weather/spark/spark_24_a.png","common/scene/weather/spark/spark_24_b.png"]];
       
      
      public var _spark_category_counts:Array;
      
      protected var _spark_category_speed:Array;
      
      protected var _category_alphas:Array;
      
      public function WeatherManager_Spark(param1:WeatherManager)
      {
         this._spark_category_counts = [1,1,0.05];
         this._spark_category_speed = [0.5,1,3];
         this._category_alphas = [1,1,1];
         super("spark",param1,SagaVar.VAR_WEATHER_SPARK_DENSITY,SagaVar.VAR_WEATHER_SPARK_GRAVITY,SagaVar.VAR_WEATHER_SPARK_VARIANCE,SagaVar.VAR_WEATHER_SPARK_COLOR,SagaVar.VAR_WEATHER_SPARK_BLINK_RATE);
         this.category_urls = _spark_category_urls;
         this.category_counts = this._spark_category_counts;
         this.category_speed = this._spark_category_speed;
         this.category_alphas = this._category_alphas;
      }
   }
}
