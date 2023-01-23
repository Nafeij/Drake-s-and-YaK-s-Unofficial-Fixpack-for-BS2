package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import engine.saga.ISagaDlc;
   import engine.saga.SagaDlcEntry;
   
   public final class SteamSagaDlc implements ISagaDlc
   {
       
      
      private var steamworks:SteamworksAne;
      
      public function SteamSagaDlc(param1:SteamworksAne)
      {
         super();
         this.steamworks = param1;
      }
      
      public function ownsDlc(param1:SagaDlcEntry, param2:Function = null) : int
      {
         var _loc3_:Boolean = false;
         if(Boolean(this.steamworks) && this.steamworks.enabled)
         {
            if(param1.platform_id_steam_appid < 0)
            {
               return SagaDlcEntry.DLC_OWNED;
            }
            if(param1.platform_id_steam_appid)
            {
               _loc3_ = this.steamworks.SteamApps_BIsDlcInstalled(param1.platform_id_steam_appid);
               return _loc3_ ? SagaDlcEntry.DLC_OWNED : SagaDlcEntry.DLC_NOT_OWNED;
            }
         }
         return SagaDlcEntry.DLC_STATUS_UNKNOWN;
      }
   }
}
