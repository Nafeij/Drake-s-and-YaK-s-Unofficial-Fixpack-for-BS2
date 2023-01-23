package game.gui
{
   import engine.core.util.Enum;
   
   public class GuiChatColor extends Enum
   {
      
      public static const LOBBY:GuiChatColor = new GuiChatColor("LOBBY","#b1ffdb",enumCtorKey);
      
      public static const GLOBAL:GuiChatColor = new GuiChatColor("GLOBAL","#ffdbb1",enumCtorKey);
      
      public static const BATTLE_ALLY:GuiChatColor = new GuiChatColor("BATTLE_ALLY","#38d3ff",enumCtorKey);
      
      public static const BATTLE_SELF:GuiChatColor = new GuiChatColor("BATTLE_SELF","#38d3ff",enumCtorKey);
      
      public static const BATTLE_ENEMY:GuiChatColor = new GuiChatColor("BATTLE_ENEMY","#ff4338",enumCtorKey);
       
      
      public var color:String;
      
      public function GuiChatColor(param1:String, param2:String, param3:Object)
      {
         super(param1,param3);
         this.color = param2;
      }
      
      public function getHtmlOpen() : String
      {
         return "<font color=\"" + this.color + "\">";
      }
      
      public function getHtmlClose() : String
      {
         return "</font>";
      }
   }
}
