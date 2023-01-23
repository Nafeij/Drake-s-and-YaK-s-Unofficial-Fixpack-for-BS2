package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class SteamPlatformSoundtrack
   {
       
      
      private var steamworks:SteamworksAne;
      
      private var soundtrack_appid:int;
      
      private var appid:int;
      
      public function SteamPlatformSoundtrack(param1:SteamworksAne, param2:int, param3:int)
      {
         super();
         this.steamworks = param1;
         this.soundtrack_appid = param2;
         this.appid = param3;
      }
      
      public function showSoundtrack() : void
      {
         var _loc2_:URLRequest = null;
         var _loc1_:String = "http://store.steampowered.com/app/" + this.soundtrack_appid;
         if(Boolean(this.steamworks) && this.steamworks.enabled)
         {
            if(this.steamworks.SteamUtils_IsOverlayEnabled())
            {
               this.steamworks.SteamFriends_ActivateGameOverlayToWebPage(_loc1_);
               return;
            }
         }
         if(this.soundtrack_appid)
         {
            _loc2_ = new URLRequest(_loc1_);
            navigateToURL(_loc2_);
         }
      }
   }
}
