package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import air.steamworks.ane.SteamworksEvent;
   import engine.session.IAuthentication;
   
   public final class SteamAuthentication implements IAuthentication
   {
       
      
      private var steamworks:SteamworksAne;
      
      private var steamAuthTicket:String = null;
      
      private var authTicketHandle:int;
      
      private var authCallback:Function;
      
      public function SteamAuthentication(param1:SteamworksAne)
      {
         super();
         this.steamworks = param1;
      }
      
      public function requestAuthSessionTicket(param1:Function) : String
      {
         if(param1 != null)
         {
            this.authCallback = param1;
            this.steamworks.addEventListener(SteamworksEvent.AUTH_TICKET,this.authTicketHandler);
         }
         this.authTicketHandle = this.steamworks.SteamUser_GetAuthSessionTicketHandle();
         if(this.authTicketHandle)
         {
            this.steamAuthTicket = this.steamworks.SteamUser_GetAuthSessionTicket(this.authTicketHandle);
         }
         return this.steamAuthTicket;
      }
      
      private function authTicketHandler(param1:SteamworksEvent) : void
      {
         var _loc2_:Function = null;
         this.steamworks.removeEventListener(SteamworksEvent.AUTH_TICKET,this.authTicketHandler);
         if(this.authCallback != null)
         {
            _loc2_ = this.authCallback;
            this.authCallback = null;
            _loc2_(this.steamAuthTicket);
         }
      }
      
      public function getUserID() : String
      {
         return this.steamworks.SteamUser_GetSteamID();
      }
      
      public function getAccountID(param1:String) : int
      {
         return this.steamworks.SteamID_GetAccountId(param1);
      }
      
      public function getDisplayName() : String
      {
         return this.steamworks.SteamFriends_GetPersonaName();
      }
      
      public function getUserLanguage() : String
      {
         return this.steamworks.SteamApps_GetCurrentGameLanguage();
      }
      
      public function get enabled() : Boolean
      {
         return Boolean(this.steamworks) && this.steamworks.enabled;
      }
      
      public function get initialized() : Boolean
      {
         return Boolean(this.steamworks) && this.steamworks.initialized;
      }
   }
}
