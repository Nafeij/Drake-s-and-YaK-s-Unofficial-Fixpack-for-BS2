package engine.gui
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   
   public interface IGuiGpTextHelperFactory
   {
       
      
      function hasGpTokens(param1:String) : Boolean;
      
      function factory(param1:Locale, param2:ILogger) : IGuiGpTextHelper;
   }
}
