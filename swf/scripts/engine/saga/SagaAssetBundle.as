package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.resource.IResource;
   import engine.resource.IResourceGroup;
   import engine.resource.IResourceManager;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.resource.ResourceMonitor;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SagaAssetBundle extends EventDispatcher
   {
       
      
      public var id:String;
      
      public var saga:ISaga;
      
      public var resman:IResourceManager;
      
      public var group:IResourceGroup;
      
      public var logger:ILogger;
      
      public var assets:Vector.<SagaAsset>;
      
      public var monitor:ResourceMonitor;
      
      public function SagaAssetBundle(param1:String, param2:ISaga, param3:IResourceManager)
      {
         this.assets = new Vector.<SagaAsset>();
         super();
         this.id = param1;
         this.logger = param2.logger;
         this.saga = param2;
         this.resman = param3;
         this.group = new ResourceGroup(this,this.logger);
         this.monitor = new ResourceMonitor(param1,this.logger,this.resourceMonitorHandler);
         (param3 as ResourceManager).addMonitor(this.monitor);
         this.logger.i("SAB ","Created " + this);
      }
      
      override public function toString() : String
      {
         var _loc2_:SagaAsset = null;
         var _loc1_:String = "";
         _loc1_ += "id=" + this.id + " assets=" + this.assets.length + "\n";
         for each(_loc2_ in this.assets)
         {
            _loc1_ += " > " + _loc2_.toString() + "\n";
         }
         return _loc1_;
      }
      
      public function loadManifest(param1:String) : void
      {
         this.addAsset(param1,null,null,SagaAssetType.MANIFEST);
      }
      
      public function cleanup() : void
      {
         (this.resman as ResourceManager).removeMonitor(this.monitor);
         this.group.release();
         this.group = null;
      }
      
      public function getResource(param1:String, param2:Class) : IResource
      {
         return this.resman.getResource(param1,param2);
      }
      
      public function addAsset(param1:String, param2:String, param3:SagaAsset, param4:SagaAssetType) : SagaAsset
      {
         if(param2)
         {
            if(!this.saga.expression.evaluate(param2,false))
            {
               this.logger.i("SAB ","Skipping asset add [" + param1 + "]");
               return null;
            }
         }
         var _loc5_:SagaAsset = SagaAssetCtor.ctor(param1,this,param3,param4);
         this.assets.push(_loc5_);
         _loc5_.load();
         this.logger.i("SAB ","addAsset " + _loc5_);
         return _loc5_;
      }
      
      private function resourceMonitorHandler(param1:ResourceMonitor) : void
      {
         this.checkFinished();
      }
      
      public function checkFinished() : void
      {
         this.logger.i("SAB ","checkFinished " + this.monitor.empty);
         if(this.monitor.empty)
         {
            this.logger.i("SAB ","COMPLETE!");
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}
