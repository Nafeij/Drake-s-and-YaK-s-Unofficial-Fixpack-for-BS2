package engine.gui.page
{
   import engine.core.fsm.State;
   
   public interface ILoadingPage extends IPage
   {
       
      
      function onTargetChanged() : void;
      
      function get targetPage() : Page;
      
      function get targetState() : State;
      
      function setTarget(param1:Page, param2:State) : void;
   }
}
