package engine.battle.entity.view
{
   import engine.anim.view.AnimControllerSprite;
   import engine.anim.view.AnimControllerSpriteStarling;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.indicator.EntityFlyTextEntry;
   import engine.battle.board.view.indicator.EntityFlyTextEntryStarling;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.resource.ResourceManager;
   import flash.display.BitmapData;
   
   public class EntityViewStarling extends EntityView
   {
       
      
      public function EntityViewStarling(param1:BattleBoardView, param2:IBattleEntity, param3:ResourceManager, param4:Boolean, param5:IEntityAssetBundleManager)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override protected function handleCreateAnimControllerSprite() : AnimControllerSprite
      {
         return new AnimControllerSpriteStarling(entity.id,entity.animController,logger,battleBoardView.board.resman,SMOOTH_ENTITY_VIEWS);
      }
      
      override public function createFlyTextEntry(param1:String, param2:BitmapData) : EntityFlyTextEntry
      {
         return new EntityFlyTextEntryStarling(param1,flyText,param2);
      }
   }
}
