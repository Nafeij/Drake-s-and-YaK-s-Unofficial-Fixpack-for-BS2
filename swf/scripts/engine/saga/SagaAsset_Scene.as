package engine.saga
{
   import engine.resource.def.DefResource;
   import engine.scene.model.SceneLoader;
   
   public class SagaAsset_Scene extends SagaAsset
   {
       
      
      public function SagaAsset_Scene(param1:String, param2:SagaAssetBundle, param3:SagaAsset)
      {
         super(param1,DefResource,param2,param3);
      }
      
      override protected function handleLoadStart() : void
      {
      }
      
      override protected function handleLoadComplete() : void
      {
         var _loc1_:DefResource = resource as DefResource;
         var _loc2_:SceneLoader = bundle.saga.ctorSceneLoader(_loc1_.url,this.sceneLoaderComplete);
         _loc2_.load(null,false);
      }
      
      public function sceneLoaderComplete(param1:SceneLoader) : void
      {
      }
   }
}
