package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.def.EffectDef;
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.effect.op.def.IdEffectOp;
   import engine.battle.ability.effect.op.model.Op_ExecAbility;
   import engine.battle.ability.effect.op.model.Op_SpawnUnit;
   import engine.battle.ability.effect.op.model.Op_TileTrigger;
   import engine.battle.ability.effect.op.model.Op_WaitForStartTurn;
   import engine.resource.BitmapResource;
   import engine.resource.IResourceManager;
   
   public class AbilityAssetBundle extends ResourceAssetBundle implements IAbilityAssetBundle
   {
       
      
      private var _aps:IAbilityAssetBundleManager;
      
      private var _ad:IBattleAbilityDef;
      
      public function AbilityAssetBundle(param1:String, param2:IAbilityAssetBundleManager, param3:IBattleAbilityDef)
      {
         this._aps = param2;
         this._ad = param3;
         super(param1,param2);
      }
      
      override public function toString() : String
      {
         return "ABILITY=" + (!!this._ad ? this._ad.toString() : "nothing");
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override protected function handleGroupComplete() : void
      {
      }
      
      public function load() : void
      {
         var _loc4_:EffectDef = null;
         var _loc5_:EffectDefOp = null;
         var _loc1_:IResourceManager = _resman;
         var _loc2_:IEntityAssetBundleManager = this._aps.entityPreloads;
         if(this._ad.iconUrl)
         {
            _loc1_.getResource(this._ad.iconUrl,BitmapResource,_group);
         }
         if(this._ad.iconBuffUrl)
         {
            _loc1_.getResource(this._ad.iconBuffUrl,BitmapResource,_group);
         }
         if(this._ad.getTileTargetUrl())
         {
            _loc1_.getResource(this._ad.getTileTargetUrl(),BitmapResource,_group);
         }
         var _loc3_:Vector.<IEffectDef> = this._ad.effects;
         for each(_loc4_ in _loc3_)
         {
            for each(_loc5_ in _loc4_.ops)
            {
               this.loadOpAssets(_loc5_);
            }
         }
      }
      
      public function preloadAbilityDef(param1:IBattleAbilityDef) : IAbilityAssetBundle
      {
         return this._aps.preloadAbilityDef(param1,this);
      }
      
      public function preloadAbilityDefById(param1:String) : IAbilityAssetBundle
      {
         return this._aps.preloadAbilityDefById(param1,this);
      }
      
      public function preloadEntityById(param1:String) : IEntityAssetBundle
      {
         return this._aps.entityPreloads.getEntityPreloadById(param1,this,false,false,true);
      }
      
      public function loadOpAssets(param1:EffectDefOp) : void
      {
         switch(param1.id)
         {
            case IdEffectOp.SPAWN:
               Op_SpawnUnit.preloadAssets(param1,this);
               break;
            case IdEffectOp.WAIT_FOR_START_TURN:
               Op_WaitForStartTurn.preloadAssets(param1,this);
               break;
            case IdEffectOp.TILE_TRIGGER:
               Op_TileTrigger.preloadAssets(param1,this);
               break;
            case IdEffectOp.EXEC_ABILITY:
               Op_ExecAbility.preloadAssets(param1,this);
         }
      }
   }
}
