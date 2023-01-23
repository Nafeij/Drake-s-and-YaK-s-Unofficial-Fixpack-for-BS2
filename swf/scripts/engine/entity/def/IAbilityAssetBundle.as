package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   
   public interface IAbilityAssetBundle extends IResourceAssetBundle
   {
       
      
      function preloadAbilityDef(param1:IBattleAbilityDef) : IAbilityAssetBundle;
      
      function preloadAbilityDefById(param1:String) : IAbilityAssetBundle;
      
      function preloadEntityById(param1:String) : IEntityAssetBundle;
   }
}
