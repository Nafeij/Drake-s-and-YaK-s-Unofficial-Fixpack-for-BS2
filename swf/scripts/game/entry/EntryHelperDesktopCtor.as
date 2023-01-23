package game.entry
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import flash.utils.Dictionary;
   
   public class EntryHelperDesktopCtor
   {
      
      private static var _entryhelpers:Dictionary = new Dictionary();
       
      
      public function EntryHelperDesktopCtor()
      {
         super();
      }
      
      public static function registerEntryHelper(param1:String, param2:Class) : void
      {
         _entryhelpers[param1] = param2;
      }
      
      public static function fromPlatform(param1:String, param2:AppInfo, param3:Boolean) : IEntryHelperDesktop
      {
         var _loc4_:IEntryHelperDesktop = null;
         var _loc5_:ILogger = param2.logger;
         Platform.id = param1;
         _loc5_.i("INIT","build_platform=[" + param1 + "]");
         var _loc6_:Class = _entryhelpers[param1];
         if(_loc6_ == null)
         {
            _loc5_.i("INIT","Generic desktop platform... [" + param1 + "]");
            _loc4_ = new GenericEntryHelper(param1);
         }
         else
         {
            _loc4_ = new _loc6_(param2);
         }
         return _loc4_;
      }
   }
}
