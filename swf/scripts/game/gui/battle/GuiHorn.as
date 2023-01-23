package game.gui.battle
{
   import engine.core.locale.LocaleCategory;
   import engine.gui.BattleHudConfig;
   import engine.gui.GuiGpBitmap;
   import engine.saga.ISaga;
   import engine.sound.ISoundDriver;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import game.gui.ButtonWithIndex;
   import game.gui.IGuiContext;
   
   public class GuiHorn extends GuiBaseArtifact implements IGuiArtifact
   {
       
      
      public var _horn_enemy:GuiHornEnemy;
      
      public var _buttonUse:ButtonWithIndex;
      
      protected var bhc:BattleHudConfig;
      
      public var markers:Vector.<GuiHornMarker>;
      
      public function GuiHorn()
      {
         this.markers = new Vector.<GuiHornMarker>();
         super();
         this._horn_enemy = requireGuiChild("horn_enemy") as GuiHornEnemy;
         this._buttonUse = requireGuiChild("buttonUse") as ButtonWithIndex;
         this.name = "assets.gui_horn";
      }
      
      public function init(param1:IGuiContext, param2:IGuiArtifactListener, param3:ISaga, param4:GuiGpBitmap, param5:ISoundDriver = null) : void
      {
         var _loc7_:DisplayObject = null;
         var _loc8_:GuiHornMarker = null;
         initGuiBaseArtifact(param1,param2,param3,param4);
         if(!this._buttonUse)
         {
            throw new ArgumentError("No buttonUse button");
         }
         this._buttonUse.setDownFunction(this.buttonUseHandler);
         var _loc6_:int = 0;
         while(_loc6_ < numChildren)
         {
            _loc7_ = getChildAt(_loc6_);
            _loc8_ = _loc7_ as GuiHornMarker;
            if(_loc8_)
            {
               this.markers.push(_loc8_);
               _loc8_.init(param1);
            }
            _loc6_++;
         }
         if(!_saga)
         {
            this._horn_enemy.init(param1);
         }
         else
         {
            this._horn_enemy.visible = false;
         }
         this.updateHornMarkers();
         gotoAndStop(1);
         this.bhc = param1.battleHudConfig;
         this.bhc.addEventListener(BattleHudConfig.EVENT_CHANGED,this.battleHudConfigHandler);
         _context.translateDisplayObjects(LocaleCategory.GUI,this);
         this.battleHudConfigHandler(null);
      }
      
      public function cleanup() : void
      {
         var _loc2_:GuiHornMarker = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.markers.length)
         {
            _loc2_ = this.markers[_loc1_];
            _loc2_.cleanup();
            _loc1_++;
         }
         this.markers = null;
         if(this.bhc)
         {
            this.bhc.removeEventListener(BattleHudConfig.EVENT_CHANGED,this.battleHudConfigHandler);
            this.bhc = null;
         }
         if(this._horn_enemy)
         {
            this._horn_enemy.cleanup();
            this._horn_enemy = null;
         }
         if(this._buttonUse)
         {
            this._buttonUse.cleanup();
            this._buttonUse = null;
         }
         super.cleanupGuiBaseArtifact();
      }
      
      private function battleHudConfigHandler(param1:Event) : void
      {
         this.checkConfig();
      }
      
      private function checkConfig() : void
      {
         mouseEnabled = context.battleHudConfig.horn;
         checkHornVisible();
      }
      
      override public function set count(param1:int) : void
      {
         param1 = Math.max(0,Math.min(this.maxCount,param1));
         if(_count == param1)
         {
            return;
         }
         _count = param1;
         this.updateHornMarkers();
      }
      
      override public function get maxCount() : int
      {
         return !!this.markers ? this.markers.length : 0;
      }
      
      public function set enemyCount(param1:int) : void
      {
         this._horn_enemy.enemyCount = param1;
      }
      
      public function get enemyCount() : int
      {
         return this._horn_enemy.enemyCount;
      }
      
      private function buttonUseHandler(param1:ButtonWithIndex) : void
      {
         context.logger.debug("***HORN GuiHorn.buttonUserHandler _count=" + _count);
         if(_count > 0)
         {
            this.markers[_count - 1].markerGlow = 1;
         }
         _listener.guiArtifactUse();
      }
      
      private function updateHornMarkers() : void
      {
         var _loc2_:GuiHornMarker = null;
         this._buttonUse.enabled = _count > 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.markers.length)
         {
            _loc2_ = this.markers[_loc1_];
            _loc2_.markerEnabled = _loc1_ < _count;
            _loc1_++;
         }
      }
   }
}
