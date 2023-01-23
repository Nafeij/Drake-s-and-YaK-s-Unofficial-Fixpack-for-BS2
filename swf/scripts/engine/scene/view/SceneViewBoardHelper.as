package engine.scene.view
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.logging.ILogger;
   import engine.landscape.view.LandscapeViewBase;
   import engine.saga.SpeakEvent;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class SceneViewBoardHelper extends EventDispatcher
   {
      
      public static const EVENT_FOCUSED_BOARDVIEW:String = "SceneView.EVENT_FOCUSED_BOARDVIEW";
       
      
      private var view:SceneViewSprite;
      
      private var scene:Scene;
      
      public var boardViews:Dictionary;
      
      public var boardViewsById:Dictionary;
      
      public var numEnabledBoardViews:int;
      
      public var enabledBoardViews:Vector.<BattleBoardView>;
      
      public var focusedBoardView:BattleBoardView;
      
      public var logger:ILogger;
      
      public function SceneViewBoardHelper(param1:SceneViewSprite)
      {
         var _loc2_:BattleBoard = null;
         var _loc3_:BattleBoardView = null;
         this.boardViews = new Dictionary();
         this.boardViewsById = new Dictionary();
         this.enabledBoardViews = new Vector.<BattleBoardView>();
         super();
         this.view = param1;
         this.scene = param1.scene;
         this.logger = this.scene._context.logger;
         this.scene.addEventListener(SceneEvent.FOCUSED_BOARD,this.focusedBoardHandler);
         for each(_loc2_ in this.scene.boards)
         {
            _loc3_ = (param1.landscapeView as LandscapeViewBase).createBattleBoardView(_loc2_);
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("SceneView attaching BattleBoardView " + _loc2_.def.id + " to scene " + this.scene._def.url);
            }
            this.boardViews[_loc2_] = _loc3_;
            this.boardViewsById[_loc2_.def.id] = _loc3_;
            _loc2_.showInfoBanners = param1.showHelp;
            this.addBoardView(_loc3_);
            param1.shell.addShell("board",_loc3_.shell);
         }
         this.focusedBoardHandler(null);
      }
      
      public function handleDelayStart() : void
      {
         if(this.focusedBoardView)
         {
            this.focusedBoardView.postLoad();
         }
      }
      
      internal function addBoardView(param1:BattleBoardView) : void
      {
         var _loc3_:Point = null;
         var _loc2_:LandscapeViewBase = this.view.landscapeView as LandscapeViewBase;
         if(_loc2_)
         {
            _loc3_ = _loc2_.addExtraToLayer(param1.board.def.layer,param1.displayObjectWrapper);
            if(_loc3_)
            {
               param1.setSceneOffset(_loc3_.x,_loc3_.y);
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:BattleBoardView = null;
         this.focusedBoardView = null;
         this.scene.removeEventListener(SceneEvent.FOCUSED_BOARD,this.focusedBoardHandler);
         for each(_loc1_ in this.boardViews)
         {
            _loc1_.cleanup();
         }
         this.boardViews = null;
         this.boardViewsById = null;
         this.enabledBoardViews = null;
         this.scene = null;
         this.view = null;
      }
      
      private function focusedBoardHandler(param1:SceneEvent) : void
      {
         this.focusedBoardView = !!this.boardViews ? this.boardViews[this.view.scene.focusedBoard] : null;
         dispatchEvent(new Event(EVENT_FOCUSED_BOARDVIEW));
      }
      
      private function setupBoards() : void
      {
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:BattleBoardView = null;
         for each(_loc2_ in this.boardViews)
         {
            _loc2_.update(param1);
         }
      }
      
      public function speakHandler(param1:SpeakEvent) : Boolean
      {
         var _loc2_:BattleBoardView = null;
         for each(_loc2_ in this.boardViews)
         {
            if(_loc2_.handleSpeak(param1,param1.anchor))
            {
               return true;
            }
         }
         return false;
      }
      
      public function getBoardView(param1:BattleBoard) : BattleBoardView
      {
         if(this.boardViews)
         {
            return this.boardViews[param1];
         }
         return null;
      }
      
      public function getBoardViewById(param1:String) : BattleBoardView
      {
         return this.boardViewsById[param1];
      }
      
      internal function resizeHandler() : void
      {
      }
      
      internal function updateShowHelp() : void
      {
         var _loc1_:BattleBoard = null;
         for each(_loc1_ in this.scene.boards)
         {
            _loc1_.showInfoBanners = this.view.showHelp;
         }
      }
   }
}
