package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import engine.session.IAuthentication;
   
   public class GogAuthentication implements IAuthentication
   {
       
      
      private var galaxy:GogAne;
      
      public function GogAuthentication(param1:GogAne)
      {
         super();
         this.galaxy = param1;
      }
      
      public function requestAuthSessionTicket(param1:Function) : String
      {
         return null;
      }
      
      public function getUserID() : String
      {
         return this.galaxy.GalaxyAPI_GetUserId();
      }
      
      public function getAccountID(param1:String) : int
      {
         this.galaxy.logger.i("GOG","Defaulting accountId=0");
         return 0;
      }
      
      public function getDisplayName() : String
      {
         var _loc1_:String = this.galaxy.GalaxyAPI_GetPersonaName();
         this.galaxy.logger.i("GOG","UserName: " + _loc1_);
         return !!_loc1_ ? _loc1_ : "unknown_user";
      }
      
      public function getUserLanguage() : String
      {
         return this.galaxy.GalaxyAPI_GetPlatformLanguageCode();
      }
      
      public function get enabled() : Boolean
      {
         return Boolean(this.galaxy) && this.galaxy.enabled;
      }
      
      public function get initialized() : Boolean
      {
         return Boolean(this.galaxy) && this.galaxy.initialized;
      }
   }
}
