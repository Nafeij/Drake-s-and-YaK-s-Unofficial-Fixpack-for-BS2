package engine.resource
{
   import engine.core.locale.LocaleId;
   import engine.resource.def.DefResource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.convo.def.ConvoDef;
   import engine.saga.convo.def.ConvoDefVars;
   import engine.saga.convo.def.ConvoStringsDef;
   import flash.utils.ByteArray;
   
   public class ConvoDefResource extends URLResource
   {
       
      
      private var stringsUrl:String;
      
      public var convoDef:ConvoDefVars;
      
      public var bytes:ByteArray;
      
      public function ConvoDefResource(param1:String, param2:ResourceManager, param3:ILoaderFactory = null)
      {
         super(param1,param2,param3);
         if(param2.localeId)
         {
            if(param2.localeId.id != LocaleId.en.id)
            {
               this.stringsUrl = ConvoDef.getStringsUrl(param1);
               this.stringsUrl = param2.localeId.translateLocaleUrl(this.stringsUrl);
               this.stringsUrl = this.stringsUrl.replace("story.z","json.z");
               addChild(this.stringsUrl,DefResource);
            }
         }
      }
      
      public static function swapConvoStrings(param1:ConvoDef, param2:ResourceManager, param3:Function) : void
      {
         var stringsUrl:String;
         var cdv:ConvoDefVars = null;
         var dr:DefResource = null;
         var drLoadedHandler:Function = null;
         var cd:ConvoDef = param1;
         var erm:ResourceManager = param2;
         var callback:Function = param3;
         drLoadedHandler = function(param1:ResourceLoadedEvent):void
         {
            var csd:ConvoStringsDef = null;
            var event:ResourceLoadedEvent = param1;
            dr.removeResourceListener(drLoadedHandler);
            try
            {
               if(dr.ok && Boolean(dr.jo))
               {
                  csd = new ConvoStringsDef(dr.url).fromJson(dr.jo,erm.logger,true);
                  cdv.strings = csd;
                  dr.release();
               }
            }
            catch(err:Error)
            {
               erm.logger.error("Problem swapping convo strings:\n" + err.getStackTrace());
            }
            if(callback != null)
            {
               callback(cd);
            }
         };
         cdv = cd as ConvoDefVars;
         if(!cdv)
         {
            if(callback != null)
            {
               callback(cd);
            }
            return;
         }
         if(Boolean(erm.localeId) && erm.localeId.isEn)
         {
            cdv.strings = null;
            callback(null);
            return;
         }
         stringsUrl = ConvoDef.getStringsUrl(cd.url);
         stringsUrl = erm.localeId.translateLocaleUrl(stringsUrl);
         stringsUrl = stringsUrl.replace("story.z","json.z");
         dr = erm.getResource(stringsUrl,DefResource) as DefResource;
         dr.addResourceListener(drLoadedHandler);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         this.bytes = data as ByteArray;
      }
      
      override protected function internalOnLoadedAllComplete() : void
      {
         var _loc2_:DefResource = null;
         var _loc1_:ConvoStringsDef = null;
         if(this.stringsUrl)
         {
            _loc2_ = resourceManager.getResource(this.stringsUrl,DefResource) as DefResource;
            if(_loc2_.ok && Boolean(_loc2_.jo))
            {
               _loc1_ = new ConvoStringsDef(_loc2_.url).fromJson(_loc2_.jo,logger,true);
            }
         }
         this.convoDef = new ConvoDefVars(_loc1_).readBytes(this.bytes,logger) as ConvoDefVars;
         this.convoDef.url = this.url;
         if(_loc1_)
         {
            _loc1_ = null;
            _loc2_.release();
            _loc2_ = null;
         }
         this.bytes.clear();
         this.bytes = null;
      }
      
      override protected function internalUnload() : void
      {
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
   }
}
