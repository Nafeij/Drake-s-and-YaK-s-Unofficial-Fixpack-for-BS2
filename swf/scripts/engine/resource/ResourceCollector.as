package engine.resource
{
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import flash.utils.Dictionary;
   
   public class ResourceCollector
   {
      
      public static var ENABLED:Boolean;
      
      public static var collected_urls_dict:Dictionary = new Dictionary();
      
      public static var collected_urls:Array = [];
      
      private static var _id:String = "ResourceCollector";
       
      
      public function ResourceCollector()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function collectUrl(param1:String) : void
      {
         if(!ENABLED)
         {
            return;
         }
         if(StringUtil.endsWith(param1,".clipq"))
         {
            return;
         }
         if(collected_urls_dict[param1])
         {
            return;
         }
         if(!StringUtil.startsWith(param1,"http://"))
         {
            collected_urls_dict[param1] = true;
            collected_urls.push(param1);
         }
      }
      
      public static function output(param1:AppInfo, param2:ResourceManager) : void
      {
         var _loc8_:String = null;
         if(!ENABLED)
         {
            return;
         }
         var _loc3_:ILogger = param2.logger;
         var _loc4_:String = "assets.alpha_files=\\\n";
         collected_urls.sort();
         _loc4_ += collected_urls.join(",\\\n");
         var _loc5_:String = param2.assetPath;
         var _loc6_:String = "assets.properties";
         var _loc7_:int = _loc5_.indexOf("/compile-assets");
         if(_loc7_ < 0)
         {
            _loc3_.info("No [/compile-assets] discovered in [" + _loc5_ + "], using Documents folder [" + _loc6_ + "]");
            param1.saveFileString(AppInfo.DIR_DOCUMENTS,_loc6_,_loc4_,false);
         }
         else
         {
            _loc8_ = param1.master_sku;
            _loc5_ = _loc5_.substring(0,_loc7_) + "/build/input/alpha/" + _loc8_ + "a/" + _loc6_;
            _loc3_.info("Saving to [" + _loc5_ + "]");
            param1.saveFileString(AppInfo.DIR_ABSOLUTE,_loc5_,_loc4_,false);
         }
      }
   }
}
