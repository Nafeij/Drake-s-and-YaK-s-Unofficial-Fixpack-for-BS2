package com.stoicstudio.platform
{
   public class PlatformRating
   {
      
      public static var _showAppRatingFunc:Function;
       
      
      public function PlatformRating()
      {
         super();
      }
      
      public static function showAppRating() : void
      {
         if(_showAppRatingFunc != null)
         {
            _showAppRatingFunc();
         }
      }
      
      public static function get canShowAppRating() : Boolean
      {
         return _showAppRatingFunc != null;
      }
   }
}
