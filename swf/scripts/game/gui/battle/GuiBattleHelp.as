package game.gui.battle
{
   import com.stoicstudio.platform.Platform;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import game.gui.GuiBase;
   import game.gui.GuiChat;
   import game.gui.IGuiChat;
   import game.gui.IGuiContext;
   import game.gui.battle.initiative.GuiInitiative;
   
   public class GuiBattleHelp extends GuiBase implements IGuiBattleHelp
   {
       
      
      public var _infoPanel:MovieClip;
      
      public var _initiativeBar:MovieClip;
      
      public var _options:MovieClip;
      
      public var _clickDrag:MovieClip;
      
      public var _horn:MovieClip;
      
      public var _chat:MovieClip;
      
      public var _statBanner:MovieClip;
      
      public var _activeChar:MovieClip;
      
      public function GuiBattleHelp()
      {
         super();
         mouseEnabled = false;
         mouseChildren = true;
      }
      
      public function init(param1:IGuiContext) : void
      {
         initGuiBase(param1);
         this._infoPanel = requireGuiChild("infoPanel") as MovieClip;
         this._initiativeBar = requireGuiChild("initiativeBar") as MovieClip;
         this._options = requireGuiChild("options") as MovieClip;
         this._clickDrag = requireGuiChild("clickDrag") as MovieClip;
         this._horn = requireGuiChild("horn") as MovieClip;
         this._chat = requireGuiChild("chat") as MovieClip;
         this._statBanner = requireGuiChild("statBanner") as MovieClip;
         this._activeChar = requireGuiChild("activeChar") as MovieClip;
         _context.translateDisplayObjects(LocaleCategory.GUI,this);
         recursiveRegisterScalableTextfields2d(this,false);
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         if(visible)
         {
            scaleTextfields();
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            scaleTextfields();
         }
      }
      
      public function updateHelp(param1:IGuiArtifact, param2:IGuiInitiative, param3:IGuiChat, param4:DisplayObject, param5:Number, param6:Number, param7:Boolean) : void
      {
         var _loc8_:Number = NaN;
         var _loc10_:GuiInitiative = null;
         var _loc11_:GuiChat = null;
         var _loc12_:Rectangle = null;
         var _loc13_:Rectangle = null;
         var _loc14_:Rectangle = null;
         var _loc15_:Rectangle = null;
         var _loc16_:Rectangle = null;
         _loc8_ = BoundedCamera.computeDpiScaling(param5,param6);
         _loc8_ = Math.max(_loc8_,Math.min(1.25,BoundedCamera.dpiFingerScale * Platform.textScale));
         _loc8_ = Math.min(1.5,_loc8_);
         _context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this,_context.logger);
         var _loc9_:GuiHorn = param1 as GuiHorn;
         if(_loc9_ && _loc9_.artifactVisible && context.battleHudConfig.showHorn)
         {
            _loc12_ = _loc9_.getRect(this);
            this._horn.x = _loc9_.x;
            this._horn.y = _loc12_.bottom;
            this._horn.visible = true;
            this._horn.scaleX = this._horn.scaleY = _loc8_;
         }
         else
         {
            this._horn.visible = false;
         }
         _loc10_ = param2 as GuiInitiative;
         if(_loc10_)
         {
            this._initiativeBar.scaleX = this._initiativeBar.scaleY = _loc8_;
            this._infoPanel.scaleX = this._infoPanel.scaleY = _loc8_;
            this._activeChar.scaleX = this._activeChar.scaleY = _loc8_;
            this._clickDrag.scaleX = this._clickDrag.scaleY = _loc8_;
            this._initiativeBar.visible = true;
            this._infoPanel.visible = true;
            _loc13_ = _loc10_._order.getRect(this);
            this._initiativeBar.x = Math.min(param5 - this._initiativeBar.width,_loc13_.right);
            this._initiativeBar.y = param6 - this._initiativeBar.height / 2 - (Platform.requiresUiSafeZoneBuffer ? 53 : 0);
            this._activeChar.visible = _loc10_._activeFrame.visible;
            _loc14_ = _loc10_._activeFrame.getRect(this);
            this._activeChar.x = Platform.requiresUiSafeZoneBuffer ? 80 : 0;
            this._activeChar.y = _loc14_.top;
            this._infoPanel.visible = _loc10_.infobar.isVisible;
            if(this._infoPanel.visible)
            {
               _loc15_ = (_loc10_.infobar as MovieClip).getRect(this);
               this._infoPanel.y = (_loc13_.top + _loc15_.top) * 0.5;
               this._infoPanel.x = Math.min(param5 - this._infoPanel.width,_loc15_.right - 100);
            }
            this._clickDrag.y = 250;
            if(this._horn.visible)
            {
               this._clickDrag.y = Math.max(this._clickDrag.y,this._horn.y + this._horn.height);
            }
            this._clickDrag.x = param5 * 0.5;
         }
         else
         {
            this._activeChar.visible = false;
            this._infoPanel.visible = false;
            this._initiativeBar.visible = false;
         }
         _loc11_ = param3 as GuiChat;
         if(_loc11_)
         {
            this._chat.visible = true;
            this._chat.x = _loc11_.width + this._chat.width * 0.48;
            this._chat.y = _loc11_.height;
         }
         else
         {
            this._chat.visible = false;
         }
         if(param7)
         {
            this._statBanner.scaleX = this._statBanner.scaleY = _loc8_;
            this._statBanner.visible = true;
            this._statBanner.x = param5 - (Platform.requiresUiSafeZoneBuffer ? 58 : 0);
            this._statBanner.y = 0 + (Platform.requiresUiSafeZoneBuffer ? 30 : 0);
         }
         else
         {
            this._statBanner.visible = false;
         }
         if(Boolean(param4) && param4.visible)
         {
            this._options.scaleX = this._options.scaleY = _loc8_;
            this._options.visible = true;
            _loc16_ = param4.getRect(this);
            this._options.x = (_loc16_.left + _loc16_.right) * 0.5;
            this._options.y = (_loc16_.bottom + _loc16_.top) * 0.5;
         }
         else
         {
            this._options.visible = false;
         }
      }
   }
}
