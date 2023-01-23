package engine.resource.def
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class DefWranglerWrangler extends EventDispatcher
   {
      
      public static const READY_DEBUG:Boolean = false;
       
      
      public var terminating:Boolean;
      
      public var ready:Boolean;
      
      private var wranglers:Dictionary;
      
      protected var logger:ILogger;
      
      public var name:String;
      
      public var resman:ResourceManager;
      
      public function DefWranglerWrangler(param1:String, param2:ResourceManager, param3:ILogger)
      {
         this.wranglers = new Dictionary();
         super();
         this.resman = param2;
         this.name = param1;
         this.logger = param3;
      }
      
      override public function toString() : String
      {
         return "DefWranglerWrangler [" + this.name + "]";
      }
      
      public function cleanup() : void
      {
         var _loc1_:DefWrangler = null;
         for each(_loc1_ in this.wranglers)
         {
            _loc1_.cleanup();
         }
         this.terminating = true;
         this.wranglers = null;
         this.resman = null;
      }
      
      private function defWranglerCompleteHandler(param1:DefWrangler) : void
      {
         this.checkReady();
      }
      
      public function wrangle(param1:String) : DefWrangler
      {
         return this.waitForDefWrangler(new DefWrangler(param1,this.logger,this.resman,this.defWranglerCompleteHandler));
      }
      
      public function add(param1:DefWrangler) : DefWrangler
      {
         param1.completeCallback = this.defWranglerCompleteHandler;
         this.waitForDefWrangler(param1);
         return param1;
      }
      
      public function wrangled(param1:String) : DefWrangler
      {
         return this.wranglers[param1];
      }
      
      public function unwrangle(param1:String) : void
      {
         var _loc2_:DefWrangler = this.wranglers[param1];
         if(_loc2_)
         {
            delete this.wranglers[param1];
            _loc2_.cleanup();
         }
      }
      
      public function load() : void
      {
         var _loc1_:DefWrangler = null;
         for each(_loc1_ in this.wranglers)
         {
            _loc1_.load();
         }
         this.checkReady();
      }
      
      private function waitForDefWrangler(param1:DefWrangler) : DefWrangler
      {
         this.wranglers[param1.url] = param1;
         return param1;
      }
      
      private function checkReady() : void
      {
         var waiting:Boolean = false;
         var defLoaderHelper:DefWrangler = null;
         if(this.terminating)
         {
            return;
         }
         if(this.ready)
         {
            return;
         }
         for each(defLoaderHelper in this.wranglers)
         {
            if(!defLoaderHelper.complete)
            {
               waiting = this.waitingOn("defLoaderHelper-" + this.name,defLoaderHelper);
            }
         }
         if(waiting)
         {
            return;
         }
         this.ready = true;
         try
         {
            this.handleCompleting();
         }
         catch(e:Error)
         {
            logger.error("DefWrangler failed:\n" + e.getStackTrace());
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function handleCompleting() : void
      {
      }
      
      private function waitingOn(param1:String, param2:Object) : Boolean
      {
         if(READY_DEBUG)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("DefWranglerWrangler " + this.name + " WAITING on " + param1 + ": " + param2);
            }
         }
         return true;
      }
   }
}
