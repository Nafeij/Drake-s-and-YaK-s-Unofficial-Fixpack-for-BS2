package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import engine.core.logging.ILogger;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class SteamPlatformShare
   {
       
      
      private var steamworks:SteamworksAne;
      
      private var logger:ILogger;
      
      public function SteamPlatformShare(param1:SteamworksAne, param2:ILogger)
      {
         super();
         this.steamworks = param1;
         this.logger = param2;
      }
      
      public function showAppShare() : void
      {
         this.logger.info("SteamPlatformShare.showAppShare steamworks=" + this.steamworks);
         if(!this.steamworks)
         {
            return;
         }
         if(this.steamworks.enabled)
         {
            if(this.steamworks.SteamUtils_IsOverlayEnabled())
            {
               this.logger.info("SteamPlatformShare.showAppShare OVERLAY appid=" + this.steamworks.appid);
               this.steamworks.SteamFriends_ActivateGameOverlayToStore(this.steamworks.appid,0);
               return;
            }
         }
         var _loc1_:String = "http://store.steampowered.com/app/" + this.steamworks.appid;
         this.logger.info("SteamPlatformShare.showAppShare URL=" + _loc1_);
         var _loc2_:URLRequest = new URLRequest(_loc1_);
         navigateToURL(_loc2_);
      }
   }
}
