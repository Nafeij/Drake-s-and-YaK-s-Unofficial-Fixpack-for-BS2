package game.gui
{
   import engine.gui.GuiGpNav;
   import flash.display.MovieClip;
   import game.gui.page.SagaOptionsPage;
   
   public class GuiSagaOptionsShare extends GuiBase implements IGuiSagaOptionsShare
   {
       
      
      public var _button$share_stats:ButtonWithIndex;
      
      public var _button$share_rate:ButtonWithIndex;
      
      public var _button$share_share:ButtonWithIndex;
      
      public var _button$share_soundtrack:ButtonWithIndex;
      
      public var _image_google_play_controller:MovieClip;
      
      public var _google_games_achievements:MovieClip;
      
      private var listener:IGuiSagaOptionsShareListener;
      
      public function GuiSagaOptionsShare()
      {
         super();
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaOptionsShareListener, param3:GuiGpNav) : void
      {
         initGuiBase(param1);
         this.listener = param2;
         this._button$share_stats = requireGuiChild("button$share_stats") as ButtonWithIndex;
         this._button$share_rate = requireGuiChild("button$share_rate") as ButtonWithIndex;
         this._button$share_share = requireGuiChild("button$share_share") as ButtonWithIndex;
         this._button$share_soundtrack = requireGuiChild("button$share_soundtrack") as ButtonWithIndex;
         this._google_games_achievements = requireGuiChild("google_games_achievements") as MovieClip;
         this._button$share_stats.setDownFunction(this.buttonStatsHandler);
         this._button$share_rate.setDownFunction(this.buttonRateHandler);
         this._button$share_share.setDownFunction(this.buttonShareHandler);
         this._button$share_soundtrack.setDownFunction(this.buttonSoundtrackHandler);
         this._button$share_stats.guiButtonContext = param1;
         this._button$share_rate.guiButtonContext = param1;
         this._button$share_share.guiButtonContext = param1;
         this._button$share_soundtrack.guiButtonContext = param1;
         this._button$share_stats.textOpaqueBackground = 0;
         this._button$share_rate.textOpaqueBackground = 0;
         this._button$share_share.textOpaqueBackground = 0;
         this._button$share_soundtrack.textOpaqueBackground = 0;
         this._image_google_play_controller = this._button$share_stats["google_play_container"] as MovieClip;
         if(this._image_google_play_controller != null)
         {
            this._image_google_play_controller.visible = GuiSagaOptionsConfig.ENABLE_GOOGLE_PLAY;
         }
         this._google_games_achievements.visible = GuiSagaOptionsConfig.ENABLE_GOOGLE_PLAY;
         this._button$share_stats.visible = param2.guiSagaOptionsShare_CanShowStats;
         this._button$share_rate.visible = param2.guiSagaOptionsShare_CanRateApp;
         this._button$share_share.visible = param2.guiSagaOptionsShare_CanShareApp;
         this._button$share_soundtrack.visible = param2.guiSagaOptionsShare_CanSoundtrack;
         var _loc4_:Boolean = SagaOptionsPage.ENABLE_SHARE_BAR;
         if(_loc4_)
         {
            param3.add(this._button$share_stats);
            param3.add(this._button$share_rate);
            param3.add(this._button$share_share);
            param3.add(this._button$share_soundtrack);
         }
         else
         {
            this.visible = false;
         }
         this.mouseEnabled = false;
         this.mouseChildren = true;
         mouseEnabled = false;
         mouseChildren = true;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
      }
      
      public function cleanup() : void
      {
         this._button$share_stats.cleanup();
         this._button$share_rate.cleanup();
         this._button$share_share.cleanup();
         this._button$share_soundtrack.cleanup();
         this.listener = null;
         cleanupGuiBase();
      }
      
      private function buttonStatsHandler(param1:*) : void
      {
         this.listener.guiSagaOptionsShare_Stats();
      }
      
      private function buttonRateHandler(param1:*) : void
      {
         this.listener.guiSagaOptionsShare_RateApp();
      }
      
      private function buttonShareHandler(param1:*) : void
      {
         this.listener.guiSagaOptionsShare_ShareApp();
      }
      
      private function buttonSoundtrackHandler(param1:*) : void
      {
         this.listener.guiSagaOptionsShare_Soundtrack();
      }
   }
}
