package engine.landscape.view
{
   public interface IWeatherParticleBmp
   {
       
      
      function cleanup() : void;
      
      function set x(param1:Number) : void;
      
      function get x() : Number;
      
      function set y(param1:Number) : void;
      
      function get y() : Number;
      
      function setup(param1:IWeatherParticleProvider, param2:int, param3:Number, param4:String) : void;
      
      function get data() : WeatherParticleBmp_Data;
      
      function update(param1:int, param2:Number, param3:Number) : Boolean;
      
      function reorient() : void;
      
      function set blendMode(param1:String) : void;
      
      function get blendMode() : String;
      
      function get alpha() : Number;
      
      function set alpha(param1:Number) : void;
   }
}
