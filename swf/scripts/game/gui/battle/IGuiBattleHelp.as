package game.gui.battle
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import game.gui.IGuiChat;
   import game.gui.IGuiContext;
   
   public interface IGuiBattleHelp
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function get movieClip() : MovieClip;
      
      function updateHelp(param1:IGuiArtifact, param2:IGuiInitiative, param3:IGuiChat, param4:DisplayObject, param5:Number, param6:Number, param7:Boolean) : void;
      
      function handleLocaleChange() : void;
   }
}
