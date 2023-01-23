package engine.entity.def
{
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.resource.IResourceManager;
   import engine.sound.ISoundDriver;
   
   public class EntityAssetBundleManager extends AssetBundleManager implements IEntityAssetBundleManager
   {
       
      
      public var cast:IEntityListDef;
      
      public var aps:IAbilityAssetBundleManager;
      
      public var _soundDriver:ISoundDriver;
      
      public function EntityAssetBundleManager(param1:String, param2:IResourceManager, param3:IEntityListDef, param4:IBattleAbilityDefFactory, param5:ISoundDriver)
      {
         super("ent_" + param1,param2);
         this.cast = param3;
         this.aps = new AbilityAssetBundleManager(this,param4);
         this._soundDriver = param5;
      }
      
      public function get abilityAssetBundleManager() : IAbilityAssetBundleManager
      {
         return this.aps;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         this.aps.cleanup();
         this.aps = null;
      }
      
      public function getEntityPreloadById(param1:String, param2:IAssetBundle, param3:Boolean, param4:Boolean, param5:Boolean) : IEntityAssetBundle
      {
         var _loc6_:IEntityDef = this.cast.getEntityDefById(param1);
         if(!_loc6_)
         {
            throw new ArgumentError("no such id [" + param1 + "]");
         }
         return this.getEntityPreload(_loc6_,param2,param3,param4,param5);
      }
      
      public function getEntityPreload(param1:IEntityDef, param2:IAssetBundle, param3:Boolean, param4:Boolean, param5:Boolean) : IEntityAssetBundle
      {
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:IBattleAbilityDef = null;
         var _loc6_:String = param1.appearanceId;
         var _loc7_:EntityAssetBundle = findExistingBundle(_loc6_,param2) as EntityAssetBundle;
         if(_loc7_)
         {
            _loc10_ = param3 && _loc7_.loadSpeechBubble() || _loc10_;
            _loc10_ = param4 && _loc7_.loadPortrait() || _loc10_;
            _loc10_ && _loc7_.listenForCompletion();
            return _loc7_;
         }
         var _loc8_:IEntityAppearanceDef = param1.appearance;
         _loc7_ = new EntityAssetBundle(_loc6_,this,_loc8_);
         _loc7_.withSounds = param5;
         if(param2)
         {
            param2.addBundle(_loc7_);
         }
         _loc7_.load();
         param3 && _loc7_.loadSpeechBubble();
         param4 && _loc7_.loadPortrait();
         var _loc9_:IAbilityDefLevels = param1.actives;
         if(_loc9_)
         {
            _loc11_ = 0;
            while(_loc11_ < _loc9_.numAbilities)
            {
               _loc12_ = _loc9_.getAbilityDef(_loc11_) as IBattleAbilityDef;
               _loc7_.preloadAbilityDef(_loc12_);
               _loc11_++;
            }
         }
         _loc7_.listenForCompletion();
         return _loc7_;
      }
      
      public function get soundDriver() : ISoundDriver
      {
         return this._soundDriver;
      }
   }
}
