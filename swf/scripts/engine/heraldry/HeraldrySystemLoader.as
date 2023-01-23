package engine.heraldry
{
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class HeraldrySystemLoader extends EventDispatcher
   {
       
      
      public var url:String;
      
      public var logger:ILogger;
      
      public var resman:ResourceManager;
      
      private var mainWrangler:DefWrangler;
      
      private var additionalWrangler:DefWrangler;
      
      private var additionalPlatformWrangler:DefWrangler;
      
      private var prefs:PrefBag;
      
      public var heraldry:HeraldrySystem;
      
      public function HeraldrySystemLoader(param1:String, param2:ILogger, param3:ResourceManager, param4:PrefBag)
      {
         super();
         this.url = param1;
         this.logger = param2;
         this.resman = param3;
         this.prefs = param4;
      }
      
      public function cleanup() : void
      {
         if(this.mainWrangler)
         {
            this.mainWrangler.cleanup();
            this.mainWrangler = null;
         }
         if(this.additionalWrangler)
         {
            this.additionalWrangler.cleanup();
            this.additionalWrangler = null;
         }
         if(this.additionalPlatformWrangler)
         {
            this.additionalPlatformWrangler.cleanup();
            this.additionalPlatformWrangler = null;
         }
      }
      
      public function load() : void
      {
         this.mainWrangler = new DefWrangler(this.url,this.logger,this.resman,this.mainWranglerCompleteHandler);
         this.mainWrangler.load();
      }
      
      private function mainWranglerCompleteHandler(param1:DefWrangler) : void
      {
         var w:DefWrangler = param1;
         try
         {
            this.heraldry = new HeraldrySystemVars(this.prefs).fromJson(w.vars,this.logger);
            if(this.heraldry.additionalUrl)
            {
               this.additionalWrangler = new DefWrangler(this.heraldry.additionalUrl,this.logger,this.resman,this.additionalWranglerCompleteHandler);
               this.additionalWrangler.load();
               return;
            }
            if(HeraldrySystem.ADDITIONAL_PLATFORM_URL)
            {
               this.additionalPlatformWrangler = new DefWrangler(HeraldrySystem.ADDITIONAL_PLATFORM_URL,this.logger,this.resman,this.additionalWranglerCompleteHandler);
               this.additionalPlatformWrangler.load();
               return;
            }
         }
         catch(err:Error)
         {
            logger.error(err.getStackTrace());
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function additionalWranglerCompleteHandler(param1:DefWrangler) : void
      {
         var add:HeraldrySystem = null;
         var w:DefWrangler = param1;
         try
         {
            add = new HeraldrySystemVars(null).fromJson(w.vars,this.logger);
            this.heraldry.mergeHeraldrySystem(add);
         }
         catch(err:Error)
         {
            logger.error(err.getStackTrace());
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}
