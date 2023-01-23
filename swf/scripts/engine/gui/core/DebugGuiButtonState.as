package engine.gui.core
{
   public class DebugGuiButtonState extends EngineEnum
   {
      
      public static const registry:EngineEnumRegistry = new EngineEnumRegistry("GuiButtonState");
      
      public static const NORMAL:DebugGuiButtonState = new DebugGuiButtonState("normal",0);
      
      public static const PRESSED:DebugGuiButtonState = new DebugGuiButtonState("pressed",1);
      
      public static const HOVER:DebugGuiButtonState = new DebugGuiButtonState("hover",2);
      
      public static const DISABLED:DebugGuiButtonState = new DebugGuiButtonState("disabled",3);
       
      
      public function DebugGuiButtonState(param1:String, param2:int)
      {
         super(param1,param2,registry);
      }
   }
}
