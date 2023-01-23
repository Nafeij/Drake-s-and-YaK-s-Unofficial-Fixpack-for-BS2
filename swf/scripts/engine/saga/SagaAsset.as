package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.resource.IResource;
   import engine.resource.event.ResourceLoadedEvent;
   
   public class SagaAsset
   {
       
      
      public var url:String;
      
      public var resource:IResource;
      
      public var bundle:SagaAssetBundle;
      
      public var parent:SagaAsset;
      
      public var clazz:Class;
      
      public var logger:ILogger;
      
      public function SagaAsset(param1:String, param2:Class, param3:SagaAssetBundle, param4:SagaAsset)
      {
         super();
         this.url = param1;
         this.bundle = param3;
         this.parent = param4;
         this.clazz = param2;
         this.logger = param3.logger;
      }
      
      public function toString() : String
      {
         return this.url;
      }
      
      protected function handleLoadStart() : void
      {
      }
      
      protected function handleLoadComplete() : void
      {
      }
      
      public function load() : void
      {
         this.resource = this.bundle.getResource(this.url,this.clazz);
         this.handleLoadStart();
         this.resource.addResourceListener(this.resourceCompleteHandler);
      }
      
      private function resourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         this.handleLoadComplete();
      }
   }
}
