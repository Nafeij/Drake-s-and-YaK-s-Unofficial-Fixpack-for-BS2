package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class SteamPlatformBuyApp
   {
       
      
      private var steamworks:SteamworksAne;
      
      private var appid:int;
      
      public function SteamPlatformBuyApp(param1:SteamworksAne, param2:int)
      {
         super();
         this.steamworks = param1;
         this.appid = param2;
      }
      
      public function showApp() : void
      {
         var _loc2_:URLRequest = null;
         var _loc1_:String = "http://store.steampowered.com/app/" + this.appid;
         if(Boolean(this.steamworks) && this.steamworks.enabled)
         {
            if(this.steamworks.SteamUtils_IsOverlayEnabled())
            {
               this.steamworks.SteamFriends_ActivateGameOverlayToWebPage(_loc1_);
               return;
            }
         }
         if(this.appid)
         {
            _loc2_ = new URLRequest(_loc1_);
            navigateToURL(_loc2_);
         }
      }
   }
}
