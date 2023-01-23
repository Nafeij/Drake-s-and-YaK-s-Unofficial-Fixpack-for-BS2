package engine.landscape.view
{
   public class WeatherLayer_Fog
   {
       
      
      private var layer:WeatherLayer;
      
      private var manager:WeatherManager;
      
      public var density:Number = 0;
      
      public var color:uint = 0;
      
      public function WeatherLayer_Fog(param1:WeatherLayer)
      {
         super();
         this.layer = param1;
         this.manager = param1.manager;
      }
      
      public function cleanup() : void
      {
      }
      
      final public function update(param1:int) : void
      {
         var _loc2_:WeatherManager_Fog = this.manager.fog;
         var _loc3_:Number = _loc2_.getDensity();
         if(this.density != _loc3_ || this.color != _loc2_.color)
         {
            this.density = _loc3_;
            this.color = _loc2_.color;
            this.layer.handleFogChange();
         }
      }
   }
}
