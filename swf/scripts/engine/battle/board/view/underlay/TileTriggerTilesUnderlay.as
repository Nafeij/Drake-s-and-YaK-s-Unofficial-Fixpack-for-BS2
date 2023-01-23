package engine.battle.board.view.underlay
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.model.BattleBoardTrigger;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.DirtyRenderSprite;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapPool;
   import engine.scene.model.IScene;
   import engine.tile.def.TileLocation;
   import flash.geom.Point;
   
   public class TileTriggerTilesUnderlay extends DirtyRenderSprite
   {
      
      public static var DEBUG_RENDER:Boolean = false;
       
      
      private var debug_render_url:String = null;
      
      private var popped:Vector.<DisplayObjectWrapper>;
      
      public function TileTriggerTilesUnderlay(param1:BattleBoardView)
      {
         this.popped = new Vector.<DisplayObjectWrapper>();
         super(param1);
         this.debug_render_url = param1.board.assets.board_move_blocked_1;
         param1.bitmapPool.addPool(this.debug_render_url,3,6);
         param1.board.addEventListener(BattleBoardEvent.TRIGGERS,this.boardTriggerHandler);
         this.loadTriggerBitmaps();
      }
      
      override public function cleanup() : void
      {
         view.board.removeEventListener(BattleBoardEvent.TRIGGERS,this.boardTriggerHandler);
         this.releaseAllBitmaps();
         super.cleanup();
      }
      
      override protected function onRender() : void
      {
         var _loc1_:IScene = view.board.scene;
         if(!_loc1_.ready)
         {
            setRenderDirty();
            return;
         }
         this.renderTriggers();
      }
      
      private function renderTriggers() : void
      {
         var _loc2_:BattleBoardTrigger = null;
         var _loc1_:int = 0;
         for each(_loc2_ in board.triggers.triggers)
         {
            _loc1_ = this.renderTrigger(_loc2_,_loc1_,null,false);
            if(DEBUG_RENDER)
            {
               _loc1_ = this.renderTrigger(_loc2_,_loc1_,this.debug_render_url,true);
            }
         }
      }
      
      private function releaseAllBitmaps() : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         displayObjectWrapper.removeAllChildren();
         var _loc1_:BitmapPool = view.bitmapPool;
         for each(_loc2_ in this.popped)
         {
            _loc1_.reclaim(_loc2_);
         }
         this.popped.splice(0,this.popped.length);
      }
      
      private function loadTriggerBitmaps() : void
      {
         var _loc2_:BattleBoardTrigger = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc1_:BitmapPool = view.bitmapPool;
         for each(_loc2_ in board.triggers.triggers)
         {
            _loc3_ = _loc2_._def.tileIconUrl;
            if(_loc3_)
            {
               _loc4_ = _loc2_.rect.area;
               _loc1_.incrementPool(_loc3_,_loc4_);
            }
         }
      }
      
      private function boardTriggerHandler(param1:BattleBoardEvent) : void
      {
         this.releaseAllBitmaps();
         if(!board.triggers)
         {
            return;
         }
         setRenderDirty();
      }
      
      private function renderTrigger(param1:BattleBoardTrigger, param2:int, param3:String, param4:Boolean) : int
      {
         var _loc7_:int = 0;
         var _loc8_:DisplayObjectWrapper = null;
         if(!param3)
         {
            param3 = param1.def.tileIconUrl;
            if(!param3)
            {
               return param2;
            }
         }
         if(!param4)
         {
            param4 = param1.visible;
         }
         var _loc5_:BitmapPool = view.bitmapPool;
         var _loc6_:int = param1.rect.left;
         while(_loc6_ < param1.rect.right)
         {
            _loc7_ = param1.rect.front;
            while(_loc7_ < param1.rect.back)
            {
               _loc8_ = _loc5_.pop(param3);
               if(!_loc8_)
               {
                  logger.error("Unable to pop icon [" + param3 + "] for trigger " + param1);
                  return param2;
               }
               this.popped.push(_loc8_);
               displayObjectWrapper.addChild(_loc8_);
               _loc8_.visible = param4;
               this.positionBmp(TileLocation.fetch(_loc6_,_loc7_),_loc8_,1);
               param2++;
               _loc7_++;
            }
            _loc6_++;
         }
         return param2;
      }
      
      public function positionBmp(param1:TileLocation, param2:DisplayObjectWrapper, param3:int) : void
      {
         var _loc4_:Point = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,param1.x + 0.5 * param3,param1.y + 0.5 * param3);
         param2.x = _loc4_.x - param2.width / 2;
         param2.y = _loc4_.y - param2.height / 2;
      }
   }
}
