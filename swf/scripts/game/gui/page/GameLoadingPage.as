package game.gui.page
{
   import com.stoicstudio.platform.Platform;
   import engine.core.fsm.State;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.gui.GuiUtil;
   import engine.gui.LoadingPips;
   import engine.gui.page.ILoadingPage;
   import engine.gui.page.Page;
   import flash.display.MovieClip;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   
   public class GameLoadingPage extends GamePage implements ILoadingPage
   {
      
      public static var mcLoadingSaga:Class;
      
      public static var mcLoadingFactions:Class;
       
      
      private var _targetPage:Page;
      
      private var _targetState:State;
      
      private var slam:Boolean;
      
      private var scaler:MovieClip;
      
      private var splashLogos:MovieClip;
      
      private var _loadingPips:LoadingPips;
      
      public function GameLoadingPage(param1:GameConfig)
      {
         super(param1);
         start();
      }
      
      override protected function handleStart() : void
      {
         this.slam = true;
         setFullPageMovieClipClass(mcLoadingSaga);
         config.context.appInfo.emitPlatformEvent("dismiss_splash_screen");
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         this._loadingPips.update(param1);
      }
      
      override protected function handleLoaded() : void
      {
         var _loc1_:MovieClip = null;
         if(fullScreenMc)
         {
            this.checkShowing();
            fullScreenMc.name = "loading";
            GuiUtil.attemptStopAllMovieClips(fullScreenMc);
            fullScreenMc.visible = false;
            fullScreenMc.mouseEnabled = false;
            fullScreenMc.mouseChildren = false;
            this.scaler = fullScreenMc.getChildByName("scaler") as MovieClip;
            this.splashLogos = fullScreenMc.getChildByName("splash_logos") as MovieClip;
            _loc1_ = !!this.scaler ? this.scaler.getChildByName("lits") as MovieClip : null;
            this._loadingPips = new LoadingPips(_loc1_);
         }
      }
      
      public function onTargetChanged() : void
      {
      }
      
      public function get targetPage() : Page
      {
         return this._targetPage;
      }
      
      public function get targetState() : State
      {
         return this._targetState;
      }
      
      public function setTarget(param1:Page, param2:State) : void
      {
         this._targetPage = param1;
         this._targetState = param2;
         this.onTargetChanged();
      }
      
      override public function set showing(param1:Boolean) : void
      {
         if(super.showing != param1)
         {
            this._loadingPips.reset();
            super.showing = param1;
            this.checkShowing();
         }
      }
      
      private function checkShowing() : void
      {
         if(fullScreenMc)
         {
            if(showing)
            {
               visible = true;
               fullScreenMc.visible = true;
               if(Platform.showStartupLogos)
               {
                  this.splashLogos.visible = true;
                  Platform.showStartupLogos = false;
               }
               else
               {
                  this.splashLogos.visible = false;
               }
               this.doTranslation();
               this.resizeHandler();
            }
            else
            {
               visible = false;
               fullScreenMc.visible = false;
            }
         }
      }
      
      public function doTranslation() : void
      {
         if(config.gameGuiContext)
         {
            config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this);
         }
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         super.resizeHandler();
         if(this.slam)
         {
            if(this.scaler)
            {
               this.scaler.scaleX = this.scaler.scaleY = 1;
            }
            if(fullScreenMc)
            {
               container.anchor.horizontalCenter = null;
               container.x = width - boundedCamera.vbar - fullScreenMc.width * boundedCamera.scale;
               fullScreenMc.x = 0;
            }
         }
         if(this.scaler)
         {
            _loc1_ = 2 * this.width / boundedCamera.scale;
            _loc2_ = 2 * this.height / boundedCamera.scale;
            _loc3_ = Math.min(1.25,BoundedCamera.computeDpiScaling(_loc1_,_loc2_));
            this.scaler.scaleX = this.scaler.scaleY = _loc3_;
         }
      }
   }
}
