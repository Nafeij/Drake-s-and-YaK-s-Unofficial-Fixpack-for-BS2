package engine.battle.entity.view
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.resource.ResourceManager;
   
   public class EntityViewFactory
   {
       
      
      public function EntityViewFactory()
      {
         super();
      }
      
      public static function create(param1:BattleBoardView, param2:IBattleEntity, param3:ResourceManager, param4:Boolean, param5:IEntityAssetBundleManager) : EntityView
      {
         var _loc6_:EntityView = null;
         if(PlatformStarling.instance)
         {
            _loc6_ = new EntityViewStarling(param1,param2,param3,param4,param5);
         }
         else
         {
            _loc6_ = new EntityViewFlash(param1,param2,param3,param4,param5);
         }
         return _loc6_;
      }
   }
}
