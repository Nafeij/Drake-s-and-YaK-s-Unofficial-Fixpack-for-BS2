package engine.resource.def
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import flash.events.Event;
   
   public class DefWrangler
   {
       
      
      private var defr:DefResource;
      
      public var completeCallback:Function;
      
      public var logger:ILogger;
      
      public var complete:Boolean;
      
      public var resman:ResourceManager;
      
      public var url:String;
      
      public function DefWrangler(param1:String, param2:ILogger, param3:ResourceManager, param4:Function)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("If you fail at passing me a url, I will fail at wrangling for you.");
         }
         if(!param3)
         {
            throw new ArgumentError("Well... My conjuration requires the sacrifice of a resource manager");
         }
         this.completeCallback = param4;
         this.logger = param2;
         this.resman = param3;
         this.url = param1;
      }
      
      public function cleanup() : void
      {
         if(this.defr)
         {
            this.defr.removeEventListener(Event.COMPLETE,this.defrCompleteHandler);
            this.defr.release();
            this.defr = null;
         }
         this.resman = null;
         this.completeCallback = null;
         this.logger = null;
         this.url = null;
      }
      
      public function toString() : String
      {
         return this.url;
      }
      
      public function load(param1:Boolean = false) : void
      {
         if(this.logger.isDebugEnabled)
         {
         }
         this.defr = this.resman.getResource(this.url,DefResource,null,null,param1) as DefResource;
         this.defr.addEventListener(Event.COMPLETE,this.defrCompleteHandler);
         if(this.logger.isDebugEnabled)
         {
         }
         if(this.defr.ok)
         {
            this.defrCompleteHandler(null);
         }
      }
      
      private function defrCompleteHandler(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         if(this.logger.isDebugEnabled)
         {
         }
         this.defr.removeEventListener(Event.COMPLETE,this.defrCompleteHandler);
         if(this.defr.ok)
         {
            _loc2_ = this.handleDefrComplete();
            if(!_loc2_)
            {
               this.logger.i("LOAD","DefWrangler " + this + " load handler did not complete, waiting...");
            }
            else
            {
               this.setComplete();
            }
            return;
         }
         this.setComplete();
      }
      
      protected function setComplete() : void
      {
         if(this.logger.isDebugEnabled)
         {
         }
         if(this.complete)
         {
            return;
         }
         this.complete = true;
         if(this.completeCallback != null)
         {
            this.completeCallback(this);
         }
      }
      
      public function get vars() : Object
      {
         return this.defr.ok ? this.defr.jo : null;
      }
      
      protected function handleDefrComplete() : Boolean
      {
         return true;
      }
   }
}
