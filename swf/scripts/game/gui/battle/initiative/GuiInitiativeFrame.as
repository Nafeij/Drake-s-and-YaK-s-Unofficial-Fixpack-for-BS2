package game.gui.battle.initiative
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.ability.effect.model.EffectPhase;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.model.PersistedEffectsEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.EntityIconType;
   import engine.entity.model.IEntity;
   import engine.gui.GuiUtil;
   import engine.saga.Saga;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import game.gui.GuiBase;
   import game.gui.GuiIcon;
   import game.gui.IGuiContext;
   
   public class GuiInitiativeFrame extends GuiBase
   {
       
      
      public var _placeholder:MovieClip;
      
      public var _glow:MovieClip;
      
      public var _bgEnemy:MovieClip;
      
      public var _bgPlayer:MovieClip;
      
      public var _playerIconRim:MovieClip;
      
      public var activeBuffsAbls:Dictionary;
      
      public var activeBuffs:Dictionary;
      
      public var buffContainer:MovieClip;
      
      private var iconInY:Number = 0;
      
      private var iconOutY:Number = 0;
      
      private var _entity:IBattleEntity;
      
      private var _icon:GuiIcon;
      
      public var willTweenOut:Boolean;
      
      public var willTweenIn:Boolean;
      
      public var _iconFrame:MovieClip;
      
      private var _titleIcon:GuiIcon;
      
      private var _hilighted:Boolean;
      
      private var _hovered:Boolean;
      
      private var _placeholderSize:Point;
      
      private var icons:Dictionary;
      
      private var startingParent:Sprite;
      
      public var _item:MovieClip;
      
      protected var iconType:EntityIconType;
      
      public var index:int;
      
      protected var wasDown:Boolean;
      
      private var _doubleClickPt0:Point;
      
      private var _doubleClickTime0:int;
      
      private var _tween:TweenMax;
      
      private var _nextEntity:IBattleEntity;
      
      private var _effects:IPersistedEffects;
      
      public function GuiInitiativeFrame()
      {
         this.activeBuffsAbls = new Dictionary();
         this.activeBuffs = new Dictionary();
         this._placeholderSize = new Point();
         this.icons = new Dictionary();
         this.iconType = EntityIconType.INIT_ORDER;
         this._doubleClickPt0 = new Point();
         super();
      }
      
      public function init(param1:IGuiContext, param2:int, param3:Boolean, param4:Vector.<IEntity>) : void
      {
         var _loc5_:IEntity = null;
         this.index = param2;
         initGuiBase(param1);
         this._item = getChildByName("item") as MovieClip;
         getGuiChild("iconFrame","_iconFrame");
         if(param3)
         {
            getGuiChild("glow","_glow");
            this._glow.visible = false;
            this._glow.stop();
            addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
            addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         }
         for each(_loc5_ in param4)
         {
            this.fetchIcon(_loc5_,this.iconType);
         }
         if(this._item)
         {
            this._item.visible = false;
         }
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownhandler);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         this._placeholder = this._iconFrame.getChildByName("placeholder") as MovieClip;
         this._bgPlayer = this._iconFrame.getChildByName("bgPlayer") as MovieClip;
         this._bgEnemy = this._iconFrame.getChildByName("bgEnemy") as MovieClip;
         this._playerIconRim = getChildByName("player_icon_rim") as MovieClip;
         if(this._playerIconRim)
         {
            this._playerIconRim.visible = false;
         }
         this._bgPlayer.visible = false;
         this._bgEnemy.visible = false;
         this._placeholderSize.setTo(this._placeholder.width / this._placeholder.scaleX,this._placeholder.height / this._placeholder.scaleY);
         this._placeholder.scaleX = 1;
         this._placeholder.scaleY = 1;
         this.iconInY = this._iconFrame.y;
         this.iconOutY = this._iconFrame.y + this._iconFrame.height;
         if(!this._placeholder || !this._bgPlayer || !this._bgEnemy)
         {
            throw new ArgumentError("Could not find placeholder, bgPlayer, or bgEnemy");
         }
         while(this._placeholder.numChildren > 0)
         {
            this._placeholder.removeChildAt(this._placeholder.numChildren - 1);
         }
         this.buffContainer = new MovieClip();
         this.addChild(this.buffContainer);
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiIcon = null;
         this.tween = null;
         removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         this.entity = null;
         this.icon = null;
         for each(_loc1_ in this.icons)
         {
            _loc1_.release();
         }
         this.icons = null;
         for each(_loc1_ in this.activeBuffs)
         {
            _loc1_.release();
         }
         this.activeBuffs = null;
         super.cleanupGuiBase();
      }
      
      protected function mouseUpHandler(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         if(this._hovered && this.wasDown)
         {
            if(!this._checkDoubleClick(param1.stageX,param1.stageY))
            {
               this.handleClick(param1);
            }
         }
         this.wasDown = false;
      }
      
      private function _checkDoubleClick(param1:int, param2:int) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = getTimer();
         var _loc4_:int = _loc3_ - this._doubleClickTime0;
         if(_loc4_ < PlatformInput.DOUBLE_CLICK_THRESHOLD_MS)
         {
            _loc5_ = Math.abs(this._doubleClickPt0.x - param1);
            _loc6_ = Math.abs(this._doubleClickPt0.y - param2);
            if(_loc5_ < PlatformInput.DOUBLE_CLICK_THRESHOLD_PIXELS && _loc6_ < PlatformInput.DOUBLE_CLICK_THRESHOLD_PIXELS)
            {
               this._doubleClickTime0 = 0;
               this.handleDoubleClick();
               return true;
            }
         }
         this._doubleClickPt0.setTo(param1,param2);
         this._doubleClickTime0 = _loc3_;
         return false;
      }
      
      protected function mouseDownhandler(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         this.wasDown = true;
      }
      
      protected function handleDoubleClick() : void
      {
         if(this._entity)
         {
            this._entity.centerCameraOnEntity();
         }
      }
      
      protected function handleClick(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         context.playSound("ui_generic");
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         this.hovered = true;
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         this.hovered = false;
      }
      
      public function set tween(param1:TweenMax) : void
      {
         if(this._tween == param1)
         {
            return;
         }
         if(this._tween)
         {
            this._tween.kill();
         }
         this._tween = param1;
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         if(Boolean(param1) && param1.cleanedup)
         {
            param1 = null;
         }
         if(this._entity == param1 && this._nextEntity == param1)
         {
            return;
         }
         if(this._effects)
         {
            this._effects.removeEventListener(PersistedEffectsEvent.CHANGED,this.onUpdateBuffs);
         }
         this._nextEntity = param1;
         this.tween = null;
         this.tweenOut();
         this._entity = param1;
         this._effects = !!this._entity ? this._entity.effects : null;
         if(this._effects)
         {
            this._effects.addEventListener(PersistedEffectsEvent.CHANGED,this.onUpdateBuffs);
         }
         if(this._item)
         {
            if(!Saga.instance || !Saga.instance.battleItemsDisabled)
            {
               this._item.visible = Boolean(this._entity) && Boolean(this._entity.item);
            }
         }
         if(!this._tween)
         {
            this.showCurrentEntity();
         }
      }
      
      public function tweenOut() : void
      {
         if(this._entity && this._icon && !this._tween)
         {
            if(this.willTweenOut)
            {
               this._tween = TweenMax.to(this._iconFrame,0.5,{
                  "y":this.iconOutY,
                  "onComplete":this.tweenOutCompleteHandler
               });
            }
         }
      }
      
      public function tweenIn() : void
      {
         if(this._entity && this._icon && !this._tween)
         {
            if(this.willTweenIn)
            {
               this._iconFrame.y = this.iconOutY;
               this._tween = TweenMax.to(this._iconFrame,0.5,{
                  "y":this.iconInY,
                  "onComplete":this.tweenInCompleteHandler
               });
            }
         }
      }
      
      private function tweenOutCompleteHandler() : void
      {
         this._tween = null;
         this.showCurrentEntity();
      }
      
      private function tweenInCompleteHandler() : void
      {
         this._tween = null;
      }
      
      private function showCurrentEntity() : void
      {
         if(this._nextEntity)
         {
            if(this._bgPlayer.visible != this._nextEntity.isPlayer)
            {
               this._bgPlayer.visible = this._nextEntity.isPlayer;
            }
            if(Boolean(this._playerIconRim) && this._playerIconRim.visible != this._nextEntity.isPlayer)
            {
               this._playerIconRim.visible = this._nextEntity.isPlayer;
            }
            if(this._bgEnemy.visible != this._nextEntity.isEnemy)
            {
               this._bgEnemy.visible = this._nextEntity.isEnemy;
            }
            this.icon = this.fetchIcon(this._nextEntity,this.iconType);
            if(this._icon)
            {
               if(this.willTweenIn)
               {
                  this.tweenIn();
               }
               else
               {
                  this._tween = null;
                  this._iconFrame.y = this.iconInY;
               }
            }
            if(hasEventListener(Event.CHANGE))
            {
               dispatchEvent(new Event(Event.CHANGE));
            }
         }
      }
      
      private function fetchIcon(param1:IEntity, param2:EntityIconType) : GuiIcon
      {
         if(!param1 || !param1.def || !param1.def.appearance || !param1.def.appearance.hasIcons())
         {
            return null;
         }
         var _loc3_:String = param1.id;
         var _loc4_:GuiIcon = this.icons[_loc3_];
         if(!_loc4_)
         {
            _loc4_ = context.getEntityIcon(param1.def,param2);
            this.icons[_loc3_] = _loc4_;
         }
         return _loc4_;
      }
      
      public function get icon() : GuiIcon
      {
         return this._icon;
      }
      
      public function set icon(param1:GuiIcon) : void
      {
         if(this._icon == param1)
         {
            return;
         }
         if(Boolean(this._icon) && this._icon.parent == this._placeholder)
         {
            this._placeholder.removeChild(this._icon);
         }
         this._icon = param1;
         if(this._icon)
         {
            if(this._icon.parent)
            {
               this._icon.parent.removeChild(this._icon);
            }
            this._icon.setTargetSize(this._placeholderSize.x,this._placeholderSize.y);
            this._placeholder.addChild(this._icon);
         }
      }
      
      public function get hilighted() : Boolean
      {
         return this._hilighted;
      }
      
      public function set hilighted(param1:Boolean) : void
      {
         this._hilighted = param1;
         this.updateGlow();
      }
      
      private function updateGlow() : void
      {
         var _loc1_:Boolean = false;
         if(this._glow)
         {
            _loc1_ = this.hilighted || this._hovered;
            if(this._glow.visible != _loc1_)
            {
               this._glow.visible = _loc1_;
               if(this.entity)
               {
                  if(this.entity.isEnemy)
                  {
                     this._glow.gotoAndStop(2);
                  }
                  else
                  {
                     this._glow.gotoAndStop(1);
                  }
               }
            }
         }
      }
      
      public function get hovered() : Boolean
      {
         return this._hovered;
      }
      
      public function set hovered(param1:Boolean) : void
      {
         this._hovered = param1;
         this.updateGlow();
      }
      
      private function onUpdateBuffs(param1:PersistedEffectsEvent) : void
      {
         if(param1.effects.target == this._entity)
         {
            this.updateBuffs(param1.effects);
         }
      }
      
      public function updateBuffs(param1:IPersistedEffects) : void
      {
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc5_:IEffect = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:GuiIcon = null;
         var _loc9_:GuiIcon = null;
         var _loc10_:GuiIcon = null;
         if(!this.activeBuffs)
         {
            return;
         }
         var _loc2_:Dictionary = GuiUtil.cloneDictionary(this.activeBuffs);
         if(param1)
         {
            this.buffContainer.visible = true;
            for each(_loc5_ in param1.effects)
            {
               _loc6_ = _loc5_.phase.index;
               _loc7_ = EffectPhase.REMOVED.index;
               if(_loc6_ < _loc7_ && Boolean(_loc5_.ability.def.iconBuffUrl))
               {
                  _loc2_[_loc5_.ability.def.id] = null;
                  _loc8_ = this.activeBuffs[_loc5_.ability.def.id];
                  if(_loc8_ == null)
                  {
                     _loc8_ = context.getAbilityBuffIcon(_loc5_.ability.def);
                     this.buffContainer.addChild(_loc8_);
                     this.activeBuffs[_loc5_.ability.def.id] = _loc8_;
                  }
                  this.activeBuffsAbls[_loc5_.ability.def.id] = _loc5_.ability;
               }
            }
         }
         else
         {
            this.buffContainer.visible = false;
         }
         for(_loc3_ in _loc2_)
         {
            if(_loc2_[_loc3_])
            {
               this.buffContainer.removeChild(_loc2_[_loc3_]);
               _loc9_ = this.activeBuffs[_loc3_];
               delete this.activeBuffs[_loc3_];
               delete this.activeBuffsAbls[_loc3_];
            }
         }
         if(Boolean(this.entity.titleItem) && Boolean(this.entity.def.defTitle))
         {
            this.buffContainer.visible = true;
            if(this._titleIcon == null)
            {
               this._titleIcon = context.getTitleBuffIcon(this.entity.def.defTitle);
               if(this._titleIcon)
               {
                  this.buffContainer.addChild(this._titleIcon);
               }
            }
         }
         else if(this._titleIcon)
         {
            this.buffContainer.removeChild(this._titleIcon);
            this._titleIcon = null;
         }
         while(_loc4_ < this.buffContainer.numChildren)
         {
            _loc10_ = this.buffContainer.getChildAt(_loc4_) as GuiIcon;
            if(_loc4_ > 2)
            {
               _loc10_.visible = false;
            }
            else
            {
               _loc10_.visible = true;
               _loc10_.x = _loc10_.width * 0.6 * _loc4_;
            }
            _loc4_++;
         }
         this.buffContainer.y = -(this.buffContainer.height * 0.5);
         this.buffContainer.x = -(this.buffContainer.width * 0.5);
      }
      
      public function getCenterPosition_g() : Point
      {
         var _loc1_:Point = new Point(this._placeholder.width / 2,this._placeholder.height / 2);
         return this._placeholder.localToGlobal(_loc1_);
      }
   }
}
