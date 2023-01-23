package game.view
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.fsm.BattleFsm;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.IGuiDevPanel;
   import game.gui.IGuiDevPanelListener;
   import game.session.states.SceneState;
   import game.session.states.SceneStateBattleHandler;
   
   public class GameDevPanel implements IGuiDevPanelListener
   {
      
      public static var mcClazz:Class;
       
      
      public var gui:IGuiDevPanel;
      
      private var config:GameConfig;
      
      private var doc:DisplayObjectContainer;
      
      public function GameDevPanel(param1:GameConfig, param2:DisplayObjectContainer)
      {
         super();
         this.config = param1;
         this.doc = param2;
         if(mcClazz)
         {
            this.gui = new mcClazz();
            this.gui.init(param1.gameGuiContext,this);
            param2.addChild(this.gui.movieClip);
         }
      }
      
      public function toggle() : void
      {
         var _loc1_:MovieClip = this.gui.movieClip;
         if(_loc1_.visible)
         {
            _loc1_.visible = false;
            this.doc.removeChild(_loc1_);
         }
         else
         {
            _loc1_.visible = true;
            this.doc.addChild(_loc1_);
         }
      }
      
      public function bringToFront() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.gui)
         {
            if(this.gui.movieClip.parent == this.doc)
            {
               _loc1_ = this.doc.numChildren - 1;
               _loc2_ = this.doc.getChildIndex(this.gui.movieClip);
               this.doc.setChildIndex(this.gui.movieClip,_loc1_);
            }
         }
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         if(this.gui)
         {
            this.gui.resizeHandler(param1,param2);
            if(!PlatformInput.isTouch)
            {
               this.gui.movieClip.scaleX = this.gui.movieClip.scaleY = 0.5;
            }
         }
      }
      
      public function guiDevPanelHandleConsole() : void
      {
         this.config.dispatchEvent(new Event(GameConfig.EVENT_TOGGLE_CONSOLE));
      }
      
      public function guiDevPanelHandlePerf() : void
      {
         this.config.dispatchEvent(new Event(GameConfig.EVENT_TOGGLE_PERF));
      }
      
      public function guiDevPanelHandleFf() : void
      {
         this.config.dispatchEvent(new Event(GameConfig.EVENT_FF));
      }
      
      public function guiDevPanelHandleQuicksave() : void
      {
         this.config.keybinder.func_save_quickstore(null);
      }
      
      public function guiDevPanelHandleKill() : void
      {
         var _loc1_:SceneState = !!this.config.fsm ? this.config.fsm.current as SceneState : null;
         var _loc2_:SceneStateBattleHandler = !!_loc1_ ? _loc1_.battleHandler : null;
         var _loc3_:BattleFsm = !!_loc2_ ? _loc2_.fsm : null;
         if(_loc3_)
         {
            _loc3_.killall();
         }
      }
   }
}
