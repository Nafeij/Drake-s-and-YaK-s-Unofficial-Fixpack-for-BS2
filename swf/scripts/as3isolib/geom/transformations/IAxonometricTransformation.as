package as3isolib.geom.transformations
{
   import as3isolib.geom.Pt;
   
   public interface IAxonometricTransformation
   {
       
      
      function screenToSpace(param1:Pt) : Pt;
      
      function spaceToScreen(param1:Pt) : Pt;
   }
}
