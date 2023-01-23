package engine.landscape.travel.view
{
   public class CaravanViewGlow_SparkleGroupVars
   {
       
      
      public var MIN_SPARKLES:int = 6;
      
      public var BASE_LIFESPAN_MS:int = 1000;
      
      public var BASE_LIFESPAN_VARIANCE_MS:int = 500;
      
      public var LIFESPAN_SCALE_DELTA:Number = 0.05;
      
      public var PAUSE_MS:int = 200;
      
      public var PAUSE_VARIANCE_MS:int = 400;
      
      public function CaravanViewGlow_SparkleGroupVars(param1:int = 6, param2:int = 1000, param3:int = 500, param4:Number = 0.05, param5:int = 200, param6:int = 400)
      {
         super();
         this.MIN_SPARKLES = param1;
         this.BASE_LIFESPAN_MS = param2;
         this.BASE_LIFESPAN_VARIANCE_MS = param3;
         this.LIFESPAN_SCALE_DELTA = param4;
         this.PAUSE_MS = param5;
         this.PAUSE_VARIANCE_MS = param6;
      }
   }
}
