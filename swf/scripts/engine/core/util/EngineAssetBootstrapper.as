package engine.core.util
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityDefFactoryVars;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.LocaleId;
   import engine.core.locale.LocaleWrangler;
   import engine.core.logging.Logger;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.EntityClassDefWrangler;
   import engine.gui.IGuiGpTextHelperFactory;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   import engine.resource.def.DefWranglerWrangler;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class EngineAssetBootstrapper extends EventDispatcher
   {
      
      public static const LOCALE_URL:String = "common/locale/en/strings.json.z";
      
      private static const CHARACTER_CLASS_DEFS_URL:String = "common/character/character_classes.json.z";
      
      private static const PROP_CLASS_DEFS_URL:String = "common/battle/prop/prop_classes.json.z";
      
      private static const GP_URL:String = "common/gp.json.z";
      
      public static var READY_DEBUG:Boolean = true;
       
      
      public var classes:EntityClassDefList;
      
      public var abilityFactory:BattleAbilityDefFactoryVars;
      
      public var ready:Boolean;
      
      private var wranglers:DefWranglerWrangler;
      
      private var localeWrangler:LocaleWrangler;
      
      private var resman:ResourceManager;
      
      public var gpjson:Object;
      
      private var context:EngineCoreContext;
      
      private var locale_id:LocaleId;
      
      private var withGpConfig:Boolean;
      
      private var ggthFactory:IGuiGpTextHelperFactory;
      
      public function EngineAssetBootstrapper(param1:ResourceManager, param2:EngineCoreContext, param3:LocaleId, param4:Boolean, param5:IGuiGpTextHelperFactory)
      {
         super();
         this.ggthFactory = param5;
         this.withGpConfig = param4;
         this.resman = param1;
         this.context = param2;
         this.locale_id = param3;
      }
      
      public function startLoadingAssets() : void
      {
         this.context.logger.i("LOAD","EngineAssetBootstrapper.startLoadingAssets");
         var _loc1_:String = this.locale_id.translateLocaleUrl(LOCALE_URL);
         this.localeWrangler = new LocaleWrangler(_loc1_,this.context.logger,this.resman,LocaleCategory,false,this.locale_id,this.ggthFactory);
         this.localeWrangler.addEventListener(Event.COMPLETE,this.localeWranglerReadyHandler);
         this.localeWrangler.load();
      }
      
      private function localeWranglerReadyHandler(param1:Event) : void
      {
         this.localeWrangler.removeEventListener(Event.COMPLETE,this.localeWranglerReadyHandler);
         this.context.logger.i("LOAD","EngineAssetBootstrapper.localeWranglerReadyHandler");
         if(!this.localeWrangler.locale)
         {
            this.context.logger.error("LocaleWrangler failed to load locale, generating silenced stub");
            this.context.locale = new Locale(this.locale_id,this.ggthFactory,new Logger("/dev/null"));
         }
         else
         {
            this.context.locale = this.localeWrangler.locale;
         }
         this.localeWrangler.cleanup();
         this.localeWrangler = null;
         this.abilityFactory = new BattleAbilityDefFactoryVars(true,this.resman,this.context.logger,this.context.locale.getLocalizer(LocaleCategory.ABILITY),this.abilityCompleteHandler);
         this.wranglers = new DefWranglerWrangler("game",this.resman,this.context.logger);
         this.wranglers.add(new EntityClassDefWrangler(CHARACTER_CLASS_DEFS_URL,this.context.logger,this.resman,this.context.locale,null));
         this.wranglers.add(new EntityClassDefWrangler(PROP_CLASS_DEFS_URL,this.context.logger,this.resman,this.context.locale,null));
         if(this.withGpConfig)
         {
            this.wranglers.add(new DefWrangler(GP_URL,this.context.logger,this.resman,null));
         }
         this.checkReady();
         this.wranglers.addEventListener(Event.COMPLETE,this.wranglersHandler);
         this.wranglers.load();
      }
      
      private function wranglersHandler(param1:Event) : void
      {
         this.checkReady();
      }
      
      private function abilityCompleteHandler(param1:BattleAbilityDefFactory) : void
      {
         if(param1.errors)
         {
            this.context.appInfo.terminateError("BattleAbilityDefFactory failed to load.");
            return;
         }
         this.checkReady();
      }
      
      private function waitingOn(param1:String, param2:Object) : Boolean
      {
         if(READY_DEBUG)
         {
            if(this.context.logger.isDebugEnabled)
            {
               this.context.logger.debug("EngineAssetBootstrapper WAITING on " + param1 + ": " + param2);
            }
         }
         return true;
      }
      
      private function checkReady() : void
      {
         var _loc1_:Boolean = false;
         if(AppInfo.terminating)
         {
            return;
         }
         if(this.ready)
         {
            return;
         }
         if(!(this.wranglers && this.wranglers.ready))
         {
            _loc1_ = this.waitingOn("wranglers",this.wranglers);
         }
         if(!(this.abilityFactory && this.abilityFactory.ready))
         {
            _loc1_ = this.waitingOn("abilityFactory",this.abilityFactory);
         }
         if(_loc1_)
         {
            return;
         }
         this.finishReady();
      }
      
      private function finishReady() : void
      {
         this.classes = new EntityClassDefList();
         var _loc1_:EntityClassDefWrangler = this.wranglers.wrangled(CHARACTER_CLASS_DEFS_URL) as EntityClassDefWrangler;
         if(!_loc1_.manager)
         {
            this.context.appInfo.terminateError("[" + _loc1_.url + "] failed to load.");
            return;
         }
         var _loc2_:EntityClassDefWrangler = this.wranglers.wrangled(PROP_CLASS_DEFS_URL) as EntityClassDefWrangler;
         if(!_loc1_.manager)
         {
            this.context.appInfo.terminateError("[" + _loc2_.url + "] failed to load.");
            return;
         }
         if(this.withGpConfig)
         {
            this.gpjson = this.wranglers.wrangled(GP_URL).vars;
         }
         this.classes.registerAll(_loc1_.manager,this.context.logger);
         this.classes.registerAll(_loc2_.manager,this.context.logger);
         this.wranglers.unwrangle(CHARACTER_CLASS_DEFS_URL);
         this.wranglers.unwrangle(PROP_CLASS_DEFS_URL);
         this.wranglers.unwrangle(GP_URL);
         this.ready = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}
