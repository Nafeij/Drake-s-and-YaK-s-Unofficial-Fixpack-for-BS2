package game.view
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefEvent;
   import engine.core.render.BoundedCamera;
   import engine.subtitle.SubtitleManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.PixelSnapping;
   import flash.events.Event;
   import game.cfg.GameConfig;
   
   public class GameSubtitlesAdapter
   {
      
      public static var MARGIN:int = 30;
       
      
      private var container:DisplayObjectContainer;
      
      private var config:GameConfig;
      
      private var pm:GamePageManagerAdapter;
      
      private var subtitle_bmp:Bitmap;
      
      private var subtitle_current:String;
      
      private var supertitle_bmp:Bitmap;
      
      private var supertitle_current:String;
      
      private var width:Number = 0;
      
      private var height:Number = 0;
      
      private var logger:ILogger;
      
      private var _bmpDirty:Boolean;
      
      public function GameSubtitlesAdapter(param1:GameConfig, param2:DisplayObjectContainer)
      {
         this.subtitle_bmp = new Bitmap(null,PixelSnapping.NEVER,true);
         this.supertitle_bmp = new Bitmap(null,PixelSnapping.NEVER,true);
         super();
         this.container = param2;
         this.config = param1;
         this.logger = param1.logger;
         this.subtitle_bmp.name = "subtitles";
         this.supertitle_bmp.name = "supertitles";
         param1.ccs.subtitle.addEventListener(SubtitleManager.EVENT_CURRENT,this.subtitleHandler);
         param1.ccs.supertitle.addEventListener(SubtitleManager.EVENT_CURRENT,this.supertitleHandler);
         param1.globalPrefs.addEventListener(PrefEvent.PREF_CHANGED,this.prefHandler);
      }
      
      private function prefHandler(param1:PrefEvent) : void
      {
         if(param1.key == GameConfig.PREF_OPTION_CC)
         {
            this.showSubtitle(this.subtitle_current);
         }
      }
      
      private function subtitleHandler(param1:Event) : void
      {
         this.showSubtitle(this.config.ccs.subtitle.current);
      }
      
      private function supertitleHandler(param1:Event) : void
      {
         this.showSupertitle(this.config.ccs.supertitle.current);
      }
      
      private function generateBmpd(param1:Bitmap, param2:String, param3:int, param4:uint, param5:String) : void
      {
         this._bmpDirty = true;
         var _loc6_:BitmapData = param1.bitmapData;
         if(_loc6_)
         {
            param1.bitmapData = null;
            _loc6_.dispose();
            _loc6_ = null;
         }
         var _loc7_:int = Math.min(1024,this.width) - MARGIN * 2;
         var _loc8_:BitmapData = this.config.gameGuiContext.generateTextBitmap(param2,param3,param4,0,param5,_loc7_);
         param1.bitmapData = _loc8_;
         param1.smoothing = true;
         this.container.addChild(param1);
         this.handleResize(this.width,this.height);
      }
      
      public function showSubtitle(param1:String) : void
      {
         var _loc2_:int = 0;
         this.hideBmp(this.subtitle_bmp);
         this.subtitle_current = param1;
         if(!this.config.globalPrefs.getPref(GameConfig.PREF_OPTION_CC))
         {
            return;
         }
         if(param1)
         {
            _loc2_ = this.computeFontSize(30);
            this.generateBmpd(this.subtitle_bmp,"minion",_loc2_,16777215,param1);
         }
      }
      
      public function showSupertitle(param1:String) : void
      {
         var _loc2_:int = 0;
         this.hideBmp(this.supertitle_bmp);
         this.supertitle_current = param1;
         if(param1)
         {
            _loc2_ = this.computeFontSize(40);
            this.generateBmpd(this.supertitle_bmp,"vinque",_loc2_,12040900,param1);
         }
      }
      
      private function computeFontSize(param1:int) : int
      {
         BoundedCamera.computeDpiFingerScale();
         var _loc2_:Number = Math.min(2,BoundedCamera.dpiFingerScale * Platform.textScale);
         _loc2_ = Math.max(1,_loc2_);
         return param1 * _loc2_;
      }
      
      public function hideBmp(param1:Bitmap) : void
      {
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
      }
      
      public function handleResize(param1:Number, param2:Number) : void
      {
         if(this.width == param1 && this.height == param2)
         {
            if(!this._bmpDirty)
            {
               return;
            }
         }
         this.width = param1;
         this.height = param2;
         this._bmpDirty = false;
         this.handleResizeBmp(this.subtitle_bmp);
         this.handleResizeBmp(this.supertitle_bmp);
      }
      
      public function handleResizeBmp(param1:Bitmap) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:BitmapData = param1.bitmapData;
         var _loc3_:Number = Math.max(param1.width,!!_loc2_ ? _loc2_.width : 0);
         var _loc4_:Number = Math.max(param1.height,!!_loc2_ ? _loc2_.height : 0);
         param1.x = (this.width - _loc3_) / 2;
         if(param1 == this.supertitle_bmp)
         {
            param1.y = MARGIN;
         }
         else
         {
            param1.y = this.height - MARGIN - _loc4_;
         }
      }
      
      public function hideSupertitle() : void
      {
         this.hideBmp(this.supertitle_bmp);
      }
      
      public function hideSubtitle() : void
      {
         this.hideBmp(this.subtitle_bmp);
      }
      
      public function cleanup() : void
      {
         this.hideBmp(this.supertitle_bmp);
         this.hideBmp(this.subtitle_bmp);
         if(Boolean(this.supertitle_bmp) && Boolean(this.supertitle_bmp.bitmapData))
         {
            this.supertitle_bmp.bitmapData.dispose();
         }
         if(Boolean(this.subtitle_bmp) && Boolean(this.subtitle_bmp.bitmapData))
         {
            this.subtitle_bmp.bitmapData.dispose();
         }
         this.subtitle_bmp = null;
         this.supertitle_bmp = null;
         this.config = null;
         this.container = null;
         this.pm = null;
      }
   }
}
