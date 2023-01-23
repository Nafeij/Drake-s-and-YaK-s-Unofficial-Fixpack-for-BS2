package engine.core.util
{
   public class Argb
   {
       
      
      public var color:uint;
      
      public function Argb(param1:uint)
      {
         super();
         this.color = param1;
         if(this.a == 0)
         {
            this.color |= 4278190080;
         }
      }
      
      public function get a() : Number
      {
         return ((this.color & 4278190080) >>> 24) / 255;
      }
      
      public function get r() : Number
      {
         return ((this.color & 16711680) >>> 16) / 255;
      }
      
      public function get g() : Number
      {
         return ((this.color & 65280) >>> 8) / 255;
      }
      
      public function get b() : Number
      {
         return ((this.color & 255) >>> 0) / 255;
      }
   }
}
