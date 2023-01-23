package as3isolib.core
{
   import as3isolib.data.INode;
   import engine.landscape.view.DisplayObjectWrapper;
   
   public interface IIsoContainer extends INode, IInvalidation
   {
       
      
      function get includeInLayout() : Boolean;
      
      function set includeInLayout(param1:Boolean) : void;
      
      function get displayListChildren() : Array;
      
      function get depth() : int;
      
      function get container() : DisplayObjectWrapper;
      
      function render(param1:Boolean = true) : void;
   }
}
