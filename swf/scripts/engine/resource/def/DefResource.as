package engine.resource.def
{
   import engine.core.util.StableJson;
   import engine.resource.ILoaderFactory;
   import engine.resource.ResourceManager;
   import engine.resource.URLResource;
   import flash.net.URLLoaderDataFormat;
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   
   public class DefResource extends URLResource
   {
       
      
      public var jo:Object;
      
      public var bytes:ByteArray;
      
      public function DefResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         if(logger.isDebugEnabled)
         {
         }
         if(!error && data)
         {
            if(dataFormat == URLLoaderDataFormat.TEXT)
            {
               this.jo = StableJson.parse(data);
            }
            else if(dataFormat == URLLoaderDataFormat.BINARY)
            {
               this.bytes = data as ByteArray;
               try
               {
                  this.jo = this.bytes.readObject();
               }
               catch(e:Error)
               {
                  logger.error("Failed to finish load of " + this + ":\n" + e.getStackTrace());
                  setError();
               }
            }
         }
         this.checkDefChildren();
      }
      
      private function checkDefChildren() : void
      {
         var _loc1_:String = null;
         var _loc2_:Class = null;
         var _loc3_:String = null;
         if(this.jo)
         {
            _loc1_ = this.jo.resourceClass;
            _loc2_ = !!_loc1_ ? getDefinitionByName(_loc1_) as Class : DefResource;
            if(this.jo.resources != undefined)
            {
               for each(_loc3_ in this.jo.resources)
               {
                  addChild(_loc3_,_loc2_);
               }
            }
         }
      }
      
      override protected function internalUnload() : void
      {
         this.jo = null;
         super.internalUnload();
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
   }
}
