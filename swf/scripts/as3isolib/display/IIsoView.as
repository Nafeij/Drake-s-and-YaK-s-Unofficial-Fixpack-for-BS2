package as3isolib.display
{
   import as3isolib.geom.Pt;
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.geom.Point;
   
   public interface IIsoView
   {
       
      
      function get scenes() : Array;
      
      function get numScenes() : uint;
      
      function localToIso(param1:Point) : Pt;
      
      function isoToLocal(param1:Pt) : Point;
      
      function reset() : void;
      
      function render(param1:Boolean = false) : void;
      
      function get width() : Number;
      
      function get height() : Number;
      
      function get mainContainer() : DisplayObjectWrapper;
   }
}
