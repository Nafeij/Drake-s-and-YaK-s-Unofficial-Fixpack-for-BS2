package engine.resource
{
   import engine.core.util.AppInfo;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class ResourceTextureSizes
   {
       
      
      private var originalSizes:Dictionary;
      
      private var appInfo:AppInfo;
      
      public function ResourceTextureSizes(param1:AppInfo)
      {
         var ba:ByteArray = null;
         var s:String = null;
         var lines:Array = null;
         var line:String = null;
         var toks:Array = null;
         var url:String = null;
         var p:Point = null;
         var appInfo:AppInfo = param1;
         this.originalSizes = new Dictionary();
         super();
         try
         {
            this.appInfo = appInfo;
            ba = appInfo.loadFile(AppInfo.DIR_APPLICATION,"png_sizes.txt");
            if(ba)
            {
               s = ba.readUTFBytes(ba.length);
               ba.clear();
               lines = s.split("\n");
               for each(line in lines)
               {
                  if(!(!line || line.charAt(0) == "#"))
                  {
                     toks = line.split(" ");
                     if(toks.length == 3)
                     {
                        url = String(toks[0]);
                        p = new Point(toks[1],toks[2]);
                        this.originalSizes[url] = p;
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
            appInfo.logger.error("ResourcetextureSizes ctor failed: " + e.getStackTrace());
            originalSizes = new Dictionary();
         }
      }
      
      public function getOriginalSize(param1:String) : Point
      {
         return this.originalSizes[param1];
      }
   }
}
