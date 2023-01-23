package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.resource.IResource;
   
   public interface IEntityAssetBundle extends IResourceAssetBundle
   {
       
      
      function preloadAbilityDef(param1:IBattleAbilityDef) : IAbilityAssetBundle;
      
      function preloadAbilityDefById(param1:String) : IAbilityAssetBundle;
      
      function get alr() : IResource;
      
      function get vlr() : IResource;
      
      function get slr() : IResource;
      
      function get propAnimClipResource() : IResource;
      
      function get shadowBitmapResource() : IResource;
      
      function get goAnimationRes() : IResource;
      
      function get speechBubbleRes() : IResource;
      
      function get portraitRes() : IResource;
      
      function loadVersus() : Boolean;
   }
}
