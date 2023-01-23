package game.gui.page
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.view.EntityView;
   import engine.core.logging.ILogger;
   import engine.gui.BattleHudConfig;
   import flash.geom.Point;
   import game.gui.battle.IGuiPopup;
   
   public class PopupHelper
   {
       
      
      protected var popup:IGuiPopup;
      
      protected var view:BattleBoardView;
      
      private var _enabled:Boolean;
      
      public var battleHudConfig:BattleHudConfig;
      
      public var logger:ILogger;
      
      public function PopupHelper(param1:IGuiPopup, param2:BattleBoardView, param3:BattleHudConfig)
      {
         super();
         this.popup = param1;
         this.view = param2;
         this.battleHudConfig = param3;
         this.logger = param2.logger;
         param1.entity = null;
      }
      
      public function cleanup() : void
      {
         this.popup = null;
         this.view = null;
      }
      
      public function positionPopup() : void
      {
         var _loc1_:EntityView = null;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         if(!this.popup || !this.popup.movieClip.parent)
         {
            return;
         }
         var _loc2_:IBattleEntity = this.popup.entity as IBattleEntity;
         _loc1_ = this.view.getEntityView(_loc2_);
         if(_loc1_)
         {
            _loc3_ = _loc1_.centerScreenPointGlobal;
            _loc4_ = this.popup.movieClip.parent.globalToLocal(_loc3_);
            this.popup.moveTo(_loc4_.x,_loc4_.y);
         }
      }
      
      protected function handleEnabled() : void
      {
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         this.handleEnabled();
      }
   }
}
