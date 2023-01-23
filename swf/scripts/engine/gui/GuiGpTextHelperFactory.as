package engine.gui
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   
   public class GuiGpTextHelperFactory implements IGuiGpTextHelperFactory
   {
       
      
      public function GuiGpTextHelperFactory()
      {
         super();
      }
      
      public function hasGpTokens(param1:String) : Boolean
      {
         return GuiGpTextHelper.hasGpTokens(param1);
      }
      
      public function factory(param1:Locale, param2:ILogger) : IGuiGpTextHelper
      {
         return new GuiGpTextHelper(param1,param2);
      }
   }
}
