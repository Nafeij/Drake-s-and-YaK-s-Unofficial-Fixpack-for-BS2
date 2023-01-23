package com.stoicstudio.platform
{
   public class PlatformSoundtrack
   {
      
      public static var _showSoundtrackFunc:Function;
       
      
      public function PlatformSoundtrack()
      {
         super();
      }
      
      public static function showSoundtrack() : void
      {
         if(_showSoundtrackFunc != null)
         {
            _showSoundtrackFunc();
         }
      }
      
      public static function get canShowSoundtrack() : Boolean
      {
         return _showSoundtrackFunc != null;
      }
   }
}
