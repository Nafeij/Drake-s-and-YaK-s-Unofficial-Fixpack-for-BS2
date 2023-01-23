package com.stoicstudio.platform
{
   public class PlatformUserProfile
   {
      
      public static var _showUserProfileFunc:Function;
       
      
      public function PlatformUserProfile()
      {
         super();
      }
      
      public static function showUserProfile(param1:String) : void
      {
         if(isSupported)
         {
            _showUserProfileFunc(param1);
         }
      }
      
      public static function get isSupported() : Boolean
      {
         return _showUserProfileFunc != null;
      }
   }
}
