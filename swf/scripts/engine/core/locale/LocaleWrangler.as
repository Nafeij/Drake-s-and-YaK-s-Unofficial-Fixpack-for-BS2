package engine.core.locale
{
   import engine.core.logging.ILogger;
   import engine.gui.IGuiGpTextHelperFactory;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   import engine.resource.def.DefWranglerWrangler;
   
   public class LocaleWrangler extends DefWranglerWrangler
   {
       
      
      public var locale:Locale;
      
      public var keepDates:Boolean;
      
      public var categoryClazz:Class;
      
      private var localeId:LocaleId;
      
      private var overlay:Locale;
      
      private var dw_locale:DefWrangler;
      
      private var dw_overlays:Vector.<DefWrangler>;
      
      private var ggthFactory:IGuiGpTextHelperFactory;
      
      public function LocaleWrangler(param1:String, param2:ILogger, param3:ResourceManager, param4:Class, param5:Boolean, param6:LocaleId, param7:IGuiGpTextHelperFactory)
      {
         var _loc9_:String = null;
         this.dw_overlays = new Vector.<DefWrangler>();
         super(param1,param3,param2);
         this.ggthFactory = param7;
         this.localeId = param6;
         this.keepDates = param5;
         this.categoryClazz = param4;
         this.dw_locale = wrangle(param1);
         var _loc8_:Array = new Array();
         if(_loc8_)
         {
            for each(_loc9_ in _loc8_)
            {
               this.dw_overlays.push(wrangle(_loc9_));
            }
         }
      }
      
      override protected function handleCompleting() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.dw_locale.vars)
         {
            this.locale = new LocaleVars(this.localeId,this.ggthFactory,this.dw_locale.vars,this.categoryClazz,this.keepDates,logger);
            for each(_loc1_ in this.dw_overlays)
            {
               this.overlay = new LocaleVars(this.localeId,this.ggthFactory,_loc1_.vars,this.categoryClazz,this.keepDates,logger);
               this.locale.consumeOverlay(this.overlay);
               this.overlay.cleanup();
            }
            this.dw_overlays = null;
         }
      }
   }
}
