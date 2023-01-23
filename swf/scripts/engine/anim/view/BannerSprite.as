package engine.anim.view
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.logging.ILogger;
   import engine.resource.AnimClipResource;
   import flash.geom.Point;
   import flash.utils.getTimer;
   
   public class BannerSprite
   {
       
      
      public var banner_attach:Point;
      
      public var rotational_adjustment:Point;
      
      public var rotational_factor:Number = 0;
      
      private var banner_attach_angle:Number;
      
      private var banner_attach_sin:Number;
      
      private var banner_attach_cos:Number;
      
      private var logger:ILogger;
      
      public var anim:XAnimClipSpriteBase;
      
      private var last_update:int;
      
      public function BannerSprite(param1:AnimClipResource, param2:Number, param3:Number, param4:ILogger, param5:Number)
      {
         this.banner_attach = new Point();
         this.rotational_adjustment = new Point();
         super();
         this.banner_attach.setTo(param2,param3);
         this.logger = param4;
         this.rotational_factor = param5;
         if(PlatformStarling.instance)
         {
            this.anim = new XAnimClipSpriteStarling(param1,null,param4,true);
         }
         else
         {
            this.anim = new XAnimClipSpriteFlash(param1,null,param4,true);
         }
         this.cacheBannerAttach();
      }
      
      public function cleanup() : void
      {
         if(this.anim)
         {
            this.anim.cleanup();
            this.anim = null;
         }
      }
      
      private function orient(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = this.banner_attach.x;
         var _loc5_:Number = this.banner_attach.y;
         this.rotational_adjustment.setTo(param1 * this.rotational_factor,-param1 * this.rotational_factor * 0.5);
         this.anim.x = param2 + _loc4_ + this.rotational_adjustment.x;
         this.anim.y = param3 + _loc5_ + this.rotational_adjustment.y;
      }
      
      public function update(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc6_:int = 0;
         if(!this.anim.clip)
         {
            return;
         }
         this.anim.clip.repeatLimit = 0;
         var _loc5_:int = getTimer();
         if(this.last_update > 0)
         {
            _loc6_ = _loc5_ - this.last_update;
            this.anim.clip.advance(_loc6_);
            this.anim.update();
         }
         this.last_update = _loc5_;
         this.orient(param1,param3,param4);
      }
      
      private function cacheBannerAttach() : void
      {
         this.banner_attach_angle = Math.atan2(this.banner_attach.y,this.banner_attach.x);
         this.banner_attach_sin = Math.sin(this.banner_attach_angle);
         this.banner_attach_cos = Math.cos(this.banner_attach_angle);
      }
   }
}
