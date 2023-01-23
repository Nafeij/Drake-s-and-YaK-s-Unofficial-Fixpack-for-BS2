package engine.gui.page
{
   import engine.core.cmd.ShellCmdManager;
   
   public interface IPageManager
   {
       
      
      function onPageStateChanged(param1:Page) : void;
      
      function onPagePercentLoadedChanged(param1:Page) : void;
      
      function get currentPage() : Page;
      
      function get shell() : ShellCmdManager;
      
      function get loading() : Boolean;
   }
}
