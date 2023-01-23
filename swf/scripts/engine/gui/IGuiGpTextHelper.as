package engine.gui
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import flash.text.TextField;
   
   public interface IGuiGpTextHelper
   {
       
      
      function cleanup() : void;
      
      function set iconsVisible(param1:Boolean) : void;
      
      function finishProcessing(param1:TextField) : void;
      
      function get locale() : Locale;
      
      function set locale(param1:Locale) : void;
      
      function preProcessText(param1:String, param2:ILogger) : String;
   }
}
