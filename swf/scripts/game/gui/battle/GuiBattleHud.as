package game.gui.battle
{
   import com.stoicstudio.platform.Platform;
   import engine.core.render.BoundedCamera;
   import engine.gui.GuiContextEvent;
   import engine.sound.ISoundDriver;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.battle.initiative.GuiInitiative;
   
   public class GuiBattleHud extends GuiBase implements IGuiBattleHud
   {
       
      
      public var _deploymentTimer:GuiDeploymentTimer;
      
      public var _waveRedeployTop:GuiWaveRedeploymentTop;
      
      public var hudWidth:Number = 0;
      
      public var hudHeight:Number = 0;
      
      private var _initiative:GuiInitiative;
      
      private var listen:IGuiBattleHudListener;
      
      public function GuiBattleHud()
      {
         super();
         mouseEnabled = false;
         mouseChildren = true;
      }
      
      private static function _performScaleDeployment(param1:MovieClip, param2:Number, param3:Number) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc4_:Number = param2;
         var _loc5_:Number = param3 / 4;
         var _loc6_:Number = BoundedCamera.computeFitScale(_loc4_,_loc5_,param1.width,param1.height);
         _loc6_ = Math.min(1.5,_loc6_);
         param1.scaleX = param1.scaleY = _loc6_;
         if(Platform.requiresUiSafeZoneBuffer)
         {
            param1.y = 50;
         }
      }
      
      public function get initiative() : IGuiInitiative
      {
         return this._initiative;
      }
      
      public function init(param1:IGuiContext, param2:IGuiPopupListener, param3:IGuiBattleHudListener, param4:ISoundDriver, param5:Boolean) : void
      {
         var _loc6_:MovieClip = null;
         initGuiBase(param1);
         this._deploymentTimer = requireGuiChild("deploymentTimer") as GuiDeploymentTimer;
         this.listen = param3;
         this._deploymentTimer.init(param1,param3);
         this._deploymentTimer.visible = false;
         if(param5)
         {
            this._waveRedeployTop = requireGuiChild("waveRedeployTop") as GuiWaveRedeploymentTop;
            this._waveRedeployTop.init(param1,param3,param4);
            this._waveRedeployTop.visible = false;
         }
         else
         {
            _loc6_ = getGuiChild("waveRedeployTop") as MovieClip;
            if(_loc6_)
            {
               _loc6_.visible = false;
               _loc6_.mouseEnabled = _loc6_.mouseChildren = false;
            }
         }
         registerLocaleChangeChild(this._deploymentTimer);
         if(this._waveRedeployTop)
         {
            registerLocaleChangeChild(this._waveRedeployTop);
         }
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      public function refreshDeploymentTimer() : void
      {
         this._deploymentTimer.refreshDeploymentTimer();
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         handleLocaleChange();
      }
      
      public function get deployTimer() : IGuiDeploymentTimer
      {
         return this._deploymentTimer;
      }
      
      public function getWaveRedeployTop() : IGuiWaveRedeploymentTop
      {
         return this._waveRedeployTop;
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         this.hudWidth = param1;
         this.hudHeight = param2;
         this.resizeHandler();
      }
      
      private function resizeHandler() : void
      {
         var _loc1_:Number = this.hudWidth / 2;
         this._deploymentTimer.x = _loc1_;
         if(this._waveRedeployTop)
         {
            this._waveRedeployTop.x = _loc1_;
         }
         this._performScaleInitiative();
         _performScaleDeployment(this._deploymentTimer,this.hudWidth,this.hudHeight);
         _performScaleDeployment(this._waveRedeployTop,this.hudWidth,this.hudHeight);
      }
      
      private function _performScaleInitiative() : void
      {
         if(!this._initiative)
         {
            return;
         }
         var _loc1_:Point = this._initiative.authorSize;
         var _loc2_:Number = this.hudWidth;
         var _loc3_:Number = this.hudHeight * 1 / 2;
         var _loc4_:Number = BoundedCamera.computeFitScale(_loc2_,_loc3_,_loc1_.x,_loc1_.y);
         _loc4_ = Math.min(1.5,_loc4_);
         this._initiative.x = 0;
         this._initiative.y = this.hudHeight;
         this._initiative.scaleX = this._initiative.scaleY = _loc4_;
         if(Platform.requiresUiSafeZoneBuffer)
         {
            this._initiative.x += 80;
            this._initiative.y -= 50;
         }
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this._deploymentTimer.cleanup();
         if(this._waveRedeployTop)
         {
            this._waveRedeployTop.cleanup();
         }
         super.cleanupGuiBase();
      }
      
      public function set initiative(param1:IGuiInitiative) : void
      {
         if(this._initiative == param1)
         {
            return;
         }
         if(this._initiative)
         {
            removeChild(this._initiative);
         }
         this._initiative = param1 as GuiInitiative;
         if(this._initiative)
         {
            addChild(this._initiative);
            this.resizeHandler();
         }
      }
      
      public function showDeploy(param1:Boolean, param2:Boolean) : void
      {
         this._deploymentTimer.showDeploy(param1,param2);
      }
      
      public function showWaveRedeploy(param1:Boolean) : void
      {
         if(!this._waveRedeployTop)
         {
            throw new IllegalOperationError("no wave gui loaded during init");
         }
         this._waveRedeployTop.showRedeploymentTop(param1);
      }
      
      public function set deployPercent(param1:Number) : void
      {
         this._deploymentTimer.deployTimerPercent(param1);
      }
      
      public function showInitiativeHud(param1:Boolean) : void
      {
         this._initiative.visible = param1;
      }
   }
}
