package game.view
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.gui.page.Page;
   import engine.sound.ISoundDriver;
   import engine.sound.SoundBundleWrapper;
   import flash.display.MovieClip;
   import game.gui.travel.IGuiTravelTop;
   
   public class LoadingOverlayLayer extends Page
   {
       
      
      public var pm:GamePageManagerAdapter;
      
      private var _guiTop:IGuiTravelTop;
      
      public var sbw:SoundBundleWrapper;
      
      public function LoadingOverlayLayer(param1:ILogger, param2:GamePageManagerAdapter)
      {
         super("loading_overlay",param1);
         this.manager = param2;
         this.pm = param2;
      }
      
      override protected function resizeHandler() : void
      {
         var _loc5_:MovieClip = null;
         var _loc6_:IGuiTravelTop = null;
         var _loc1_:Number = width;
         var _loc2_:Number = Math.max(height,640);
         if(PlatformInput.isTouch)
         {
            _loc1_ = Math.max(BoundedCamera.UI_AUTHOR_WIDTH * 1.2,width);
            _loc2_ = Math.max(BoundedCamera.UI_AUTHOR_HEIGHT * 1.2,height);
         }
         var _loc3_:Number = BoundedCamera.computeDpiScaling(_loc1_,_loc2_);
         _loc3_ = Math.min(2,_loc3_);
         var _loc4_:int = 0;
         while(_loc4_ < numChildren)
         {
            _loc5_ = getChildAt(_loc4_) as MovieClip;
            _loc5_.x = width / 2;
            _loc5_.scaleX = _loc5_.scaleY = _loc3_;
            _loc6_ = getChildAt(_loc4_) as IGuiTravelTop;
            if(_loc6_)
            {
               _loc6_.resizeHandler();
            }
            _loc4_++;
         }
         super.resizeHandler();
      }
      
      public function clear() : void
      {
         var _loc1_:IGuiTravelTop = null;
         while(numChildren > 0)
         {
            _loc1_ = getChildAt(0) as IGuiTravelTop;
            if(_loc1_)
            {
               _loc1_.cleanup();
            }
            removeChildAt(0);
         }
         if(this.sbw)
         {
            this.sbw.cleanup();
            this.sbw = null;
         }
      }
      
      public function addGuiTop(param1:IGuiTravelTop) : void
      {
         var _loc2_:String = null;
         var _loc3_:ISoundDriver = null;
         this._guiTop = param1;
         if(this._guiTop)
         {
            addChild(this._guiTop.movieClip);
         }
         if(!this.sbw)
         {
            _loc2_ = "world/saga3_ui/hud_darkness/ui_sfx_hud_flip";
            _loc3_ = this.pm.config.soundSystem.driver;
            this.sbw = new SoundBundleWrapper("LoadingOverlayLayer",_loc2_,_loc3_);
         }
      }
      
      public function playTransition() : void
      {
         if(this._guiTop)
         {
            this._guiTop.playDarknessTransition(this.clear);
            if(this.sbw)
            {
               this.sbw.playSound();
               this.sbw.cleanup();
               this.sbw = null;
            }
         }
      }
   }
}
