package engine.entity.def
{
   import engine.core.locale.Locale;
   import flash.utils.Dictionary;
   
   public interface ITitleListDef
   {
       
      
      function changeLocale(param1:Locale) : void;
      
      function getTitleDef(param1:String) : ITitleDef;
      
      function getTitleDict() : Dictionary;
   }
}
