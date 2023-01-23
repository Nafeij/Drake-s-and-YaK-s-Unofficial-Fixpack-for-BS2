package engine.saga.save
{
   import engine.core.logging.ILogger;
   import engine.saga.SagaMetrics;
   import engine.saga.SagaMetricsEntry;
   
   public class SagaMetricsSave
   {
       
      
      public var global:SagaMetricsEntry;
      
      public function SagaMetricsSave()
      {
         this.global = new SagaMetricsEntry();
         super();
      }
      
      public function fromSagaMetrics(param1:SagaMetrics) : SagaMetricsSave
      {
         var _loc2_:String = null;
         this.global = param1.global.clone();
         return this;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaMetricsSave
      {
         var _loc3_:String = null;
         var _loc4_:SagaMetricsEntry = null;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc2_:String = null;
         return {"global":this.global.toJson()};
      }
   }
}
