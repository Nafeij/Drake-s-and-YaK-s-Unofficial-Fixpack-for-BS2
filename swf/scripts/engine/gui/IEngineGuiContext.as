package engine.gui
{
   import engine.ability.IAbilityDef;
   import engine.core.RunMode;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.locale.ILocaleProvider;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntitiesMetadata;
   import engine.entity.def.ILegend;
   import engine.heraldry.Heraldry;
   import engine.resource.ResourceManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   
   public interface IEngineGuiContext extends IEventDispatcher, IGuiSound, ILocaleProvider
   {
       
      
      function get logger() : ILogger;
      
      function get resourceManager() : ResourceManager;
      
      function getAbilityDefById(param1:String) : IAbilityDef;
      
      function get legend() : ILegend;
      
      function eatEvent(param1:MouseEvent) : void;
      
      function isEventEaten(param1:MouseEvent) : Boolean;
      
      function reportUserAbuse(param1:String) : void;
      
      function setPref(param1:String, param2:*) : void;
      
      function getPref(param1:String) : *;
      
      function translateRaw(param1:String) : String;
      
      function translate(param1:String) : String;
      
      function translateDisplayObjects(param1:LocaleCategory, param2:DisplayObject) : void;
      
      function translateCategory(param1:String, param2:LocaleCategory) : String;
      
      function translateCategoryRaw(param1:String, param2:LocaleCategory) : String;
      
      function translateTaunt(param1:String) : String;
      
      function getTaunts() : Localizer;
      
      function replaceTranslatedTokens(param1:String, param2:Array) : String;
      
      function isClassAvailable(param1:String) : Boolean;
      
      function getAbilityDef(param1:String) : IAbilityDef;
      
      function get randomMaleName() : String;
      
      function get randomFemaleName() : String;
      
      function get currencySymbol() : String;
      
      function get currencyCode() : String;
      
      function showMarket(param1:Boolean, param2:String, param3:String, param4:Function) : void;
      
      function tutorialMode() : Boolean;
      
      function get runMode() : RunMode;
      
      function get entitiesMetadata() : EntitiesMetadata;
      
      function get heraldry() : Heraldry;
      
      function hasShownGameTip(param1:String) : Boolean;
      
      function showGameTip(param1:String, param2:String, param3:String) : void;
      
      function generateTextBitmap(param1:String, param2:int, param3:uint, param4:*, param5:String, param6:int) : BitmapData;
      
      function removeAllTooltips() : void;
      
      function get numLocales() : int;
      
      function getLocale(param1:int) : String;
      
      function get currentLocale() : Locale;
      
      function createTutorialPopup(param1:DisplayObject, param2:String, param3:TutorialTooltipAlign, param4:TutorialTooltipAnchor, param5:Boolean, param6:Boolean, param7:Function) : int;
      
      function removeTutorialTooltip(param1:int) : void;
      
      function setTutorialTooltipNeverClamp(param1:int, param2:Boolean) : void;
   }
}
