package engine.battle.board.view
{
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.entity.model.BattleEntity;
   import flash.geom.Rectangle;
   
   public class EntityLinkedDirtyRenderSprite extends DirtyRenderSprite
   {
       
      
      protected var _entity:BattleEntity;
      
      public function EntityLinkedDirtyRenderSprite(param1:BattleBoardView)
      {
         super(param1);
         canRender = false;
      }
      
      public function get entity() : BattleEntity
      {
         return this._entity;
      }
      
      public function set entity(param1:BattleEntity) : void
      {
         if(this._entity)
         {
            this.onEntityRemoved();
         }
         this._entity = param1;
         if(this._entity)
         {
            this.onEntityAdded();
         }
         this.checkCanRender();
         setRenderDirty();
      }
      
      override protected function checkCanRender() : void
      {
         canRender = this._entity != null;
      }
      
      public function getEntityBaseScreenRect() : Rectangle
      {
         if(!this._entity)
         {
            return null;
         }
         return IsoBattleRectangleUtils.getIsoRectScreenRect(view.units,this._entity.x,this._entity.y,this._entity.boardWidth,this._entity.boardLength);
      }
      
      protected function onEntityAdded() : void
      {
      }
      
      protected function onEntityRemoved() : void
      {
      }
   }
}
