package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   
   public class AbilityAssetBundleManager extends AssetBundleManager implements IAbilityAssetBundleManager
   {
       
      
      public var abilities:IBattleAbilityDefFactory;
      
      public var _eps:IEntityAssetBundleManager;
      
      public function AbilityAssetBundleManager(param1:IEntityAssetBundleManager, param2:IBattleAbilityDefFactory)
      {
         super("abl_" + param1.id,param1.resman);
         this.abilities = param2;
         this._eps = param1;
      }
      
      public function preloadAbilityDefById(param1:String, param2:IAssetBundle) : IAbilityAssetBundle
      {
         var _loc3_:IBattleAbilityDef = this.abilities.fetchIBattleAbilityDef(param1,true);
         return this.preloadAbilityDef(_loc3_,param2);
      }
      
      public function preloadAbilityDef(param1:IBattleAbilityDef, param2:IAssetBundle) : IAbilityAssetBundle
      {
         if(param1.id == "abl_rest")
         {
            param1 = param1;
         }
         var _loc3_:AbilityAssetBundle = findExistingBundle(param1.id,param2) as AbilityAssetBundle;
         if(_loc3_)
         {
            return _loc3_;
         }
         _loc3_ = new AbilityAssetBundle(param1.id,this,param1);
         if(param2)
         {
            param2.addBundle(_loc3_);
         }
         _loc3_.load();
         _loc3_.listenForCompletion();
         return null;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      public function set entityPreloads(param1:IEntityAssetBundleManager) : void
      {
         this._eps = param1;
      }
      
      public function get entityPreloads() : IEntityAssetBundleManager
      {
         return this._eps;
      }
   }
}
