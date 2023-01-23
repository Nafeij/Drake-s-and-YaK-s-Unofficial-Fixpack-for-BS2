package lib.engine.resource.air
{
   import engine.core.logging.ILogger;
   import engine.resource.IVideoFinder;
   import engine.resource.loader.IResourceScheme;
   import flash.filesystem.File;
   
   public class FallbackVideoFinder implements IVideoFinder
   {
       
      
      private var scheme:IResourceScheme;
      
      private var looseVideoPaths:Vector.<File>;
      
      public var assetUrl:String;
      
      private var logger:ILogger;
      
      public function FallbackVideoFinder(param1:IResourceScheme, param2:String, param3:String, param4:ILogger)
      {
         super();
         this.logger = param4;
         this.scheme = param1;
         this.assetUrl = param2;
         if(this.assetUrl.charAt(this.assetUrl.length - 1) != "/")
         {
            this.assetUrl += "/";
         }
         this.looseVideoPaths = new Vector.<File>();
         if(param3 != null)
         {
            this.looseVideoPaths.push(File.applicationDirectory.resolvePath(param3));
         }
      }
      
      public function addSearchPath(param1:File) : void
      {
         this.looseVideoPaths.push(param1);
      }
      
      public function getVideoUrl(param1:String) : String
      {
         var _loc2_:File = null;
         var _loc3_:File = null;
         this.logger.info("FallbackVideoFinder: looking for " + param1);
         for each(_loc2_ in this.looseVideoPaths)
         {
            this.logger.info("FallbackVideoFinder: checking " + _loc2_.url);
            _loc3_ = _loc2_.resolvePath(param1);
            if(_loc3_.exists)
            {
               this.logger.info("FallbackVideoFinder: found loose file at " + _loc3_.url);
               return _loc3_.url;
            }
         }
         return this.scheme.getVideoUrl(this.assetUrl + param1);
      }
      
      public function releaseVideoUrl(param1:String) : void
      {
         var _loc2_:File = null;
         var _loc3_:File = null;
         for each(_loc2_ in this.looseVideoPaths)
         {
            _loc3_ = _loc2_.resolvePath(param1);
            if(_loc3_.exists)
            {
               return;
            }
         }
         this.logger.i("VIDEO","Did not find loose file for video {0}. Releasing from resource scheme at {1} {2}",param1,this.assetUrl,param1);
         this.scheme.releaseVideoUrl(this.assetUrl + param1);
      }
   }
}
