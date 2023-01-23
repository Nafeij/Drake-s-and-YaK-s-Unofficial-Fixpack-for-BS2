package engine.saga
{
   import flash.geom.Rectangle;
   
   public class CaravanViewGlowDef
   {
       
      
      public var DIAMETER_MAX:int = 900;
      
      public var DIAMETER_CLOSE_MULTIPLIER:Number = 0.2222;
      
      public var target_diameter:int;
      
      public var rimscale:Number = 2.25;
      
      public var glowrimscale:Number = 1;
      
      public var bmp_rim:String = "common/caravan/glow/light_rays_final_blur.png";
      
      public var rim_rects:Array;
      
      public var bmp_fill:String = "common/caravan/glow/inner_new.png";
      
      public var bmp_sparkle:String = "common/caravan/glow/glow_sparkle.png";
      
      public var bmp_outer:String = "common/caravan/glow/outer_glow_final.png";
      
      public var center_anim:String = "hero_juno";
      
      public function CaravanViewGlowDef()
      {
         this.target_diameter = this.DIAMETER_MAX;
         this.rim_rects = [new Rectangle(6,26,4,20),new Rectangle(11,26,5,21),new Rectangle(20,29,4,11),new Rectangle(31,31,3,11),new Rectangle(36,30,3,12),new Rectangle(46,26,5,18),new Rectangle(58,28,4,15),new Rectangle(65,33,5,11)];
         super();
      }
      
      public static function ctorWorld() : CaravanViewGlowDef
      {
         var _loc1_:CaravanViewGlowDef = new CaravanViewGlowDef();
         _loc1_.target_diameter = _loc1_.DIAMETER_MAX * _loc1_.DIAMETER_CLOSE_MULTIPLIER;
         _loc1_.rimscale = 0.25;
         _loc1_.glowrimscale = 0.25;
         return _loc1_;
      }
      
      public static function ctorClose() : CaravanViewGlowDef
      {
         return new CaravanViewGlowDef();
      }
   }
}
