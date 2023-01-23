package engine.saga
{
   import engine.resource.BitmapResource;
   import engine.resource.def.DefResource;
   import engine.subtitle.SubtitleSequenceResource;
   
   public class SagaAssetCtor
   {
       
      
      public function SagaAssetCtor()
      {
         super();
      }
      
      public static function ctor(param1:String, param2:SagaAssetBundle, param3:SagaAsset, param4:SagaAssetType) : SagaAsset
      {
         switch(param4)
         {
            case SagaAssetType.SCENE:
               return new SagaAsset_Scene(param1,param2,param3);
            case SagaAssetType.SUBTITLE:
               return new SagaAsset(param1,SubtitleSequenceResource,param2,param3);
            case SagaAssetType.BITMAP:
               return new SagaAsset(param1,BitmapResource,param2,param3);
            default:
               return new SagaAsset(param1,DefResource,param2,param3);
         }
      }
   }
}
