package game.gui.battle.initiative
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuiInitiativeOrderFrame extends GuiInitiativeFrame
   {
      
      public static const HIGHLIGHTED:String = "GuiInitiativeOrderFrame.HIGHLIGHTED";
       
      
      public function GuiInitiativeOrderFrame()
      {
         super();
      }
      
      override protected function handleClick(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         super.handleClick(param1);
         hilighted = true;
         dispatchEvent(new Event(HIGHLIGHTED));
      }
   }
}
