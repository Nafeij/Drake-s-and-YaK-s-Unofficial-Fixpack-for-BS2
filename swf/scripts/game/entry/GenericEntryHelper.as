package game.entry
{
   import com.stoicstudio.platform.PlatformRating;
   import com.stoicstudio.platform.PlatformShare;
   import com.stoicstudio.platform.PlatformSoundtrack;
   import com.stoicstudio.platform.UrlPlatformRating;
   import com.stoicstudio.platform.UrlPlatformShare;
   import com.stoicstudio.platform.UrlPlatformSoundtrack;
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSave;
   import engine.saga.NullSagaAchievements;
   import engine.saga.NullSagaDlc;
   import engine.saga.NullSagaLeaderboards;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaDlcEntry;
   import engine.saga.SagaLeaderboards;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.session.NullAuthentication;
   import game.cfg.GameConfig;
   import game.session.states.PreAuthState;
   import game.session.states.StartState;
   import game.view.GameWrapper;
   
   public class GenericEntryHelper implements IEntryHelperDesktop
   {
       
      
      private var _entry:GameEntryDesktop;
      
      private var _platformId:String;
      
      private var _userId:String = null;
      
      public function GenericEntryHelper(param1:String)
      {
         super();
         this._platformId = param1;
      }
      
      public static function performGenericPlatformSetup(param1:AppInfo) : void
      {
         var _loc5_:UrlPlatformRating = null;
         var _loc6_:UrlPlatformSoundtrack = null;
         var _loc7_:UrlPlatformShare = null;
         SagaAchievements.impl = new NullSagaAchievements();
         SagaLeaderboards.impl = new NullSagaLeaderboards();
         SagaDlcEntry.dlcCheck = new NullSagaDlc();
         PreAuthState.authenticator = new NullAuthentication();
         StartState.authenticator = PreAuthState.authenticator;
         var _loc2_:String = param1.ini["url_platform_rating"];
         var _loc3_:String = param1.ini["url_platform_soundtrack"];
         var _loc4_:String = param1.ini["url_platform_share"];
         if(_loc2_)
         {
            _loc5_ = new UrlPlatformRating(_loc2_);
            PlatformRating._showAppRatingFunc = _loc5_.showAppRating;
         }
         if(_loc3_)
         {
            _loc6_ = new UrlPlatformSoundtrack(_loc3_);
            PlatformSoundtrack._showSoundtrackFunc = _loc6_.showSoundtrack;
         }
         if(_loc4_)
         {
            _loc7_ = new UrlPlatformShare(_loc4_);
            PlatformShare._showAppShareFunc = _loc7_.showAppShare;
         }
      }
      
      public function get entry() : GameEntryDesktop
      {
         return this._entry;
      }
      
      public function get betaBranch() : String
      {
         return null;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function init(param1:GameEntryDesktop) : void
      {
         this._entry = param1;
         GameSaveSynchronizer.PULL_ENABLED = false;
         GameSaveSynchronizer.MULTIPLE_PULL = false;
         var _loc2_:AppInfo = this._entry.appInfo;
         this._userId = _loc2_.macAddress;
      }
      
      public function setup() : void
      {
         this._entry.logInfo("GenericEntryHelper.setup " + this._platformId);
         performGenericPlatformSetup(this._entry.appInfo);
      }
      
      public function initWrapper(param1:GameWrapper) : void
      {
         param1.config.addUpdateFunction(this.updateGeneric);
      }
      
      public function startWrapper(param1:GameWrapper, param2:int) : void
      {
      }
      
      public function getAnalyticsInfo() : Vector.<String>
      {
         var _loc1_:Vector.<String> = null;
         _loc1_ = new Vector.<String>();
         var _loc2_:String = "/" + this._platformId;
         _loc1_.push(_loc2_,this.userId);
         return _loc1_;
      }
      
      public function processArgument(param1:String) : Boolean
      {
         return false;
      }
      
      final public function initCloudSave(param1:GameConfig, param2:AppInfo) : CloudSave
      {
         return null;
      }
      
      final private function updateGeneric(param1:int) : void
      {
      }
      
      final private function logDebug(param1:String) : void
      {
         if(this._entry.appInfo.logger.isDebugEnabled)
         {
            this._entry.logDebug(param1);
         }
      }
      
      final private function logInfo(param1:String) : void
      {
         this._entry.logInfo(param1);
      }
      
      final private function logError(param1:String) : void
      {
         this._entry.logError(param1);
      }
   }
}
