package engine.core.util
{
   import engine.core.locale.ILocaleProvider;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   
   public class EngineCoreContext implements ILocaleProvider
   {
       
      
      private var _locale:Locale;
      
      public var logger:ILogger;
      
      public var appInfo:AppInfo;
      
      public function EngineCoreContext(param1:Locale, param2:AppInfo, param3:ILogger)
      {
         super();
         this.locale = param1;
         this.logger = param3;
         this.appInfo = param2;
      }
      
      public function get locale() : Locale
      {
         return this._locale;
      }
      
      public function set locale(param1:Locale) : void
      {
         this._locale = param1;
      }
   }
}
