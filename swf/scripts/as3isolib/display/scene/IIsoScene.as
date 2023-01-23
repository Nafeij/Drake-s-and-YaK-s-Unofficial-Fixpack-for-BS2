package as3isolib.display.scene
{
   import as3isolib.bounds.IBounds;
   import as3isolib.core.IIsoContainer;
   import engine.landscape.view.DisplayObjectWrapper;
   
   public interface IIsoScene extends IIsoContainer
   {
       
      
      function get isoBounds() : IBounds;
      
      function get invalidatedChildren() : Array;
      
      function get hostContainer() : DisplayObjectWrapper;
      
      function set hostContainer(param1:DisplayObjectWrapper) : void;
   }
}
