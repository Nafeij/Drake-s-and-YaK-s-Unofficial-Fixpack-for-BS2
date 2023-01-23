package game.view
{
   import engine.gui.page.PageManagerAdapter;
   import flash.display.DisplayObjectContainer;
   import game.cfg.GameConfig;
   import game.session.states.SceneState;
   
   public class GameScreenFlyTextManagerAdapter
   {
      
      public static var ENABLED:Boolean = true;
       
      
      private var container:DisplayObjectContainer;
      
      private var current:ScreenFlyText;
      
      private var flyTextQ:Array;
      
      private var config:GameConfig;
      
      private var pm:GamePageManagerAdapter;
      
      public function GameScreenFlyTextManagerAdapter(param1:GameConfig, param2:DisplayObjectContainer)
      {
         this.flyTextQ = [];
         super();
         this.container = param2;
         this.config = param1;
      }
      
      public function purgeQueue() : void
      {
         if(!this.flyTextQ)
         {
            return;
         }
         if(this.flyTextQ.length)
         {
            this.flyTextQ.splice(0,this.flyTextQ.length);
         }
         if(this.current)
         {
            this.current.delinger();
         }
      }
      
      public function delinger() : void
      {
         if(this.current)
         {
            this.current.delinger();
         }
      }
      
      public function showScreenFlyText(param1:String, param2:uint, param3:String, param4:Number) : void
      {
         if(!ENABLED || !this.flyTextQ)
         {
            return;
         }
         var _loc5_:ScreenFlyText = new ScreenFlyText(this.config.gameGuiContext,param1,param2,this.container,this.container.height / 2,param3,param4,this.screenFlyTextHandler);
         this.flyTextQ.push(_loc5_);
         this.checkQ();
      }
      
      private function screenFlyTextHandler(param1:ScreenFlyText) : void
      {
         if(this.current == param1)
         {
            this.current = null;
            this.checkQ();
         }
      }
      
      public function checkQ() : void
      {
         if(this.current)
         {
            return;
         }
         if(!this.flyTextQ || this.flyTextQ.length == 0)
         {
            return;
         }
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(!_loc1_ || !_loc1_.scene || !_loc1_.scene.ready)
         {
            return;
         }
         var _loc2_:GamePageManagerAdapter = this.config.pageManager;
         if(Boolean(_loc2_) && _loc2_.loading)
         {
            return;
         }
         if(PageManagerAdapter.OVERLAY_VISIBLE)
         {
            return;
         }
         var _loc3_:ScreenFlyText = this.flyTextQ.shift();
         if(_loc3_)
         {
            this.current = _loc3_;
            _loc3_.start();
         }
      }
      
      public function cleanup() : void
      {
         this.flyTextQ = null;
         if(this.current)
         {
            this.current.cleanup();
            this.current = null;
         }
      }
   }
}
