package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class SteamPlatformRating
   {
       
      
      private var steamworks:SteamworksAne;
      
      public function SteamPlatformRating(param1:SteamworksAne)
      {
         super();
         this.steamworks = param1;
      }
      
      public function showAppRating() : void
      {
         var _loc1_:String = null;
         var _loc2_:URLRequest = null;
         if(Boolean(this.steamworks) && Boolean(this.steamworks.appid))
         {
            _loc1_ = "http://store.steampowered.com/recommended/recommendgame/" + this.steamworks.appid;
            if(this.steamworks.SteamUtils_IsOverlayEnabled())
            {
               this.steamworks.SteamFriends_ActivateGameOverlayToWebPage(_loc1_);
               return;
            }
            _loc2_ = new URLRequest(_loc1_);
            navigateToURL(_loc2_);
         }
      }
   }
}
