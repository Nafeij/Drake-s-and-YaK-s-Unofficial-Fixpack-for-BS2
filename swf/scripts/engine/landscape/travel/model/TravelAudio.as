package engine.landscape.travel.model
{
   import engine.saga.Saga;
   import engine.scene.def.SceneAudioEmitterDef;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneAudio;
   import engine.scene.model.SceneAudioEmitterAudible;
   import engine.sound.ISoundDriver;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class TravelAudio
   {
       
      
      private var travel:Travel;
      
      private var saga:Saga;
      
      private var scene:Scene;
      
      private var cartEmitter:SceneAudioEmitterDef;
      
      private var bannerEmitter:SceneAudioEmitterDef;
      
      private var driver:ISoundDriver;
      
      private var bannerOffsetX:Number = 200;
      
      private var _last_cart_param_value:Number = -1;
      
      public function TravelAudio(param1:Travel)
      {
         super();
         this.travel = param1;
         this.scene = param1.landscape.scene;
         this.saga = this.scene._context.saga as Saga;
         this.driver = this.scene._context.soundDriver;
         var _loc2_:Boolean = Boolean(param1.def.points) && param1.def.points.length > 1 && param1.def.points[0].x > param1.def.points[1].x;
         if(!_loc2_)
         {
            this.bannerOffsetX = -this.bannerOffsetX;
         }
         this._configureCartEmitter();
         this._configureBannerEmitter();
         this.update();
      }
      
      private function _configureCartEmitter() : void
      {
         if(this.travel.def.ships)
         {
            this.cartEmitter = this.makeEmitter();
            this.cartEmitter.event = "world/saga2_travel/tbs2_travel_boats";
         }
         else if(this.travel.def.showCartFront)
         {
            this.cartEmitter = this.makeEmitter();
            this.cartEmitter.paramNames = ["cart_speed"];
            this.cartEmitter.paramValues = [0];
            if(this.travel.def.close)
            {
               this.cartEmitter.event = "world/travel_ambience/cart/cart_near";
            }
            else
            {
               this.cartEmitter.event = "world/travel_ambience/cart/cart_far";
            }
         }
         else
         {
            this.cartEmitter = this.makeEmitter();
            this.cartEmitter.paramNames = ["cart_speed","travel_close"];
            this.cartEmitter.event = "world_saga3/ambience_common/caravan/caraven_darkness_marching";
            if(this.travel.def.close)
            {
               this.cartEmitter.paramValues = [0,1];
            }
            else
            {
               this.cartEmitter.paramValues = [0,0];
            }
         }
      }
      
      private function _configureBannerEmitter() : void
      {
         if(!this.travel.def.showBanner && !this.travel.def.showGlow)
         {
            return;
         }
         this.bannerEmitter = this.makeEmitter();
         if(this.travel.def.ships)
         {
            this.bannerEmitter.event = "world/banner/banner_travel";
            this.bannerEmitter.paramValues.push(1);
            this.bannerOffsetX *= 2;
         }
         else if(this.travel.def.showGlow)
         {
            this.bannerEmitter.event = "world_saga3/ambience_common/caravan/caravan_darkness_juno_magic";
            if(this.travel.def.close)
            {
               this.bannerEmitter.paramValues.push(1);
            }
            else
            {
               this.bannerEmitter.paramValues.push(0);
            }
         }
         else if(this.travel.def.close)
         {
            this.bannerEmitter.event = "world/banner/banner_travel";
            this.bannerEmitter.paramValues.push(1);
            this.bannerOffsetX *= 2;
         }
         else
         {
            this.bannerEmitter.event = "world/banner/banner_travel";
            this.bannerEmitter.paramValues.push(0);
         }
         this.bannerEmitter.paramNames.push("travel_close");
      }
      
      private function makeEmitter() : SceneAudioEmitterDef
      {
         var _loc1_:SceneAudioEmitterDef = new SceneAudioEmitterDef();
         _loc1_.source = new Rectangle(-100,-100,200,200);
         _loc1_.limit = new Rectangle(-1500,-1500,3000,3000);
         _loc1_.sku = "common";
         return _loc1_;
      }
      
      public function update() : void
      {
         var _loc1_:Boolean = true;
         var _loc2_:Boolean = true;
         if(this.saga)
         {
            if(this.saga.halted || !this.saga.showCaravan || this.saga.camped)
            {
               _loc1_ = false;
            }
            if((!this.saga.showCaravan || this.saga.camped) && !this.travel.def.showGlow)
            {
               _loc2_ = false;
            }
         }
         var _loc3_:Point = this.travel.caravan_pt;
         if(this.cartEmitter)
         {
            this.cartEmitter.enabled = _loc1_;
            this.cartEmitter.setOffset(_loc3_.x,_loc3_.y);
         }
         if(this.bannerEmitter)
         {
            this.bannerEmitter.enabled = _loc2_;
            this.bannerEmitter.setOffset(_loc3_.x,_loc3_.y);
         }
         if(!this.scene.audio)
         {
            return;
         }
         if(!this.travel.def.ships)
         {
            if(this.travel.speedFactor != this._last_cart_param_value)
            {
               this._last_cart_param_value = this.travel.speedFactor;
               this.setEmitterParam(this.cartEmitter,"cart_speed",this.travel.speedFactor);
            }
         }
      }
      
      private function setEmitterParam(param1:SceneAudioEmitterDef, param2:String, param3:Number) : void
      {
         var _loc4_:SceneAudioEmitterAudible = this.scene.audio.auds[param1];
         if(Boolean(_loc4_) && Boolean(_loc4_.systemid))
         {
            this.driver.setEventParameterValueByName(_loc4_.systemid,param2,param3);
         }
      }
      
      public function handleSceneAudio(param1:SceneAudio) : void
      {
         if(this.cartEmitter)
         {
            param1.addExtraEmitter(this.cartEmitter);
         }
         if(this.bannerEmitter)
         {
            param1.addExtraEmitter(this.bannerEmitter);
         }
      }
   }
}
