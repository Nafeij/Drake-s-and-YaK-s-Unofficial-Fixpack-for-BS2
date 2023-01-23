package engine.landscape.model
{
   import engine.landscape.def.LandscapeLayerDef;
   import flash.geom.Point;
   
   public class LandscapeLayer
   {
       
      
      public var landscape:Landscape;
      
      public var def:LandscapeLayerDef;
      
      public var offset:Point;
      
      public function LandscapeLayer(param1:Landscape, param2:LandscapeLayerDef)
      {
         this.offset = new Point();
         super();
         this.landscape = param1;
         this.def = param2;
      }
   }
}
