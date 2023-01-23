package engine.heraldry
{
   import engine.core.logging.ILogger;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class HeraldryLoader extends EventDispatcher
   {
       
      
      public var def:HeraldryDef;
      
      public var heraldry:Heraldry;
      
      public var resman:ResourceManager;
      
      public var system:HeraldrySystem;
      
      public var br:BitmapResource;
      
      public var cr:BitmapResource;
      
      public var loading:Boolean;
      
      public var logger:ILogger;
      
      public function HeraldryLoader(param1:ResourceManager, param2:HeraldryDef, param3:HeraldrySystem)
      {
         super();
         this.def = param2;
         this.resman = param1;
         this.system = param3;
         this.logger = param1.logger;
      }
      
      public function cleanup() : void
      {
         if(this.br)
         {
            this.br.removeResourceListener(this.resourceHandler);
            this.br.release();
            this.br = null;
         }
         if(this.cr)
         {
            this.cr.removeResourceListener(this.resourceHandler);
            this.cr.release();
            this.cr = null;
         }
      }
      
      public function loadHeraldry() : void
      {
         var _loc2_:String = null;
         if(this.def.name == "hyperrpg0")
         {
            this.def = this.def;
         }
         if(this.heraldry || this.br || Boolean(this.cr))
         {
            return;
         }
         this.loading = true;
         if(!this.def)
         {
            this.logger.error("Cannot load heraldry.  no def: " + this);
            dispatchEvent(new Event(Event.COMPLETE));
            return;
         }
         if(!this.def.crestDef)
         {
            this.logger.info("Heraldry, no crestDef for [" + this.def + "] for loader: " + this);
         }
         else
         {
            _loc2_ = this.system.getCrestUrl(this.def.crestDef.id);
            this.cr = this.resman.getResource(_loc2_,BitmapResource) as BitmapResource;
            this.cr.addResourceListener(this.resourceHandler);
         }
         var _loc1_:String = this.system.getBannerUrl(this.def.bannerId);
         this.br = this.resman.getResource(_loc1_,BitmapResource) as BitmapResource;
         this.br.addResourceListener(this.resourceHandler);
      }
      
      private function resourceHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:BitmapData = null;
         param1.resource.removeResourceListener(this.resourceHandler);
         if(this.br && this.br.ok && (!this.cr || this.cr.ok))
         {
            _loc2_ = !!this.cr ? this.cr.bitmapData : null;
            this.heraldry = new Heraldry(this.def,_loc2_,this.br.bitmapData);
            this.loading = false;
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}
