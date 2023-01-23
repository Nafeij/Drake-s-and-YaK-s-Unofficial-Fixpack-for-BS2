package engine.saga
{
   import engine.core.util.Enum;
   
   public class SagaAssetType extends Enum
   {
      
      public static const NONE:SagaAssetType = new SagaAssetType("NONE",enumCtorKey);
      
      public static const SCENE:SagaAssetType = new SagaAssetType("SCENE",enumCtorKey);
      
      public static const MANIFEST:SagaAssetType = new SagaAssetType("MANIFEST",enumCtorKey);
      
      public static const SUBTITLE:SagaAssetType = new SagaAssetType("SUBTITLE",enumCtorKey);
      
      public static const BITMAP:SagaAssetType = new SagaAssetType("BITMAP",enumCtorKey);
       
      
      public function SagaAssetType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
