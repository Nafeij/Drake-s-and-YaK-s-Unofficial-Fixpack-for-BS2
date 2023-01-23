package game.gui.battle
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.gui.GuiGpBitmap;
   import engine.saga.ISaga;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.travel.GuiTravelTopMorale;
   
   public class GuiBaseArtifact extends GuiBase
   {
       
      
      protected var _listener:IGuiArtifactListener;
      
      protected var _saga:ISaga;
      
      protected var _gpbmp:GuiGpBitmap;
      
      public var _morale:GuiTravelTopMorale;
      
      protected var _count:int;
      
      private var _artifactVisible:Boolean;
      
      private var _hidden_y:Number = 0;
      
      public function GuiBaseArtifact()
      {
         super();
         this._morale = requireGuiChild("morale") as GuiTravelTopMorale;
      }
      
      public function initGuiBaseArtifact(param1:IGuiContext, param2:IGuiArtifactListener, param3:ISaga, param4:GuiGpBitmap) : void
      {
         initGuiBase(param1);
         this._listener = param2;
         this._gpbmp = param4;
         if(param4)
         {
            param4.alwaysHint = true;
            param4.scale = 0.75;
            addChild(param4);
            param4.x = -180;
            param4.y = 30;
         }
         this._saga = param3;
         this._morale.visible = !!this._saga ? !this._saga.isSurvival : false;
         if(this._saga)
         {
            this._morale.init(param1,this._saga,this._saga.caravanVars);
            this._morale.visible = !this._saga.isSurvival;
         }
         else
         {
            this._morale.visible = false;
         }
         y = -height - 20;
         this._hidden_y = y;
      }
      
      protected function cleanupGuiBaseArtifact() : void
      {
         if(this._morale)
         {
            this._morale.cleanup();
         }
         this._listener = null;
         this._gpbmp = null;
         this._saga = null;
         super.cleanupGuiBase();
      }
      
      public function get maxCount() : int
      {
         return 0;
      }
      
      public function get count() : int
      {
         return this._count;
      }
      
      public function set count(param1:int) : void
      {
         param1 = Math.max(0,Math.min(this.maxCount,param1));
         if(this._count == param1)
         {
            return;
         }
         this._count = param1;
      }
      
      public function get hornFinishedAnimating() : Boolean
      {
         return y == 0;
      }
      
      public function set artifactVisible(param1:Boolean) : void
      {
         this._artifactVisible = param1;
         this.checkHornVisible();
      }
      
      public function get artifactVisible() : Boolean
      {
         return this._artifactVisible;
      }
      
      protected function checkHornVisible() : void
      {
         TweenMax.killTweensOf(this);
         if(this._artifactVisible && context.battleHudConfig.showHorn)
         {
            if(Platform.requiresUiSafeZoneBuffer)
            {
               TweenMax.to(this,0.75,{"y":20});
            }
            else
            {
               TweenMax.to(this,0.75,{"y":0});
            }
            if(this._saga)
            {
               this._morale.showBattleWillpower();
            }
         }
         else
         {
            this._hidden_y = -height * this.scaleY - 20;
            TweenMax.to(this,0.75,{"y":this._hidden_y});
         }
      }
      
      public function handleResize() : void
      {
         TweenMax.killTweensOf(this);
         if(this._artifactVisible && context.battleHudConfig.showHorn)
         {
            this.y = 0;
            if(Platform.requiresUiSafeZoneBuffer)
            {
               this.y += 20;
            }
         }
         else
         {
            this._hidden_y = -height * this.scaleY - 20;
            this.y = this._hidden_y;
         }
      }
   }
}
