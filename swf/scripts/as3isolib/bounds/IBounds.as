package as3isolib.bounds
{
   import as3isolib.geom.Pt;
   
   public interface IBounds
   {
       
      
      function get width() : Number;
      
      function get length() : Number;
      
      function get height() : Number;
      
      function get left() : Number;
      
      function get right() : Number;
      
      function get back() : Number;
      
      function get front() : Number;
      
      function get bottom() : Number;
      
      function get top() : Number;
      
      function get centerPt() : Pt;
      
      function getPts() : Array;
      
      function intersects(param1:IBounds) : Boolean;
      
      function containsPt(param1:Pt) : Boolean;
   }
}
