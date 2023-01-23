package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   
   public interface IAbilityAssetBundleManager extends IAssetBundleManager
   {
       
      
      function preloadAbilityDef(param1:IBattleAbilityDef, param2:IAssetBundle) : IAbilityAssetBundle;
      
      function preloadAbilityDefById(param1:String, param2:IAssetBundle) : IAbilityAssetBundle;
      
      function set entityPreloads(param1:IEntityAssetBundleManager) : void;
      
      function get entityPreloads() : IEntityAssetBundleManager;
   }
}
