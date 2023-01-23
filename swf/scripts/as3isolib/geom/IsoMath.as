package as3isolib.geom
{
   import as3isolib.geom.transformations.DefaultIsometricTransformation;
   import as3isolib.geom.transformations.IAxonometricTransformation;
   
   public class IsoMath
   {
      
      private static var transformationObj:IAxonometricTransformation = new DefaultIsometricTransformation();
       
      
      public function IsoMath()
      {
         super();
      }
      
      public static function get transformationObject() : IAxonometricTransformation
      {
         return transformationObj;
      }
      
      public static function set transformationObject(param1:IAxonometricTransformation) : void
      {
         if(param1)
         {
            transformationObj = param1;
         }
         else
         {
            transformationObj = new new DefaultIsometricTransformation()();
         }
      }
      
      public static function screenToIso(param1:Pt, param2:Boolean = false) : Pt
      {
         var _loc3_:Pt = transformationObject.screenToSpace(param1);
         if(param2)
         {
            return _loc3_;
         }
         param1.x = _loc3_.x;
         param1.y = _loc3_.y;
         param1.z = _loc3_.z;
         return param1;
      }
      
      public static function isoToScreen(param1:Pt, param2:Boolean = false) : Pt
      {
         var _loc3_:Pt = transformationObject.spaceToScreen(param1);
         if(param2)
         {
            return _loc3_;
         }
         param1.x = _loc3_.x;
         param1.y = _loc3_.y;
         param1.z = _loc3_.z;
         return param1;
      }
   }
}
