package engine.entity.def
{
   import engine.sound.ISoundDriver;
   
   public interface IEntityAssetBundleManager extends IAssetBundleManager
   {
       
      
      function getEntityPreload(param1:IEntityDef, param2:IAssetBundle, param3:Boolean, param4:Boolean, param5:Boolean) : IEntityAssetBundle;
      
      function getEntityPreloadById(param1:String, param2:IAssetBundle, param3:Boolean, param4:Boolean, param5:Boolean) : IEntityAssetBundle;
      
      function get abilityAssetBundleManager() : IAbilityAssetBundleManager;
      
      function get soundDriver() : ISoundDriver;
   }
}
