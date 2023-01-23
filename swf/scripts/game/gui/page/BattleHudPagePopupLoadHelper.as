package game.gui.page
{
   import com.stoicstudio.platform.Platform;
   import engine.core.locale.LocaleCategory;
   import flash.display.MovieClip;
   import game.cfg.GameConfig;
   import game.gui.battle.IGuiEnemyPopup;
   import game.gui.battle.IGuiMovePopup;
   import game.gui.battle.IGuiPropPopup;
   import game.gui.battle.IGuiSelfPopup;
   
   public class BattleHudPagePopupLoadHelper
   {
      
      public static var mcSelfPopup:Class;
      
      public static var mcClazzMovePopup:Class;
      
      public static var mcClazzEnemyPopup:Class;
      
      public static var mcClazzPropPopup:Class;
       
      
      private var bhp:BattleHudPage;
      
      private var config:GameConfig;
      
      private var _guiSelfPopup:IGuiSelfPopup;
      
      private var _guiMovePopup:IGuiMovePopup;
      
      private var _guiEnemyPopup:IGuiEnemyPopup;
      
      private var _guiPropPopup:IGuiPropPopup;
      
      public var hud_scale:Number = 1;
      
      public function BattleHudPagePopupLoadHelper(param1:BattleHudPage, param2:GameConfig)
      {
         super();
         this.bhp = param1;
         this.config = param2;
         this.selfPopupCreate();
         this.movePopupCreate();
         this.enemyPopupLoadedHandler();
         this.propPopupLoadedHandler();
      }
      
      public function cleanup() : void
      {
         if(this._guiMovePopup)
         {
            this._guiMovePopup.cleanup();
            this._guiMovePopup = null;
         }
         if(this._guiEnemyPopup)
         {
            this._guiEnemyPopup.cleanup();
            this._guiEnemyPopup = null;
         }
         if(this._guiSelfPopup)
         {
            this._guiSelfPopup.cleanup();
            this._guiSelfPopup = null;
         }
         if(this._guiPropPopup)
         {
            this._guiPropPopup.cleanup();
            this._guiPropPopup = null;
         }
      }
      
      public function get guiMovePopup() : IGuiMovePopup
      {
         return this._guiMovePopup;
      }
      
      public function get guiSelfPopup() : IGuiSelfPopup
      {
         return this._guiSelfPopup;
      }
      
      public function get guiPropPopup() : IGuiPropPopup
      {
         return this._guiPropPopup;
      }
      
      public function get guiEnemyPopup() : IGuiEnemyPopup
      {
         return this._guiEnemyPopup;
      }
      
      private function movePopupCreate() : void
      {
         if(Boolean(mcClazzMovePopup) && !this._guiMovePopup)
         {
            this._guiMovePopup = new mcClazzMovePopup() as IGuiMovePopup;
            this._guiMovePopup.init(this.config.gameGuiContext,this.bhp);
            this.bhp.addChild(this._guiMovePopup.movieClip);
            this.bhp.checkPopupHelper();
         }
      }
      
      private function selfPopupCreate() : void
      {
         if(Boolean(mcSelfPopup) && !this._guiSelfPopup)
         {
            this._guiSelfPopup = new mcSelfPopup() as IGuiSelfPopup;
            this.bhp.addChild(this._guiSelfPopup.movieClip);
            this._guiSelfPopup.init(this.config.gameGuiContext,this.bhp);
            this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this._guiSelfPopup as MovieClip,this.config.logger);
            this.bhp.checkPopupHelper();
         }
      }
      
      private function enemyPopupLoadedHandler() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = new mcClazzEnemyPopup() as MovieClip;
         _loc1_.name = "assets.enemy_popup";
         this._guiEnemyPopup = _loc1_ as IGuiEnemyPopup;
         this.bhp.addChild(this._guiEnemyPopup.movieClip);
         this._guiEnemyPopup.init(this.config.gameGuiContext,this.bhp);
         this.bhp.checkPopupHelper();
      }
      
      private function propPopupLoadedHandler() : void
      {
         var _loc1_:MovieClip = new mcClazzPropPopup() as MovieClip;
         _loc1_.name = "assets.prop_popup";
         this._guiPropPopup = _loc1_ as IGuiPropPopup;
         this.bhp.addChild(this._guiPropPopup.movieClip);
         this._guiPropPopup.init(this.config.gameGuiContext,this.bhp);
         this.bhp.checkPopupHelper();
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         this.hud_scale = Platform.textScale;
         this.hud_scale = Math.min(2,this.hud_scale);
         if(this._guiSelfPopup)
         {
            this._guiSelfPopup.movieClip.scaleX = this._guiSelfPopup.movieClip.scaleY = this.hud_scale;
         }
         if(this._guiEnemyPopup)
         {
            this._guiEnemyPopup.movieClip.scaleX = this._guiEnemyPopup.movieClip.scaleY = this.hud_scale;
         }
         if(this._guiMovePopup)
         {
            this._guiMovePopup.movieClip.scaleX = this._guiMovePopup.movieClip.scaleY = this.hud_scale;
         }
         if(this._guiPropPopup)
         {
            this._guiPropPopup.movieClip.scaleX = this._guiPropPopup.movieClip.scaleY = this.hud_scale;
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._guiSelfPopup)
         {
            this._guiSelfPopup.update(param1);
         }
      }
   }
}
