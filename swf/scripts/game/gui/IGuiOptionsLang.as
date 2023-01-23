package game.gui
{
   public interface IGuiOptionsLang
   {
       
      
      function init(param1:IGuiContext, param2:IGuiOptionsLangListener) : void;
      
      function closeOptionsLang() : Boolean;
      
      function cleanup() : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
   }
}
