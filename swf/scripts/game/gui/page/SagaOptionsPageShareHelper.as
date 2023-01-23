package game.gui.page
{
   import com.stoicstudio.platform.PlatformRating;
   import com.stoicstudio.platform.PlatformShare;
   import com.stoicstudio.platform.PlatformSoundtrack;
   import engine.core.locale.Locale;
   import engine.core.util.AppInfo;
   import engine.saga.SagaAchievements;
   import game.cfg.GameConfig;
   import game.gui.IGuiDialog;
   import game.gui.IGuiSagaOptionsShareListener;
   
   public class SagaOptionsPageShareHelper implements IGuiSagaOptionsShareListener
   {
       
      
      private var config:GameConfig;
      
      public function SagaOptionsPageShareHelper(param1:GameConfig)
      {
         super();
         this.config = param1;
      }
      
      public function guiSagaOptionsShare_Stats() : void
      {
         this.config.logger.info(">>> STATSBUTTON SagaOptionsPageShareHelper");
         SagaAchievements.showPlatformAchievements();
      }
      
      public function get guiSagaOptionsShare_CanRateApp() : Boolean
      {
         return PlatformRating.canShowAppRating;
      }
      
      public function get guiSagaOptionsShare_CanShareApp() : Boolean
      {
         return PlatformShare.canShowAppShare;
      }
      
      public function get guiSagaOptionsShare_CanSoundtrack() : Boolean
      {
         return PlatformSoundtrack.canShowSoundtrack;
      }
      
      public function get guiSagaOptionsShare_CanShowStats() : Boolean
      {
         return SagaAchievements.canShowPlatformAchievements;
      }
      
      public function guiSagaOptionsShare_RateApp() : void
      {
         var _loc4_:String = null;
         var _loc1_:AppInfo = AppInfo.instance;
         var _loc2_:String = "share_rate_title_" + _loc1_.master_sku;
         var _loc3_:Locale = this.config.gameGuiContext.locale;
         _loc4_ = _loc3_.translateGui(_loc2_,true);
         if(!_loc4_)
         {
            _loc4_ = _loc3_.translateGui("share_rate_title",false);
         }
         var _loc5_:IGuiDialog = this.config.gameGuiContext.createDialog();
         var _loc6_:String = this.config.gameGuiContext.translate("share_rate_body");
         var _loc7_:String = this.config.gameGuiContext.translate("yes");
         var _loc8_:String = this.config.gameGuiContext.translate("no");
         _loc5_.openTwoBtnDialog(_loc4_,_loc6_,_loc7_,_loc8_,this.dialogRateAppCloseHandler);
      }
      
      public function guiSagaOptionsShare_ShareApp() : void
      {
         PlatformShare.showAppShare();
      }
      
      public function guiSagaOptionsShare_Soundtrack() : void
      {
         PlatformSoundtrack.showSoundtrack();
      }
      
      private function dialogRateAppCloseHandler(param1:String) : void
      {
         var _loc2_:String = this.config.gameGuiContext.translate("yes");
         if(param1 == _loc2_)
         {
            PlatformRating.showAppRating();
         }
      }
   }
}
