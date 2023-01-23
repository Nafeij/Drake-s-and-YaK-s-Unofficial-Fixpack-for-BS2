package engine.landscape.view
{
   public class WeatherParticleBmp_Data
   {
       
      
      public var rw:Number = 0;
      
      public var rg:Number = 0;
      
      public var speedMod:Number = 1;
      
      public var lifespan:int = 0;
      
      public var speed_bias:Number = 0;
      
      public var width:Number = 0;
      
      public var height:Number = 0;
      
      public var left:Number = 0;
      
      public var right:Number = 0;
      
      public var top:Number = 0;
      
      public var bottom:Number = 0;
      
      public var alphaMod:Number = 1;
      
      public var nearness:Number = 0;
      
      public function WeatherParticleBmp_Data(param1:Number)
      {
         super();
         this.speed_bias = param1;
      }
      
      public function setBounds(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.left = param1;
         this.top = param2;
         this.right = param3;
         this.bottom = param4;
         this.width = Math.abs(this.right - this.left);
         this.height = Math.abs(this.bottom - this.top);
      }
      
      public function setup(param1:Number) : void
      {
         this.nearness = param1;
         this.lifespan = 0;
         this.speedMod = (1 + param1) * this.speed_bias;
         this.rw = Math.random() - 0.5;
         this.rg = Math.random() - 0.5;
      }
   }
}
