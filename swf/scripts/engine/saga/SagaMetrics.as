package engine.saga
{
   public class SagaMetrics implements ISagaMetrics
   {
       
      
      public var global:SagaMetricsEntry;
      
      public var saga:Saga;
      
      public function SagaMetrics(param1:Saga)
      {
         this.global = new SagaMetricsEntry();
         super();
         this.saga = param1;
      }
      
      public function snapshotVariable(param1:String, param2:int) : void
      {
         this.global.setTotal(param1,param2);
      }
      
      public function handleVariableChanged(param1:String, param2:int, param3:int) : void
      {
         this.global.handleVariableChanged(param1,param2,param3);
      }
   }
}
