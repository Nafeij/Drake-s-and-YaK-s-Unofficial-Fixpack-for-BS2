package com.stoicstudio.platform
{
   public class PlatformShare
   {
      
      public static var _showAppShareFunc:Function;
       
      
      public function PlatformShare()
      {
         super();
      }
      
      public static function showAppShare() : void
      {
         if(_showAppShareFunc != null)
         {
            _showAppShareFunc();
         }
      }
      
      public static function get canShowAppShare() : Boolean
      {
         return _showAppShareFunc != null;
      }
   }
}
