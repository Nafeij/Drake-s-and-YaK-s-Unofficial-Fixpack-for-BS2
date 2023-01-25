package game.gui.battle
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import engine.gui.GuiGpBitmap;
   import engine.resource.loader.SoundControllerManager;
   import engine.saga.ISaga;
   import engine.sound.ISoundDriver;
   import engine.sound.SoundBundleWrapper;
   import flash.display.DisplayObject;
   import game.gui.ButtonWithIndex;
   import game.gui.IGuiContext;
   import game.gui.travel.GuiTravelTopMorale;
   
   public class GuiValkaSpear extends GuiBaseArtifact implements IGuiArtifact
   {
      
      private static const NUM_CHARGES:int = 3;
      
      private static const DARKSUN_FADE_IN_SEC:Number = 0.5;
      
      private static const DARKSUN_FADE_OUT_SEC:Number = 1;
      
      private static const DARKSUN_FULL_ROTATION_SEC:Number = 10;
      
      private static const DARKSUN_RAY_FADE_IN_SEC:Number = 0.75;
      
      private static const DARKSUN_RAY_FADE_OUT_SEC:Number = 1.25;
      
      private static const GUI_SOUND_GAIN_CHARGE:String = "tbs3_ui_valka_spear_gain_charge";
      
      private static const GUI_SOUND_SELECT_CHARGE:String = "tbs3_ui_valka_spear_select_charge";
      
      private static const GUI_SOUND_APPEARS:String = "tbs3_ui_valka_spear_hud_appears";
      
      private static const GUI_SOUND_DISAPPEARS:String = "tbs3_ui_valka_spear_hud_disappears";
       
      
      private var _darkstone:ButtonWithIndex;
      
      private var _darksun:ButtonWithIndex;
      
      private var _darksun_ray:DisplayObject;
      
      private var _charges:Vector.<DisplayObject>;
      
      private var _darksun_fading:Boolean = false;
      
      private var _darksun_ray_fading:Boolean = false;
      
      private var _soundControllerManager:SoundControllerManager;
      
      private var sbw_appear:SoundBundleWrapper;
      
      public function GuiValkaSpear()
      {
         super();
         _morale = requireGuiChild("morale") as GuiTravelTopMorale;
         this._darkstone = requireGuiChild("darkstone") as ButtonWithIndex;
         this._darksun = requireGuiChild("darksun") as ButtonWithIndex;
         this._darksun_ray = requireGuiChild("darksun_ray") as DisplayObject;
         this.name = "assets.gui_valkaspear";
      }
      
      public function init(param1:IGuiContext, param2:IGuiArtifactListener, param3:ISaga, param4:GuiGpBitmap, param5:ISoundDriver = null) : void
      {
         super.initGuiBaseArtifact(param1,param2,param3,param4);
         if(param4)
         {
            param4.x = -70;
            param4.y = 50;
         }
         _saga = param3;
         this._darksun.visible = false;
         this._darksun_ray.visible = false;
         this._charges = new Vector.<DisplayObject>();
         var _loc6_:int = 0;
         while(_loc6_ < NUM_CHARGES)
         {
            this._charges.push(requireGuiChild("spiral_" + (_loc6_ + 1).toString()) as DisplayObject);
            this._charges[_loc6_].visible = false;
            _loc6_++;
         }
         this._soundControllerManager = new SoundControllerManager("gui_valka_spear_soundcontroller","saga3/sound/saga3_gui_valkaspear.sound.json.z",param1.resourceManager,param5,null,param3.logger);
         this._darkstone.setDownFunction(this.onDarkstoneDown);
         this._darksun.setDownFunction(this.onDarksunDown);
         this.updateSpirals();
         this.updateSun();
      }
      
      public function cleanup() : void
      {
         if(this._darkstone)
         {
            this._darkstone.cleanup();
         }
         if(this._darksun)
         {
            this._darksun.cleanup();
         }
         super.cleanupGuiBaseArtifact();
      }
      
      override public function set count(param1:int) : void
      {
         param1 = Math.max(0,Math.min(this.maxCount,param1));
         if(_count == param1)
         {
            return;
         }
         if(this._soundControllerManager.isLoaded && _count < param1)
         {
            this._soundControllerManager.soundController.playSound(GUI_SOUND_GAIN_CHARGE,null);
         }
         _count = param1;
         this.updateSpirals();
         this.updateSun();
      }
      
      override public function get maxCount() : int
      {
         return !!this._charges ? int(this._charges.length) : 0;
      }
      
      public function set enemyCount(param1:int) : void
      {
      }
      
      public function get enemyCount() : int
      {
         return 0;
      }
      
      private function onDarkstoneDown(param1:ButtonWithIndex) : void
      {
         context.playSound("ui_error");
      }
      
      private function onDarksunDown(param1:ButtonWithIndex) : void
      {
         context.logger.debug("GuiValkaSpear.onDarksunDown _count=" + _count);
         if(count <= 0)
         {
            context.playSound("ui_error");
            return;
         }
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound(GUI_SOUND_SELECT_CHARGE,null);
         }
         _listener.guiArtifactUse();
      }
      
      private function updateSpirals() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._charges.length)
         {
            this._charges[_loc1_].visible = _loc1_ < count;
            _loc1_++;
         }
      }
      
      private function updateSun() : void
      {
         var _loc1_:* = count > 0;
         if((!this._darksun.visible || this._darksun_fading) && _loc1_)
         {
            this.playSunIntro();
         }
         else if(this._darksun.visible && !_loc1_)
         {
            this.playSunOutro();
         }
         if((!this._darksun_ray.visible || this._darksun_ray_fading) && _loc1_)
         {
            this.playSunRayIntro();
         }
         else if(this._darksun_ray.visible && !_loc1_)
         {
            this.playSunRayOutro();
         }
      }
      
      private function playSunIntro() : void
      {
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound(GUI_SOUND_APPEARS,null);
         }
         TweenMax.killTweensOf(this._darksun);
         this._darksun_fading = false;
         this._darksun.visible = true;
         this._darksun.alpha = 0;
         TweenMax.to(this._darksun,DARKSUN_FULL_ROTATION_SEC,{
            "rotation":"360",
            "ease":Linear.easeNone,
            "repeat":-1
         });
         TweenMax.to(this._darksun,DARKSUN_FADE_IN_SEC,{"alpha":1});
      }
      
      private function playSunRayIntro() : void
      {
         TweenMax.killTweensOf(this._darksun_ray);
         this._darksun_ray_fading = false;
         this._darksun_ray.visible = true;
         this._darksun_ray.alpha = 0;
         TweenMax.to(this._darksun_ray,DARKSUN_RAY_FADE_IN_SEC,{"alpha":1});
      }
      
      private function playSunOutro() : void
      {
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound(GUI_SOUND_DISAPPEARS,null);
         }
         TweenMax.killTweensOf(this._darksun);
         this._darksun_fading = true;
         TweenMax.to(this._darksun,DARKSUN_FADE_OUT_SEC,{
            "alpha":0,
            "onComplete":this.playSunOutroComplete
         });
      }
      
      private function playSunRayOutro() : void
      {
         TweenMax.killTweensOf(this._darksun_ray);
         this._darksun_ray_fading = true;
         TweenMax.to(this._darksun_ray,DARKSUN_RAY_FADE_OUT_SEC,{
            "alpha":0,
            "onComplete":this.playSunRayOutroComplete
         });
      }
      
      private function playSunOutroComplete() : void
      {
         this._darksun_fading = false;
         this._darksun.visible = false;
      }
      
      private function playSunRayOutroComplete() : void
      {
         this._darksun_ray_fading = false;
         this._darksun_ray.visible = false;
      }
   }
}
