package game.gui
{
   import flash.display.MovieClip;
   import game.gui.battle.IGuiBattleChatListener;
   
   public interface IGuiChat
   {
       
      
      function init(param1:IGuiContext, param2:IGuiBattleChatListener) : void;
      
      function appendMessage(param1:String, param2:GuiChatColor, param3:String, param4:Boolean) : void;
      
      function focusChat() : void;
      
      function unfocusChat() : void;
      
      function get movieClip() : MovieClip;
      
      function get context() : IGuiContext;
      
      function sendMessage() : void;
      
      function get focused() : Boolean;
      
      function setEnabledAvailable(param1:Boolean) : void;
      
      function set showWhenUnfocused(param1:Boolean) : void;
      
      function set showChatButton(param1:Boolean) : void;
      
      function appendText(param1:String) : void;
      
      function set chatVisible(param1:Boolean) : void;
      
      function get chatWidth() : Number;
   }
}
