package engine.gui.page
{
   public interface IPage
   {
       
      
      function get manager() : IPageManager;
      
      function set manager(param1:IPageManager) : void;
      
      function get showing() : Boolean;
      
      function set showing(param1:Boolean) : void;
   }
}
